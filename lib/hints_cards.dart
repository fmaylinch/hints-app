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
  List<HintsCard> _cards;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _cardsRepo = ServicesWidget.of(context).cardsRepo;
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
      body: _buildCardList()
    );
  }

  void retrieveCards(String reason) {
    print("Loading cards because: $reason");
    _cardsRepo.getAll().then((cards) {
      setState(() {
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

    return ListTile(

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: hintWidgets,
      ),
      onTap: () => _pushEditCard(card),
    );

  }

  /// Plays one card - TODO: Play all the cards
  void _playOneCard() async {

    final randomIndex = Random().nextInt(_cards.length);

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CardViewScreen(_cards[randomIndex]))
    );
  }

  void _pushCreateCard() {
    _pushEditCard(HintsCard());
  }

  void _pushEditCard(HintsCard card) async {

    final CardScreenResponse response = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CardEditScreen(card))
    );

    switch (response.action) {

      case CardScreenAction.update:
        print("Creating or updating ${response.card}");
        _cardsRepo.saveOrUpdate(response.card).then((card) {
          retrieveCards("One was updated");
        });
        break;
      case CardScreenAction.delete:
        print("Removing ${response.card}");
        _cardsRepo.deleteOne(response.card.id).then((card) {
          retrieveCards("One was deleted");
        });
        break;
      case CardScreenAction.nothing:
        print("Nothing to do");
        break;
    }
  }
}
