import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final _db = FirebaseFirestore.instance;
  static final _fcm = FirebaseMessaging.instance;

  static Future<void> initialize(
      FlutterLocalNotificationsPlugin plugin) async {
    await _fcm.requestPermission();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
        android: androidSettings, iOS: iosSettings);

    await plugin.initialize(settings);

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        _showLocalNotification(plugin, message);
      }
    });
  }

  static Future<void> _showLocalNotification(
      FlutterLocalNotificationsPlugin plugin, RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'logitrack_channel',
      'LogiTrack Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await plugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  static Future<String?> getToken() => _fcm.getToken();

  static Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? refId,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'refId': refId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => NotificationModel.fromDoc(d)).toList());
  }

  static Future<void> markAsRead(String id) =>
      _db.collection('notifications').doc(id).update({'isRead': true});

  static Future<void> markAllAsRead(String userId) async {
    final snap = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}