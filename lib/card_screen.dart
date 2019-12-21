import 'package:flutter/material.dart';
import 'hints_card.dart';

class CardScreen extends StatelessWidget {

  final HintsCard card;
  final List<TextEditingController> _controllers;

  CardScreen(this.card) :
        _controllers = _buildControllers(card);

  static List<TextEditingController> _buildControllers(HintsCard card) {
    var hintCtrls = card.hints.map((it) => TextEditingController(text: it)).toList();
    var allCtrls = [...hintCtrls, TextEditingController(text: card.notes)];
    return allCtrls;
  }

  void _saveCardAndGoBack(BuildContext context) {
    print("Will save card"); // TODO
    _goBack(context);
  }

  void _goBack(BuildContext context) {
    // TODO: We could save here, but then we need to intercept other ways of going back.
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Card', style: TextStyle(fontSize: 30, color: Colors.white)),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () => _goBack(context)
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: () => _saveCardAndGoBack(context))
        ]
      ),
      body: Container(
        child: ListView(
          children: _controllers.map((controller) =>
              Container(
                padding: EdgeInsets.all(8),
                child: TextFormField(
                    style: TextStyle(fontSize: 20),
                    maxLines: null,
                    controller: controller
                ),
              )
          ).toList(),
        ),
      ),
    );
  }
}