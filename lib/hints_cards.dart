import 'dart:math';
import 'package:flutter/material.dart';
import 'card_view_screen.dart';
import 'main.dart';
import 'card_edit_screen.dart';
import 'cards_repo.dart';
import 'hints_card.dart';

class HintsCards extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HintsCardsState();
}

class HintsCardsState extends State<HintsCards> {

  CardsRepo _cardsRepo;
  List<HintsCard> _allCards;
  List<HintsCard> _cards;
  TextEditingController _searchCtrl;
  ValueChanged<String> _onSearchChanged;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _cardsRepo = ServicesWidget.of(context).cardsRepo;
  }

  @override
  void initState() {
    super.initState();

    _searchCtrl = TextEditingController();
    _onSearchChanged = (query) {
      setState(() {
        if (query.isEmpty) {
          _cards = _allCards;
        } else {
          _cards = _allCards.where((c) =>
              c.rawContent.contains(query.toLowerCase())
          ).toList();
        }
      });
    };
  }

  @override
  Widget build(BuildContext context) {

    if (_cards == null) {
      retrieveCards("Cards are not loaded");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('All Cards', style: TextStyle(fontSize: 30, color: Colors.white)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.play_arrow), onPressed: () => _playOneCard()),
          IconButton(icon: Icon(Icons.add), onPressed: () => _pushCreateCard())
        ],
      ),
      body: Column(
        children: <Widget>[
          SearchBar(_searchCtrl, _onSearchChanged),
          Expanded(child: _buildCardList())
        ],
      )
    );
  }

  void retrieveCards(String reason) {
    print("Loading cards because: $reason");
    _cardsRepo.getAll().then((cards) {
      setState(() {
        _searchCtrl.text = "";
        _allCards = cards;
        _cards = cards;
      });
    });
  }

  Widget _buildCardList() {

    if (_cards == null) {
      return Padding(
          padding: EdgeInsets.all(20),
          child: Text("Loading cards...", style: TextStyle(fontSize: 20))
      );
    }

    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return _buildItem(_cards, index);
        }
    );
  }

  Widget _buildItem(List<HintsCard> cards, int index) {

    final card = cards[index];

    // TODO: How many items (hints) to display? How to display them?
    // For now, we display a maximum of 2 hints, horizontally.
    final maxItems = 2;
    final numItems = min(maxItems, card.hints.length);
    final hintWidgets = card.hints.sublist(0, numItems).map((it) =>
        Text(it, style: TextStyle(fontSize: 20)))
        .toList();

    final colors = [
      Colors.red[200], Colors.red[100],
      Colors.orange[200], Colors.orange[100],
      Colors.grey[200], Colors.white,
      Colors.blue[100], Colors.blue[200],
      Colors.green[100], Colors.green[200]
    ];

    final color = colors[min(card.score ~/ 10, 9)];

    return Container(
      decoration: BoxDecoration(color: color),
      child: ListTile(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: hintWidgets
          ),
          onTap: () => _pushEditCard(card)

      )
    );
  }

  /// Plays one card - TODO: Play all the cards
  void _playOneCard() async {

    final randomIndex = Random().nextInt(_cards.length);

    final CardViewScreenResponse response = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CardViewScreen(_cards[randomIndex]))
    );

    switch (response.action) {

      case CardViewScreenAction.edit:
        _pushEditCard(response.card);
        break;
      case CardViewScreenAction.update:
        print("Updating ${response.card}");
        _cardsRepo.saveOrUpdate(response.card).then((card) {
          retrieveCards("One was updated");
        });
        break;
      case CardViewScreenAction.nothing:
        break;
    }
  }

  void _pushCreateCard() {
    _pushEditCard(HintsCard());
  }

  void _pushEditCard(HintsCard card) async {

    final CardEditScreenResponse response = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CardEditScreen(card))
    );

    if (response == null) return;

    switch (response.action) {

      case CardEditScreenAction.update:
        print("Creating or updating ${response.card}");
        _cardsRepo.saveOrUpdate(response.card).then((card) {
          retrieveCards("One was updated");
        });
        break;
      case CardEditScreenAction.delete:
        print("Removing ${response.card}");
        _cardsRepo.deleteOne(response.card.id).then((card) {
          retrieveCards("One was deleted");
        });
        break;
      case CardEditScreenAction.nothing:
        print("Nothing to do");
        break;
    }
  }
}

class SearchBar extends StatelessWidget {

  TextEditingController ctrl;
  ValueChanged<String> onChanged;

  SearchBar(this.ctrl, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        decoration: InputDecoration(hintText: "Search..."),
        style: TextStyle(fontSize: 20),
        controller: ctrl,
        onChanged: onChanged,
      )
    );
  }
}
