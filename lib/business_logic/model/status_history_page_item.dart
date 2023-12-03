import 'package:hamuwemu/business_logic/model/hw_message.dart';

class StatusHistoryPageItem {
  final int id;
  final int userId;
  final HwMessage message;
  final String createdAt;

  StatusHistoryPageItem({
    required this.id,
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  factory StatusHistoryPageItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryPageItem(
      id: json['id'],
      userId: json['userId'],
      message: HwMessage.fromJson(json['message']),
      createdAt: json['createdAt'],
    );
  }

  static StatusHistoryPageItem fromJsonModel(Map<String, dynamic> json) => StatusHistoryPageItem.fromJson(json);
}