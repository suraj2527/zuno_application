// lib/models/chat_preview_model.dart
class ChatPreviewModel {
  final String id;
  final String name;
  final String imageUrl;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final bool isTyping;
  final int unreadCount;
  final bool isSeen;
  final bool isDelivered;

  ChatPreviewModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.isTyping,
    required this.unreadCount,
    required this.isSeen,
    required this.isDelivered,
  });

  factory ChatPreviewModel.fromJson(Map<String, dynamic> json) {
    return ChatPreviewModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      time: json['time'] ?? '',
      isOnline: json['isOnline'] ?? false,
      isTyping: json['isTyping'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
      isSeen: json['isSeen'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'lastMessage': lastMessage,
      'time': time,
      'isOnline': isOnline,
      'isTyping': isTyping,
      'unreadCount': unreadCount,
      'isSeen': isSeen,
      'isDelivered': isDelivered,
    };
  }
}