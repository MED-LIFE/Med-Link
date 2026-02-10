import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<int> getUnreadCountStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .doc(user.uid)
        .collection('items')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Simulator: This method simulates a "Push" being sent by the server/admin
  // In production, this would be a Cloud Function or Admin Panel action.
  Future<void> simulateNotification(String userId, String title, String body, String type) async {
    await _firestore
        .collection('notifications')
        .doc(userId)
        .collection('items')
        .add({
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('notifications')
        .doc(user.uid)
        .collection('items')
        .where('read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}

// Widget to display the notification badge
class NotificationBadge extends StatelessWidget {
  final Widget child;
  const NotificationBadge({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Requires a Provider or simple StreamBuilder usage in parent
    final service = NotificationService();
    return StreamBuilder<int>(
      stream: service.getUnreadCountStream(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (count > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
