import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Imports corregidos
import 'historia_clinica_screen.dart';
import 'completar_perfil_screen.dart';
import 'estudios_screen.dart';
import 'mi_perfil_screen.dart';
import 'sacar_turno_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<_DashboardSection> _sections = [
    _DashboardSection(Icons.folder_shared, 'Historia clínica'),
    _DashboardSection(Icons.event_available, 'Sacar turno'),
    _DashboardSection(Icons.science, 'Ver estudios'),
    _DashboardSection(Icons.person, 'Editar perfil'),
  ];

  String _query = '';
  bool _isLoading = false;
  String _loadingMessage = '';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _crearDatosMockSiNoExisten();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Crear datos mock con loading state
  void _crearDatosMockSiNoExisten() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isLoading = true;
        _loadingMessage = 'Verificando datos del paciente...';
      });

      try {
        final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
        if (!doc.exists) {
          setState(() {
            _loadingMessage = 'Configurando historia clínica...';
          });
          
          await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
            'dni': '12345678',
            'edad': '35',
            'centro': 'Roffo',
            'proxima_cita': 'Hoy 10:00 - Dra. Pérez',
            'fecha_actualizacion': '25/10/2025',
            'resumen': 'Paciente estable bajo seguimiento regular',
            'diagnostico': 'Hipertensión arterial esencial',
            'medicamentos': 'Losartán 50mg - 1 comp cada 12hs',
            'estado_salud': 'Estable',
            'alertas_medicas': 'Ninguna',
            'ultimo_control': '15/10/2025'
          });
        }
      } catch (e) {
        setState(() {
          _loadingMessage = 'Error al cargar datos. Reintentando...';
        });
      } finally {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  // Feedback háptico para interacciones importantes
  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _navigateWithAnimation(Widget destination, String heroTag) async {
    _hapticFeedback();
    
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Cargando...';
    });

    // Simular un pequeño delay para mostrar el loading
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isLoading = false;
      _loadingMessage = '';
    });

    if (mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bannerHeight = screenWidth * (100 / 320);
    final filtered = _sections
        .where((sec) => sec.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      drawer: _MainDrawer(onLogout: () async {
        _hapticFeedback();
        setState(() {
          _isLoading = true;
          _loadingMessage = 'Cerrando sesión...';
        });
        
        await Future.delayed(const Duration(milliseconds: 1000));
        await FirebaseAuth.instance.signOut();
        
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        }
      }),
      backgroundColor: const Color(0xFFFEF9F1),
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Header más compacto
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF083866), Color(0xFF2376F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(22),
                          bottomRight: Radius.circular(22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF2376F6),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Builder(
                            builder: (context) => Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.menu, color: Color(0xFF2376F6), size: 22),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                onPressed: () {
                                  _hapticFeedback();
                                  Scaffold.of(context).openDrawer();
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                'assets/logo_hospi.jpg',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.local_hospital, color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "ROFFO",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: user != null && user.photoURL != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoURL!),
                                  radius: 16,
                                )
                              : const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 16,
                                  child: Icon(Icons.person, color: Color(0xFF2376F6), size: 18),
                                ),
                          ),
                        ],
                      ),
                    ),

                    // User info con avatar corregido
                    if (user != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(19, 10, 19, 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF2376F6).withOpacity(0.08),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2376F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF2376F6).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: user.photoURL != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Image.network(
                                      user.photoURL!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.person, color: Color(0xFF2376F6), size: 22);
                                      },
                                    ),
                                  )
                                : const Icon(Icons.person, color: Color(0xFF2376F6), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName ?? "Usuario",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Color(0xFF083866),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    user.email ?? "",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EDB92).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF0EDB92).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, color: Color(0xFF0EDB92), size: 8),
                                  SizedBox(width: 5),
                                  Text(
                                    'Activo',
                                    style: TextStyle(
                                      color: Color(0xFF0EDB92),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Banner con Anto
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
                            errorBuilder: (context, error, stackTrace) => 
                              Container(
                                color: const Color(0xFFE8F4FD),
                                child: const Center(
                                  child: Icon(Icons.person_outline, size: 80, color: Colors.grey),
                                ),
                              ),
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
                            child: Text(
                              "¡Hola! Soy Anto, tu\nasistente personal en la app.",
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).textScaleFactor * 13.7,
                                color: const Color(0xFF46336C),
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
                      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 4),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF2376F6).withOpacity(0.08),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          style: const TextStyle(fontSize: 14),
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            prefixIcon: Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(10),
                              child: const Icon(Icons.search, color: Color(0xFF2376F6), size: 18),
                            ),
                            hintText: 'Buscar',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),

                    // Próximo turno banner - ARREGLADO
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 19),
                      child: InkWell(
                        onTap: () {
                          _hapticFeedback();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SacarTurnoScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          margin: const EdgeInsets.only(bottom: 12, top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF2376F6).withOpacity(0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2376F6).withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2376F6),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2376F6).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF2376F6).withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(Icons.schedule_rounded, color: Color(0xFF2376F6), size: 24),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Próximo turno",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2376F6),
                                            fontSize: 12,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.circle, color: Color(0xFF0EDB92), size: 6),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      "Hoy, 10:00 • Dra. Pérez",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF083866),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2376F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Grid de opciones
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.8,
                          children: filtered.isEmpty
                              ? [
                                  const Center(
                                    child: Text("Sin resultados", style: TextStyle(fontSize: 15)),
                                  ),
                                ]
                              : filtered.asMap().entries
                                  .map((entry) {
                                    final section = entry.value;
                                    return _DashboardCard(
                                      icon: section.icon,
                                      label: section.label,
                                      onTap: () async {
                                        switch (section.label) {
                                          case 'Historia clínica':
                                            _navigateWithAnimation(const HistoriaClinicaScreen(), 'historia_clinica');
                                            break;
                                          case 'Sacar turno':
                                            _navigateWithAnimation(const SacarTurnoScreen(), 'sacar_turno');
                                            break;
                                          case 'Ver estudios':
                                            _navigateWithAnimation(const EstudiosScreen(), 'ver_estudios');
                                            break;
                                          case 'Editar perfil':
                                            _navigateWithAnimation(const MiPerfilScreen(), 'editar_perfil');
                                            break;
                                        }
                                      },
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                  ],
                ),
              ),
            ),
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2376F6)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _loadingMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF083866),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashboardSection {
  final IconData icon;
  final String label;
  _DashboardSection(this.icon, this.label);
}

