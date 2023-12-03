class HwMessage {
  int? id;
  int creatorId;
  String content;

  HwMessage({
    this.id,
    required this.creatorId,
    required this.content,
  });

  factory HwMessage.fromJson(Map<String, dynamic> json) {
    return HwMessage(
      id: json['id'],
      creatorId: json['creatorId'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'creatorId': this.creatorId,
      'content': this.content,
    };
  }

  static HwMessage fromJsonModel(Map<String, dynamic> json) => HwMessage.fromJson(json);
}
