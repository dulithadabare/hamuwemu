import 'hw_message.dart';

class SuggestedStatus {
  HwMessage message;
  double averageSentTime;
  List<int> sentUserList;
  int lastSentTime;

  SuggestedStatus({
    required this.averageSentTime,
    required this.lastSentTime,
    required this.message,
    this.sentUserList = const [],
  });

  factory SuggestedStatus.fromJson(Map<String, dynamic> json) {
    final sentUserList = json['sentUserList'] != null ? List<int>.from((json['sentUserList'] as List)) : <int>[];
    return SuggestedStatus(
      averageSentTime: json['averageSentTime'],
      lastSentTime: json['lastSentTime'],
      message: HwMessage.fromJson(json['message']),
      sentUserList: sentUserList,
    );
  }

  static SuggestedStatus fromJsonModel(Map<String, dynamic> json) => SuggestedStatus.fromJson(json);
}
