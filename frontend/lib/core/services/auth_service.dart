import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prbd_2526_a07/core/services/api_client.dart';
import 'package:prbd_2526_a07/core/tools/params.dart';

class AuthService {
  static const String _baseUrl = 'http://localhost:3000/rpc';

  static Future<String> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed: ${response.body}');
    }

    final data = json.decode(response.body); // extrait la clé token

    Params.setValue('token', data['token']);
    return data['token'];
  }

  static Future<void> signup({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final url = Uri.parse('$_baseUrl/signup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone': phone,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('Signup failed: ${response.body}');
    }
  }

  static Future<void> resetDatabase() async {
    final url = Uri.parse('$_baseUrl/reset_database');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({}),
    );

    if (response.statusCode != 204) {
      throw Exception('Reset database failed: ${response.body}');
    }
  }

  static Future<bool> isEmailAvailable(String email) async {
    final url = Uri.parse('$_baseUrl/is_email_available');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Check email failed: ${response.body}');
    }

    return json.decode(response.body) as bool;
  }

  static Future<bool> isFullNameAvailable(String fullName) async {
    final url = Uri.parse('$_baseUrl/is_full_name_available');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'full_name': fullName}),
    );

    if (response.statusCode != 200) {
      throw Exception('Check full name failed: ${response.body}');
    }

    return json.decode(response.body) as bool;
  }

  static Future<bool> isClient() async {
    final response = await ApiClient.get("isclient");

    if (response.statusCode != 200) {
      throw Exception('Cet utilisateur n''est pas un client: ${response.body}');
    }

    return json.decode(response.body) as bool;
  }

  static Future<bool> isManager() async {
    final response = await ApiClient.get("ismanager");

    if (response.statusCode != 200) {
      throw Exception('Cet utilisateur n''est pas un manager: ${response.body}');
    }

    return json.decode(response.body) as bool;
  }


  static Future<String> getRole() async {
    final response = await ApiClient.get("get_role");

    if (response.statusCode != 200)
      throw Exception("Role fetch failed");

    final body = jsonDecode(response.body);
    return body["role"];
  }

}