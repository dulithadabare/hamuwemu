import 'package:hamuwemu/business_logic/model/add_friend_req.dart';
import 'package:hamuwemu/business_logic/model/chat_page_item.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/contact_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';

import 'abstract_view_model.dart';

class FriendsViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();
  ContactService get contacts => serviceLocator<ContactService>();

  List<ChatPageItem> chatPageItemList = <ChatPageItem>[];

  Future<void> load() async {
    setStatus(ViewModelStatus.busy);
    try {
      chatPageItemList = await _webApi.getChats();

      if(chatPageItemList.isNotEmpty) {
        await contacts.load();
        await _webApi.syncContacts(contacts.phoneContacts);
      }

      setStatus(ViewModelStatus.idle);
      print('Loaded chatPageItemsList size ${chatPageItemList.length}');
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> setSeen() async {
    if(chatPageItemList.isEmpty) return;
    try {
      for (var chatPageItem in chatPageItemList) {
        if( !chatPageItem.seen ) {
          _webApi.addSeen(chatPageItem.friend.userId!, chatPageItem.receivedMessage?.message?.id ?? 0);
          chatPageItem.seen = true;
        }
      }
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> addFriends(Set<int> friendIdList) async {
    setStatus(ViewModelStatus.busy);
    try {
      final data = await _webApi.addFriends(friendIdList.toList());
      for (var user in data) {
        print('Added Friend ${user.userId!}');
      }
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e);
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> addFriendReq(List<UserProfile> addFriendList) async {
    setStatus(ViewModelStatus.busy);
    try {
      List<AddFriendReq> addFriendReqList = [];

      for (var addFriend in addFriendList) {
        AddFriendReq addFriendReq = AddFriendReq( friendId: addFriend.userId!, displayName: contacts.getDisplayNameFromAppUser(addFriend) );
        addFriendReqList.add(addFriendReq);
      }

      final data = await _webApi.addFriendReq(addFriendReqList);
      for (var user in data) {
        print('Added Friend ${user.userId!}');
      }
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e);
      setStatus(ViewModelStatus.error);
    }
  }

}
