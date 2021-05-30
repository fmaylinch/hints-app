import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cards_repo.dart';
import 'hints_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiCardsRepo implements CardsRepo {

  // This is for web
  static bool _isProduction = const bool.fromEnvironment('dart.vm.product');
  //static String _apiRootUrl = _isProduction ? '/' : 'http://localhost:8090/';

  // This is for the app (or to always connect to the real API)
  static String _apiRootUrl = 'http://hintcards.site/';

  static String _baseUrl = _apiRootUrl + 'cards';

  ApiCardsRepo() {
    print("baseUrl: $_baseUrl");
  }

  @override
  Future<List<HintsCard>> getAll() {

    return _testGetJwt().then((jwt) {
      var headers = {"Authorization": "Bearer $jwt"};
      print("Loading cards...");
      return http
          .post(Uri.parse('$_baseUrl/getAll'), headers: headers)
          .then((r) {
        print("Cards loaded");
        return HintsCard.listFromJson(decodeBody(r));
      });
    });
  }

  Future<String> _testGetJwt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString('jwt');
    if (jwt != null) {
      print("Found jwt = ${jwt.substring(0, 10)}...");
    } else {
      jwt = "SAMPLE_JWT_HERE"; // TODO testing
      print("Storing jwt = ${jwt.substring(0, 10)}...");
      await prefs.setString('jwt', jwt);
    }
    return Future.value(jwt);
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
