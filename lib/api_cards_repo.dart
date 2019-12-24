import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cards_repo.dart';
import 'hints_card.dart';

class ApiCardsRepo implements CardsRepo {

  String _baseUrl = 'http://localhost:8080/cards';

  @override
  Future<List<HintsCard>> getAll() {

    print("Loading cards...");
    return http.post('$_baseUrl/getAll').then((r) {
      print("Cards loaded");
      return HintsCard.listFromJson(json.decode(r.body));
    });
  }

  @override
  Future<HintsCard> deleteOne(String id) {
    return http.post('$_baseUrl/deleteOne', body: id).then((r) {
      return HintsCard.fromJson(json.decode(r.body));
    });
  }

  @override
  Future<HintsCard> saveOrUpdate(HintsCard card) {
    // https://stackoverflow.com/a/55000232/1121497
    var body = json.encode(HintsCard.toJson(card));
    return http.post(
        '$_baseUrl/saveOrUpdate',
        headers: {"Content-Type": "application/json"},
        body: body
    ).then((r) {
      return HintsCard.fromJson(json.decode(r.body));
    });
  }

}
