class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final bool isMe;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.isMe,
  });
}
