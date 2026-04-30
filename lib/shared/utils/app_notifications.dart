import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

class AppNotifications {
  static void showError(String message) {
    _show(
      message: _friendlyMessage(message),
      isError: true,
    );
  }

  static void showSuccess(String message) {
    _show(
      message: message,
      isError: false,
    );
  }

  static void _show({required String message, bool isError = false}) {
    // Close existing to make it feel "instant"
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.rawSnackbar(
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError ? const Color(0xFF8B1A1A) : const Color(0xFF3F3D56),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: isError 
        ? const Color(0xFFFFE8E8) 
        : const Color(0xFFF2F0FF),
      borderRadius: 100,
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 80),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 2000),
      animationDuration: const Duration(milliseconds: 300),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static String _friendlyMessage(String raw) {
    final msg = raw.toLowerCase();
    
    // API/Firebase common errors
    if (msg.contains('token not found')) return "Session expired. Please login again.";
    if (msg.contains('network') || msg.contains('socket')) return "Connection failed. Check your internet.";
    if (msg.contains('already registered')) return "Already registered, please login";
    if (msg.contains('invalid-email')) return "Invalid email address";
    if (msg.contains('wrong-password')) return "Incorrect password";
    if (msg.contains('user-not-found')) return "Account not found";
    if (msg.contains('too-many-requests')) return "Too many attempts. Try again later.";
    if (msg.contains('email-already-in-use')) return "Email already in use";
    
    // Generic logic errors
    if (msg.contains('invalid profile')) return "Unable to load profile";
    
    // Fallback: strip "Exception:" prefix if exists
    String clean = raw.replaceAll(RegExp(r'^(Exception:|error:|Error:)\s*'), '');
    
    if (clean.length > 1) {
      return clean[0].toUpperCase() + clean.substring(1);
    }
    return clean;
  }
}
