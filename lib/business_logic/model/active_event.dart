import 'package:hamuwemu/business_logic/model/user_profile.dart';

class ActiveEvent {
  int userId;
  String? description;
  int timestampUtc;
  List<UserProfile> likedUserList;

  ActiveEvent({
    required this.userId,
    required this.description,
    required this.timestampUtc,
    this.likedUserList = const [],
  });

  factory ActiveEvent.fromJson(Map<String, dynamic> json) {
    final likedUserList = json['likedUserList'] != null ? List<UserProfile>.from((json['likedUserList'] as List).map((e) => UserProfile.fromJson(e))) : <UserProfile>[];
    return ActiveEvent(
      userId: json['userId'],
      description: json['description'],
      timestampUtc: json['timestampUtc'],
      likedUserList: likedUserList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': this.description,
    };
  }

  static ActiveEvent fromJsonModel(Map<String, dynamic> json) => ActiveEvent.fromJson(json);
}
