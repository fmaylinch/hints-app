import 'dart:math';
import 'package:flutter/material.dart';
import 'card_view_screen.dart';
import 'main.dart';
import 'card_edit_screen.dart';
import 'cards_repo.dart';
import 'hints_card.dart';

// TODO: Organise these colors. With theme? Also, how to change field underline?
var primaryTextColor = Colors.grey;
var hintTextColor = Colors.grey[700];
var backgroundColor = Color(0xFF303030);

class HintsCards extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HintsCardsState();
}

class HintsCardsState extends State<HintsCards> {

  CardsRepo _cardsRepo;
  List<HintsCard> _allCards;
  List<HintsCard> _cards;
  TextEditingController _searchCtrl;
  _CardSortType _cardsSortType = _CardSortTypeExt.apiDefault();

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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Hint Cards', style: TextStyle(fontSize: 30)),
        actions: <Widget>[
          IconButton(icon: _cardsSortType.icon(), onPressed: () => _sortCards(changeSortType: true)),
          IconButton(icon: Icon(Icons.play_arrow), onPressed: () => _playOneCard()),
          IconButton(icon: Icon(Icons.add), onPressed: () => _pushCreateCard())
        ],
      ),
      body: Container(
            color: backgroundColor,
            child: Column(
              children: <Widget>[
                SearchBar(_searchCtrl, (q) => _filterCardsBySearchQuery()),
                Expanded(child: _buildCardList())
              ],
            )));
  }

  void _filterCardsBySearchQuery() {

    var query = _searchCtrl.text.toLowerCase();

    setState(() {
      print("Search query: $query");
      if (query.isEmpty) {
        _cards = _allCards;
      } else {

        var filter = query.startsWith("tag:")
            ? (HintsCard c) => _containsAllTags(c, _tagsFromQuery(query))
            : (HintsCard c) => c.allContentLower.contains(query);
          _cards = _allCards.where(filter).toList();
      }
    });
  }

  bool _containsAllTags(HintsCard card, List<String> tags) {

    if (tags.isEmpty) return false;

    for (var tag in tags) {
      if (!card.tags.contains(tag)) return false;
    }

    return true;
  }

  List<String> _tagsFromQuery(String query) =>
      query.substring("tag:".length).trim().split(new RegExp(r"[\s,]+")).toList();

  void retrieveCards(String reason) {
    print("Loading cards because: $reason");
    _cardsRepo.getAll().then((cards) {
      setState(() {
        _searchCtrl.text = "";
        _allCards = cards;
        _cards = cards;
        _cardsSortType = _CardSortTypeExt.apiDefault();
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
      Colors.red[700], Colors.red[500],
      Colors.orange[700], Colors.orange[500],
      Colors.grey[600], Colors.grey[800],
      Colors.blue[700], Colors.blue[500],
      Colors.green[700], Colors.green[500]
    ];

    final color = colors[min(card.score ~/ 10, 9)];

    return Container(
      //decoration: BoxDecoration(color: color),
      child: ListTile(
          title: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: hintWidgets
              ),
              SizedBox(
                height: 1,
                child: LinearProgressIndicator(
                  value: card.score / 100,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: Colors.grey[800],
                )
                ,
              )
            ],
          ),
          onTap: () => _pushEditCard(card)

      )
    );
  }

  /// Sorts cards (optionally changes to the next sort type)
  void _sortCards({bool changeSortType = false}) {

    print("Sorting cards (changeSortType = $changeSortType)");

    setState(() {

      if (changeSortType) {
        // Select next type
        _cardsSortType = _cardsSortType.next();
        _showSnackBar("Sort by ${_cardsSortType.message()}");
      }

      _allCards.sort(_cardsSortType.sortFunction());
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
          // Instead of retrieving cards, we just sort the list
          _showSnackBar("Updated score: ${response.card.hints[0]} (${response.card.score})");
          _sortCards();

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
              hintText: "Search…",
              hintStyle: TextStyle(fontSize: 20, color: hintTextColor),
              prefixIcon: Icon(Icons.search, color: hintTextColor)
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

enum _CardSortType {
  hint0, hint1, score
}

extension _CardSortTypeExt on _CardSortType {

  String message() {
    switch (this) {
      case _CardSortType.hint0: return "first hint";
      case _CardSortType.hint1: return "second hint";
      case _CardSortType.score: return "score";
    }
  }

  /// Returns next type (or the first one if there are no more)
  _CardSortType next() {
    return _CardSortType.values[(index + 1) % _CardSortType.values.length];
  }

  Icon icon() {
    switch(this) {
      case _CardSortType.hint0: return Icon(Icons.arrow_back);
      case _CardSortType.hint1: return Icon(Icons.arrow_forward);
      case _CardSortType.score: return Icon(Icons.score);
    }
  }

  static _CardSortType apiDefault() {
    return _CardSortType.hint0;
  }

  int Function(HintsCard a, HintsCard b) sortFunction() {
    switch (this) {
      case _CardSortType.hint0:
        return (a,b) => a.allContentLower.compareTo(b.allContentLower);
      case _CardSortType.hint1:
        return (a,b) => a.hint1Lower.compareTo(b.hint1Lower);
      case _CardSortType.score:
        return (a,b) => a.score.compareTo(b.score);
    }
  }
}