class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final bool isMe;
  final bool isSent;
  final bool isDelivered;
  final bool isSeen;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.isMe,
    required this.isSent,
    required this.isDelivered,
    required this.isSeen,
  });

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? createdAt,
    bool? isMe,
    bool? isSent,
    bool? isDelivered,
    bool? isSeen,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isMe: isMe ?? this.isMe,
      isSent: isSent ?? this.isSent,
      isDelivered: isDelivered ?? this.isDelivered,
      isSeen: isSeen ?? this.isSeen,
    );
  }
}
