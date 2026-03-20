import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

// Background message handler (needs to be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Configure background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
          // Note: In a real app, you might want to show a local notification here
          // using flutter_local_notifications if you want a heads-up display
          // while the app is actively open. FCM handles background notifications automatically.
        }
      });

      // 4. Get FCM Token & Send to Server
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("FCM Token: $token");
        await _sendTokenToServer(token);
      }

      // 5. Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen(_sendTokenToServer);
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final authToken = await _storage.read(key: AppConstants.tokenKey);
      if (authToken == null) return; // User not logged in, ignore
      
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.fcmRegisterEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print("✅ FCM Token registered successfully on server");
      } else {
        print("❌ Failed to register FCM token: ${response.body}");
      }
    } catch (e) {
      print("❌ Error registering token: $e");
    }
  }
}
