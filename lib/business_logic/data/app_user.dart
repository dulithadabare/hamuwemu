class AppUser {
  final String displayName;
  final String phoneNumber;
  final String firebaseUid;

  AppUser({
    required this.firebaseUid,
    required this.displayName,
    required this.phoneNumber,
  });

  factory AppUser.fromJson(Map<dynamic, dynamic> json) {
    return AppUser(
      firebaseUid: json['firebaseUid'],
      displayName: json['displayName'],
      phoneNumber: json['phoneNo'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'firebaseUid' : this.firebaseUid,
      'displayName' : this.displayName,
      'phoneNo' : this.phoneNumber,
    };
  }

  static AppUser fromJsonModel(Map<String, dynamic> json) => AppUser.fromJson(json);
}