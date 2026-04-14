import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApi {
  final String baseUrl = "https://app-backend-a901.onrender.com/api";

  Future<List<dynamic>> getConversations(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/chats/conversations"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<dynamic>.from(data["data"] ?? []);
    }

    throw "Failed to fetch conversations: ${res.body}";
  }

  Future<List<dynamic>> getMessages(String token, String conversationId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/chats/$conversationId/messages"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List<dynamic>.from(data["data"] ?? []);
    }

    throw "Failed to fetch messages: ${res.body}";
  }

  Future<Map<String, dynamic>> sendMessage({
    required String token,
    required String conversationId,
    required String text,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/chats/send"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "conversationId": conversationId,
        "text": text,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return Map<String, dynamic>.from(data["data"] ?? {});
    }

    throw "Failed to send message: ${res.body}";
  }
}
