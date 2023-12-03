import 'package:hamuwemu/business_logic/data/app_user.dart';

class UserProfile {
  final int? userId;
  final int? partnerId;
  final String? firebaseUid;
  final String? facebookId;
  final String? displayName;
  final String? fullName;
  final String? email;
  final String? phoneNumber;

  UserProfile({
    this.userId,
    this.firebaseUid,
    this.facebookId,
    this.displayName,
    this.email,
    this.partnerId,
    this.fullName,
    this.phoneNumber,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      firebaseUid: json['firebaseUid'],
      facebookId: json['facebookId'],
      displayName: json['displayName'],
      email: json['email'],
      partnerId: json['partnerId'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNo'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'userId' : this.userId,
      'firebaseUid' : this.firebaseUid,
      'facebookId' : this.facebookId,
      'displayName' : this.displayName,
      'fullName' : this.fullName,
      'email' : this.email,
      'phoneNo' : this.phoneNumber,
    };
  }

  factory UserProfile.fromAppUser(AppUser appUser) {
    return UserProfile(
      firebaseUid: appUser.firebaseUid,
      displayName: appUser.displayName,
      phoneNumber: appUser.phoneNumber,
    );
  }

  static UserProfile fromJsonModel(Map<String, dynamic> json) => UserProfile.fromJson(json);
}