import 'package:flutter/material.dart';
import 'hints_card.dart';
import 'card_screen.dart';

class HintsCards extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HintsCardsState();
}

class HintsCardsState extends State<HintsCards> {

  // TODO: Get from Service
  List<HintsCard> _cards = [
    HintsCard(hints: ["buy", "покупать", "купить"], notes: "other notes"),
    HintsCard(hints: ["speak, say", "говорить", "сказать"]),
    HintsCard(hints: ["walk", "гулять", "погулять"]),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Hints Cards', style: TextStyle(fontSize: 30, color: Colors.white)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: _addCard,)
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

    final allHintWidgets = card.hints.map((it) =>
        Text(it, style: TextStyle(fontSize: 20)))
        .toList();

    final twoHintWidgets = card.hints.sublist(0, 2).map((it) =>
        Text(it, style: TextStyle(fontSize: 20)))
        .toList();

    return ListTile(

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: twoHintWidgets,
      ),
      onTap: () => _openCard(card),
    );

  }

  _openCard(HintsCard card) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CardScreen(card))
    );
  }

  void _addCard() {
    print("Will add a card"); // TODO
  }
}
