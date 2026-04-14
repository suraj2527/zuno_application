import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:zuno_application/core/services/auth_service.dart';
import 'package:zuno_application/data/model/chat/chat_message_model.dart';
import 'package:zuno_application/data/sources/remote/chat_api.dart';
import '../../data/model/chat/chat_preview_model.dart';
import '../../data/model/chat/chat_user_model.dart';

class ChatController extends GetxController {
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final isMessagesLoading = false.obs;

  final activeUsers = <ChatUserModel>[].obs;
  final chatList = <ChatPreviewModel>[].obs;
  final messagesByConversation = <String, RxList<ChatMessageModel>>{};

  final AuthService _authService = AuthService();
  final ChatApi _chatApi = ChatApi();
  io.Socket? _socket;
  String? _myUserId;
  String? _activeConversationId;

  int get totalUnreadCount =>
      chatList.fold<int>(0, (sum, item) => sum + item.unreadCount);

  @override
  void onInit() {
    super.onInit();
    loadChatData();
  }

  Future<void> loadChatData() async {
    isLoading.value = true;
    try {
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);
      if (token == null) throw "Token not found";

      _myUserId = user?.uid;
      await _connectSocket(token);

      final conversations = await _chatApi.getConversations(token);
      final mapped = conversations.map(_mapConversation).toList();
      chatList.assignAll(mapped);

      activeUsers.assignAll(
        mapped
            .where((e) => e.isOnline)
            .map(
              (e) => ChatUserModel(
                id: e.id,
                name: e.name,
                imageUrl: e.imageUrl,
                isOnline: e.isOnline,
              ),
            )
            .toList(),
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshChats() async {
    isRefreshing.value = true;
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

  RxList<ChatMessageModel> getConversationMessages(String conversationId) {
    return messagesByConversation.putIfAbsent(
      conversationId,
      () => <ChatMessageModel>[].obs,
    );
  }

  Future<void> loadConversationMessages(String conversationId) async {
    isMessagesLoading.value = true;
    try {
      setActiveConversation(conversationId);
      final user = _authService.currentUser;
      final token = await user?.getIdToken(true);
      if (token == null) throw "Token not found";

      final data = await _chatApi.getMessages(token, conversationId);
      final mapped = data.map(_mapMessage).toList();
      getConversationMessages(conversationId).assignAll(mapped);
      _joinConversation(conversationId);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isMessagesLoading.value = false;
    }
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final user = _authService.currentUser;
    final token = await user?.getIdToken(true);
    if (token == null) {
      Get.snackbar("Error", "Token not found");
      return;
    }

    try {
      // REST fallback as reliable source of persistence.
      final sent = await _chatApi.sendMessage(
        token: token,
        conversationId: conversationId,
        text: trimmed,
      );

      final message = _mapMessage(sent);
      final list = getConversationMessages(conversationId);
      if (!list.any((m) => m.id == message.id && m.id.isNotEmpty)) {
        list.add(message);
      }
      _updateConversationPreview(conversationId, trimmed);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> _connectSocket(String token) async {
    if (_socket?.connected == true) return;

    _socket?.dispose();
    _socket = io.io(
      "https://app-backend-a901.onrender.com",
      io.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .setAuth({"token": token})
          .build(),
    );

    _socket?.onConnect((_) {});
    _socket?.on("new_message", (payload) {
      if (payload is! Map) return;
      final message = _mapMessage(Map<String, dynamic>.from(payload));
      final conversationId = message.conversationId;
      if (conversationId.isEmpty) return;

      final list = getConversationMessages(conversationId);
      final exists = list.any((m) => m.id.isNotEmpty && m.id == message.id);
      if (!exists) {
        list.add(message);
      }
      _updateConversationPreview(
        conversationId,
        message.text,
        increaseUnread: !message.isMe && conversationId != _activeConversationId,
      );
    });

    _socket?.connect();
  }

  void _joinConversation(String conversationId) {
    _socket?.emit("join_conversation", {"conversationId": conversationId});
  }

  ChatPreviewModel _mapConversation(dynamic raw) {
    if (raw is! Map) {
      return ChatPreviewModel(
        id: "",
        name: "Unknown",
        imageUrl: "",
        lastMessage: "",
        time: "",
        isOnline: false,
        isTyping: false,
        unreadCount: 0,
        isSeen: true,
        isDelivered: true,
      );
    }

    final item = Map<String, dynamic>.from(raw);
    final id = item["_id"]?.toString() ??
        item["conversationId"]?.toString() ??
        item["id"]?.toString() ??
        "";
    final user = item["user"] is Map
        ? Map<String, dynamic>.from(item["user"])
        : item;
    final name = user["name"]?.toString() ?? item["name"]?.toString() ?? "Unknown";
    final image = user["image"]?.toString() ??
        user["profileImage"]?.toString() ??
        item["image"]?.toString() ??
        "";
    final lastMessage = item["lastMessage"]?.toString() ??
        item["lastMessageText"]?.toString() ??
        "";
    final unread = int.tryParse(item["unreadCount"]?.toString() ?? "0") ?? 0;
    final createdAt = _parseDate(item["updatedAt"] ?? item["lastMessageAt"]);

    return ChatPreviewModel(
      id: id,
      name: name,
      imageUrl: image,
      lastMessage: lastMessage,
      time: _formatRelativeTime(createdAt),
      isOnline: user["isOnline"] == true || item["isOnline"] == true,
      isTyping: false,
      unreadCount: unread,
      isSeen: unread == 0,
      isDelivered: true,
    );
  }

  ChatMessageModel _mapMessage(dynamic raw) {
    if (raw is! Map) {
      return ChatMessageModel(
        id: "",
        conversationId: "",
        senderId: "",
        text: "",
        createdAt: null,
        isMe: false,
      );
    }

    final item = Map<String, dynamic>.from(raw);
    final conversationId = item["conversationId"]?.toString() ??
        item["chatId"]?.toString() ??
        item["roomId"]?.toString() ??
        "";
    final senderMap = item["sender"] is Map
        ? Map<String, dynamic>.from(item["sender"])
        : null;
    final senderId = item["senderId"]?.toString() ??
        senderMap?["_id"]?.toString() ??
        item["sender"]?.toString() ??
        "";

    return ChatMessageModel(
      id: item["_id"]?.toString() ?? item["id"]?.toString() ?? "",
      conversationId: conversationId,
      senderId: senderId,
      text: item["text"]?.toString() ?? item["message"]?.toString() ?? "",
      createdAt: _parseDate(item["createdAt"] ?? item["timestamp"]),
      isMe: senderId.isNotEmpty && senderId == _myUserId,
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _formatRelativeTime(DateTime? time) {
    if (time == null) return "";
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return "now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    return "${diff.inDays}d";
  }

  String formatMessageTime(DateTime? time) {
    if (time == null) return "";
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, "0");
    final suffix = time.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $suffix";
  }

  void _updateConversationPreview(
    String conversationId,
    String text, {
    bool increaseUnread = false,
  }) {
    final idx = chatList.indexWhere((e) => e.id == conversationId);
    if (idx == -1) return;
    final old = chatList[idx];
    chatList[idx] = ChatPreviewModel(
      id: old.id,
      name: old.name,
      imageUrl: old.imageUrl,
      lastMessage: text,
      time: "now",
      isOnline: old.isOnline,
      isTyping: old.isTyping,
      unreadCount: increaseUnread ? old.unreadCount + 1 : old.unreadCount,
      isSeen: increaseUnread ? false : old.isSeen,
      isDelivered: old.isDelivered,
    );
    chatList.refresh();
  }

  void setActiveConversation(String conversationId) {
    _activeConversationId = conversationId;
    _markConversationAsRead(conversationId);
  }

  void clearActiveConversation(String conversationId) {
    if (_activeConversationId == conversationId) {
      _activeConversationId = null;
    }
  }

  void _markConversationAsRead(String conversationId) {
    final idx = chatList.indexWhere((e) => e.id == conversationId);
    if (idx == -1) return;
    final old = chatList[idx];
    if (old.unreadCount == 0) return;

    chatList[idx] = ChatPreviewModel(
      id: old.id,
      name: old.name,
      imageUrl: old.imageUrl,
      lastMessage: old.lastMessage,
      time: old.time,
      isOnline: old.isOnline,
      isTyping: old.isTyping,
      unreadCount: 0,
      isSeen: true,
      isDelivered: old.isDelivered,
    );
    chatList.refresh();
  }

  @override
  void onClose() {
    _socket?.dispose();
    super.onClose();
  }
}