import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // For BackdropFilter
import '../services/push_notification_service.dart';
import '../repositories/medico_repository.dart';
import '../models/agenda_item_model.dart';

import 'historia_clinica_screen.dart';
import 'completar_perfil_screen.dart';
import 'mi_perfil_screen.dart';
import 'sacar_turno_screen.dart';
import 'mis_medicos_screen.dart'; 
import 'mis_recetas_screen.dart'; 
import 'estudios_screen.dart';
import 'farmacias_screen.dart';
import 'mis_turnos_screen.dart';
import '../widgets/patient/home_widgets.dart';
import '../widgets/main_drawer.dart';
import '../widgets/common/bouncing_card.dart';
import 'detalle_estudio_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _query = '';
  bool _isLoading = false;
  String _loadingMessage = '';
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _crearDatosMockSiNoExisten();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/banner_patient_welcome.png'), context);
      PushNotificationService().initialize(context);
    });
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.isEmpty) return;
    
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains("turno")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const SacarTurnoScreen()));
    } else if (lowerQuery.contains("clinica") || lowerQuery.contains("historia") || lowerQuery.contains("paciente")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoriaClinicaScreen()));
    } else if (lowerQuery.contains("estudio") || lowerQuery.contains("laboratorio") || lowerQuery.contains("analisis")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const EstudiosScreen()));
    } else if (lowerQuery.contains("farmacia") || lowerQuery.contains("medicamento") || lowerQuery.contains("remedio")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmaciasScreen()));
    } else if (lowerQuery.contains("receta")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const MisRecetasScreen()));  
    } else if (lowerQuery.contains("medico") || lowerQuery.contains("doctor") || lowerQuery.contains("profesional")) {
       Navigator.push(context, MaterialPageRoute(builder: (_) => const MisMedicosScreen()));
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text("No se encontraron resultados para '$query'."),
           backgroundColor: Colors.grey[800],
           behavior: SnackBarBehavior.floating,
         )
       );
    }
    
    FocusScope.of(context).unfocus(); // Close keyboard
  }

  void _crearDatosMockSiNoExisten() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get()
            .timeout(const Duration(seconds: 5));
        if (!doc.exists) {
           await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
             'dni': '12345678',
             'centro': 'ZANOO',
             'creado': DateTime.now().toIso8601String(),
           });
        }
      } catch (e) {
        // Silent
      }
    }
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
    );
  }

  void _navigateWithAnimation(Widget destination, String heroTag) async {
    _hapticFeedback();
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

  // --- RESULTS DIALOG (Enriched) ---
  void _showResultsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Resultados", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF083866))),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 20),
              
              // Featured Result (The one clicked)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.1))
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.analytics_outlined, size: 28, color: Color(0xFF1565C0)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                           Text("Hemograma Completo", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF083866), fontSize: 16)),
                           Text("15 Ene 2024 • Dr. Rossi", style: TextStyle(fontSize: 13, color: Color(0xFF1565C0))),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Text("Historial Reciente", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              
              // List of other studies
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildResultItem("Ecografía Abdominal", "10 Dic 2023", Icons.image_search_rounded),
                    _buildResultItem("Perfil Lipídico", "28 Nov 2023", Icons.water_drop_rounded),
                    _buildResultItem("Resonancia Magnética", "15 Oct 2023", Icons.camera_alt_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded),
                  label: const Text("Descargar PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2376F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(String title, String date, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF5F9FF), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: const Color(0xFF2376F6).withOpacity(0.6), size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF0D1C2E))),
        subtitle: Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        trailing: Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[300]),
        onTap: () {
          Navigator.pop(context); // Close dialog
          // Mock Data for Detail
          final mockEstudio = {
             "tipo": title,
             "fecha": date,
             "profesional": "Dr. Generico",
             "estado": "Disponible",
             "observaciones": "Estudio realizado sin complicaciones. Valores dentro de rango."
          };
          _navigateWithAnimation(DetalleEstudioScreen(estudio: mockEstudio), 'estudio_detail');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    String fullDate = DateFormat('d, MMMM', 'es').format(now).toUpperCase();

    // SYSTEM UI: Force Light Icons for Dark Header
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, 
      ),
      child: Scaffold(
        key: _scaffoldKey, 
        drawer: MainDrawer(
          role: UserRole.patient,
          onLogout: () async {
            _hapticFeedback();
            setState(() {
              _isLoading = true;
              _loadingMessage = 'Cerrando sesión...';
            });
            await Future.delayed(const Duration(milliseconds: 1000));
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              // Navigate to AuthWrapper (Home) to trigger Intro Logic
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthWrapper()),
                (route) => false,
              );
            }
          }
        ),
        backgroundColor: const Color(0xFFFEF9F1), 
        body: Stack(
          children: [
            Column(
              children: [
                 // HEADER (Standardized: Radius 16, Shadow Medico)
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // PLATINUM: 24px Padding, 8px Vertical
                   decoration: const BoxDecoration(
                     gradient: LinearGradient(
                       colors: [Color(0xFF083866), Color(0xFF2376F6)],
                       begin: Alignment.topLeft, end: Alignment.bottomRight
                     ),
                     borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                     boxShadow: [BoxShadow(color: Color(0xFF2376F6), blurRadius: 16, offset: Offset(0, 8), spreadRadius: -5)], // 15->16 (8pt grid)
                   ),
                   child: SafeArea( // Keep SafeArea for Header content
                     bottom: false,
                     child: Row(
                       children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: BouncingCard( // PLATINUM: Bounce
                              onTap: () => _scaffoldKey.currentState?.openDrawer(),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.menu, color: Color(0xFF2376F6), size: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12), // 10->12
                          Image.asset('assets/images/logo_zanoo_white.png', height: 22, fit: BoxFit.contain), 
                          const Spacer(),
                          const SizedBox(width: 12), // 10->12
                          BouncingCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
                              );
                            },
                            child: Container(
                               padding: const EdgeInsets.all(2),
                               decoration: BoxDecoration(
                                 color: Colors.white.withOpacity(0.2),
                                 shape: BoxShape.circle,
                               ),
                                child: ListenableBuilder(
                                  listenable: SessionManager(),
                                  builder: (context, _) {
                                    final sessionAvatar = SessionManager().avatarPath;
                                    // Logic: 1. Session Avatar -> 2. Firebase User Photo -> 3. Default Icon
                                    
                                    ImageProvider? bgImage;
                                    if (sessionAvatar != null && sessionAvatar.isNotEmpty) {
                                       if (sessionAvatar.contains("assets/")) {
                                         bgImage = AssetImage(sessionAvatar);
                                       } else {
                                         // Web/Local File
                                          bgImage = NetworkImage(sessionAvatar); // For web simplicity, normally FileImage check
                                       }
                                    } else if (user != null && user.photoURL != null) {
                                      bgImage = NetworkImage(user.photoURL!);
                                    }

                                    return CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white,
                                      backgroundImage: bgImage,
                                      child: bgImage == null
                                          ? const Icon(Icons.person, color: Color(0xFF2376F6), size: 18)
                                          : null,
                                    );
                                  }
                                ),
                             ),
                          ),
                       ],
                     ),
                   ),
                 ),

                 Expanded(
                   child: FadeTransition(
                     opacity: _fadeAnimation,
                     child: SlideTransition(
                       position: _slideAnimation,
                       child: ListView(
                         physics: const BouncingScrollPhysics(),
                         padding: EdgeInsets.zero,
                         children: [
                           
                           // BANNER 
                           SizedBox(
                             width: double.infinity,
                             height: 232, // Adjusted to 8pt grid (230->232)
                             child: Stack(
                               clipBehavior: Clip.none,
                               children: [
                                  // Background
                                  Positioned.fill(
                                    child: Container(
                                      color: const Color(0xFFFEF9F1), 
                                    ),
                                  ),
                                  
                                  // ILLUSTRATION
                                  Positioned(
                                    right: -20, 
                                    bottom: -30, // Adjusted to pull up slightly (was -72)
                                    height: 280, // Reduced from 330 to match StandardPageHeader fix
                                    child: Image.asset(
                                      'assets/images/banner_patient_welcome.png', 
                                      fit: BoxFit.contain, 
                                    ),
                                  ),
                                    
                                  // TEXT CONTENT (PLATINUM: 24/32 Padding)
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(32, 48, 24, 16), // 28->32, 45->48, 20->24, 12->16 (All 8pt)
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Hola, ${user?.displayName?.split(' ').first ?? 'Laura'}", 
                                            style: const TextStyle(
                                              fontSize: 26, 
                                              fontWeight: FontWeight.bold, 
                                              color: Color(0xFF083866),
                                              letterSpacing: -0.5
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "Centro Médico: Instituto Roffo",
                                            style: TextStyle(
                                              fontSize: 14, 
                                              fontWeight: FontWeight.w600, 
                                              color: Color(0xFF2376F6)
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fullDate, 
                                            style: TextStyle(
                                              fontSize: 12, 
                                              fontWeight: FontWeight.bold, 
                                              color: Colors.grey[600],
                                              letterSpacing: 0.5
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // FLOATING SEARCH BAR (PLATINUM: 24px Side Margins)
                                  Positioned(
                                    bottom: 0, 
                                    left: 24, // 16->24
                                    right: 24, // 16->24
                                    height: 48, // 50->48 (8pt grid)
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24), // 25->24 (8pt grid)
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                        child: Container(
                                         decoration: BoxDecoration(
                                           color: Colors.white.withOpacity(0.95),
                                           borderRadius: BorderRadius.circular(24),
                                           boxShadow: const [
                                             BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8)) // 15->16
                                           ],
                                           border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.1))
                                         ),
                                         child: TextField(
                                           onChanged: (val) {
                                             setState(() {
                                               _query = val;
                                             });
                                           },
                                           decoration: InputDecoration(
                                             hintText: "¿Qué estás buscando?",
                                             hintStyle: TextStyle(fontSize: 15, color: Colors.grey[400]),
                                             prefixIcon: const Icon(Icons.search_rounded, size: 22, color: Color(0xFF2376F6)),
                                             suffixIcon: Padding(
                                               padding: const EdgeInsets.all(4.0),
                                               child: Container(
                                                 decoration: const BoxDecoration(
                                                   color: Color(0xFFE3F2FD),
                                                   shape: BoxShape.circle,
                                                 ),
                                                 child: IconButton(
                                                   icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF2376F6)),
                                                   onPressed: () => _handleSearch(_query), 
                                                   padding: EdgeInsets.zero,
                                                   constraints: const BoxConstraints(),
                                                 ),
                                               ),
                                             ),
                                             border: InputBorder.none,
                                             contentPadding: const EdgeInsets.symmetric(vertical: 12), // 14->12 
                                           ),
                                           onSubmitted: _handleSearch,
                                         ),
                                        ),
                                      ), 
                                    ),
                                  ),
                               ],
                             ),
                           ),

                           const SizedBox(height: 24), 

                           // MAIN CONTENT (PLATINUM: 24px Padding)
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 24), // 16->24
                             child: Column(
                               children: [
                                 // 1. KPI ROW (Standardized)
                                 Row(
                                   children: [
                                     Expanded(
                                       child: _buildPatientKPI(
                                         Icons.favorite_rounded, 
                                         "Médicos Fav.", 
                                         "3 Médicos", 
                                         const Color(0xFFE91E63), 
                                         () => _navigateWithAnimation(const MisMedicosScreen(), 'medicos')
                                       )
                                     ),
                                     const SizedBox(width: 12),
                                     Expanded(
                                       child: _buildPatientKPI(
                                         Icons.medical_services_outlined, 
                                         "Recetas", 
                                         "2 Disp.", 
                                         const Color(0xFF00C853), 
                                         () => _navigateWithAnimation(const MisRecetasScreen(), 'recetas')
                                       )
                                     ),
                                     const SizedBox(width: 12),
                                     Expanded(
                                       child: _buildPatientKPI(
                                         Icons.science_outlined, 
                                         "Estudios", 
                                         "1 Nuevo", 
                                         const Color(0xFF2376F6), 
                                         () => _navigateWithAnimation(const EstudiosScreen(), 'estudios')
                                       )
                                     ),
                                   ],
                                 ),

                                 const SizedBox(height: 24),

                                 // 2. PRÓXIMOS TURNOS SLIDER (Real Data)
                                 const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 4, bottom: 12),
                                      child: Text("Próximos Turnos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF083866))),
                                    ),
                                 ),
                                 StreamBuilder<List<AgendaItem>>(
                                    stream: MedicoRepository().getMyAppointmentsStream(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                      }
                                      
                                      final turns = snapshot.data ?? [];
                                      final upcomingTurns = turns.where((t) => t.estado != 'Realizado' && t.estado != 'Cancelado').toList(); 

                                      if (upcomingTurns.isEmpty) {
                                        return Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey[300]),
                                              const SizedBox(height: 8),
                                              Text("No tenés turnos próximos", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                                              TextButton(
                                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SacarTurnoScreen())),
                                                child: const Text("Sacar Turno Nuevo"),
                                              )
                                            ],
                                          ),
                                        );
                                      }

                                      return SizedBox(
                                        height: 110, // Slightly taller
                                        child: PageView.builder(
                                          controller: PageController(viewportFraction: 0.9),
                                          padEnds: false,
                                          physics: const BouncingScrollPhysics(),
                                          itemCount: upcomingTurns.length,
                                          itemBuilder: (context, index) {
                                            final turn = upcomingTurns[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: _buildTurnoCard(
                                                  "${turn.hora} hs", 
                                                  turn.doctor, 
                                                  "Consulta ${turn.specialty}"
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                 ),
                                 
                                 const SizedBox(height: 24),
                                 
                                 // "Accesos" Label
                                 const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 4, bottom: 12),
                                      child: Text("Accesos Rápidos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF083866))),
                                    ),
                                 ),

                                 // 3. HORIZONTAL SLIDER (Standard 16px)
                                 SizedBox(
                                   height: 136, // 135->136 (8pt)
                                   child: ListView(
                                     scrollDirection: Axis.horizontal,
                                     physics: const BouncingScrollPhysics(),
                                     clipBehavior: Clip.none,
                                     padding: const EdgeInsets.only(bottom: 24),
                                     children: [
                                       _buildSliderButton(context, Icons.folder_shared_rounded, "Historia", () => _navigateWithAnimation(const HistoriaClinicaScreen(), 'hc')),
                                       const SizedBox(width: 12),
                                       _buildSliderButton(context, Icons.calendar_month_rounded, "Turnos", () => _navigateWithAnimation(const SacarTurnoScreen(), 'turnos')),
                                       const SizedBox(width: 12),
                                       _buildSliderButton(context, Icons.person_outline_rounded, "Perfil", () => _navigateWithAnimation(const MiPerfilScreen(), 'perfil')),
                                        const SizedBox(width: 12),
                                       _buildSliderButton(context, Icons.local_pharmacy_rounded, "Farmacias", () => _navigateWithAnimation(const FarmaciasScreen(), 'farmacias')),
                                        const SizedBox(width: 12),
                                       _buildSliderButton(context, Icons.add_location_alt_rounded, "Guardias", () => _showToast("Mapa de Guardias (Próximamente)")),
                                       const SizedBox(width: 16),
                                     ],
                                   ),
                                 ),
                                 
                                 const SizedBox(height: 8), // 10->8

                                 // 4. TECH VISUAL (24px Radius to match Medico Cards)
                                 const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 4, bottom: 12),
                                      child: Text("Últimos Resultados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF083866))),
                                    ),
                                 ),
                                 
                                 BouncingCard(
                                   onTap: () {
                                     _hapticFeedback();
                                     _showResultsDialog(context);
                                   },
                                   child: Container( 
                                     decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF90A4AE).withOpacity(0.08), 
                                            blurRadius: 24,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                     ),
                                     child: Padding(
                                       padding: const EdgeInsets.all(16),
                                       child: Row(
                                         children: [
                                           Container(
                                             padding: const EdgeInsets.all(12),
                                             decoration: BoxDecoration(
                                               color: const Color(0xFFE3F2FD),
                                               borderRadius: BorderRadius.circular(12),
                                             ),
                                             child: const Icon(Icons.description_rounded, color: Color(0xFF1565C0), size: 28),
                                           ),
                                           const SizedBox(width: 16),
                                           Expanded(
                                             child: Column(
                                               crossAxisAlignment: CrossAxisAlignment.start,
                                               children: [
                                                 const Text("Análisis de Sangre", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF083866))),
                                                 const SizedBox(height: 4),
                                                 Row(
                                                   children: [
                                                     Icon(Icons.check_circle_rounded, size: 14, color: Colors.green[600]),
                                                     const SizedBox(width: 4),
                                                     Text("Disponible • 15 Ene", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                                   ],
                                                 ),
                                               ],
                                             ),
                                           ),
                                           Container(
                                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                             decoration: BoxDecoration(
                                               color: const Color(0xFF2376F6).withOpacity(0.1),
                                               borderRadius: BorderRadius.circular(24), // 20->24
                                             ),
                                             child: const Text("Ver Online", style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold, fontSize: 13)),
                                           )
                                         ],
                                       ),
                                     ),
                                   ),
                                 ),
                                 
                                 const SizedBox(height: 40),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
              ],
            ),
            
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
      ),
    );
  }

  // STANDARD slider button
  Widget _buildSliderButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return BouncingCard(
      onTap: onTap,
      child: Container( 
         width: 104, // 100->104 (8pt grid)
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(16),
           boxShadow: [BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))], // 8->16 (Softer)
         ),
         child: Padding( 
               padding: const EdgeInsets.symmetric(vertical: 16),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Container(
                     padding: const EdgeInsets.all(12), // 10->12
                     decoration: const BoxDecoration(
                       color: Color(0xFFE3F2FD),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(icon, color: const Color(0xFF1565C0), size: 24),
                   ),
                   const SizedBox(height: 8),
                   Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0D1C2E))),
                 ],
               ),
         ),
      ),
    );
  }

  // STANDARD KPI
  Widget _buildPatientKPI(IconData icon, String label, String value, Color color, VoidCallback onTap) {
    return BouncingCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 16, // 10->16 (Premium Soft)
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)), 
        ),
        child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8), // 12->16 (8pt)
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24), 
                  const SizedBox(height: 8), // 6->8
                  Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color), textAlign: TextAlign.center), 
                  Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.bold), textAlign: TextAlign.center), 
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildTurnoCard(String date, String doctor, String type) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: BouncingCard(
          onTap: () {
             _hapticFeedback();
             Navigator.push(context, MaterialPageRoute(builder: (_) => const MisTurnosScreen()));
          },
         child: Container( 
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(16),
             border: Border.all(color: Colors.grey.withOpacity(0.1)),
             boxShadow: [
               BoxShadow(
                 color: const Color(0xFF90A4AE).withOpacity(0.08), 
                 blurRadius: 16, // 15->16
                 offset: const Offset(0, 4),
               ),
             ],
           ),
           child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // 14->16 (8pt)
               child: Row(
                 children: [
                    Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: const Color(0xFFE3F2FD),
                         borderRadius: BorderRadius.circular(12), // 10->12
                       ),
                       child: const Icon(Icons.calendar_today_rounded, color: Color(0xFF1565C0), size: 20),
                     ),
                     const SizedBox(width: 16), // 14->16
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text(type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1565C0), letterSpacing: 0.5)),
                           const SizedBox(height: 4), 
                           Text("$date • $doctor", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF083866), fontSize: 14)),
                         ],
                       ),
                     ),
                     const Icon(Icons.chevron_right_rounded, color: Colors.grey)
                 ],
               ),
           ),
         ),
      ),
    );
  }
}
