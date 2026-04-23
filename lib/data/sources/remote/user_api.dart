import 'dart:convert';
import 'package:http/http.dart' as http;

class UserApi {
  final String baseUrl = "https://app-backend-a901.onrender.com/api";

  /// ✅ CREATE PROFILE (already hai)
  Future<bool> createProfile(String token, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    }

    throw "Profile creation failed: ${res.body}";
  }

  /// ✅ GET PROFILE
  Future<Map<String, dynamic>> getProfile(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"];
    }

    throw "Failed to fetch profile";
  }

  /// ✅ UPDATE PROFILE (PATCH)
  Future<bool> updateProfile(String token, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      return true;
    }

    throw "Profile update failed";
  }
}
