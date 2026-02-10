import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // Added for BackdropFilter
import '../../widgets/main_drawer.dart';
import '../../widgets/patient/home_widgets.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({Key? key}) : super(key: key);

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  List<Map<String, dynamic>> _queue = [];
  String _searchQuery = "";
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _generateMockQueue();
    
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

  void _generateMockQueue() {
    _queue = [
      {"time": "11:00", "name": "Juan Perez", "details": "11:00 Control - con Dr. Favaloro", "status": "waiting"},
      {"time": "10:45", "name": "Sofía Martinez", "details": "10:45 Consulta - Dr. Fernández", "status": "waiting"},
      {"time": "10:30", "name": "Roberto Lopez", "details": "10:30 Certif. - con Dr. González", "status": "checked_in"},
      {"time": "10:15", "name": "Maria Garcia", "details": "10:15 Ecografía - Sala 2", "status": "completed"},
    ];
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String dayName = DateFormat('EEEE', 'es').format(now).toUpperCase();
    String fullDate = DateFormat('d, MMMM', 'es').format(now).toUpperCase();

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFEF9F1), 
      drawer: MainDrawer(
        role: UserRole.admin,
        onLogout: () async {
           await FirebaseAuth.instance.signOut();
           if (context.mounted) {
             Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
           }
        },
      ),
      body: Column(
        children: [
           // 1. HEADER (Static - Stays put)
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
                    const SizedBox(width: 10),
                   IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () => _showNotifications(context),
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
                // Updated: Clip.none to let elements float out of bounds (Search Bar & Big Illustration)
                SizedBox(
                  width: double.infinity,
                  height: 240, 
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                       // Background Color
                       Positioned.fill(
                         child: Container(
                           color: const Color(0xFFFEF9F1), 
                         ),
                       ),
                       
                       // ILLUSTRATION: "Big Anto"
                       // Positioned to spill out. Anchored bottom-right.
                       // Adjusted: Kept at -90 as requested previously for relation to header.
                       Positioned(
                         right: -20, 
                         bottom: -90, 
                         height: 380, 
                         child: Image.asset(
                           'assets/banner_admin.png', 
                           fit: BoxFit.contain, 
                         ),
                       ),
                         
                       // TEXT CONTENT
                       Positioned.fill(
                         child: Padding(
                           // Adjusted: Increased top padding (45) to LOWER text as requested "Bajá el saludo..."
                           padding: const EdgeInsets.fromLTRB(28, 45, 20, 12), 
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text(
                                 "Hola, Laura",
                                 style: TextStyle(
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
                                 fullDate.toUpperCase(),
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

                       // FLOATING SEARCH BAR (Updated to PREMIUM BLUR)
                       Positioned(
                         bottom: 0, 
                         left: 16, 
                         right: 16,
                         height: 50,
                         child: ClipRRect(
                           borderRadius: BorderRadius.circular(25),
                           child: BackdropFilter(
                             filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                             child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))
                                ],
                                border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.1))
                              ),
                              child: TextField(
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                onSubmitted: (value) => Navigator.pushNamed(context, '/medico/buscar-paciente'),
                                decoration: InputDecoration(
                                  hintText: "Buscar paciente...",
                                  hintStyle: TextStyle(fontSize: 15, color: Colors.grey[400]),
                                  prefixIcon: const Icon(Icons.search_rounded, size: 22, color: Color(0xFF2376F6)),
                                  // Added Suffix "Send" Button
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE3F2FD),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF2376F6)),
                                        onPressed: () => Navigator.pushNamed(context, '/medico/buscar-paciente'),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14), 
                                ),
                              ),
                             ),
                           ),
                         ), 
                       ),
                    ],
                  ),
                ),

                const SizedBox(height: 4), // Reduced to MINIMUM to pull body up ("achicar el aire")

                // METRICS GRID
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                           Expanded(child: _buildVisualChartCard(
                             title: "Turnos", 
                             value: "142", 
                             diff: "+12%", 
                             color: const Color(0xFF2376F6), 
                             chartType: 'turnos',
                             onTap: () => Navigator.pushNamed(context, '/admin/turnos')
                           )),
                           const SizedBox(width: 12),
                           Expanded(child: _buildVisualChartCard(
                             title: "Staff", 
                             value: "18/22", 
                             diff: "80%", 
                             color: const Color(0xFF34C759), 
                             chartType: 'staff',
                             onTap: () => Navigator.pushNamed(context, '/admin/profesionales')
                           )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                           Expanded(child: _buildVisualChartCard(
                             title: "Demora", 
                             value: "15m", 
                             diff: "-2m", 
                             color: Colors.orange, 
                             chartType: 'demora',
                             progress: 0.25, 
                             onTap: () => _showDelayAnalysis(context)
                           )),
                           const SizedBox(width: 12),
                           Expanded(child: _buildVisualChartCard(
                             title: "Ausentismo", 
                             value: "5%", 
                             diff: "Estable", 
                             color: Colors.purple, 
                             chartType: 'ausentismo',
                             progress: 0.05,
                             onTap: () => Navigator.pushNamed(context, '/admin/reportes')
                           )),
                        ],
                      ),

                      const SizedBox(height: 24),
                      
                      // NAV BUTTONS
                      Row(
                        children: [
                          _buildNavButton(context, Icons.calendar_month_rounded, "Turnos", () => Navigator.pushNamed(context, '/admin/turnos')),
                          const SizedBox(width: 12),
                          _buildNavButton(context, Icons.list_alt_rounded, "Pacientes", () => Navigator.pushNamed(context, '/medico/buscar-paciente')),
                          const SizedBox(width: 12),
                          _buildNavButton(context, Icons.medical_services_rounded, "Profesionales", () => Navigator.pushNamed(context, '/admin/profesionales')),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                 // LIST
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 18),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text("Pacientes en Espera", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF083866))),
                       TextButton(onPressed: () => Navigator.pushNamed(context, '/admin/turnos'), child: const Text("Ver todos", style: TextStyle(color: Color(0xFF2376F6)))),
                     ],
                   ),
                 ),
                 const SizedBox(height: 8),
                 _buildPatientQueueList(),
                 
                 const SizedBox(height: 40),
               ]
             ),
           ),
         ),
       )
     ]
   )
 );
}

  Widget _buildPatientQueueList() {
    final filteredQueue = _queue.where((item) {
       final q = _searchQuery.toLowerCase();
       return item['name'].toString().toLowerCase().contains(q) || 
              item['details'].toString().toLowerCase().contains(q);
    }).toList();

    if (filteredQueue.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text("No se encontraron pacientes", style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: filteredQueue.map((item) {
          return _buildQueueItem(item['time'], item['name'], item['details'], item['status'] == 'waiting');
        }).toList(),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
             padding: const EdgeInsets.symmetric(vertical: 16),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(16),
               boxShadow: [BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
             ),
             child: Column(
               children: [
                 Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     color: const Color(0xFFE3F2FD),
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
      ),
    );
  }

  Widget _buildVisualChartCard({
    required String title, required String value, required String diff, 
    required Color color, required String chartType, 
    double progress = 0.0, VoidCallback? onTap
  }) {
    return SizedBox(
      height: 160, 
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), 
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [
                 BoxShadow(color: const Color(0xFF90A4AE).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 10)),
              ],
            ),
            // HARMONIC LAYOUT: Start with the Chart at the bottom (Background), then Text on top
            child: Stack(
              children: [
                // 1. HARMONIC CHART FOUNDATION (Full Bottom Width)
                if (chartType == 'turnos')
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    height: 80, // Substantial height for the "Landscape"
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                      child: CustomPaint(painter: WaveChartPainter(color: color)),
                    ),
                  ),
                if (chartType == 'staff')
                   Positioned(
                     left: 0, right: 0, bottom: 0,
                     height: 80, // Matching "Landscape" height
                     child: ClipRRect(
                       borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                       child: CustomPaint(painter: LineChartPainter(color: color)),
                     ),
                   ),
                
                // Radial stays as corner indicator (Personal/Metric specific)
                if (chartType == 'demora' || chartType == 'ausentismo')
                   Positioned(
                     right: 16, bottom: 16, 
                     width: 70, height: 70,
                     child: CustomPaint(
                        painter: RadialProgressPainter(color: color, progress: progress),
                        child: Center(
                          child: Icon(
                            chartType == 'demora' ? Icons.access_time_filled_rounded : Icons.person_off_rounded,
                            color: color.withOpacity(0.2), 
                            size: 24
                          ),
                        ),
                     ),
                   ),

                // 2. DATA LAYER (Lifted)
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(
                              chartType == 'turnos' ? Icons.calendar_today_rounded : 
                              chartType == 'staff' ? Icons.people_outline_rounded :
                              chartType == 'demora' ? Icons.timer_rounded : 
                              Icons.block_rounded,
                              size: 14, color: color
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(title, style: const TextStyle(color: Color(0xFF546E7A), fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Big Value
                      Text(
                        value, 
                        style: const TextStyle(
                          color: Color(0xFF263238), 
                          fontSize: 36, 
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          height: 1.0
                        )
                      ),
                      
                      const SizedBox(height: 8),

                      // Footer Trend Badge (Lifted above charts)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              // Semi-transparent white background to ensure legibility over charts
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black.withOpacity(0.05))
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  chartType == 'turnos' ? Icons.trending_up :
                                  (diff.contains('-') ? Icons.trending_down : Icons.trending_flat),
                                  size: 14, 
                                  color: chartType == 'turnos' ? Colors.blue[700] : 
                                         (diff.contains('-') || diff == 'Estable' ? Colors.green[700] : Colors.orange[700])
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  diff, 
                                  style: TextStyle(
                                    color: chartType == 'turnos' ? Colors.blue[700] :
                                           (diff.contains('-') || diff == 'Estable' || diff.contains('%') ? Colors.green[700] : Colors.orange[700]),
                                    fontSize: 11, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ],
                            ),
                          ),
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
    );
  }



  Widget _buildQueueItem(String time, String name, String details, bool isWait) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                   CircleAvatar(
                     backgroundColor: const Color(0xFFE3F2FD),
                     child: Text(name[0], style: const TextStyle(color: Color(0xFF1565C0))),
                   ),
                   const SizedBox(width: 12),
                   Expanded(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.access_time, "Horario", time),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.health_and_safety, "Detalle", details),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.info_outline, "Estado", isWait ? "En Sala de Espera" : "Ingresado"),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
                ElevatedButton(
                  onPressed: () {
                     Navigator.pop(context);
                     Navigator.pushNamed(context, '/medico/buscar-paciente'); 
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2376F6),
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Ver Historia Clínica")
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
               Column(
                 children: [
                   Text(
                     time,
                     style: const TextStyle(
                       fontWeight: FontWeight.bold,
                       color: Color(0xFF2376F6),
                       fontSize: 13,
                     ),
                   ),
                 ],
               ),
               const SizedBox(width: 16),
               
               Container(
                 height: 24, 
                 width: 1, 
                 color: Colors.grey[200], 
                 margin: const EdgeInsets.symmetric(horizontal: 4)
               ),
               const SizedBox(width: 12),

               Container(
                 padding: const EdgeInsets.all(6),
                 decoration: BoxDecoration(
                   color: isWait ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(
                   isWait ? Icons.access_time_rounded : Icons.check_circle_outline,
                   color: isWait ? const Color(0xFFFFA726) : const Color(0xFF43A047),
                   size: 16,
                 ),
               ),
               const SizedBox(width: 16),

               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       name,
                       style: const TextStyle(
                         fontWeight: FontWeight.bold,
                         fontSize: 14,
                         color: Color(0xFF0D1C2E),
                       ),
                     ),
                     const SizedBox(height: 2),
                     Text(
                       details,
                       style: TextStyle(
                         fontSize: 12,
                         color: Colors.grey[600],
                         ),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ],
                 ),
               ),

               InkWell(
                 onTap: () {
                   setState(() {
                      if (isWait) {
                        final index = _queue.indexWhere((element) => element['time'] == time);
                        if (index != -1) {
                          _queue[index]['status'] = 'checked_in';
                        }
                      }
                   });
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                     content: Text("Paciente $name ingresado"),
                     backgroundColor: const Color(0xFF34C759),
                     duration: const Duration(seconds: 2),
                   ));
                 },
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: isWait ? const Color(0xFF2376F6) : Colors.grey[300], 
                     shape: BoxShape.circle,
                   ),
                   child: const Icon(Icons.check, color: Colors.white, size: 18),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }

  void _showNotifications(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(children: [Icon(Icons.notifications_active_rounded, color: Colors.indigo), SizedBox(width: 12), Text("Alertas")]),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: const Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                ListTile(leading: Icon(Icons.verified_user_rounded, color: Colors.orange), title: Text("Solicitud de Acceso"), subtitle: Text("Dr. Perez solicita restablecer clave")),
                Divider(),
                ListTile(leading: Icon(Icons.analytics_rounded, color: Colors.blue), title: Text("Reporte Mensual"), subtitle: Text("El reporte de Diciembre está listo")),
              ]
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Entendido"))],
        ),
      );
  }

  void _showDelayAnalysis(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            const Text("Análisis de Demoras", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
            const SizedBox(height: 8),
            const Text("Promedio general: 15 minutos", style: TextStyle(fontSize: 16, color: Colors.blue)),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                 Expanded(
                   child: Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(16)), 
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                         const SizedBox(height: 8),
                         const Text("Pico Máximo", style: TextStyle(fontSize: 12, color: Colors.black54)),
                         const Text("32 min", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                         const Text("Jueves 14:00hs", style: TextStyle(fontSize: 11, color: Colors.black45)),
                       ],
                     ),
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(16)), 
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Icon(Icons.check_circle_outline, color: Colors.green),
                         const SizedBox(height: 8),
                         const Text("Mejor Horario", style: TextStyle(fontSize: 12, color: Colors.black54)),
                         const Text("5 min", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                         const Text("Martes 09:00hs", style: TextStyle(fontSize: 11, color: Colors.black45)),
                       ],
                     ),
                   ),
                 ),
              ],
            ),
            
            const SizedBox(height: 32),
            const Text("Tendencia Semanal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
              child: CustomPaint(painter: LineChartPainter(color: Colors.orange)), // Reusing Painter
            )
          ],
        ),
      ),
    );
  }
}
