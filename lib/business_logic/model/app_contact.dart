import 'package:hamuwemu/business_logic/model/phone_contact.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';

class AppContact {
  UserProfile user;
  List<PhoneContact> contactList;

  AppContact({
    required this.user,
    this.contactList = const <PhoneContact>[],
  });

  factory AppContact.fromJson(Map<String, dynamic> json) {
    final contactList = json['contactList'] != null ? List<PhoneContact>.from((json['contactList'] as List).map((e) => PhoneContact.fromJson(e))) : <PhoneContact>[];
    return AppContact(
      user: UserProfile.fromJson(json['user']),
      contactList: contactList,
    );
  }

  static AppContact fromJsonModel(Map<String, dynamic> json) => AppContact.fromJson(json);
}
