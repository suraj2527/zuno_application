import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  final String baseUrl = "https://app-backend-a901.onrender.com";

  /// ✅ health check
  Future<bool> checkBackendHealth(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/health"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["success"] == true;
    }
    throw "Health check failed";
  }

  /// ✅ login api
  Future<Map<String, dynamic>> login(String token) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw "Login API failed";
  }
}
