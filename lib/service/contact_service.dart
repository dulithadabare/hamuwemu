import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:hamuwemu/business_logic/model/app_contact.dart';
import 'package:hamuwemu/business_logic/model/confirmed_event.dart';
import 'package:hamuwemu/business_logic/model/current_status.dart';
import 'package:hamuwemu/business_logic/model/data_list_page.dart';
import 'package:hamuwemu/business_logic/model/event_response.dart';
import 'package:hamuwemu/business_logic/model/hw_message.dart';
import 'package:hamuwemu/business_logic/model/invite_friend_page_item.dart';
import 'package:hamuwemu/business_logic/model/phone_contact.dart';
import 'package:hamuwemu/business_logic/model/response.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';
import 'package:phone_number/phone_number.dart';

class ContactService {
  Set<AppContact> addedFriendList = <AppContact>{};
  List<Contact> contacts = [];
  // Map<String, AppContact> appContactMap = {};
  List<AppContact> appContacts = <AppContact>[];
  Map<String, PhoneContact> displayNameMap = {};
  bool permissionDenied = false;


  // ContactService(){
  //   _init();
  // }

  void _init() async {
    load();
  }

  Future<void> _loadPhoneContacts() async {
    print('Loading Contacts');
    String code = await PhoneNumberUtil().carrierRegionCode();
    // print('Country Code : $code');
    for (var contact in contacts) {
      for (var phone in contact.phones) {
        String internationalFormat = phone.number;
        if (phone.number.startsWith('+')) {
          try {
            PhoneNumber phoneNumber = await PhoneNumberUtil().parse(phone.number);
            internationalFormat = phoneNumber.international;
          } catch (e) {
            print(e);
          }
        } else {
          try {
            PhoneNumber phoneNumber = await PhoneNumberUtil().parse(phone.number, regionCode: code.toUpperCase());
            internationalFormat = phoneNumber.international;
          } catch (e) {
            print(e);
          }
        }
        // print('${contact.displayName} International Format : $internationalFormat');
        final internationalCleanNumber = internationalFormat.replaceAll(RegExp(r"[^0-9+]"), "");
        displayNameMap[internationalCleanNumber] = PhoneContact(displayName: contact.displayName, phoneNumber: internationalCleanNumber);
      }
    }
  }

  Future<void> load() async {
    if (!await FlutterContacts.requestPermission()) {
      permissionDenied = true;
      // throw ContactsPermissionException('Contact Permission Denied');
    } else {
      contacts = await FlutterContacts.getContacts(withProperties: true);
      await _loadPhoneContacts();
    }

    // if(permissionDenied) return;
    // contacts = await FlutterContacts.getContacts(withProperties: true);
    // _loadPhoneContacts();
  }

  String? getDisplayNameFromAppUser(UserProfile appUser) {
    return displayNameMap[appUser.phoneNumber]?.displayName;
  }

  List<PhoneContact> get phoneContacts {
    print('DisplayNameMap size ${displayNameMap.length}');
    return displayNameMap.values.toList();
  }

}
