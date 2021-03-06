import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cards_repo.dart';
import 'security_service.dart';
import 'hints_card.dart';

class ApiCardsRepo implements CardsRepo {

  // This is for web
  static bool _isProduction = const bool.fromEnvironment('dart.vm.product');
  //static String _apiRootUrl = _isProduction ? '/' : 'http://localhost:8090/';

  // This is for the app (or to always connect to the real API)
  static String _apiRootUrl = 'http://hintcards.site/';

  static String _baseUrl = _apiRootUrl + 'cards';

  final SecurityService securityService;

  ApiCardsRepo(this.securityService) {
    print("baseUrl: $_baseUrl");
  }

  @override
  Future<List<HintsCard>> getAll() {

    // TODO use await
    return securityService.getCredentials().then((cred) {
      var headers = {"Authorization": "Bearer ${cred!.jwt}"};
      print("Loading cards...");
      return http
          .post(Uri.parse('$_baseUrl/getAll'), headers: headers)
          .then((r) {
        print("Cards loaded");
        return HintsCard.listFromJson(decodeBody(r));
      });
    });
  }

  @override
  Future<HintsCard> deleteOne(String id) {
    return http.post(Uri.parse('$_baseUrl/deleteOne'), body: id).then((r) {
      return HintsCard.fromJson(decodeBody(r));
    });
  }

  @override
  Future<HintsCard> saveOrUpdate(HintsCard card) {
    // https://stackoverflow.com/a/55000232/1121497
    var body = json.encode(HintsCard.toJson(card));
    return http.post(
        Uri.parse('$_baseUrl/saveOrUpdate'),
        headers: {"Content-Type": "application/json"},
        body: body
    ).then((r) {
      return HintsCard.fromJson(decodeBody(r));
    });
  }

  /// utf8.decode is needed for cyrillic - https://stackoverflow.com/a/51370010/1121497
  decodeBody(http.Response r) => json.decode(utf8.decode(r.bodyBytes));
}
