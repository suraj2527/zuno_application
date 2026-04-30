import 'dart:convert';
import 'package:http/http.dart' as http;
import '../sources/remote/auth_api.dart';

class AuthRepository {
  final AuthApi _api = AuthApi();

  Future<bool> verifyBackend(String token) async {
    return await _api.checkBackendHealth(token);
  }

  Future<Map<String, dynamic>> login(String token) async {
    final res = await http.post(
      Uri.parse("https://app-backend-a901.onrender.com/api/auth/login"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"];
    }

    throw "Login API failed";
  }
}