class _DashboardCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF2376F6).withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2376F6).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF2376F6).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    widget.icon, 
                    size: 24, 
                    color: const Color(0xFF2376F6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF083866),
                    height: 1.2,
                  ),
                ),
              ],
            ),
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
    final user = FirebaseAuth.instance.currentUser;
    
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header del drawer
          Container(
            height: 140,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2376F6), Color(0xFF73BFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_hospital, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ROFFO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (user != null) 
                  Text(
                    user.displayName ?? "Usuario",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          
          // Opciones del menú
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.home_rounded,
                  title: 'Inicio',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.person_rounded,
                  title: 'Mi Perfil',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.folder_shared_rounded,
                  title: 'Historia Clínica',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoriaClinicaScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.event_available_rounded,
                  title: 'Mis Turnos',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SacarTurnoScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.science_rounded,
                  title: 'Estudios Médicos',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EstudiosScreen()),
                    );
                  },
                ),
                const Divider(height: 32, indent: 16, endIndent: 16),
                _DrawerItem(
                  icon: Icons.notifications_rounded,
                  title: 'Notificaciones',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Configuración',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Ayuda y Soporte',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'Acerca de',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
                _DrawerItem(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar Sesión',
                  isDestructive: true,
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    if (onLogout != null) onLogout!();
                  },
                ),
              ],
            ),
          ),
          
          // Footer con versión
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Versión 1.0.0',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red[600] : const Color(0xFF2376F6);
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDestructive ? color : const Color(0xFF083866),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}