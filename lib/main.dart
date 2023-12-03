import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'service/service_locator.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  final prefs = await SharedPreferences.getInstance();
  final key = 'new_notifications';
  prefs.setBool(key, true);

  print("Handling a background message: ${message.messageId}");
}


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(HamuWemuApp());
}