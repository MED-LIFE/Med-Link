import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/mi_perfil_screen.dart';
import '../../screens/historia_clinica_screen.dart';
import '../../screens/sacar_turno_screen.dart';
import '../../screens/estudios_screen.dart';


enum UserRole { patient, doctor, admin }

class MainDrawer extends StatelessWidget {
  final VoidCallback? onLogout;
  final UserRole role;

  const MainDrawer({
    Key? key, 
    this.onLogout,
    this.role = UserRole.patient, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
            // Header Refined (Premium Gradient)
            Container(
              height: 160, 
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF083866), Color(0xFF2376F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: user?.photoURL != null 
                         ? DecorationImage(image: NetworkImage(user!.photoURL!), fit: BoxFit.cover)
                         : null,
                    ),
                     child: user?.photoURL == null 
                         ? const Icon(Icons.person, color: Colors.white) 
                         : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hola, ${user?.displayName?.split(' ').first ?? 'Usuario'}",
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "Panel de Acceso",
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                children: _buildMenuOptions(context),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  List<Widget> _buildMenuOptions(BuildContext context) {
    if (role == UserRole.admin) {
       return [
        DrawerItem(
          icon: Icons.grid_view_rounded, 
          title: 'Panel Admin',
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context); 
            Navigator.of(context).popUntil((route) => route.settings.name == '/home_admin');
          },
        ),
        DrawerItem(
          icon: Icons.medical_services_rounded, 
          title: 'Profesionales',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            Navigator.pushNamed(context, '/admin/profesionales');
          },
        ),
        DrawerItem(
          icon: Icons.calendar_today_rounded, 
          title: 'Gestión de Turnos',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            Navigator.pushNamed(context, '/admin/turnos');
          },
        ),
        DrawerItem(
          icon: Icons.people_alt_rounded,
          title: 'Pacientes',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            Navigator.pushNamed(context, '/medico/buscar-paciente');
          },
        ),
         DrawerItem(
          icon: Icons.bar_chart_rounded, 
          title: 'Reportes',
          isPremium: true,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            _showPremiumDialog(context);
          },
        ),
        
        const SizedBox(height: 12),
        const Divider(height: 1, indent: 16, endIndent: 16, thickness: 0.5),
        const SizedBox(height: 12),

        DrawerItem(
          icon: Icons.person_outline_rounded,
          title: 'Mi Perfil',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            Navigator.pushNamed(context, '/mi_perfil');
          },
        ),
        DrawerItem(
          icon: Icons.settings_outlined,
          title: 'Sistema',
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Configuración del Sistema"),
              behavior: SnackBarBehavior.floating,
              duration: Duration(milliseconds: 1500),
            ));
          },
        ),
        const SizedBox(height: 16),
        DrawerItem(
          icon: Icons.logout_rounded,
          title: 'Cerrar Sesión',
          isDestructive: true,
          onTap: () async {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            if (onLogout != null) onLogout!();
          },
        ),
       ];
    }
    
    if (role == UserRole.doctor) {
      return [
        DrawerItem(
          icon: Icons.dashboard_rounded, 
          title: 'Panel Médico', 
          onTap: () => Navigator.pop(context),
        ),
        DrawerItem(
          icon: Icons.calendar_month_rounded, 
          title: 'Mi Agenda', 
          onTap: () {
             Navigator.pop(context);
             Navigator.pushNamed(context, '/medico/agenda');
          },
        ),
        DrawerItem(
          icon: Icons.people_alt_rounded, 
          title: 'Pacientes', 
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/medico/buscar-paciente');
          },
        ),
        DrawerItem(
          icon: Icons.bar_chart_rounded, 
          title: 'Reportes', 
          isPremium: true,
          onTap: () {
            Navigator.pop(context);
            _showPremiumDialog(context);
          }
        ),
        
        const SizedBox(height: 12),
        const Divider(height: 1, indent: 16, endIndent: 16, thickness: 0.5),
        const SizedBox(height: 12),

        DrawerItem(
          icon: Icons.person_outline_rounded,
          title: 'Mi Perfil',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/mi_perfil');
          },
        ),
        DrawerItem(
          icon: Icons.settings_outlined,
          title: 'Sistema',
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Configuración del Sistema")));
          },
        ),
         DrawerItem(
          icon: Icons.logout_rounded,
          title: 'Cerrar Sesión',
          isDestructive: true,
          onTap: () async {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            if (onLogout != null) onLogout!();
          },
        ),
      ];
    }

    // LISTA DE PACIENTE (DEFAULT)
    return [
       DrawerItem(
         icon: Icons.home_rounded, 
         title: 'Inicio', 
         onTap: () {
           Navigator.pop(context);
         }
       ),
       DrawerItem(
         icon: Icons.assignment_ind_rounded, 
         title: 'Mi Historia Clínica', 
         onTap: () {
           Navigator.pop(context);
           Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoriaClinicaScreen()));
         }
       ),
       DrawerItem(
         icon: Icons.calendar_month_rounded, 
         title: 'Mis Turnos', 
         onTap: () {
           Navigator.pop(context);
           Navigator.push(context, MaterialPageRoute(builder: (_) => const SacarTurnoScreen()));
         }
       ),
       DrawerItem(
         icon: Icons.science_rounded, 
         title: 'Mis Estudios', 
         onTap: () {
           Navigator.pop(context);
           Navigator.push(context, MaterialPageRoute(builder: (_) => const EstudiosScreen()));
         }
       ),
       const SizedBox(height: 12),
       const Divider(height: 1, indent: 16, endIndent: 16, thickness: 0.5),
       const SizedBox(height: 12),
       DrawerItem(
         icon: Icons.person_outline_rounded, 
         title: 'Mi Perfil', 
         onTap: () {
           Navigator.pop(context);
           Navigator.push(context, MaterialPageRoute(builder: (_) => const MiPerfilScreen()));
         }
       ),
       DrawerItem(
         icon: Icons.logout_rounded, 
         title: 'Cerrar Sesión', 
         isDestructive: true, 
         onTap: () async {
           Navigator.pop(context);
           // VERIFIED FIX: TRIGGERS CALLBACK
           if (onLogout != null) onLogout!();
         }
       ),
    ];
  }


  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: const Color(0xFFFFF4DE),
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(Icons.star_rounded, color: Color(0xFFDAA520), size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Función Premium",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0D1C2E)),
              ),
              const SizedBox(height: 8),
              const Text(
                "El módulo de Reportes Avanzados está disponible exclusivamente para planes Zanoo Platinum.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2376F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Entendido"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isPremium;

  const DrawerItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.isPremium = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFFF3B30) : const Color(0xFF083866); 
    final iconColor = isDestructive ? const Color(0xFFFF3B30) : const Color(0xFF2376F6); 
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: iconColor.withOpacity(0.1),
        highlightColor: iconColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive ? const Color(0xFFFFEBEE) : const Color(0xFFF0F5FF), 
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600, 
                        color: color,
                        letterSpacing: -0.3
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, color: Color(0xFFDAA520), size: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
