import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class HomeApi {
  final String baseUrl = "https://app-backend-a901.onrender.com/api";

  /// ✅ GET DISCOVERY FEED
  Future<List<dynamic>> getDiscoveryFeed(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/discovery/feed"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<dynamic>.from(data["data"] ?? []);
    }

    throw "Failed to fetch discovery feed: ${res.body}";
  }

  /// ✅ LIKE / DISLIKE ACTION ON DISCOVERY PROFILE
  Future<Map<String, dynamic>?> sendDiscoveryAction({
    required String token,
    required String targetUserId,
    required String action,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/likes/action"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"targetUserId": targetUserId, "action": action}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return Map<String, dynamic>.from(data);
    }

    throw "Failed to submit $action: ${res.body}";
  }
}
