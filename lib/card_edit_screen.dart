import 'package:flutter/material.dart';
import 'score_slider.dart';
import 'hints_card.dart';

/// Edits a card, which may have empty data (in case it's a new card)
/// It pops a CardScreenResponse with the card and action to do.
///
class CardEditScreen extends StatefulWidget {

  final HintsCard card;

  CardEditScreen(this.card);

  @override
  State<StatefulWidget> createState() => _CardEditScreenState();
}

class _CardEditScreenState extends State<CardEditScreen> {

  bool _newCard;
  int _score;
  TextEditingController _hintsController;
  TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    _newCard = widget.card.id == null;
    _score = widget.card.score;
    _hintsController = TextEditingController(text: widget.card.hints.join("\n"));
    _notesController = TextEditingController(text: widget.card.notes);
  }

  @override
  Widget build(BuildContext context) {

    var actions = _newCard ? null
        : <Widget>[
            IconButton(
                icon: Icon(Icons.delete), onPressed: () => _deleteCard())
          ];

    var title = _newCard ? 'New Card' :  'Edit Card';

    return WillPopScope( // TODO: This disables swipe back https://github.com/flutter/flutter/issues/14203
      onWillPop: () async => _saveCardAndGoBack(),
      child: Scaffold(
        appBar: AppBar(
            title: Text(title, style: TextStyle(fontSize: 30, color: Colors.white)),
          actions: actions,
        ),
        body: Container(
          child: ListView(
            children: [
              _buildField(_hintsController, "Write hints, one per line"),
              _buildRatingSlider(),
              _buildField(_notesController, "Write optional notes")
            ]
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSlider() {

    return ScoreSlider(score: _score, onChanged: (newValue) =>
      setState(() {
        _score = newValue.round();
      })
    );
  }

  bool _saveCardAndGoBack() {

    final newHints = _hintsController.text
        .split("\n")
        .map((x) => x.trim())
        .where((x) => x.isNotEmpty)
        .toList();
    final newNotes = _notesController.text;

    //print("Card edited: $card");

    var newCard = HintsCard(id: widget.card.id, score: _score, hints: newHints, notes: newNotes);

    // Avoid saving incomplete or unmodified card
    var updateNeeded = newCard.hints.isNotEmpty && newCard != widget.card;

    final CardEditScreenAction action = updateNeeded
        ? CardEditScreenAction.update : CardEditScreenAction.nothing;

    Navigator.pop(context, CardEditScreenResponse(newCard, action));

    return false;
  }

  _deleteCard() {
    Navigator.pop(context, CardEditScreenResponse(widget.card, CardEditScreenAction.delete));
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

class CardEditScreenResponse {

  final HintsCard card;
  final CardEditScreenAction action;

  CardEditScreenResponse(this.card, this.action);
}

enum CardEditScreenAction {
  update, delete, nothing
}

