import 'package:hamuwemu/business_logic/model/user_profile.dart';

import 'chat_message.dart';

class ChatPageItem {
  UserProfile friend;
  ChatMessage? receivedMessage;
  ChatMessage? sentMessage;
  int timestampUtc;
  bool seen;
  List<int> chatGroupId;

  ChatPageItem({
    required this.friend,
    required this.receivedMessage,
    required this.sentMessage,
    required this.timestampUtc,
    this.chatGroupId = const [],
    this.seen = false,
  });

  factory ChatPageItem.fromJson(Map<String, dynamic> json) {
    final chatGroupId = json['chatGroupId'] != null ? List<int>.from((json['chatGroupId'] as List)) : <int>[];
    return ChatPageItem(
      friend: UserProfile.fromJson(json['friend']),
      receivedMessage: json['receivedMessage'] != null ? ChatMessage.fromJson(json['receivedMessage']) : null,
      sentMessage: json['sentMessage'] != null ? ChatMessage.fromJson(json['sentMessage']) : null,
      timestampUtc: json['timestampUtc'],
      chatGroupId: chatGroupId,
      seen: json['seen'],
    );
  }

  static ChatPageItem fromJsonModel(Map<String, dynamic> json) => ChatPageItem.fromJson(json);
}
