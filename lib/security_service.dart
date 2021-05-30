import 'package:hints_app/credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {

  Credentials? credentials;

  Future<Credentials?> getCredentials() async {

    if (credentials != null) {
      return Future.value(credentials);
    }

    var jwt = await _testGetJwt();

    if (jwt != null) {
      credentials = Credentials("fake-user", jwt);
      return credentials;
    } else {
      return null;
    }
  }

  Future<String?> _testGetJwt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jwt = prefs.getString('jwt');
    if (jwt != null) {
      print("Found jwt = ${jwt.substring(0, 10)}...");
    } else {
      jwt = "TEST-TOKEN"; // TODO testing
      print("Storing jwt = ${jwt.substring(0, 10)}...");
      await prefs.setString('jwt', jwt);
    }
    return Future.value(jwt);
  }
}
