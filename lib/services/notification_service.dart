import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final _supabase = Supabase.instance.client;

  /// Initialize everything
  static Future<void> init() async {
    await _requestPermission();
    await _setupHandlers();
    await _saveFCMToken();
  }

  /// Request permission (important for Android 13+ & iOS)
  static Future<void> _requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permission: ${settings.authorizationStatus}');
  }

  /// Handle foreground + background messages
  static Future<void> _setupHandlers() async {
    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message: ${message.notification?.title}');
    });

    // When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification clicked');
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  /// Save token to Supabase
  static Future<void> _saveFCMToken() async {
    final token = await _fcm.getToken();
    print('FCM Token: $token');

    final user = _supabase.auth.currentUser;
    if (user != null && token != null) {
      await _supabase.from('profiles').update({
        'fcm_token': token,
      }).eq('id', user.id);
    }
  }
}

/// Background handler MUST be top-level
Future<void> _backgroundHandler(RemoteMessage message) async {
  print('📩 Background message: ${message.notification?.title}');
}