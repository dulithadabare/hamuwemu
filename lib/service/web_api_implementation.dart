import 'dart:convert';
import 'dart:io';
import 'package:hamuwemu/business_logic/model/active_event.dart';
import 'package:hamuwemu/business_logic/model/active_event_response.dart';
import 'package:hamuwemu/business_logic/model/active_user.dart';
import 'package:hamuwemu/business_logic/model/add_friend_req.dart';
import 'package:hamuwemu/business_logic/model/app_contact.dart';
import 'package:hamuwemu/business_logic/model/basic_profile.dart';
import 'package:hamuwemu/business_logic/model/chat_page_item.dart';
import 'package:hamuwemu/business_logic/model/current_activity.dart';
import 'package:hamuwemu/business_logic/model/basic_response.dart';
import 'package:hamuwemu/business_logic/model/current_status.dart';
import 'package:hamuwemu/business_logic/model/data_list_page.dart';
import 'package:hamuwemu/business_logic/model/event_history_page_item.dart';
import 'package:hamuwemu/business_logic/model/happening_feed_item.dart';
import 'package:hamuwemu/business_logic/model/confirmed_event.dart';
import 'package:hamuwemu/business_logic/model/event.dart';
import 'package:hamuwemu/business_logic/model/event_response.dart';
import 'package:hamuwemu/business_logic/model/interested_friend_page_item.dart';
import 'package:hamuwemu/business_logic/model/invite_friend_page_item.dart';
import 'package:hamuwemu/business_logic/model/phone_contact.dart';
import 'package:hamuwemu/business_logic/model/status_history_page_item.dart';
import 'package:hamuwemu/business_logic/model/suggested_status.dart';
import 'package:hamuwemu/business_logic/model/upcoming_page_item.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';
import 'package:hamuwemu/business_logic/model/notification_page_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'api_helper.dart';

class WebApi {
  // final String _baseUrl = "fierce-anchorage-05453.herokuapp.com"; //prod
  // final String _baseUrl = "evening-temple-78315.herokuapp.com"; //staging
  final String _baseUrl = "localhost:8080";

  FirebaseAuth get auth => FirebaseAuth.instance;

  Uri createURI(String baseURL,  String resource, [Map<String, dynamic>? queryParameters] ) {
    if(_baseUrl == "localhost:8080") return Uri.http(_baseUrl, resource, queryParameters);
    return Uri.https(_baseUrl, resource, queryParameters);
  }

