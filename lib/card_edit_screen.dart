import 'package:flutter/material.dart';

import 'score_slider.dart';
import 'hints_card.dart';
import 'color_util.dart';

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

  int _score;
  TextEditingController _hintsController;
  TextEditingController _notesController;
  TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();

    _score = widget.card.score;
    _hintsController = TextEditingController(text: widget.card.hints.join("\n"));
    _notesController = TextEditingController(text: widget.card.notes);
    _tagsController = TextEditingController(text: widget.card.tags.join(" "));
  }

  @override
  Widget build(BuildContext context) {

    var actions = widget.card.isPersisted()
        ? <Widget>[
            IconButton(
                icon: Icon(Icons.delete), onPressed: () => _deleteCard())
          ]
        : null;

    var title = widget.card.isPersisted() ? 'Edit Card' : 'New Card';

    return WillPopScope( // TODO: This disables swipe back https://github.com/flutter/flutter/issues/14203
      onWillPop: () async => _saveCardAndGoBack(),
      child: Scaffold(
        appBar: AppBar(
            title: Text(title, style: TextStyle(fontSize: 30)),
          actions: actions,
        ),
        body: Container(
          color: ColorUtil.backgroundColor,
          child: ListView(
            children: [
              _buildField(_hintsController, "Write hints here, one per line"),
              _buildRatingSlider(),
              _buildField(_notesController, "Optional notes"),
              _buildField(_tagsController, "Optional tags", maxLines: 1)
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

    var newCard = HintsCard(
        id: widget.card.id,
        score: _score,
        hints: _hintsController.text.split("\n").map((x) => x.trim()).where(_notEmpty).toList(),
        notes: _notesController.text,
        tags: _tagsController.text.toLowerCase().split(new RegExp(r"[\s,]+")).where(_notEmpty).toList());

    // Avoid saving incomplete or unmodified card
    var updateNeeded = newCard.hints.isNotEmpty && newCard != widget.card;

    final CardEditScreenAction action = updateNeeded
        ? CardEditScreenAction.update : CardEditScreenAction.nothing;

    Navigator.pop(context, CardEditScreenResponse(newCard, action));

    return false;
  }

  /// Just to make the `where` clauses shorter
  bool _notEmpty(String str) => str.isNotEmpty;

  _deleteCard() {
    Navigator.pop(context, CardEditScreenResponse(widget.card, CardEditScreenAction.delete));
  }

  _buildField(TextEditingController controller, String hintText, {int maxLines}) {
    return Container(
      padding: EdgeInsets.all(8),
      child: TextFormField(
          decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: ColorUtil.hintTextColor)
          ),
          style: TextStyle(fontSize: 20),
          maxLines: maxLines,
          controller: controller,
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

