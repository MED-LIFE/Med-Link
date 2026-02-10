import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'medico/home_medico_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
    with TickerProviderStateMixin {
  final _authService = AuthService();
  bool _loading = false;
  String? _error;
  
  // Biometrics
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Iniciar animaciones escalonadas
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    HapticFeedback.lightImpact();
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
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      setState(() {
        _error = "Error al iniciar sesión: $e";
      });
      HapticFeedback.lightImpact();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleDevLogin(String email, String role, Function(BuildContext) onNavigate, {String password = 'Zanoo123!'}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      // Use Real Auth (Create or Login)
      final user = await _authService.signInDevUser(email, password);
      
      if (mounted) {
         setState(() => _loading = false);
         if (user != null) {
           onNavigate(context);
         } else {
           setState(() => _error = "No se pudo iniciar sesión. Verifique consola.");
         }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = "Error: $e"; // Show the specific error from AuthService
        });
      }
    }
  }

  Future<void> _checkBiometrics() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheck && isDeviceSupported;
      });
    } catch (e) {
      print("Error checking biometrics: $e");
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Escanea tu huella para ingresar a Zanoo',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print("Biometric auth error: $e");
      setState(() => _error = "Error biométrico: $e");
      return;
    }

    if (authenticated) {
      // Auto-login as Patient (Default for biometric convenience)
      _handleDevLogin('paciente@zanoo.com', 'paciente', (ctx) => Navigator.pushReplacementNamed(ctx, '/home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF083866),
              Color(0xFF2376F6),
              Color(0xFF73BFFF),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Patrones de fondo decorativos
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            
            // Contenido principal
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 80 : 32,
                    vertical: 20,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Logo principal con mejor diseño
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  "assets/images/logo_zanoo.png",
                                  height: isTablet ? 150 : 120,
                                  width: isTablet ? 150 : 120,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => 
                                    Container(
                                      height: isTablet ? 150 : 120,
                                      width: isTablet ? 150 : 120,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF2376F6), Color(0xFF73BFFF)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.medical_services_rounded,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Card principal de bienvenida
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(maxWidth: isTablet ? 380 : 320),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Text(
                                    "¡Hola! 👋",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0D1C2E),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  Text(
                                    "Ingresa para gestionar tu salud",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Mensaje de error
                                  if (_error != null)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      margin: const EdgeInsets.only(bottom: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  
                                    // 1. Google Login (Primary)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: (_loading) ? () {} : _signIn, // Disabled if loading
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black87,
                                          elevation: 4,
                                          shadowColor: Colors.black.withOpacity(0.1),
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                            side: BorderSide(color: Colors.grey[200]!),
                                          ),
                                        ),
                                        child: _loading
                                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.network(
                                                    "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png",
                                                    height: 22,
                                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.g_mobiledata, size: 28, color: Colors.blue),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Text("Continuar con Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 16),

                                    // 2. Email Login (Secondary) -> Ahora muestra diálogo real
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => _showProfessionalLoginDialog(context, 'paciente', 'paciente@zanoo.com'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE3F2FD),
                                          foregroundColor: const Color(0xFF1565C0),
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: const Text("Ingresar con Email", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                      ),
                                    ),

                                    const SizedBox(height: 32),
                                    Row(
                                      children: [
                                        Expanded(child: Divider(color: Colors.grey[300])),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text("Acceso Profesional", style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                                        ),
                                        Expanded(child: Divider(color: Colors.grey[300])),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    
                                    // ACCESO PROFESIONAL (Fixed Buttons)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ProLoginButton(
                                            label: "Médico",
                                            icon: Icons.medical_services_rounded,
                                            color: const Color(0xFF2376F6), // Brand Blue
                                            onTap: () => _showProfessionalLoginDialog(context, 'medico', 'medico@zanoo.com'),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _ProLoginButton(
                                            label: "Admin",
                                            icon: Icons.admin_panel_settings_rounded,
                                            color: const Color(0xFF193A72), // Dark Blue
                                            onTap: () => _showProfessionalLoginDialog(context, 'admin', 'admin@zanoo.com'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          

                           
                           // Footer
                           Padding(
                             padding: const EdgeInsets.only(bottom: 20),
                             child: Column(
                               children: [
                                  Text("v1.0.6 - Zanoo Platinum", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock_rounded, size: 14, color: Colors.white.withOpacity(0.5)),
                                      const SizedBox(width: 6),
                                      Text("Conexión Segura 256-bit", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                                    ],
                                  ),
                               ],
                             ),
                           ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfessionalLoginDialog(BuildContext context, String role, String defaultEmail) {
    final emailCtrl = TextEditingController(text: defaultEmail);
    final passCtrl = TextEditingController(text: "Zanoo123!");
    String title = role == 'paciente' ? "Ingresar con Email" : "Acceso ${role.toUpperCase()}";
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: "Email", 
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              decoration: InputDecoration(
                labelText: "Contraseña", 
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              obscureText: true,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2376F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleDevLogin(emailCtrl.text, role, (c) {
                 if (role == 'medico') {
                   Navigator.pushReplacement(c, MaterialPageRoute(builder: (_) => const HomeMedicoScreen()));
                 } else if (role == 'admin') {
                   Navigator.pushReplacementNamed(c, '/home_admin');
                 } else {
                   Navigator.pushReplacementNamed(c, '/home'); // Patient
                 }
              }, password: passCtrl.text);
            },
            child: const Text("Ingresar"),
          ),
        ],
      ),
    );
  }
}

class _ProLoginButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ProLoginButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ]
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }
}