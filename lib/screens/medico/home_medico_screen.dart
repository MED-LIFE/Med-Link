import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import '../../constants/medico_constants.dart';
import '../../models/agenda_item_model.dart';
import '../../repositories/medico_repository.dart';
import 'historia_clinica_medico_screen.dart';
import 'patient_search_screen.dart';
import 'agenda_medico_screen.dart';
import '../mi_perfil_screen.dart';
import '../../widgets/main_drawer.dart';
import 'widgets/spontaneous_appointment_widget.dart';

class HomeMedicoScreen extends StatefulWidget {
  const HomeMedicoScreen({Key? key}) : super(key: key);

  @override
  State<HomeMedicoScreen> createState() => _HomeMedicoScreenState();
}

class _HomeMedicoScreenState extends State<HomeMedicoScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFabExtended = true;
  int _unreadNotifications = 5;
  String _searchQuery = "";
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final MedicoRepository _medicoRepository = MedicoRepository();

  @override
  void initState() {
    super.initState();
    // Seed data if empty (just for demo/first run)
    _medicoRepository.seedData();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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

  // void _removePatient(String patientName) {
  //   setState(() {
  //     _agenda.removeWhere((item) => item.paciente == patientName);
  //   });
  // }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String fullDate = DateFormat('d, MMMM', 'es').format(now).toUpperCase();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFEF9F1),
      drawer: MainDrawer(
        role: UserRole.doctor,
        onLogout: () async {
          _hapticFeedback();
          setState(() {
            // _isLoading = true; // If we had loading state
          });
          await Future.delayed(const Duration(milliseconds: 1000));
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
          }
        },
      ),
      body: Column(
        children: [
           // HEADER
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 colors: [Color(0xFF083866), Color(0xFF2376F6)],
                 begin: Alignment.topLeft, end: Alignment.bottomRight
               ),
               borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
               boxShadow: [BoxShadow(color: Color(0xFF2376F6), blurRadius: 15, offset: Offset(0, 8), spreadRadius: -5)],
             ),
             child: SafeArea(
               bottom: false,
               child: Row(
                 children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF2376F6), size: 22),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset('assets/images/logo_zanoo_white.png', height: 22, fit: BoxFit.contain), 
                    const Spacer(),
                    IconButton(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: Colors.white),
                          if (_unreadNotifications > 0)
                            Positioned(
                              right: -2, top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                child: Text("$_unreadNotifications", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            )
                        ],
                      ),
                      onPressed: () => _showNotifications(context),
                    ),
                    const SizedBox(width: 10),
                    Container(
                       padding: const EdgeInsets.all(2),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.2),
                         shape: BoxShape.circle,
                       ),
                       child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(Icons.person, color: Color(0xFF2376F6), size: 18),
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
                       height: 240,
                       child: Stack(
                         clipBehavior: Clip.none,
                         children: [
                            Positioned.fill(child: Container(color: const Color(0xFFFEF9F1))),
                            Positioned(
                              right: -20, bottom: -70, height: 330,
                              child: Image.asset('assets/images/banner_patient_welcome.png', fit: BoxFit.contain),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(28, 45, 20, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Hola, Dr. ${user?.displayName?.split(' ').first ?? 'Medico'}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF083866), letterSpacing: -0.5)),
                                    const SizedBox(height: 4),
                                    const Text("Agenda del día", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2376F6))),
                                    const SizedBox(height: 4),
                                    Text(fullDate, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0, left: 16, right: 16, height: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                   decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(25), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))], border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.1))),
                                   child: TextField(
                                     onChanged: (val) => setState(() => _searchQuery = val),
                                     decoration: InputDecoration(
                                       hintText: "Buscar paciente...",
                                       hintStyle: TextStyle(fontSize: 15, color: Colors.grey[400]),
                                       prefixIcon: const Icon(Icons.search_rounded, size: 22, color: Color(0xFF2376F6)),
                                       suffixIcon: Padding(
                                         padding: const EdgeInsets.all(4.0), 
                                         child: Container(
                                           decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle), 
                                           child: IconButton(
                                             icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF2376F6)),
                                             padding: EdgeInsets.zero,
                                             constraints: const BoxConstraints(),
                                             onPressed: () => FocusScope.of(context).unfocus(),
                                           )
                                         )
                                       ),
                                       border: InputBorder.none,
                                       contentPadding: const EdgeInsets.symmetric(vertical: 14), 
                                     ),
                                     onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                   ),
                                  ),
                                ), 
                              ),
                            ),
                         ],
                       ),
                     ),
                     
                     const SizedBox(height: 24),
                     
                     // 1. QUICK ACCESS BUTTONS (New)
                     Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickAccessButton(
                                context,
                                "Pacientes",
                                Icons.person_search_rounded,
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientSearchScreen())),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAccessButton(
                                context,
                                "Mi Agenda",
                                Icons.calendar_month_rounded, 
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaMedicoScreen())),
                              ),
                            ),
                          ],
                        ),
                     ),
                     
                     const SizedBox(height: 24),

                     // KPIS SECTION
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       child: Column(
                         children: [
                            Row(
                              children: [
                                 Expanded(child: _buildVisualChartCard(
                                   title: "Pacientes", 
                                   value: "14", 
                                   diff: "+2 vs ayer", 
                                   color: const Color(0xFF2376F6), 
                                   chartType: 'turnos',
                                   onTap: () => _showPremiumFeatureDialog(context, "Pacientes en Tiempo Real", "Visualiza el flujo de pacientes en tiempo real."),
                                 )),
                                 const SizedBox(width: 12),
                                 Expanded(child: _buildVisualChartCard(
                                   title: "Espera", 
                                   value: "15m", 
                                   diff: "-2m", 
                                   color: MedicoConstants.warning, 
                                   chartType: 'demora',
                                   onTap: () => _showPremiumFeatureDialog(context, "Tiempos de Espera", "Monitorea la demora promedio en sala de espera."),
                                 )),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildCriticalPending(),
                         ],
                       ),
                     ),
                     
                     const SizedBox(height: 24),

                     // AGENDA LIST
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 20),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                            const Text("Agenda del día", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF083866))),
                            TextButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => _buildFilterSheet(context),
                                  backgroundColor: Colors.transparent,
                                );
                              },
                              icon: const Icon(Icons.tune_rounded, size: 16),
                              label: const Text("Filtrar"),
                            ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 12),
                     _buildTimelineList(),
                     const SizedBox(height: 80),
                   ],
                 ),
               ),
             ),
           ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSpontaneousAppointmentDialog(context),
        backgroundColor: MedicoConstants.primaryColor,
        foregroundColor: Colors.white,
        isExtended: _isFabExtended,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text("Turno espontáneo"),
      ),
    );
  }

  // --- DRAWER ---
  // Removed local _buildCustomDrawer to use shared MainDrawer for consistency.

  // Removed unused _buildDrawerItem

  Widget _buildVisualChartCard({required String title, required String value, required String diff, required Color color, required String chartType, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
                Icon(Icons.more_horiz, color: Colors.grey[400], size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(diff, style: TextStyle(fontSize: 11, color: Colors.green[600], fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalPending() {
    return _buildAlertCard(
      context,
      "Resultado crítico no comunicado",
      "Juan Pérez - Glucemia 300 mg/dL",
      "Hace 2 días",
      Icons.notification_important_rounded,
    );
  }

  Widget _buildAlertCard(BuildContext context, String title, String subtitle, String time, IconData icon) {
    return InkWell(
      onTap: () => _showCriticalResultActionDialog(context, title, subtitle),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE0E0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: MedicoConstants.error.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: MedicoConstants.error, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: MedicoConstants.textDark, fontSize: 13)),
                   Text(subtitle, style: const TextStyle(color: MedicoConstants.textLight, fontSize: 12)),
                ],
              ),
            ),
            Text(time, style: const TextStyle(color: MedicoConstants.error, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  void _showCriticalResultActionDialog(BuildContext context, String title, String subtitle) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
         title: Row(
           children: [
             Icon(Icons.warning_rounded, color: MedicoConstants.error, size: 28),
             const SizedBox(width: 12),
             const Expanded(child: Text("Acción Requerida", style: TextStyle(fontWeight: FontWeight.bold))),
           ],
         ),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
             const SizedBox(height: 4),
             Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
             const SizedBox(height: 24),
             const Text("Notificar al paciente:", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF083866))),
             const SizedBox(height: 12),
             
             _buildActionOption(context, Icons.notification_important_rounded, "Solicitar Turno Urgente", Colors.red, "Urgencia notificada al paciente"),
             const SizedBox(height: 8),
             _buildActionOption(context, Icons.calendar_month_rounded, "Solicitar Turno a la Brevedad", Colors.orange, "Solicitud de turno enviada"),
             const SizedBox(height: 8),
             _buildActionOption(context, Icons.check_circle_rounded, "Todo en orden (Check)", Colors.green, "Paciente notificado: Todo OK"),
             const SizedBox(height: 16),
             OutlinedButton.icon(
               onPressed: () {
                 Navigator.pop(context);
                 // Navigate to study viewer (mock)
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Abriendo visor de estudios...")));
               }, 
               icon: const Icon(Icons.description_rounded),
               label: const Text("Ver Estudio"),
               style: OutlinedButton.styleFrom(
                 foregroundColor: const Color(0xFF2376F6),
                 side: const BorderSide(color: Color(0xFF2376F6)),
                 minimumSize: const Size(double.infinity, 48),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
               )
             )
           ],
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
         ],
       ),
     );
  }

  Widget _buildActionOption(BuildContext context, IconData icon, String label, Color color, String successMsg) {
    return InkWell(
      onTap: () {
         Navigator.pop(context);
         _sendNotification(successMsg);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08), 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2))
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label, 
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF323232),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      )
    );
  }
  
  Widget _buildTimelineList() {
    return StreamBuilder<List<AgendaItem>>(
      stream: _medicoRepository.getAgendaStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final agenda = snapshot.data ?? [];
        final filteredAgenda = agenda.where((item) {
          if (_searchQuery.isEmpty) return true;
          return item.paciente.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredAgenda.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("No hay pacientes"),
          ));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredAgenda.length,
          itemBuilder: (context, index) {
            final item = filteredAgenda[index];
            final isLast = index == filteredAgenda.length - 1;
            return _buildTimelineItem(item, isLast);
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(AgendaItem item, bool isLast) {
    bool isCurrent = item.estado == 'en_consultorio';
    Color statusColor;

    switch (item.estado) {
      case 'atendido': statusColor = MedicoConstants.success; break;
      case 'en_consultorio': statusColor = MedicoConstants.primaryColor; break;
      case 'en_sala': statusColor = MedicoConstants.warning; break;
      case 'pendiente': statusColor = MedicoConstants.error; break;
      default: statusColor = MedicoConstants.textLight;
    }

    return InkWell(
      onTap: () {
         _showPatientSummaryDialog(context, item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(16),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.04),
               blurRadius: 8, 
               offset: const Offset(0,2)
             )
           ],
           border: isCurrent ? Border.all(color: MedicoConstants.primaryColor.withOpacity(0.3), width: 1.5) : null
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Column(
               children: [
                 Text(
                   item.hora,
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     color: isCurrent ? MedicoConstants.primaryColor : MedicoConstants.textDark,
                     fontSize: 15,
                   ),
                 ),
                 if (isCurrent)
                   Container(
                     margin: const EdgeInsets.only(top: 4),
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(color: MedicoConstants.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                     child: const Text("AHORA", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: MedicoConstants.primaryColor)),
                   )
               ],
             ),
             const SizedBox(width: 16),
             Container(
               height: 40, width: 2, 
               color: Colors.grey.shade200,
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Expanded(
                         child: Text(
                           item.paciente,
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D1C2E)),
                         ),
                       ),
                       if (item.estado != 'pendiente')
                          Icon(
                            item.estado == 'atendido' ? Icons.check_circle : Icons.timer,
                            size: 16,
                            color: statusColor,
                          )
                     ],
                   ),
                   const SizedBox(height: 4),
                   Text(item.motivo, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                 ],
               ),
             ),
             
             if (isCurrent)
               ElevatedButton(
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoriaClinicaMedicoScreen(patient: {
                            'name': item.paciente,
                            'id': item.id,
                            'dni': item.dni,
                            'age': item.age,
                            'img': item.img
                          }),
                        ),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MedicoConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                  ),
                  child: const Text("Atender"),
               )
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    setState(() => _unreadNotifications = 0);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.notifications_active_rounded, color: MedicoConstants.primaryColor),
            SizedBox(width: 10),
            Text("Notificaciones"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
             Text("Sin notificaciones nuevas.")
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
        ],
      ),
    );
  }

  void _showSpontaneousAppointmentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Padding(padding: EdgeInsets.all(20), child: Text("Nuevo Turno Espontáneo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            Expanded(
              child: SpontaneousAppointmentContent(
                onConfirm: (patientName, dni) async {
                  Navigator.pop(context);
                  
                  final newItem = AgendaItem(
                       id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
                       hora: DateFormat('HH:mm').format(DateTime.now()),
                       paciente: patientName,
                       motivo: "Consulta Espontánea",
                       estado: "en_consultorio",
                       img: "assets/images/user_placeholder.png", // Or generic avatar
                       dni: dni,
                       age: 35, // Mock age
                    );
                    
                  await _medicoRepository.addNewPatient(newItem);
                  _sendNotification("Turno creado para $patientName");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Filtrar Agenda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
        ],
      ),
    );
  }

  void _showPatientSummaryDialog(BuildContext context, AgendaItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            
            // 1. Patient Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                   CircleAvatar(
                     radius: 28,
                     backgroundImage: AssetImage(item.img), 
                     onBackgroundImageError: (_, __) {},
                     child: item.img.contains('placeholder') ? Text(item.paciente[0], style: const TextStyle(fontSize: 24)) : null,
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(item.paciente, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
                         Text("${item.age} años • DNI: ${item.dni}", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                       ],
                     ),
                   ),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                     decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                     child: const Text("OSDE 210", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0), fontSize: 12)),
                   )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // 2. Consultation Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildInfoColumn(Icons.access_time_filled_rounded, "Horario", item.hora),
                    _buildInfoColumn(Icons.medical_information_rounded, "Motivo", item.motivo),
                    _buildInfoColumn(Icons.info_rounded, "Estado", item.estado.replaceAll('_', ' ').toUpperCase()),
                 ],
              ),
            ),
            
            const Spacer(),
            
            // 3. Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                   Expanded(
                     child: OutlinedButton.icon(
                       onPressed: () => _showToast("Llamando al paciente..."),
                       icon: const Icon(Icons.call_rounded), 
                       label: const Text("Llamar"),
                       style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), foregroundColor: const Color(0xFF2376F6), side: const BorderSide(color: Color(0xFF2376F6))),
                     )
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: ElevatedButton.icon(
                       onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => HistoriaClinicaMedicoScreen(patient: {
                               'name': item.paciente,
                               'id': item.id,
                               'dni': item.dni,
                               'age': item.age,
                               'img': item.img
                            }))
                          );
                       },
                       icon: const Icon(Icons.history_edu_rounded), 
                       label: const Text("Historia Clínica"),
                       style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: const Color(0xFF2376F6), foregroundColor: Colors.white, elevation: 0),
                     )
                   ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0D1C2E))),
      ],
    );
  }

  void _showPatientInfo(BuildContext context) {}
  void _showWaitInfo(BuildContext context) {}
  void _showToast(String msg) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))); }

  Widget _buildQuickAccessButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF2376F6).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF1565C0), size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF083866),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPremiumFeatureDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD54F), width: 2),
              ),
              child: const Icon(Icons.star_rounded, color: Color(0xFFFFA000), size: 48),
            ),
            const SizedBox(height: 24),
            Text("Función Premium", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2376F6))),
            const SizedBox(height: 12),
            Text(
              "Esta funcionalidad es para instituciones que ya cuenten con la tecnología necesaria (PC, internet estable, tablets, etc).",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey[100]!)
              ),
              child: Row(
                children: [
                   Icon(Icons.help_outline_rounded, size: 20, color: Colors.blueGrey[400]),
                   const SizedBox(width: 12),
                   const Expanded(
                     child: Text(
                       "Si su institución cumple con los requisitos, contáctanos para activar el plan PREMIUM.",
                       style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                     ),
                   )
                ],
              ),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Entendido", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA000),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Más Información")
          )
        ],
      ),
    );
  }
}
