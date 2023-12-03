import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:hamuwemu/business_logic/view_model/active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/app_notification_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/current_activity_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hamuwemu/business_logic/view_model/current_status_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/friends_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/partner_active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/suggestions_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/ui/page/friends_page.dart';
import 'package:hamuwemu/ui/page/history_page.dart';
import 'package:hamuwemu/ui/page/status_page.dart';
import 'package:hamuwemu/ui/page/updates_page.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';

import 'notifications_page.dart';
import 'now_page.dart';
import 'pops_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CupertinoTabController _controller = CupertinoTabController();

  late final StreamSubscription<FGBGType> subscription;
  late final AppNotificationViewModel _notificationModel;
  late final FriendsViewModel _friendsModel;

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == '1') {
      serviceLocator<FriendsViewModel>().load();
      _controller.index = 1;
    }
  }

  @override
  void initState() {
    super.initState();
    final _userModel = Provider.of<UserViewModel>(context, listen: false);
    // final _activeEventModel = Provider.of<ActiveEventViewModel>(context, listen: false);
    // final _partnerActiveEventModel = Provider.of<PartnerActiveEventViewModel>(context, listen: false);
    final _currentStatusModel = Provider.of<CurrentStatusViewModel>(context, listen: false);
    _friendsModel = Provider.of<FriendsViewModel>(context, listen: false);
    final _suggestionsModel = Provider.of<SuggestionsViewModel>(context, listen: false);
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _currentStatusModel.loadEvent());
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _friendsModel.load());
    WidgetsBinding.instance!
        .addPostFrameCallback((_) => _suggestionsModel.load());

    // final _activityModel = Provider.of<CurrentActivityViewModel>(context, listen: false);
    _notificationModel = Provider.of<AppNotificationViewModel>(context, listen: false);
    _notificationModel.initializeMessaging();
    // WidgetsBinding.instance!
    //     .addPostFrameCallback((_) => _activityModel.load());
    subscription = FGBGEvents.stream.listen((event) {
      print(event); // FGBGType.foreground or FGBGType.background
      if(event == FGBGType.foreground ) {
        _notificationModel.read();
        serviceLocator<SuggestionsViewModel>().load();
      }

      // _activeEventModel.loadEvent();
      // _partnerActiveEventModel.loadEvent();
    });

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }


  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _controller,
      tabBar: CupertinoTabBar(
        activeColor: Colors.red,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor.withOpacity(1.0),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(CupertinoIcons.conversation_bubble),
          // ),
          BottomNavigationBarItem(
            icon: Consumer<AppNotificationViewModel>(
              builder: (context, model, child) {
                if(model.newNotificationAvailable) {
                  return Badge(
                    shape: BadgeShape.circle,
                    borderRadius: BorderRadius.circular(100),
                    child: Icon(Icons.group_work),
                    badgeContent: Container(
                      height: 5,
                      width: 5,
                      // decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                    position: BadgePosition.topEnd(top: 0, end: 0),
                  );
                } else {
                  return Icon(Icons.group_work);
                }
              },
            ),
          ),
          // BottomNavigationBarItem(
          //   icon: Consumer<AppNotificationViewModel>(
          //     builder: (context, model, child) {
          //       if(model.newNotificationAvailable) {
          //         return Badge(
          //           shape: BadgeShape.circle,
          //           borderRadius: BorderRadius.circular(100),
          //           child: Icon(CupertinoIcons.bell),
          //           badgeContent: Container(
          //             height: 5,
          //             width: 5,
          //             // decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          //           ),
          //           position: BadgePosition.topEnd(top: 0, end: 0),
          //         );
          //       } else {
          //         return Icon(CupertinoIcons.bell);
          //       }
          //     },
          //   ),
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        late CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: StatusPage(),
              );
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              WidgetsBinding.instance!
                  .addPostFrameCallback((_) => _notificationModel.save(false));
              WidgetsBinding.instance!
                  .addPostFrameCallback((_) => _friendsModel.setSeen());
              return CupertinoPageScaffold(
                child: FriendsPage(),
              );
            });
            serviceLocator<AnalyticsService>().logCurrentScreen(screenName: 'Friends Page');
            break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: SettingsPage(),
              );
            });
            break;
          // case 3:
          //   returnValue = CupertinoTabView(builder: (context) {
          //   WidgetsBinding.instance!
          //       .addPostFrameCallback((_) => _notificationModel.save(false));
          //     return CupertinoPageScaffold(
          //       child: SettingsPage(),
          //     );
          //   });
          //   break;
        }
        return returnValue;
      },
    );
  }
}

