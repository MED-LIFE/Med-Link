import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '585362276918-vttr6vpko8vo2pgufo32c32t3n1vasnv.apps.googleusercontent.com'
        : null,
  );

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print("Anonymous auth failed: $e");
      return null;
    }
  }

  // Tries to sign in. If user doesn't exist, creates it.
  Future<User?> signInDevUser(String email, String password) async {
    try {
      // 1. Try Login
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // 2. Create if not exists
        try {
          final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
          // Optional: Set custom claims or create user document here if needed
          return credential.user;
        } catch (createError) {
          print("Error creating dev user: $createError");
          return null;
        }
      } else if (e.code == 'wrong-password') {
        print("Wrong password for $email. Creating a fresh dev account to ensure access...");
        // Fallback: Create a new random user for this role to guarantee entry
        final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
        final prefix = email.split('@')[0];
        final newEmail = "${prefix}_$timestamp@zanoo.com";
        return signInDevUser(newEmail, "Zanoo123!"); // Stronger password
      } else {
        print("Login error: ${e.code}");
        // Failover to Anonymous for DEV simplicity
        print("Falling back to Anonymous Auth due to error: ${e.code}");
        try {
           return await signInAnonymously(); // Ensure we await and bubble up error if this fails
        } catch (_) {
           throw e; // Use the original error if fallback fails
        }
      }
    } catch (e) {
      print("Unexpected auth error: $e");
      // Ultimate Failover
      return signInAnonymously();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
