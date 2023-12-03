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
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/contact_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';
import 'package:phone_number/phone_number.dart';

import 'abstract_view_model.dart';

class AddFriendsViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();
  ContactService get contacts => serviceLocator<ContactService>();
  Set<AppContact> addedFriendList = <AppContact>{};
  // Map<String, AppContact> appContactMap = {};
  List<AppContact> appContacts = <AppContact>[];
  bool permissionDenied = false;

  AddFriendsViewModel(){
    _init();
  }

  void _init() async {
    setStatus(ViewModelStatus.busy);
    await contacts.load();
    permissionDenied = contacts.permissionDenied;
    if (!permissionDenied) {
      await getAppContacts();
    }
  }

  void add(AppContact appContact) {
    this.addedFriendList.add(appContact);
    setStatus(ViewModelStatus.idle);
  }

  void remove(AppContact appContact) {
    addedFriendList.remove(appContact);
    setStatus(ViewModelStatus.idle);
  }

  Future<void> getAppContacts() async {
    try {
      await contacts.load();
      appContacts = await _webApi.getAppContacts(contacts.phoneContacts);

      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e);
      setStatus(ViewModelStatus.error);
    }
  }


}
