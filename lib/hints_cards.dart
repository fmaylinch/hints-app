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
  Widget build(BuildContext context) {

    _cardsRepo = ServicesWidget.of(context).cardsRepo;
    retrieveCards();

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
    _cards = _cardsRepo.getAll();
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

    final HintsCard newOrUpdatedCard = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CardScreen(card))
    );

    if (newOrUpdatedCard == null) {
      print("No need to update card");
      return; // no update
    }

    print("Will save or update card: $newOrUpdatedCard");
    _cardsRepo.saveOrUpdate(newOrUpdatedCard);
    retrieveCards();
  }
}
