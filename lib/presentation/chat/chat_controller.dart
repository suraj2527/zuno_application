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
  final Set<String> _myKnownIds = <String>{};
  String? _activeConversationId;

  int get totalUnreadCount =>
      chatList.fold<int>(0, (sum, item) => sum + item.unreadCount);

  List<ChatPreviewModel> get activeChats => chatList;

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
      _registerMyId(_myUserId);
      await _connectSocket(token);

      final conversations = await _chatApi.getConversations(token);
      for (final raw in conversations) {
        _extractAndRegisterMyIdsFromConversation(raw);
      }
      final mapped = conversations.map(_mapConversation).toList();
      chatList.assignAll(mapped);

      activeUsers.assignAll(
        mapped
            .where((e) => e.isOnline)
            .map(
              (e) => ChatUserModel(
                id: e.id,
                name: normalizeDisplayName(e.name),
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

  Future<void> deleteChat(ChatPreviewModel chat) async {
    final idx = chatList.indexWhere((c) => c.id == chat.id);
    if (idx == -1) return;
    final removed = chatList[idx];
    final removedMessages = messagesByConversation.remove(chat.id);

    // Optimistic UI remove.
    chatList.removeAt(idx);
    chatList.refresh();

    try {
      final token = await _authService.currentUser?.getIdToken(true);
      if (token == null) throw "Token not found";
      await _chatApi.deleteConversation(token: token, conversationId: chat.id);
    } catch (e) {
      // Rollback on failure.
      chatList.insert(idx, removed);
      if (removedMessages != null) {
        messagesByConversation[chat.id] = removedMessages;
      }
      chatList.refresh();
      Get.snackbar("Error", e.toString());
    }
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

  String normalizeDisplayName(String? name) {
    final cleaned = (name ?? "").trim();
    if (cleaned.isEmpty) return "User";
    final lower = cleaned.toLowerCase();
    if (lower == "unknown" || lower == "null" || lower == "n/a") return "User";
    return cleaned;
  }

  String getInitials(String name) {
    final display = normalizeDisplayName(name);
    if (display == "User") return "U";

    final parts = display
        .split(RegExp(r'\s+'))
        .where((p) => p.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return "U";
    String firstChar(String s) => s.isEmpty ? "" : s.substring(0, 1);
    if (parts.length == 1) return firstChar(parts.first).toUpperCase();
    final first = firstChar(parts.first).toUpperCase();
    final last = firstChar(parts.last).toUpperCase();
    return "$first$last";
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
      final localId = "local_${DateTime.now().microsecondsSinceEpoch}";
      final list = getConversationMessages(conversationId);
      final optimisticMessage = ChatMessageModel(
        id: localId,
        conversationId: conversationId,
        senderId: _myUserId ?? user?.uid ?? "",
        text: trimmed,
        createdAt: DateTime.now(),
        isMe: true,
        isSent: true,
        isDelivered: false,
        isSeen: false,
      );
      list.add(optimisticMessage);
      _updateConversationPreview(
        conversationId,
        trimmed,
        isDelivered: false,
        isSeen: false,
      );

      // REST fallback as reliable source of persistence.
      final sent = await _chatApi.sendMessage(
        token: token,
        conversationId: conversationId,
        text: trimmed,
      );

      final mapped = _mapMessage(sent);
      final message = mapped.isMe
          ? mapped
          : ChatMessageModel(
              id: mapped.id,
              conversationId: mapped.conversationId,
              senderId: mapped.senderId,
              text: mapped.text,
              createdAt: mapped.createdAt,
              // Outgoing messages from this action must render on right.
              isMe: true,
              isSent: true,
              isDelivered: mapped.isDelivered,
              isSeen: mapped.isSeen,
            );
      _registerMyId(message.senderId);
      final localIndex = list.indexWhere((m) => m.id == localId);
      if (localIndex != -1) {
        list[localIndex] = message;
      } else if (!list.any((m) => m.id == message.id && m.id.isNotEmpty)) {
        list.add(message);
      }
      _updateConversationPreview(
        conversationId,
        trimmed,
        isDelivered: message.isDelivered,
        isSeen: message.isSeen,
      );
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
    _socket?.on("message_status", (payload) {
      if (payload is! Map) return;
      _applyMessageStatusUpdate(Map<String, dynamic>.from(payload));
    });
    _socket?.on("message_seen", (payload) {
      if (payload is! Map) return;
      _applyMessageStatusUpdate(Map<String, dynamic>.from(payload));
    });
    _socket?.on("message_delivered", (payload) {
      if (payload is! Map) return;
      _applyMessageStatusUpdate(Map<String, dynamic>.from(payload));
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
        isArchived: false,
      );
    }

    final item = Map<String, dynamic>.from(raw);
    final id = item["_id"]?.toString() ??
        item["conversationId"]?.toString() ??
        item["id"]?.toString() ??
        "";
    final user =
        item["user"] is Map ? Map<String, dynamic>.from(item["user"]) : null;
    final candidateNames = <String?>[
      user?["name"]?.toString(),
      user?["fullName"]?.toString(),
      user?["username"]?.toString(),
      item["name"]?.toString(),
      item["fullName"]?.toString(),
      item["username"]?.toString(),
    ];
    final rawName = candidateNames.firstWhere(
      (v) => v != null && v.trim().isNotEmpty,
      orElse: () => null,
    );
    final name = normalizeDisplayName(rawName);
    final image = user?["image"]?.toString() ??
        user?["profileImage"]?.toString() ??
        item["image"]?.toString() ??
        "";
    final lastMessage = item["lastMessage"]?.toString() ??
        item["lastMessageText"]?.toString() ??
        "";
    final unread = int.tryParse(item["unreadCount"]?.toString() ?? "0") ?? 0;
    final createdAt = _parseDate(item["updatedAt"] ?? item["lastMessageAt"]);
    final status = item["status"]?.toString().toLowerCase();
    final isSeen = _readBool(item, const ["isSeen", "seen", "read"]) ||
        status == "seen" ||
        status == "read";
    final isDelivered =
        _readBool(item, const ["isDelivered", "delivered"]) ||
            status == "delivered" ||
            isSeen;

    // The backend may send one of these fields. We interpret "inactive/archived"
    // as anything explicitly marked archived/inactive, or explicitly not active.
    final isArchived = _readBool(item, const ["isArchived", "archived"]) ||
        (status == "archived" || status == "inactive") ||
        (_readBool(item, const ["isActive", "active"]) == false &&
            _hasKey(item, const ["isActive", "active"]));

    return ChatPreviewModel(
      id: id,
      name: name,
      imageUrl: image,
      lastMessage: lastMessage,
      time: _formatRelativeTime(createdAt),
      isOnline: user?["isOnline"] == true || item["isOnline"] == true,
      isTyping: false,
      unreadCount: unread,
      isSeen: unread > 0 ? false : isSeen,
      isDelivered: isDelivered,
      isArchived: isArchived,
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
        isSent: false,
        isDelivered: false,
        isSeen: false,
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
    final explicitIsMe = _readBool(
      item,
      const ["isMe", "isMine", "fromMe", "isSender"],
    );
    final senderCandidates = <String>{
      senderId.trim(),
      senderMap?["_id"]?.toString().trim() ?? "",
      senderMap?["id"]?.toString().trim() ?? "",
      senderMap?["userId"]?.toString().trim() ?? "",
      senderMap?["uid"]?.toString().trim() ?? "",
      senderMap?["firebaseUid"]?.toString().trim() ?? "",
      item["senderUid"]?.toString().trim() ?? "",
      item["senderFirebaseUid"]?.toString().trim() ?? "",
      item["createdBy"]?.toString().trim() ?? "",
    }..removeWhere((e) => e.isEmpty);
    final myCandidates = <String>{
      (_myUserId ?? "").trim(),
      (_authService.currentUser?.uid ?? "").trim(),
      ..._myKnownIds,
    }..removeWhere((e) => e.isEmpty);
    final isMe = explicitIsMe ||
        senderCandidates.any((sender) => myCandidates.contains(sender));
    if (isMe) {
      _registerMyId(senderId);
      _registerMyId(senderMap?["_id"]?.toString());
      _registerMyId(senderMap?["id"]?.toString());
      _registerMyId(senderMap?["userId"]?.toString());
      _registerMyId(senderMap?["uid"]?.toString());
      _registerMyId(senderMap?["firebaseUid"]?.toString());
    }
    final status = item["status"]?.toString().toLowerCase();
    final isSeen = _readBool(item, const ["isSeen", "seen", "read"]) ||
        status == "seen" ||
        status == "read";
    final isDelivered =
        _readBool(item, const ["isDelivered", "delivered"]) ||
            status == "delivered" ||
            isSeen;
    final isSent = _readBool(item, const ["isSent", "sent"]) ||
        status == "sent" ||
        isDelivered ||
        isSeen ||
        isMe;

    return ChatMessageModel(
      id: item["_id"]?.toString() ?? item["id"]?.toString() ?? "",
      conversationId: conversationId,
      senderId: senderId,
      text: item["text"]?.toString() ?? item["message"]?.toString() ?? "",
      createdAt: _parseDate(item["createdAt"] ?? item["timestamp"]),
      isMe: isMe,
      isSent: isSent,
      isDelivered: isDelivered,
      isSeen: isSeen,
    );
  }

  void _registerMyId(String? id) {
    final value = (id ?? "").trim();
    if (value.isNotEmpty) {
      _myKnownIds.add(value);
    }
  }

  void _extractAndRegisterMyIdsFromConversation(dynamic raw) {
    if (raw is! Map) return;
    final item = Map<String, dynamic>.from(raw);

    Map<String, dynamic>? toMap(dynamic value) {
      if (value is Map) return Map<String, dynamic>.from(value);
      return null;
    }

    void registerFromMap(Map<String, dynamic>? map) {
      if (map == null) return;
      _registerMyId(map["_id"]?.toString());
      _registerMyId(map["id"]?.toString());
      _registerMyId(map["userId"]?.toString());
      _registerMyId(map["uid"]?.toString());
      _registerMyId(map["firebaseUid"]?.toString());
    }

    registerFromMap(toMap(item["me"]));
    registerFromMap(toMap(item["self"]));
    registerFromMap(toMap(item["currentUser"]));
    registerFromMap(toMap(item["myUser"]));

    final members = item["members"];
    if (members is List) {
      for (final member in members) {
        if (member is! Map) continue;
        final m = Map<String, dynamic>.from(member);
        final isSelf = _readBool(m, const ["isMe", "me", "isSelf", "self"]);
        if (isSelf) {
          registerFromMap(m);
        }
      }
    }
  }

  void _applyMessageStatusUpdate(Map<String, dynamic> payload) {
    final conversationId = payload["conversationId"]?.toString() ??
        payload["chatId"]?.toString() ??
        payload["roomId"]?.toString() ??
        "";
    if (conversationId.isEmpty) return;

    final list = messagesByConversation[conversationId];
    if (list == null || list.isEmpty) return;

    final messageId = payload["messageId"]?.toString() ??
        payload["_id"]?.toString() ??
        payload["id"]?.toString() ??
        "";
    final status = payload["status"]?.toString().toLowerCase();
    final seenFlag = _readBool(payload, const ["isSeen", "seen", "read"]);
    final deliveredFlag =
        _readBool(payload, const ["isDelivered", "delivered"]);
    final sentFlag = _readBool(payload, const ["isSent", "sent"]);

    final isSeen = seenFlag || status == "seen" || status == "read";
    final isDelivered = deliveredFlag || status == "delivered" || isSeen;
    final isSent = sentFlag || status == "sent" || isDelivered || isSeen;

    final idx = messageId.isNotEmpty
        ? list.indexWhere((m) => m.id == messageId)
        : -1;
    if (idx == -1) return;

    final current = list[idx];
    list[idx] = current.copyWith(
      isSent: current.isSent || isSent,
      isDelivered: current.isDelivered || isDelivered,
      isSeen: current.isSeen || isSeen,
    );
    list.refresh();

    final previewIndex = chatList.indexWhere((c) => c.id == conversationId);
    if (previewIndex != -1) {
      final preview = chatList[previewIndex];
      _updateConversationPreview(
        conversationId,
        preview.lastMessage,
        isDelivered: current.isDelivered || isDelivered,
        isSeen: current.isSeen || isSeen,
      );
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  bool _hasKey(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      if (map.containsKey(k)) return true;
    }
    return false;
  }

  bool _readBool(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      if (!map.containsKey(k)) continue;
      final v = map[k];
      if (v is bool) return v;
      final s = v?.toString().toLowerCase();
      if (s == "true" || s == "1") return true;
      if (s == "false" || s == "0") return false;
    }
    return false;
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
    bool? isDelivered,
    bool? isSeen,
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
      isSeen: increaseUnread ? false : (isSeen ?? old.isSeen),
      isDelivered: isDelivered ?? old.isDelivered,
      isArchived: old.isArchived,
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
      isArchived: old.isArchived,
    );
    chatList.refresh();
  }

  @override
  void onClose() {
    _socket?.dispose();
    super.onClose();
  }
}