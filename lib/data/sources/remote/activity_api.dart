import 'dart:convert';
import 'package:http/http.dart' as http;

class ActivityApi {
  final String baseUrl = "https://app-backend-a901.onrender.com/api";

  /// ✅ GET LIKES RECEIVED
  Future<List<dynamic>> getReceivedLikes(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/likes/received"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<dynamic>.from(data["data"] ?? []);
    }

    throw "Failed to fetch likes received: ${res.body}";
  }

  /// ✅ GET MATCHES
  Future<List<dynamic>> getMatches(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/matches"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<dynamic>.from(data["data"] ?? []);
    }

    throw "Failed to fetch matches: ${res.body}";
  }
}
