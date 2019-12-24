import 'package:flutter/material.dart';
import 'package:hints_app/card_screen.dart';
import 'package:hints_app/cards_repo.dart';
import 'package:hints_app/hints_card.dart';
import 'package:hints_app/main.dart';
import 'dart:math';

class HintsCards extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HintsCardsState();
}

class HintsCardsState extends State<HintsCards> {

  CardsRepo _cardsRepo;
  List<HintsCard> _cards;

  @override
  void initState() {
    super.initState();

    _cards = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inherited widgets can't be accessed from initState()
    _cardsRepo = ServicesWidget.of(context).cardsRepo;
    retrieveCards();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('All Cards', style: TextStyle(fontSize: 30, color: Colors.white)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: () => _pushCreateCard())
        ],
      ),
      body: _buildCardList(),
    );
  }

  void retrieveCards() {
    // TODO: We could use FutureBuilder
    _cardsRepo.getAll().then((cards) {
      this.setState(() {
        _cards = cards;
      });
    });
  }

  _buildCardList() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return _buildItem(index);
        }
    );
  }

  Widget _buildItem(int index) {

    final card = _cards[index];

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

  void _pushCreateCard() {
    _pushEditCard(HintsCard());
  }

  void _pushEditCard(HintsCard card) async {

    final CardScreenResponse response = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CardScreen(card))
    );

    switch (response.action) {

      case CardScreenAction.update:
        print("Creating or updating ${response.card}");
        _cardsRepo.saveOrUpdate(response.card).then((card) {
          retrieveCards();
        });
        break;
      case CardScreenAction.delete:
        print("Removing ${response.card}");
        _cardsRepo.deleteOne(response.card.id).then((card) {
          retrieveCards();
        });
        break;
      case CardScreenAction.nothing:
        print("Nothing to do");
        break;
    }
  }
}
