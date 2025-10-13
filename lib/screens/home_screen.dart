import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importá las pantallas (ajustá el nombre y path según tu proyecto)
import 'package:app_roffo/screens/historia_clinica_screen.dart';
import 'package:app_roffo/screens/completar_perfil_screen.dart';   // Para completar perfil / editar perfil
import 'package:app_roffo/screens/estudios_screen.dart';           // Ver estudios
import 'package:app_roffo/screens/mi_perfil_screen.dart'; // Editar perfil actualizado
import 'package:app_roffo/screens/sacar_turno_screen.dart';        // Sacar turno


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_DashboardSection> _sections = [
    _DashboardSection(Icons.folder_shared, 'Historia clínica'),
    _DashboardSection(Icons.event_available, 'Sacar turno'),
    _DashboardSection(Icons.science, 'Ver estudios'),
    _DashboardSection(Icons.person, 'Editar perfil'),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bannerHeight = screenWidth * (100 / 320);
    final filtered = _sections
        .where((sec) => sec.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final double gridAspect = 1.29;

    return Scaffold(
      drawer: _MainDrawer(onLogout: () async {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        }
      }),
      backgroundColor: const Color(0xFFFEF9F1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF083866),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/logo_hospi.jpg',
                          width: 33,
                          height: 33,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "ROFFO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Spacer(),
                      if (user != null && user.photoURL != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(user.photoURL!),
                          radius: 17,
                        )
                      else
                        const CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 17,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                    ],
                  ),
                ),

                // User info debajo del header
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 2),
                    child: Row(
                      children: [
                        if (user.photoURL != null)
                          CircleAvatar(
                            backgroundImage: NetworkImage(user.photoURL!),
                            radius: 23,
                          )
                        else
                          const CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 23,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        if (user.photoURL != null) const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? "Usuario",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF083866),
                                ),
                              ),
                              Text(
                                user.email ?? "",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Banner con imagen y texto
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: bannerHeight,
                      margin: const EdgeInsets.only(top: 6, left: 14, right: 14),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/banner_home.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    Positioned(
                      left: screenWidth * 0.08,
                      top: bannerHeight * 0.23,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: screenWidth * 0.62),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7E8FF),
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          "¡Hola! Soy Anto, tu\nasistente personal en la app.",
                          style: TextStyle(
                            fontSize: 13.7,
                            color: Color(0xFF46336C),
                            fontWeight: FontWeight.w500,
                            height: 1.22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Buscador
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 5),
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      style: const TextStyle(fontSize: 15),
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF083866), size: 21),
                        hintText: 'Buscar',
                        filled: true,
                        fillColor: const Color(0xFFF0F4F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),

                // Próximo turno banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    margin: const EdgeInsets.only(bottom: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8A72CE),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.event_available, color: Colors.white, size: 25),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Próximo turno",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 15.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Hoy, 10:00 a.m. Dra. Pérez",
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                // Grid de opciones
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 6,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: gridAspect,
                      children: filtered.isEmpty
                          ? [
                              const Center(
                                child: Text("Sin resultados", style: TextStyle(fontSize: 15)),
                              ),
                            ]
                          : filtered
                              .map((s) => _DashboardCard(
                                    icon: s.icon,
                                    label: s.label,
                                    onTap: () async {
                                      switch (s.label) {
case 'Historia clínica':
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const HistoriaClinicaScreen(),
    ),
  );
  break;
                                        case 'Sacar turno':
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const SacarTurnoScreen()),
                                          );
                                          break;
                                        case 'Ver estudios':
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const EstudiosScreen()),
                                          );
                                          break;
case 'Editar perfil':
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MiPerfilScreen()),
  );
  break;
                                      }
                                    },
                                  ))
                              .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 1),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardSection {
  final IconData icon;
  final String label;
  _DashboardSection(this.icon, this.label);
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      elevation: 1.3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 46, color: const Color(0xFF083866)),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainDrawer extends StatelessWidget {
  final VoidCallback? onLogout;
  const _MainDrawer({this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.only(top: 60, left: 12),
        children: [
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF083866)),
            title: const Text('Inicio'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF083866)),
            title: const Text('Configuración'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF083866)),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              if (onLogout != null) onLogout!();
            },
          ),
        ],
      ),
    );
  }
}
