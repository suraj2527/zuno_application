import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:developer';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _initLocalNotifications();
    await getToken();

    // Start listening for token refreshes and re-subscribe to default topics
    setupTokenRefresh(resubscribeTopics: ['all_users']);

    // If user is already logged in, ensure they are subscribed to default topics
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('[FCM] User already logged in, ensuring subscription to "all_users"');
      subscribeToTopic('all_users');
    }

    _listenToMessages();
    return this;
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('[FCM] User notification permission status: ${settings.authorizationStatus}');
  }

  Future<String?> getToken() async {
    try {
      String? token = await _fcm.getToken();
      print("\n========================================");
      print("FCM TOKEN: $token");
      print("========================================\n");
      return token;
    } catch (e) {
      print("[FCM] Error getting FCM token: $e");
      return null;
    }
  }

  // ─── FCM Topic Helpers ─────────────────────────────────────────────────────

  /// Subscribe the current device to an FCM topic.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      print('[FCM] ✅ Successfully subscribed to topic: $topic');
    } catch (e) {
      print('[FCM] ❌ Failed to subscribe to topic "$topic": $e');
    }
  }

  /// Unsubscribe the current device from an FCM topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      print('[FCM] ✅ Successfully unsubscribed from topic: $topic');
    } catch (e) {
      print('[FCM] ❌ Failed to unsubscribe from topic "$topic": $e');
    }
  }

  /// Listen for token refreshes and re-subscribe to the given topics.
  void setupTokenRefresh({List<String> resubscribeTopics = const []}) {
    _fcm.onTokenRefresh.listen((newToken) async {
      print('[FCM] 🔄 Token refreshed: $newToken');
      for (final topic in resubscribeTopics) {
        await subscribeToTopic(topic);
      }
    });
  }

  // ─── Local Notifications ───────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("Local notification clicked: ${response.payload}");
        // Handle local notification click
      },
    );
    
    // Create android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', 
      'High Importance Notifications', 
      description: 'This channel is used for important notifications.', 
      importance: Importance.max,
    );
    
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _listenToMessages() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCM] 📩 Received a foreground message: ${message.messageId}');
      
      RemoteNotification? notification = message.notification;
      
      print('[FCM] Notification Title: ${notification?.title}');
      print('[FCM] Notification Body: ${notification?.body}');
      print('[FCM] Data: ${message.data}');

      if (notification != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    // App opened from background via notification click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[FCM] 🖱️ App opened from notification: ${message.messageId}');
    });
    
    // Terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('[FCM] 🚀 App opened from terminated state via notification: ${message.messageId}');
      }
    });
  }
}
