import 'package:flutter/material.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/common/bouncing_card.dart';
import '../../widgets/patient/standard_header.dart';

class AdminProfessionalsScreen extends StatefulWidget {
  const AdminProfessionalsScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfessionalsScreen> createState() => _AdminProfessionalsScreenState();
}

class _AdminProfessionalsScreenState extends State<AdminProfessionalsScreen> {
  final List<Map<String, dynamic>> doctors = [
    {'name': 'Dr. René Favaloro', 'specialty': 'Cardiología', 'status': 'Activo', 'patients': 120, 'email': 'rene.f@hospital.com', 'phone': '+54 11 1234-5678', 'matricula': 'MN 12345'},
    {'name': 'Dra. Cecilia Grierson', 'specialty': 'Pediatría', 'status': 'Activo', 'patients': 85, 'email': 'c.grierson@hospital.com', 'phone': '+54 11 8765-4321', 'matricula': 'MN 67890'},
    {'name': 'Dr. Salvador Mazza', 'specialty': 'Infectología', 'status': 'Licencia', 'patients': 45, 'email': 's.mazza@hospital.com', 'phone': '+54 11 1111-2222', 'matricula': 'MN 11223'},
    {'name': 'Dr. Bernardo Houssay', 'specialty': 'Clinica Médica', 'status': 'Activo', 'patients': 150, 'email': 'b.houssay@hospital.com', 'phone': '+54 11 3333-4444', 'matricula': 'MN 33445'},
    {'name': 'Dra. Julieta Lanteri', 'specialty': 'Psiquiatría', 'status': 'Inactivo', 'patients': 0, 'email': 'j.lanteri@hospital.com', 'phone': '+54 11 5555-6666', 'matricula': 'MN 55667'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      drawer: const MainDrawer(role: UserRole.admin),
      body: Column(
        children: [
          // HEADER & BANNER SECTION (Premium Blue Gradient)
          const StandardPageHeader(
             title: "Gestión de Profesionales",
             subtitle: "Administración de Staff",
             imagePath: 'assets/images/ilustracion_mis_medicos.png',
             isLarge: false,
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: doctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                 final doc = doctors[index];
                 Color statusColor;
                 Color statusBg;
                 switch(doc['status']) {
                   case 'Activo': 
                     statusColor = const Color(0xFF34C759); 
                     statusBg = const Color(0xFFE8F5E9);
                     break;
                   case 'Licencia': 
                     statusColor = const Color(0xFFFF9500); 
                     statusBg = const Color(0xFFFFF3E0);
                     break;
                   default: 
                     statusColor = Colors.grey;
                     statusBg = Colors.grey.shade100;
                 }
      
                 return BouncingCard(
                   onTap: () => _showDoctorDetails(doc),
                   child: Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(20),
                       boxShadow: [
                         BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
                       ],
                     ),
                     child: Row(
                       children: [
                         Container(
                           width: 56, height: 56,
                           decoration: BoxDecoration(
                             gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
                             borderRadius: BorderRadius.circular(16),
                             border: Border.all(color: Colors.white, width: 2),
                             boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 8)],
                           ),
                           child: Center(
                             child: Text(
                               doc['name'].length > 4 ? doc['name'].substring(4, 6) : "Dr",
                               style: const TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold, fontSize: 18),
                             ),
                           ),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D1C2E))),
                               const SizedBox(height: 4),
                               Text(doc['specialty'], style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                             ],
                           ),
                         ),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: [
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                               decoration: BoxDecoration(
                                 color: statusBg,
                                 borderRadius: BorderRadius.circular(10),
                               ),
                               child: Text(
                                 doc['status'].toString().toUpperCase(),
                                 style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                               ),
                             ),
                             const SizedBox(height: 6),
                             Row(
                               children: [
                                 Icon(Icons.people_rounded, size: 12, color: Colors.grey[400]),
                                 const SizedBox(width: 4),
                                 Text("${doc['patients']}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                               ],
                             )
                           ],
                         ),
                       ],
                     ),
                   ),
                 );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProfessionalDialog(),
        backgroundColor: const Color(0xFF2376F6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nuevo Profesional", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showDoctorDetails(Map<String, dynamic> doc) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Banner & Avatar
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Banner (Cloud/Sky aesthetic)
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        colors: [Color(0xFFE3F2FD), Color(0xFFF1F8FF)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight
                      ),
                      image: DecorationImage(
                        image: AssetImage("assets/images/pattern_bg.png"), // Optional texture
                        opacity: 0.05,
                        fit: BoxFit.cover,
                      )
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.edit_rounded, size: 20, color: Color(0xFF0D1C2E)),
                        ),
                      ),
                    ),
                  ),
                  // Overlapping Avatar
                  Transform.translate(
                    offset: const Offset(0, 40),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Colors.white], begin: Alignment.topLeft),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: Center(
                          child: Text(
                            doc['name'].length > 4 ? doc['name'].substring(4, 6) : "Dr",
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF083866)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50), // Space for avatar overlap
              
              // 2. Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0D1C2E))),
                    const SizedBox(height: 4),
                    Text(
                      "Especilista en ${doc['specialty']} enfocado en brindar\natención de calidad y seguimiento personalizado.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 16),
              
              // 3. Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("${doc['patients']}K", "Pacientes"),
                  _buildStatItem(doc['status'] == 'Activo' ? "98%" : "0%", "Asistencia"),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 4. Actions Footer
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFfafafa),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.email_outlined), color: Colors.grey, onPressed: () {}),
                    const SizedBox(width: 20),
                    IconButton(icon: const Icon(Icons.phone_outlined), color: Colors.grey, onPressed: () {}),
                    const SizedBox(width: 20),
                    IconButton(icon: const Icon(Icons.calendar_month_outlined), color: const Color(0xFF2376F6), onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0D1C2E))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showAddProfessionalDialog({Map<String, dynamic>? professional, int? index}) {
    // Simplified dialog logic for brevity - keeping core structure but updating aesthetics lightly if needed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(professional != null ? "Editar Profesional" : "Nuevo Profesional", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text("Formulario de profesional (Simulado)"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF083866), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
