import 'hints_card.dart';

class CardScreenResponse {

  final HintsCard card;
  final CardScreenAction action;

  CardScreenResponse(this.card, this.action);
}

enum CardScreenAction {
  update, delete, nothing
}
