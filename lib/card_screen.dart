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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Card', style: TextStyle(fontSize: 30, color: Colors.white))
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