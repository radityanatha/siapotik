import 'package:http/http.dart' as http;

class AuthService {
  Future<String> login(String username, String password) async {
    var url = Uri.parse('http://192.168.9.166/siapotik_api/login.php');

    var response = await http.post(url, body: {
      'username': username,
      'password': password,
    });

    return response.body; // bisa di-decode json juga
  }
}
