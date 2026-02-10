import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ayuda_screen.dart';
import 'screens/mi_perfil_screen.dart';

import 'screens/medico/patient_search_screen.dart';
import 'screens/medico/agenda_medico_screen.dart';
import 'screens/admin/home_admin_screen.dart';
import 'screens/admin/admin_professionals_screen.dart';
import 'screens/admin/admin_reports_screen.dart';
import 'screens/admin/admin_turnos_screen.dart';
import 'screens/common/patient_intake_wizard_screen.dart';

import 'screens/admin/admin_patient_import_screen.dart';
import 'screens/common/patient_intake_options_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SYSTEM UI: Transparent Status Bar for "Edge-to-Edge" look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Default to dark, overridden in specific screens
  ));

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // FORCE LOCAL PERSISTENCE (Keep user logged in)
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    
    await initializeDateFormatting('es_ES', null);
  } catch (e) {
    print("Error en inicialización: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zanoo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF083866)),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFEF9F1),
      ),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: child,
          ),
        );
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/ayuda': (_) => const AyudaScreen(),
        '/medico/buscar-paciente': (_) => const PatientSearchScreen(),
        '/home_admin': (_) => const HomeAdminScreen(),
        '/medico/agenda': (_) => const AgendaMedicoScreen(),
        '/admin/profesionales': (_) => const AdminProfessionalsScreen(),
        '/admin/reportes': (_) => const AdminReportsScreen(),
        '/admin/turnos': (context) => const AdminTurnosScreen(),
        '/mi_perfil': (_) => const MiPerfilScreen(),
        '/patient/new': (_) => const PatientIntakeOptionsScreen(),
        '/admin/patient-import': (_) => const AdminPatientImportScreen(),
      },
    );
  }
}