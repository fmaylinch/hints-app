import 'package:flutter/material.dart';
import 'hints_card.dart';

class CardScreen extends StatelessWidget {

  final HintsCard card;
  final TextEditingController _hintsController;
  final TextEditingController _notesController;

  CardScreen(this.card) :
        _hintsController = TextEditingController(text: card.hints.join("\n")),
        _notesController = TextEditingController(text: card.notes);

  bool _saveCardAndGoBack(BuildContext context) {
    print("Will save card"); // TODO: save card; first split hints (removing blank lines)
    Navigator.pop(context, true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( // TODO: This disables swipe back https://github.com/flutter/flutter/issues/14203
      onWillPop: () async => _saveCardAndGoBack(context),
      child: Scaffold(
        appBar: AppBar(
            title: Text('Edit Card', style: TextStyle(fontSize: 30, color: Colors.white))
        ),
        body: Container(
          child: ListView(
            children: [
              _buildField(_hintsController, "Write hints, one per line"),
              _buildField(_notesController, "Write optional notes")
            ]
          ),
        ),
      ),
    );
  }

  _buildField(TextEditingController controller, String hintText) {
    return Container(
      padding: EdgeInsets.all(8),
      child: TextFormField(
          decoration: InputDecoration(hintText: hintText),
          style: TextStyle(fontSize: 20),
          maxLines: null,
          controller: controller
      ),
    );
  }
}