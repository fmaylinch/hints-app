import 'dart:math';

import 'package:flutter/material.dart';
import 'score_slider.dart';
import 'hints_card.dart';

/// Views a card, first showing one of the hints,
/// and a button to display the rest.
///
class CardViewScreen extends StatefulWidget {

  final HintsCard card;

  CardViewScreen(this.card);

  @override
  State<StatefulWidget> createState() => _CardViewScreenState();
}

class _CardViewScreenState extends State<CardViewScreen> {

  TextEditingController _answerCtrl = TextEditingController();
  bool _revealed = false;
  int _score;


  @override
  void initState() {
    super.initState();

    _score = widget.card.score;
  }

  @override
  Widget build(BuildContext context) {

    var hint = "Try to write the answer here";

    final answer = TextFormField(
        decoration: InputDecoration(hintText: hint),
        style: TextStyle(fontSize: 20),
        maxLines: null,
        controller: _answerCtrl
    );

    final revealButton = Center(
      child: MaterialButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: Text("REVEAL"),
        onPressed: () => this.setState(() {
          _revealed = true;
        }),
      ),
    );

    final randomHintIndex = Random().nextInt(widget.card.hints.length);

    var slider = ScoreSlider(score: _score, onChanged: (newValue) =>
        setState(() {
          _score = newValue.round();
        })
    );

    final widgets = _revealed ?
      [answer, ...widget.card.hints.map(_toWidget).toList(), slider, _toWidget(widget.card.notes)]
        : [_toWidget("Hint: ${widget.card.hints[randomHintIndex]}"), answer, revealButton];

    return WillPopScope(
      onWillPop: () async => _saveCardAndGoBack(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('View Card', style: TextStyle(fontSize: 30, color: Colors.white)),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.edit), onPressed: () => _editCard())
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          child: ListView(
              children: widgets.map((w) => Container(
                child: w,
                margin: EdgeInsets.all(10),
              )).toList()
          ),
        ),
      )
    );
  }

  Text _toWidget(String str) => Text(str, style: TextStyle(fontSize: 20));

  _editCard() {
    Navigator.pop(context, CardViewScreenResponse(widget.card, CardViewScreenAction.edit));
  }

  bool _saveCardAndGoBack() {

    var updateNeeded = _score != widget.card.score;
    widget.card.score = _score;

    final CardViewScreenAction action = updateNeeded
        ? CardViewScreenAction.update : CardViewScreenAction.nothing;

    Navigator.pop(context, CardViewScreenResponse(widget.card, action));

    return false;
  }

}

class CardViewScreenResponse {

  final HintsCard card;
  final CardViewScreenAction action;

  CardViewScreenResponse(this.card, this.action);
}

// TODO: Add score slider and update action if slider is changed
enum CardViewScreenAction {
  edit, update, nothing
}

