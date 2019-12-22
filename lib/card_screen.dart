import 'package:flutter/material.dart';
import 'hints_card.dart';

/// Edits a card, which may have empty data (in case it's a new card)
/// It pops the edited card, or null if there's no need to update.
/// In case the hints are not filled, it will pop null, so no updates.
/// TODO: Detect if the card was not updated.
class CardScreen extends StatelessWidget {

  final HintsCard card;
  final TextEditingController _hintsController;
  final TextEditingController _notesController;

  CardScreen(this.card) :
        _hintsController = TextEditingController(text: card.hints.join("\n")),
        _notesController = TextEditingController(text: card.notes);

  bool _saveCardAndGoBack(BuildContext context) {

    final newHints = _hintsController.text
        .split("\n")
        .map((x) => x.trim())
        .where((x) => x.isNotEmpty)
        .toList();
    final newNotes = _notesController.text;

    print("Card edited:");
    print(" - Id: ${card.id}");
    print(" - Hints: $newHints");
    print(" - Notes: $newNotes");

    var cardToSave = newHints.isEmpty ? null
        : HintsCard(id: card.id, hints: newHints, notes: newNotes);
    Navigator.pop(context, cardToSave);

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