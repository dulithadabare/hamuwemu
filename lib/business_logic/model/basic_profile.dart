class BasicProfile {
  final int userId;
  final String? displayName;
  final String? fullName;

  BasicProfile({
    required this.userId,
    required this.displayName,
    required this.fullName,
  });

  factory BasicProfile.fromJson(Map<String, dynamic> json) {
    return BasicProfile(
      userId: json['userId'],
      displayName: json['displayName'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic>? toJson(){
    return {
      'userId' : this.userId,
      'displayName' : this.displayName,
      'fullName' : this.fullName,
    };
  }

  static BasicProfile fromJsonModel(Map<String, dynamic> json) => BasicProfile.fromJson(json);
}