import 'package:flutter/material.dart';
import 'hints_card.dart';

/// Edits a card, which may have empty data (in case it's a new card)
/// It pops a CardScreenResponse with the card and action to do.
/// In case the hints are not filled, the action is nothing.
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

    var newCard = HintsCard(id: card.id, hints: newHints, notes: newNotes);

    // Avoid saving incomplete or unmodified card
    var updateNeeded = newCard.hints.isNotEmpty && newCard != card;

    final CardScreenAction action = updateNeeded
        ? CardScreenAction.update : CardScreenAction.nothing;

    Navigator.pop(context, CardScreenResponse(newCard, action));

    return false;
  }

  _deleteCard(BuildContext context) {
    Navigator.pop(context, CardScreenResponse(card, CardScreenAction.delete));
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope( // TODO: This disables swipe back https://github.com/flutter/flutter/issues/14203
      onWillPop: () async => _saveCardAndGoBack(context),
      child: Scaffold(
        appBar: AppBar(
            title: Text('Edit Card', style: TextStyle(fontSize: 30, color: Colors.white)),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteCard(context))
          ],
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

class CardScreenResponse {

  final HintsCard card;
  final CardScreenAction action;

  CardScreenResponse(this.card, this.action);
}

enum CardScreenAction {
  update, delete, nothing
}

