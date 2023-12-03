import 'package:hamuwemu/business_logic/model/hw_message.dart';

class CurrentStatus {
  int userId;
  int timestampUtc;
  HwMessage? message;
  List<int> sendList;

  CurrentStatus({
    required this.userId,
    required this.timestampUtc,
    required this.message,
    this.sendList = const [],
  });

  factory CurrentStatus.fromJson(Map<String, dynamic> json) {
    final sendList = json['sendList'] != null ? List<int>.from((json['sendList'] as List).map((e) => e)) : <int>[];
    return CurrentStatus(
      userId: json['userId'],
      timestampUtc: json['timestampUtc'],
      message: json['message'] != null ? HwMessage.fromJson(json['message']) : null,
      sendList: sendList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': this.userId,
      'message': this.message?.toJson(),
      'sendList': this.sendList,
    };
  }

  static CurrentStatus fromJsonModel(Map<String, dynamic> json) => CurrentStatus.fromJson(json);
}
