import 'user_model.dart';

class ChatMessageModel {
  final int id;
  final int chatId;
  final int senderId;
  final String message;
  final String? imageUrl;
  final bool isRead;
  final String? createdAt;
  final UserModel? sender;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    this.imageUrl,
    this.isRead = false,
    this.createdAt,
    this.sender,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      chatId: json['chat_id'] is int
          ? json['chat_id']
          : int.tryParse(json['chat_id']?.toString() ?? '') ?? 0,
      senderId: json['sender_id'] is int
          ? json['sender_id']
          : int.tryParse(json['sender_id']?.toString() ?? '') ?? 0,
      message: json['message'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] as String?,
      sender: json['sender'] != null && json['sender'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['sender'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'message': message,
      'image_url': imageUrl,
      'is_read': isRead,
      'created_at': createdAt,
      'sender': sender?.toJson(),
    };
  }
}

class ChatModel {
  final int id;
  final int orderId;
  final List<ChatMessageModel> messages;
  final ChatMessageModel? lastMessage;

  ChatModel({
    required this.id,
    required this.orderId,
    this.messages = const [],
    this.lastMessage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      messages: (json['messages'] is List)
          ? (json['messages'] as List)
              .map((m) => ChatMessageModel.fromJson(Map<String, dynamic>.from(m as Map)))
              .toList()
          : [],
      lastMessage: json['last_message'] != null && json['last_message'] is Map
          ? ChatMessageModel.fromJson(Map<String, dynamic>.from(json['last_message'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
    };
  }
}
