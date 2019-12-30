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
  bool _cardsSortedByFirstHint = true; // Default sort

  /// Used to display SnackBar
  /// https://medium.com/@ksheremet/flutter-snackbar-3a817635aeb2
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _cardsRepo = ServicesWidget.of(context).cardsRepo;
  }

  @override
  void initState() {
    super.initState();

    _searchCtrl = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {

    if (_cards == null) {
      retrieveCards("Cards are not loaded");
    }

    var sortIcon = _cardsSortedByFirstHint ? Icon(Icons.arrow_back) : Icon(Icons.arrow_forward);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('All Cards', style: TextStyle(fontSize: 30, color: Colors.white)),
        actions: <Widget>[
          IconButton(icon: sortIcon, onPressed: () => _sortCards(swapSort: true)),
          IconButton(icon: Icon(Icons.play_arrow), onPressed: () => _playOneCard()),
          IconButton(icon: Icon(Icons.add), onPressed: () => _pushCreateCard())
        ],
      ),
      body: Column(
        children: <Widget>[
          SearchBar(_searchCtrl, (q) => _filterCardsBySearchQuery()),
          Expanded(child: _buildCardList())
        ],
      )
    );
  }

  void _filterCardsBySearchQuery() {

    setState(() {
      var query = _searchCtrl.text;
      print("Search query: $query");
      if (query.isEmpty) {
        _cards = _allCards;
      } else {
        _cards = _allCards.where((c) =>
            c.allContentLower.contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  void retrieveCards(String reason) {
    print("Loading cards because: $reason");
    _cardsRepo.getAll().then((cards) {
      setState(() {
        _searchCtrl.text = "";
        _allCards = cards;
        _cards = cards;
        _cardsSortedByFirstHint = true; // We suppose this is the default order
      });
    });
  }

  bool _cardsNotLoaded() => _cards == null;

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

  /// Switches between sort by hints[0] and hints[1]
  void _sortCards({bool swapSort = false}) {

    print("Sorting cards (swapSort = $swapSort)");

    setState(() {

      if (swapSort) {
        _cardsSortedByFirstHint = !_cardsSortedByFirstHint;
        _showSnackBar("Sort by hint " + (_cardsSortedByFirstHint ? "1" : "2"));
      }

      if (_cardsSortedByFirstHint) {
        _allCards.sort((a,b) => a.allContentLower.compareTo(b.allContentLower));
      } else {
        _allCards.sort((a,b) => a.hint1Lower.compareTo(b.hint1Lower));
      }
    });

    _filterCardsBySearchQuery(); // Refresh search
  }

  /// Plays one random card - TODO: Play all the cards
  void _playOneCard() async {

    if (_cardsNotLoaded()) return;

    final randomIndex = Random().nextInt(_cards.length);

    final CardViewScreenResponse response = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CardViewScreen(_cards[randomIndex]))
    );

    switch (response.action) {

      case CardViewScreenAction.edit:
        _pushEditCard(response.card);
        break;
      case CardViewScreenAction.updateScore:

        print("Updating ${response.card}");

        _cardsRepo.saveOrUpdate(response.card).then((card) {

          // retrieveCards("One was updated");
          // No need to update cards, just the score was updated

          _showSnackBar("Updated score: ${response.card.hints[0]} (${response.card.score})");
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

        print("Updating or creating ${response.card}");

        _cardsRepo.saveOrUpdate(response.card).then((card) {

          // retrieveCards("One was updated");
          // Instead of retrieving cards, we update and sort the list

          var updating = response.card.isPersisted();
          var action = updating ? "Updated" : "Created";
          _showSnackBar("$action: ${card.hints[0]}");

          if (updating) {
            _allCards[_indexOfId(card.id)] = card;
          } else {
            _allCards.add(card);
          }
          _sortCards();

        });
        break;

      case CardEditScreenAction.delete:

        print("Removing ${response.card}");
        _cardsRepo.deleteOne(response.card.id).then((card) {

          // retrieveCards("One was deleted");
          // Instead of retrieving cards, we remove the card and sort the list
          _showSnackBar("Removed: ${card.hints[0]}");
          _allCards.removeAt(_indexOfId(card.id));
          _sortCards();

        });
        break;

      case CardEditScreenAction.nothing:

        // _showSnackBar("Nothing to do");
        break;
    }
  }

  /// Finds the card that has the given id and returns its index
  /// Note: We can't use the index of _buildItem, since we might be filtering
  int _indexOfId(String id) => _allCards.indexWhere((c) => c.id == id);

  void _showSnackBar(String message) {

    // Don't wait for previous snackbar to be hidden
    _scaffoldKey.currentState.removeCurrentSnackBar();

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(fontSize: 20)),
      duration: Duration(seconds: 3)
    ));
  }
}

class SearchBar extends StatelessWidget {

  final TextEditingController ctrl;
  final ValueChanged<String> onChanged;

  SearchBar(this.ctrl, this.onChanged);

  @override
  Widget build(BuildContext context) {

    var children = <Widget>[
      Expanded(
        child: TextField(
          decoration: InputDecoration(
              hintText: "Search...",
              prefixIcon: Icon(Icons.search)
          ),
          style: TextStyle(fontSize: 20),
          controller: ctrl,
          onChanged: onChanged
        ),
      )
    ];

    // Add cancel button to remove search text
    if (ctrl.text.isNotEmpty) {
      children.add(Container(
        padding: EdgeInsets.only(left: 10),
        child: GestureDetector(
          child: Icon(Icons.cancel),
          onTap: () {
            ctrl.text = "";
            onChanged("");
          },
        )
      ));
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(children: children)
    );
  }
}
