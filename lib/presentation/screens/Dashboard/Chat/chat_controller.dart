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
      ChatUserModel(id: '1', name: 'Maya', imageUrl: '', isOnline: true),
      ChatUserModel(id: '2', name: 'Priya', imageUrl: '', isOnline: true),
      ChatUserModel(id: '3', name: 'Ananya', imageUrl: '', isOnline: true),
      ChatUserModel(id: '4', name: 'Neha', imageUrl: '', isOnline: false),
    ]);

    chatList.assignAll([
      ChatPreviewModel(
        id: '1',
        name: 'Maya',
        imageUrl: '',
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
        imageUrl: '',
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
        name: 'Neha',
        imageUrl: '',
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
        name: 'Ananya',
        imageUrl: '',
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
    isRefreshing.value = false;
  }

  void openChat(ChatPreviewModel chat) {
    Get.snackbar(
      'Open Chat',
      'Opening chat with ${chat.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // void openSearch() {
  //   Get.snackbar(
  //     'Search',
  //     'Search chats clicked',
  //     snackPosition: SnackPosition.BOTTOM,
  //     duration: const Duration(seconds: 2),
  //   );
  // }

  String getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}