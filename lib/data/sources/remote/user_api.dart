import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  /// ✅ UPLOAD PHOTO
  Future<Map<String, dynamic>> uploadPhoto(
    String token,
    String imagePath,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/profile/upload-photo"),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return data; // Usually contains publicId and url
    }

    throw "Photo upload failed: ${res.body}";
  }

  /// ✅ SET PRIMARY PHOTO
  Future<bool> setPrimaryPhoto(String token, String publicId) async {
    final res = await http.put(
      Uri.parse("$baseUrl/profile/photo/set-primary"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"publicId": publicId}),
    );

    if (res.statusCode == 200) {
      return true;
    }

    throw "Setting primary photo failed: ${res.body}";
  }

  /// ✅ DELETE PHOTO
  Future<bool> deletePhoto(String token, String publicId) async {
    final encodedId = Uri.encodeComponent(publicId);
    final res = await http.delete(
      Uri.parse("$baseUrl/profile/photo/$encodedId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return true;
    }

    throw "Photo deletion failed: ${res.body}";
  }
}
