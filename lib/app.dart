import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:hamuwemu/business_logic/view_model/app_notification_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/current_activity_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/friends_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/partner_active_event_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/suggestions_view_model.dart';
import 'package:hamuwemu/business_logic/view_model/user_view_model.dart';
import 'package:hamuwemu/service/analytics_service.dart';
import 'package:hamuwemu/service/service_locator.dart';
import 'package:hamuwemu/ui/page/add_friends_page.dart';
import 'package:hamuwemu/ui/page/home_page.dart';
import 'package:hamuwemu/ui/page/phone_sign_in_page.dart';
import 'package:hamuwemu/ui/page/sign_in_page.dart';
import 'package:hamuwemu/ui/page/updates_page.dart';
import 'package:hamuwemu/ui/widget/error_message.dart';
import 'package:hamuwemu/ui/widget/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'business_logic/view_model/abstract_view_model.dart';
import 'business_logic/view_model/active_event_view_model.dart';
import 'business_logic/view_model/current_status_view_model.dart';

class HamuWemuApp extends StatelessWidget {
  HamuWemuApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This app is designed only to work vertically, so we limit
    // orientations to portrait up and down.
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserViewModel>.value(value: serviceLocator<UserViewModel>(),),
        ChangeNotifierProvider<CurrentStatusViewModel>(create: (_) => CurrentStatusViewModel(),),
        ChangeNotifierProvider<CurrentActivityViewModel>(create: (_) => CurrentActivityViewModel(),),
        ChangeNotifierProvider<AppNotificationViewModel>(create: (_) => AppNotificationViewModel(),),
        ChangeNotifierProvider<SuggestionsViewModel>.value(value: serviceLocator<SuggestionsViewModel>(),),
        ChangeNotifierProvider<FriendsViewModel>.value(value: serviceLocator<FriendsViewModel>(),),
        ChangeNotifierProvider<ActiveEventViewModel>.value(value: serviceLocator<ActiveEventViewModel>(),),
        ChangeNotifierProvider<PartnerActiveEventViewModel>.value(value: serviceLocator<PartnerActiveEventViewModel>(),),
      ],
      child: MaterialApp(
        title: 'HamuWemu',
        home: Consumer<UserViewModel>(
          builder: (context, model, child) {
            if( !model.initialized ) {
              return SplashScreen();
            } else if ( !model.signedIn ) {
              return SignInPage();
            } else if ( model.status == ViewModelStatus.error ) {
              return ErrorMessage(message: 'Error');
            } else {
              return HomePage();
            }
          },
        ),
        navigatorObservers: [
          serviceLocator<AnalyticsService>().getAnalyticsObserver(),
        ],
      ),
    );
  }
}