  Future<List<UserProfile>> createUser(UserProfile newUser) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.post(
        createURI(_baseUrl, 'users',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(newUser),
      );
      final basicResponse = BasicResponse<UserProfile>.fromJson(_returnJsonFromResponse(response), UserProfile.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<int>> saveUserToken(String token) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.post(
        createURI(_baseUrl, 'app/tokens', {
          "token" : token,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      final basicResponse = BasicResponse<int>.fromJson(_returnJsonFromResponse(response), (e) => e);
      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<int>> logout(String token) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.post(
        createURI(_baseUrl, 'app/logout', {
          "token" : token,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      final basicResponse = BasicResponse<int>.fromJson(_returnJsonFromResponse(response), (e) => e);
      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<UserProfile>> addUser(UserProfile newUser) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.post(
        createURI(_baseUrl, 'app/user',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(newUser),
      );
      final basicResponse = BasicResponse<UserProfile>.fromJson(_returnJsonFromResponse(response), UserProfile.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<AppContact>> getAppContacts(List<PhoneContact> contactList) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.post(
        createURI(_baseUrl, 'app/contacts',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(contactList),
      );

      print('response ${response.body}');
      final basicResponse = BasicResponse<AppContact>.fromJson(_returnJsonFromResponse(response), AppContact.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<AppContact>> syncContacts(List<PhoneContact> contactList) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.put(
        createURI(_baseUrl, 'app/contacts',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(contactList),
      );
      final basicResponse = BasicResponse<AppContact>.fromJson(_returnJsonFromResponse(response), AppContact.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }


  Future<List<UserProfile>> getUser() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.get(
        createURI(_baseUrl, 'app/user',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      final jsonMap = _returnJsonFromResponse(response);
      final basicResponse = BasicResponse<UserProfile>.fromJson(jsonMap, UserProfile.fromJsonModel);

      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<BasicProfile> getPartner() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.get(
        createURI(_baseUrl, 'app/partner',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      final jsonMap = _returnJsonFromResponse(response);
      final basicResponse = BasicResponse<BasicProfile>.fromJson(jsonMap, BasicProfile.fromJsonModel);

      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data[0];
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<ActiveEventResponse> getActiveEvent() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.get(
        createURI(_baseUrl, 'app/event',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print(response.body);

      final jsonMap = _returnJsonFromResponse(response);
      final basicResponse = BasicResponse<ActiveEventResponse>.fromJson(jsonMap, ActiveEventResponse.fromJsonModel);

      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data[0];
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<ActiveEventResponse> getPartnerEvent() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.get(
        createURI(_baseUrl, 'app/partner/event',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );
      print(response.body);
      final jsonMap = _returnJsonFromResponse(response);
      final basicResponse = BasicResponse<ActiveEventResponse>.fromJson(jsonMap, ActiveEventResponse.fromJsonModel);

      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data[0];
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<DataListPage<EventHistoryPageItem>>> getEventHistoryPage( int userId, String? pageKey ) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'app/users/$userId/event-history', {
          "pageKey" : pageKey,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print(response.body);

      final basicResponse = EventHistoryBasicResponse.fromJson( _returnJsonFromResponse(response), DataListPage.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<ActiveEventResponse>> joinEvent(ActiveEvent event) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'app/event'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event),
      );

      print('Created Event ${response.body}');

      final basicResponse = BasicResponse<ActiveEventResponse>.fromJson( _returnJsonFromResponse(response), ActiveEventResponse.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<ActiveEventResponse>> leaveEvent() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.delete(
        createURI(_baseUrl, 'app/event'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      final basicResponse = BasicResponse<ActiveEventResponse>.fromJson( _returnJsonFromResponse(response), ActiveEventResponse.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<ActiveEventResponse>> likePartnerEvent() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'app/like'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
      );

      print('Created Event ${response.body}');

      final basicResponse = BasicResponse<ActiveEventResponse>.fromJson( _returnJsonFromResponse(response), ActiveEventResponse.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<ActiveEventResponse>> removeLike() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.delete(
        createURI(_baseUrl, 'app/like'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
      );

      print('Created Event ${response.body}');

      final basicResponse = BasicResponse<ActiveEventResponse>.fromJson( _returnJsonFromResponse(response), ActiveEventResponse.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<CurrentStatus> getCurrentStatus() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.get(
        createURI(_baseUrl, 'app/status',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );
      print(response.body);
      final jsonMap = _returnJsonFromResponse(response);
      final basicResponse = BasicResponse<CurrentStatus>.fromJson(jsonMap, CurrentStatus.fromJsonModel);

      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data[0];
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<CurrentStatus> addStatus(CurrentStatus status) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'app/status'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(status),
      );

      print('Created Event ${response.body}');

      final basicResponse = BasicResponse<CurrentStatus>.fromJson( _returnJsonFromResponse(response), CurrentStatus.fromJsonModel);
      return basicResponse.data[0];
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<CurrentStatus> addMessage(CurrentStatus status) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'app/chats'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(status),
      );

      print('Created Event ${response.body}');

      final basicResponse = BasicResponse<CurrentStatus>.fromJson( _returnJsonFromResponse(response), CurrentStatus.fromJsonModel);
      return basicResponse.data[0];
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }


  Future<List<ChatPageItem>> getChats() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.get(
        createURI(_baseUrl, 'app/chats',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );
      print(response.body);
      final jsonMap = _returnJsonFromResponse(response);
      final basicResponse = BasicResponse<ChatPageItem>.fromJson(jsonMap, ChatPageItem.fromJsonModel);

      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data;
    } on ClientException {
      throw FetchDataException('Connection Closed');
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<SuggestedStatus>> getSuggestions() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.get(
        createURI(_baseUrl, 'app/suggestions',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );
      print(response.body);
      final jsonMap = _returnJsonFromResponse(response);
      final basicResponse = BasicResponse<SuggestedStatus>.fromJson(jsonMap, SuggestedStatus.fromJsonModel);

      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<UserProfile>> getFriends() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.get(
        createURI(_baseUrl, 'app/friends',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );
      print(response.body);
      final jsonMap = _returnJsonFromResponse(response);
      final basicResponse = BasicResponse<UserProfile>.fromJson(jsonMap, UserProfile.fromJsonModel);

      if(basicResponse.status == -1) {
        throw FetchDataException(basicResponse.message);
      }

      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<int>> addSeen(int friendId, int messageId) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'app/chats/$friendId/messages/$messageId/seen'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
      );

      print('Created Event ${response.body}');

      final basicResponse = BasicResponse<int>.fromJson( _returnJsonFromResponse(response), (e) => e);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<CurrentStatus> removeStatus() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.delete(
        createURI(_baseUrl, 'app/status'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      final basicResponse = BasicResponse<CurrentStatus>.fromJson( _returnJsonFromResponse(response), CurrentStatus.fromJsonModel);
      return basicResponse.data[0];
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<DataListPage<StatusHistoryPageItem>>> getHistoryPage( int userId, String? pageKey ) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'app/friends/$userId/history', {
          "pageKey" : pageKey,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print(response.body);

      final basicResponse = HistoryBasicResponse.fromJson( _returnJsonFromResponse(response), DataListPage.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<UserProfile>> addFriends(List<int> friendIdList) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.post(
        createURI(_baseUrl, 'app/friends',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(friendIdList),
      );
      final basicResponse = BasicResponse<UserProfile>.fromJson(_returnJsonFromResponse(response), UserProfile.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<UserProfile>> addFriendReq(List<AddFriendReq> addFriendReqList) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.post(
        createURI(_baseUrl, 'app/friends',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(addFriendReqList),
      );
      final basicResponse = BasicResponse<UserProfile>.fromJson(_returnJsonFromResponse(response), UserProfile.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<UserProfile>> acceptFriendReq(AddFriendReq addFriendReq) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();
      final response = await http.put(
        createURI(_baseUrl, 'app/friends',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(addFriendReq),
      );
      final basicResponse = BasicResponse<UserProfile>.fromJson(_returnJsonFromResponse(response), UserProfile.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }


  Future<List<DataListPage<HappeningPageItem>>> getHappeningFeedPage( String? pageKey ) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'now', {
          "pageKey" : pageKey,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print(response.body);

      final basicResponse = HappeningBasicResponse.fromJson( _returnJsonFromResponse(response), DataListPage.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<DataListPage<UpcomingPageItem>>> getUpcomingFeedPage( String? pageKey ) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'pops', {
          "pageKey" : pageKey,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print(response.body);

      final basicResponse = UpcomingBasicResponse.fromJson( _returnJsonFromResponse(response), DataListPage.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<EventResponse>> getEventById(int eventId) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'pops/$eventId'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );
      print('event $eventId  ${utf8.decode(response.bodyBytes)}');
      final basicResponse = BasicResponse<EventResponse>.fromJson( _returnJsonFromResponse(response), EventResponse.fromJsonModel);
      return basicResponse.data;

    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<EventResponse>> getConfirmedEventById(int eventId) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'now/$eventId'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print('Confirmed Event $eventId ${response.body}');

      final basicResponse = BasicResponse<EventResponse>.fromJson( _returnJsonFromResponse(response), EventResponse.fromJsonModel);
      return basicResponse.data;

    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<DataListPage<InterestedFriendPageItem>>> getInterestedFriendFeedPage( int eventId, String? pageKey ) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'pops/$eventId/interested', {
          "pageKey" : pageKey,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print(response.body);

      final basicResponse = InterestedFriendBasicResponse.fromJson( _returnJsonFromResponse(response), DataListPage.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<DataListPage<InviteFriendPageItem>>> getFriendPage(String? pageKey ) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'users/friends', {
          "pageKey" : pageKey,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print(response.body);

      final basicResponse = InviteFriendBasicResponse.fromJson( _returnJsonFromResponse(response), DataListPage.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<CurrentActivity>> joinEventWithEventId(int eventId) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'now/$eventId/active'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      final basicResponse = BasicResponse<CurrentActivity>.fromJson( _returnJsonFromResponse(response), CurrentActivity.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<CurrentActivity>> leaveEventWithEventId(int eventId) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.delete(
        createURI(_baseUrl, 'now/$eventId/active'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      final basicResponse = BasicResponse<CurrentActivity>.fromJson( _returnJsonFromResponse(response), CurrentActivity.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<int>> getFriendCount() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'settings/friend-count'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print('friend count ${response.body}');

      final basicResponse = BasicResponse<int>.fromJson( _returnJsonFromResponse(response), (e) => e);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<CurrentActivity>> getCurrentActivity() async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'users/current-activity'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
      );

      print('Current Activity ${response.body}');

      final basicResponse = BasicResponse<CurrentActivity>.fromJson( _returnJsonFromResponse(response), CurrentActivity.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<DataListPage<ActivePageItem>>> getActivePage( int eventId, String? pageKey ) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'now/$eventId/active', {
          "pageKey" : pageKey,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print(response.body);

      final basicResponse = ActiveBasicResponse.fromJson( _returnJsonFromResponse(response), DataListPage.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<EventResponse>> createEvent(Event event) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'pops'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event),
      );

      print('Created Event ${response.body}');

      final basicResponse = BasicResponse<EventResponse>.fromJson( _returnJsonFromResponse(response), EventResponse.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<EventResponse>> createConfirmedEvent(ConfirmedEvent event) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'now'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event),
      );
      print( response.body );
      final basicResponse = BasicResponse<EventResponse>.fromJson( _returnJsonFromResponse(response), EventResponse.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<EventResponse>> addEventInterest(int eventId) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'pops/$eventId/interested',),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
      );

      final basicResponse = BasicResponse<EventResponse>.fromJson( _returnJsonFromResponse(response), EventResponse.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<EventResponse>> removeEventInterest(int eventId) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.delete(
        createURI(_baseUrl, 'pops/$eventId/interested'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      final basicResponse = BasicResponse<EventResponse>.fromJson( _returnJsonFromResponse(response), EventResponse.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<EventResponse>> peek(int eventId, int friendId) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.post(
        createURI(_baseUrl, 'pops/$eventId/peek/$friendId'),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
          'X-USER-TIMEZONE': 'Asia/Colombo',
        },
      );

      final basicResponse = BasicResponse<EventResponse>.fromJson( _returnJsonFromResponse(response), EventResponse.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<List<DataListPage<NotificationPageItem>>> getAppNotifications( String? pageKey ) async {
    try {
      final firebaseIdToken = await auth.currentUser!.getIdToken();

      final response = await http.get(
        createURI(_baseUrl, 'notifications', {
          "pageKey" : pageKey,
        }),
        headers: <String, String>{
          'Authorization': 'Bearer $firebaseIdToken',
        },
      );

      print(response.body);

      final basicResponse = BasicResponse<DataListPage<NotificationPageItem>>.fromJsonAppNotification( _returnJsonFromResponse(response), DataListPage.fromJsonModel);
      return basicResponse.data;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  dynamic _returnJsonFromResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(utf8.decode(response.bodyBytes));
        // print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
