import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuditService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Log critical actions (e.g., viewing medical records)
  Future<void> logAccess({
    required String action, 
    required String details, 
    String? resourceId
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('audit_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'actor_uid': user.uid,
        'actor_email': user.email ?? 'unknown',
        'action': action,
        'details': details,
        'resource_id': resourceId,
        'platform': kIsWeb ? 'web' : 'mobile',
        'app_version': '1.1.1',
      });
      print("🔐 Audit Log: $action - $details");
    } catch (e) {
      print("⚠️ Failed to write audit log: $e");
      // Fail silently in UI, but this is critical for compliance
    }
  }
}
