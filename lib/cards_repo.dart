
import 'dart:collection';

import 'package:hints_app/hints_card.dart';

abstract class CardsRepo {

  List<HintsCard> getAll();
  void saveOrUpdate(HintsCard card);
  HintsCard remove(String id);
}

/// Simple in-memory repo
class InMemoryCardsRepo implements CardsRepo {
  
  final _cardsMap = LinkedHashMap<String, HintsCard>();
  int nextId = 0;


  InMemoryCardsRepo() {

    var sampleCards = [
      HintsCard(hints: ["buy", "покупать", "купить"], notes: "other notes"),
      HintsCard(hints: ["speak, say", "говорить", "сказать"]),
      HintsCard(hints: ["walk", "гулять", "погулять"]),
    ];

    sampleCards.forEach((c) => saveOrUpdate(c));
  }

  @override
  List<HintsCard> getAll() {
    return _cardsMap.values.toList();
  }

  @override
  void saveOrUpdate(HintsCard card) {

    if (card.id == null) {
      card.id = nextId.toString();
      nextId += 1;
    }

    _cardsMap.update(card.id, (c) => card, ifAbsent: () => card);
  }

  @override
  HintsCard remove(String id) {

    _cardsMap.remove(id);
  }
}