// lib/models/chat_user_model.dart
class ChatUserModel {
  final String id;
  final String name;
  final String imageUrl;
  final bool isOnline;

  ChatUserModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isOnline,
  });

  // Optional: parse from JSON
  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'imageUrl': imageUrl, 'isOnline': isOnline};
  }
}
