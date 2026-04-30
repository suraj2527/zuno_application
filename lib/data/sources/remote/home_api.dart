import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class HomeApi {
  final String baseUrl = "https://app-backend-a901.onrender.com/api";

  /// ✅ GET DISCOVERY FEED
  Future<List<dynamic>> getDiscoveryFeed(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/discovery/feed"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      print("========== DISCOVERY FEED RESPONSE ==========");
      print("Status: ${res.statusCode}");
      print("Body: ${res.body}");
      print("=============================================");
      final data = jsonDecode(res.body);
      return List<dynamic>.from(data["data"] ?? []);
    }

    throw "Failed to fetch discovery feed: ${res.body}";
  }

  /// ✅ LIKE / DISLIKE ACTION ON DISCOVERY PROFILE
  Future<bool> sendDiscoveryAction({
    required String token,
    required String targetUserId,
    required String action,
  }) async {
    print("========== DISCOVERY ACTION API ==========");
    print("API: POST $baseUrl/likes/action");
    print(
      "Payload: {\"targetUserId\":\"$targetUserId\",\"action\":\"$action\"}",
    );
    log(
      "sendDiscoveryAction -> action=$action, targetUserId=$targetUserId",
      name: "HomeApi",
    );

    final res = await http.post(
      Uri.parse("$baseUrl/likes/action"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "targetUserId": targetUserId,
        "action": action,
      }),
    );

    log(
      "sendDiscoveryAction <- status=${res.statusCode}, body=${res.body}",
      name: "HomeApi",
    );
    print("Response Status: ${res.statusCode}");
    print("Response Body: ${res.body}");
    print("=========================================");

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    }

    throw "Failed to submit $action: ${res.body}";
  }
}
