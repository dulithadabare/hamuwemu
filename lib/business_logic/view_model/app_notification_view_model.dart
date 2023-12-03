import 'dart:ffi';

import 'package:hamuwemu/business_logic/model/active_event.dart';
import 'package:hamuwemu/business_logic/model/active_event_response.dart';
import 'package:hamuwemu/business_logic/model/chat_message.dart';
import 'package:hamuwemu/business_logic/model/chat_page_item.dart';
import 'package:hamuwemu/business_logic/model/current_activity.dart';
import 'package:hamuwemu/business_logic/model/hw_message.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';
import 'package:hamuwemu/business_logic/view_model/partner_active_event_view_model.dart';
import 'package:hamuwemu/service/api_helper.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/service/web_api_implementation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundpool/soundpool.dart';

import 'abstract_view_model.dart';
import 'active_event_view_model.dart';
import 'app_sounds_view_model.dart';
import 'friends_view_model.dart';

class AppNotificationViewModel extends AbstractViewModel {
  final WebApi _webApi = WebApi();

  bool _newNotificationAvailable = false;
  Soundpool? _pool;
  int? soundId;
  ActiveEventViewModel get _activeModel => serviceLocator<ActiveEventViewModel>();
  FriendsViewModel get _friendsModel => serviceLocator<FriendsViewModel>();
  PartnerActiveEventViewModel get _partnerModel => serviceLocator<PartnerActiveEventViewModel>();

  bool get newNotificationAvailable => _newNotificationAvailable;

  set newNotificationAvailable(bool value) {
    _newNotificationAvailable = value;

    notifyListeners();
  }


  AppNotificationViewModel(){
    read();
    loadSoundool();
  }

  Future<void> check() async {
    setStatus(ViewModelStatus.busy);
    try {
      final data = await _webApi.getCurrentActivity();
      // _activeEvent = data[0];
      setStatus(ViewModelStatus.idle);
    } on FetchDataException catch (e) {
      print(e.toString());
      setStatus(ViewModelStatus.error);
    }
  }

  Future<void> initializeMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      print('Requesting Permission');
      settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // Get the token each time the application loads
      final token = await FirebaseMessaging.instance.getToken();

      // Save the initial token to the database
      await saveTokenToDatabase(token);

      // Any time the token refreshes, store this in the database too.
      FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
      registerForegroundListeners();
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> saveTokenToDatabase(String? token) async {
    print('Saving token to database $token');
    try {
      if(token != null) await _webApi.saveUserToken(token);
    } on FetchDataException catch (e) {
      print(e.toString());
    }
  }

  void registerBackgroundMessageHandler(BackgroundMessageHandler handler) {
    FirebaseMessaging.onBackgroundMessage(handler);
  }

  void registerForegroundListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        newNotificationAvailable = true;
        serviceLocator<AppSoundsViewModel>().playNotificationSound();

        print('Message also contained a notification: ${message.notification!.body}');
      }

      if(message.data.isNotEmpty) {
        int notificationType = int.parse(message.data['type']);

        if (notificationType == 1) {
          int type = int.parse(message.data['type']);
          int friendId = int.parse(message.data['friendId']);
          int messageId = int.parse(message.data['messageId']);
          String content = message.data['content'];
          int timestampUtc = int.parse(message.data['timestampUtc']);

          ChatPageItem friendPageItem = _friendsModel.chatPageItemList.where((element) => element.friend.userId == friendId).first;

          if( friendPageItem.timestampUtc < timestampUtc ) {
            friendPageItem.seen = false;
            friendPageItem.timestampUtc = timestampUtc;
            friendPageItem.receivedMessage = ChatMessage(senderId: friendId, receiverId: -1, message: HwMessage(id: messageId, content: content, creatorId: -1), seen: false, timestampUtc: timestampUtc);
            _friendsModel.notifyListeners();

            print('New Update from Partner');
          }

          // ActiveEventResponse? currEvent = _partnerModel.activeEvent;
          // ActiveEvent newEvent = ActiveEvent(userId: 2, description: content == 'null' ? null : content, timestampUtc: int.parse(timestampUtc));
          // if(currEvent != null && currEvent.event.timestampUtc < newEvent.timestampUtc ) {
          //   ActiveEventResponse newActiveEventResponse = ActiveEventResponse(event: newEvent, liked: false);
          //   _partnerModel.activeEvent = newActiveEventResponse;
          //   _partnerModel.notifyListeners();
          //
          //   print('New Update from Partner');
          // }
        } else if (notificationType == 2) {
          String displayName = message.data['displayName'];
          int timestampUtc = int.parse(message.data['timestampUtc']);
          ActiveEventResponse? currEvent = _activeModel.activeEvent;
          if(currEvent != null && currEvent.event.timestampUtc < timestampUtc ) {
            UserProfile user = UserProfile(displayName: displayName);
            _activeModel.activeEvent!.event.likedUserList.add(user);
            _activeModel.notifyListeners();

            print('New like from Partner');
          }
        } else if (notificationType == 3) {
          int type = int.parse(message.data['type']);
          int friendId = int.parse(message.data['friendId']);
          // int messageId = int.parse(message.data['messageId']);
          // String content = message.data['content'];
          // int timestampUtc = int.parse(message.data['timestampUtc']);

          // ChatPageItem? friendPageItem = _friendsModel.chatPageItemList?.where((element) => element.friend.userId == friendId).first;
          //
          // if( friendPageItem != null && friendPageItem.timestampUtc < timestampUtc ) {
          //   friendPageItem.seen = false;
          //   friendPageItem.timestampUtc = timestampUtc;
          //   friendPageItem.receivedMessage = ChatMessage(senderId: friendId, receiverId: -1, message: HwMessage(id: messageId, content: content, creatorId: -1), seen: false, timestampUtc: timestampUtc);
          //   _friendsModel.notifyListeners();
          //
          //   print('New Update from Partner');
          // }

          // ActiveEventResponse? currEvent = _partnerModel.activeEvent;
          // ActiveEvent newEvent = ActiveEvent(userId: 2, description: content == 'null' ? null : content, timestampUtc: int.parse(timestampUtc));
          // if(currEvent != null && currEvent.event.timestampUtc < newEvent.timestampUtc ) {
          //   ActiveEventResponse newActiveEventResponse = ActiveEventResponse(event: newEvent, liked: false);
          //   _partnerModel.activeEvent = newActiveEventResponse;
          //   _partnerModel.notifyListeners();
          //
          //   print('New Update from Partner');
          // }
        }
      }
    });
  }

  read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'new_notifications';
    newNotificationAvailable = prefs.getBool(key) ?? false;
    print('read new_notifications: $newNotificationAvailable');
  }

  save(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'new_notifications';
    prefs.setBool(key, value);
    print('saved new_notifications $value');
    read();
  }

  loadSoundool() async {
    _pool = Soundpool.fromOptions(options: SoundpoolOptions(
        streamType: StreamType.notification
    ));
    soundId = await rootBundle.load('assets/notification.wav').then((ByteData soundData) {
      return _pool!.load(soundData);
    });
  }
}
