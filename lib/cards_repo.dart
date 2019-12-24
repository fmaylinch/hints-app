import 'dart:collection';
import 'hints_card.dart';

abstract class CardsRepo {

  Future<List<HintsCard>> getAll();
  Future<HintsCard> saveOrUpdate(HintsCard card);
  Future<HintsCard> deleteOne(String id);
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
  Future<List<HintsCard>> getAll() =>
    Future.value(_cardsMap.values.toList());

  @override
  Future<HintsCard> saveOrUpdate(HintsCard card) {

    if (card.id == null) {
      card.id = nextId.toString();
      nextId += 1;
    }

    _cardsMap.update(card.id, (c) => card, ifAbsent: () => card);

    return Future.value(card);
  }

  @override
  Future<HintsCard> deleteOne(String id) =>
    Future.value(_cardsMap.remove(id));
}