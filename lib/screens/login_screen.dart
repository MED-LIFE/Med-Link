import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        setState(() {
          _error = "No se pudo iniciar sesión.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error al iniciar sesión: $e";
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/logo_hospi.jpg", height: 98),
              const SizedBox(height: 24),
              const Text(
                "Bienvenido a la App ROFFO",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF083866),
                ),
              ),
              const SizedBox(height: 44),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              _loading
                  ? const CircularProgressIndicator(color: Color(0xFF083866))
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 2,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF083866), width: 1.2),
                        ),
                      ),
                      icon: Image.asset('assets/google_logo.png', height: 26, width: 26),
                      label: const Text(
                        "Iniciar sesión con Google",
                        style: TextStyle(
                          color: Color(0xFF083866),
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5,
                        ),
                      ),
                      onPressed: _signIn,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
