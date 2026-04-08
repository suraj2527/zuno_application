// lib/controllers/chat_controller.dart
import 'package:get/get.dart';
import 'models/chat_preview_model.dart';
import 'models/chat_user_model.dart';

class ChatController extends GetxController {
  final isLoading = true.obs;
  final isRefreshing = false.obs;

  final activeUsers = <ChatUserModel>[].obs;
  final chatList = <ChatPreviewModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChatData();
  }

  Future<void> loadChatData() async {
    isLoading.value = true;

    await Future.delayed(const Duration(milliseconds: 1400));

    activeUsers.assignAll([
      ChatUserModel(id: '1', name: 'Maya', imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80', isOnline: true),
      ChatUserModel(id: '2', name: 'Priya', imageUrl: 'https://images.unsplash.com/photo-1597739239353-50270a473397?q=80&w=327&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', isOnline: true),
      ChatUserModel(id: '3', name: 'Ananya', imageUrl: 'https://images.unsplash.com/photo-1602233158242-3ba0ac4d2167?q=80&w=436&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', isOnline: true),
      ChatUserModel(id: '4', name: 'Neha', imageUrl: 'https://plus.unsplash.com/premium_photo-1668319914124-57301e0a1850?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', isOnline: false),
    ]);

    chatList.assignAll([
      ChatPreviewModel(
        id: '1',
        name: 'Maya',
        imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
        lastMessage: 'Just grabbing a coffee. You?',
        time: '2m',
        isOnline: true,
        isTyping: false,
        unreadCount: 2,
        isSeen: false,
        isDelivered: true,
      ),
      ChatPreviewModel(
        id: '2',
        name: 'Priya',
        imageUrl: 'https://images.unsplash.com/photo-1597739239353-50270a473397?q=80&w=327&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        lastMessage: 'That movie was so good!',
        time: '1h',
        isOnline: false,
        isTyping: false,
        unreadCount: 0,
        isSeen: true,
        isDelivered: true,
      ),
      ChatPreviewModel(
        id: '3',
        name: 'Ananya',
        imageUrl: 'https://images.unsplash.com/photo-1602233158242-3ba0ac4d2167?q=80&w=436&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        lastMessage: 'Hey! Saw you nearby 👋',
        time: '3h',
        isOnline: false,
        isTyping: false,
        unreadCount: 1,
        isSeen: false,
        isDelivered: true,
      ),
      ChatPreviewModel(
        id: '4',
        name: 'Neha',
        imageUrl: 'https://plus.unsplash.com/premium_photo-1668319914124-57301e0a1850?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        lastMessage: 'Maybe I’ll join you 😊',
        time: '1d',
        isOnline: false,
        isTyping: false,
        unreadCount: 0,
        isSeen: false,
        isDelivered: false,
      ),
    ]);

    isLoading.value = false;
  }

  Future<void> refreshChats() async {
    isRefreshing.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    await loadChatData();
    // isRefreshing.value = false;
  }

  void openChat(ChatPreviewModel chat) {
    Get.snackbar(
      'Open Chat',
      'Opening chat with ${chat.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void openSearch() {
    Get.snackbar(
      'Search',
      'Search chats clicked',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  String getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}