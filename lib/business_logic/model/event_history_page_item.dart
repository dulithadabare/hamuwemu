class EventHistoryPageItem {
  final int userId;
  final String? description;
  final String startTime;
  final String endTime;
  final int timeSpentMillis;

  EventHistoryPageItem({
    required this.userId,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.timeSpentMillis,
  });

  factory EventHistoryPageItem.fromJson(Map<String, dynamic> json) {
    return EventHistoryPageItem(
      userId: json['userId'],
      description: json['description'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      timeSpentMillis: json['timeSpentMillis'],
    );
  }

  static EventHistoryPageItem fromJsonModel(Map<String, dynamic> json) => EventHistoryPageItem.fromJson(json);
}