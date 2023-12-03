import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:hamuwemu/business_logic/model/hw_message.dart';
import 'package:hamuwemu/business_logic/model/user_profile.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future setUserProperties({required String userId, String? userGroup}) async {
    await _analytics.setUserId(userId);
    // Set the user_role
    await _analytics.setUserProperty(name: 'user_group', value: userGroup);
  }

  Future logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future logAddSuggestedStatus({required HwMessage message}) async {
    await _analytics.logEvent(
      name: 'add_suggested_status',
      parameters: {
        'hw_message_content': message.content,
        'hw_message_id': message.id,
        'creator_id': message.creatorId,
      },
    );
  }

  // add_friend_status
  Future logAddFriendStatus({required HwMessage message}) async {
    await _analytics.logEvent(
      name: 'add_friend_status',
      parameters: {
        'hw_message_content': message.content,
        'hw_message_id': message.id,
        'creator_id': message.creatorId,
      },
    );
  }

  // Add new status
  Future logAddNewStatus({required HwMessage message}) async {
    await _analytics.logEvent(
      name: 'add_new_status',
      parameters: {
        'hw_message_content': message.content,
      },
    );
  }

  Future logCurrentScreen({required String screenName}) async {
    await _analytics.setCurrentScreen(
      screenName: screenName,
    );
  }

  Future logRemoveCurrentStatus({required HwMessage message}) async {
    await _analytics.logEvent(
      name: 'remove_current_status',
      parameters: {
        'hw_message_id': message.id,
        'hw_message_content': message.content,
      },
    );
  }

  Future logLogout({required UserProfile user}) async {
    await _analytics.logEvent(
      name: 'log_out',
      parameters: {
        'hw_user_id': user.userId,
      },
    );
  }

  Future logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future logStartPhoneSignUpFlow() async {
    await _analytics.logEvent(
      name: 'start_phone_sign_up_flow',
    );
  }

  Future logEndPhoneSignUpFlow({required String currentPage}) async {
    await _analytics.logEvent(
      name: 'end_phone_sign_up_flow',
      parameters: {
        'end_point': currentPage,
      },
    );
  }

  Future logExitAddFriends() async {
    await _analytics.logEvent(
      name: 'exit_add_friends',
    );
  }

  Future logAddFriends({required int count}) async {
    await _analytics.logEvent(
      name: 'add_friends',
      parameters: {
        'count': count,
      },
    );
  }

  Future logSendSuggestedToAll({required HwMessage message}) async {
    await _analytics.logEvent(
      name: 'send_suggested_status_all',
      parameters: {
        'hw_message_content': message.content,
      },
    );
  }

}