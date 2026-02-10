import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
       // 2. Get Token
       String? token = await _fcm.getToken();
       print("FCM Token: $token");
       _saveTokenToDatabase(token);

       // 3. Foreground Messages
       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
         print('Got a message whilst in the foreground!');
         print('Message data: ${message.data}');

         if (message.notification != null) {
           print('Message also contained a notification: ${message.notification}');
           // Show In-App Notification (Snackbar)
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Row(
                 children: [
                   const Icon(Icons.notifications_active, color: Colors.white),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(message.notification?.title ?? 'Notificación', style: const TextStyle(fontWeight: FontWeight.bold)),
                         Text(message.notification?.body ?? '', style: const TextStyle(fontSize: 12)),
                       ],
                     ),
                   ),
                 ],
               ),
               backgroundColor: const Color(0xFF083866),
               behavior: SnackBarBehavior.floating,
               margin: const EdgeInsets.all(16),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               duration: const Duration(seconds: 4),
             )
           );
         }
       });
    }
  }

  Future<void> _saveTokenToDatabase(String? token) async {
    if (token == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
}
