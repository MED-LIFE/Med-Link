import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/medico/home_medico_screen.dart';
import '../screens/admin/home_admin_screen.dart';
import '../screens/intro_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;
  String? _role;
  bool _isLoading = true;
  bool _showLogin = false;

  @override
  void initState() {
    super.initState();
    // Listen to Auth Changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        if (mounted) {
           setState(() {
             _user = null;
             _role = null;
             _isLoading = false;
             // Reset Intro state on Logout to show it again
             _showLogin = false; 
           });
        }
      } else {
        _fetchUserRole(user);
      }
    });
  }

  Future<void> _fetchUserRole(User user) async {
    try {
      // 0. PRIORITY OVERRIDE for Dev/Demo Accounts
      // This ensures 'admin@zanoo.com' ALWAYS gets admin role, regardless of what Firestore says.
      if (user.email != null) {
         final emailLower = user.email!.toLowerCase();
         if (emailLower.contains("admin")) {
           if (mounted) setState(() { _user = user; _role = 'admin'; _isLoading = false; });
           return;
         }
         if (emailLower.contains("medico")) {
           if (mounted) setState(() { _user = user; _role = 'medico'; _isLoading = false; });
           return;
         }
      }

      // 1. Check 'users' collection (Patients/Admins/Medicos might all be here with a 'role' field)
      //    OR check specific collections if your DB is structured that way.
      //    Assuming a unified 'users' collection or checking 'role' field.
      
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      
      String? role = 'paciente'; // Default
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('role')) {
          role = data['role'];
        } else if (data.containsKey('rol')) {
           role = data['rol'];
        }
      } else {
        // If doc doesn't exist, we might create it or assume patient.
        // For existing specific emails (dev), we can hardcode fallback if DB is empty.
        if (user.email != null) {
           if (user.email!.contains("medico")) role = 'medico';
           if (user.email!.contains("admin")) role = 'admin';
        }
      }

      if (mounted) {
        setState(() {
          _user = user;
          _role = role;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching role: $e");
      // Fallback to patient on error to allow entry
      if (mounted) {
        setState(() {
          _user = user;
          _role = 'paciente';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      if (!_showLogin) {
        return IntroScreen(onFinish: () {
          setState(() {
            _showLogin = true;
          });
        });
      }
      return const LoginScreen();
    }

    // Routing based on Role
    switch (_role) {
      case 'medico':
        return const HomeMedicoScreen();
      case 'admin':
         // Ensure HomeAdminScreen is imported or use correct widget name
        return const HomeAdminScreen(); 
      case 'paciente':
      default:
        return const HomeScreen();
    }
  }
}
