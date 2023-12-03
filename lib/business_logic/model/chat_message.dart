import 'package:hamuwemu/business_logic/model/hw_message.dart';

class ChatMessage {
  int senderId;
  int receiverId;
  HwMessage? message;
  bool seen;
  int timestampUtc;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.seen,
    required this.timestampUtc,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      message: json['message'] != null ? HwMessage.fromJson(json['message']) : null,
      seen: json['seen'],
      timestampUtc: json['timestampUtc'],
    );
  }

  static ChatMessage fromJsonModel(Map<String, dynamic> json) => ChatMessage.fromJson(json);
}
