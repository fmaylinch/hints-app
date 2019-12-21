import 'package:flutter/material.dart';
import 'dart:math';
import 'hints_card.dart';
import 'card_screen.dart';

class HintsCards extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HintsCardsState();
}

class HintsCardsState extends State<HintsCards> {

  // TODO: Get from Service
  List<HintsCard> _cards = [
    HintsCard(id: "1", hints: ["buy", "покупать", "купить"], notes: "other notes"),
    HintsCard(id: "2", hints: ["speak, say", "говорить", "сказать"]),
    HintsCard(id: "3", hints: ["walk", "гулять", "погулять"]),
  ];

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

    // TODO: Save card. If card id is null, this is a new card.
    print("Will save or update card: ${newOrUpdatedCard.id}");
  }
}
