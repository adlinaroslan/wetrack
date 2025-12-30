import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Background message handler must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  try {
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        '';
    final type = message.data['type'] ?? 'info';
    final relatedId = message.data['relatedId'] ?? message.data['requestId'];

    final Map<String, dynamic> doc = {
      'title': title,
      'message': body,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    if (message.data.containsKey('toUserId')) {
      doc['userId'] = message.data['toUserId'];
    } else if (message.data.containsKey('userId')) {
      doc['userId'] = message.data['userId'];
    } else if (message.data.containsKey('role')) {
      doc['role'] = message.data['role'];
    }

    if (relatedId != null) doc['relatedId'] = relatedId;

    await FirebaseFirestore.instance.collection('notifications').add(doc);
  } catch (e) {
    // ignore
  }
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Request permissions (especially for iOS and Android 13+)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Setup Local Notifications (Needed for pop-ups while app is open)
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // 3. Listen for foreground messages and persist them to Firestore
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _showPopup(notification);
      }

      // Persist incoming message to Firestore so in-app notification pages show it
      try {
        final title = notification?.title ?? message.data['title'] ?? '';
        final body = notification?.body ??
            message.data['body'] ??
            message.data['message'] ??
            '';
        final type = message.data['type'] ?? 'info';
        final relatedId =
            message.data['relatedId'] ?? message.data['requestId'];

        final Map<String, dynamic> doc = {
          'title': title,
          'message': body,
          'type': type,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        };

        // Support targeting by userId or by role
        if (message.data.containsKey('toUserId')) {
          doc['userId'] = message.data['toUserId'];
        } else if (message.data.containsKey('userId')) {
          doc['userId'] = message.data['userId'];
        } else if (message.data.containsKey('role')) {
          doc['role'] = message.data['role'];
        }

        if (relatedId != null) doc['relatedId'] = relatedId;

        await FirebaseFirestore.instance.collection('notifications').add(doc);
      } catch (e) {
        // Avoid crashing the app on notification save failure
      }
    });

    // 4. Register background handler so messages received while app is terminated/background are also saved
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static void _showPopup(RemoteNotification notification) {
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel', // channel ID
          'High Importance Notifications', // channel name
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
