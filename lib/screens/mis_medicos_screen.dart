import 'package:flutter/material.dart';
import '../widgets/common/bouncing_card.dart';
import '../widgets/patient/standard_header.dart';

class MisMedicosScreen extends StatelessWidget {
  const MisMedicosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final doctors = [
       {"name": "Dra. Laura Pérez", "specialty": "Oncología Clínica", "rating": "4.9", "online": true, "image": "assets/images/doctors/doctor_1.png"},
       {"name": "Dr. Miguel Ángel Rossi", "specialty": "Cirugía General", "rating": "4.8", "online": false, "image": "assets/images/doctors/doctor_2.png"},
       {"name": "Dra. Sofía Martínez", "specialty": "Dermatología", "rating": "5.0", "online": true, "image": "assets/images/doctors/doctor_3.png"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FCFF),
          child: Column(
            children: [
              const StandardPageHeader(
                title: "Mis médicos", 
                subtitle: "Tus especialistas de confianza",
                imagePath: "assets/images/ilustracion_mis_medicos.png", 
                isLarge: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                           // Lista de Médicos
                           ...doctors.map((doc) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: BouncingCard(
                onTap: () => _showDoctorDetail(context, doc),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2376F6).withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                             padding: const EdgeInsets.all(4),
                             decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                             child: CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFFE3F2FD),
                              backgroundImage: doc["image"] != null ? AssetImage(doc["image"] as String) : null,
                              child: doc["image"] == null ? Text(
                                doc["name"].toString().split(" ").last[0], 
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))
                              ) : null,
                            ),
                          ),
                          if (doc["online"] == true)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc["name"].toString(), 
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.w700, 
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.3,
                              )
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc["specialty"].toString(), 
                              style: const TextStyle(
                                fontSize: 14, 
                                color: Color(0xFF6B7280), 
                                fontWeight: FontWeight.w500
                              )
                            ),
                            const SizedBox(height: 8),
                            Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                 color: const Color(0xFFFFF7ED),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    doc["rating"].toString(), 
                                    style: const TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold, 
                                      color: Color(0xFFB45309) // Darker orange
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                       IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444)),
                          onPressed: () {},
                       ),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ],
  ),
),
            ],
          ),
        ),
      ),
    );
  }

  void _showDoctorDetail(BuildContext context, Map<String, dynamic> doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
             // Handle
             Center(
               child: Container(
                 width: 40, height: 4,
                 margin: const EdgeInsets.only(top: 12, bottom: 20),
                 decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
               ),
             ),
             
             Expanded(
               child: ListView(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                             padding: const EdgeInsets.all(4),
                             decoration: BoxDecoration(
                               shape: BoxShape.circle,
                               border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.2), width: 1)
                             ),
                             child: CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFFE3F2FD),
                              backgroundImage: doc["image"] != null ? AssetImage(doc["image"] as String) : null,
                              child: doc["image"] == null ? Text(
                                doc["name"].toString().split(" ").last[0], 
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))
                              ) : null,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                            ),
                            child: const Icon(Icons.videocam_rounded, color: Color(0xFF10B981), size: 20),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      doc["name"].toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    Text(
                      doc["specialty"].toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Stats Row
                    Row(
                      children: [
                        Expanded(child: _buildStatItem("Pacientes", "1.2k+", Icons.people_alt_rounded)),
                        Container(width: 1, height: 40, color: Colors.grey[200]),
                        Expanded(child: _buildStatItem("Experiencia", "10 años", Icons.work_rounded)),
                        Container(width: 1, height: 40, color: Colors.grey[200]),
                        Expanded(child: _buildStatItem("Reseñas", "4.9", Icons.star_rounded)),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const Text("Última Consulta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF083866))),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                           Container(
                             padding: const EdgeInsets.all(10),
                             decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                             child: const Icon(Icons.history_edu_rounded, color: Color(0xFF2376F6)),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text("Control General", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                                 Text("15 Ago 2024", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                               ],
                             ),
                           ),
                           const Icon(Icons.chevron_right_rounded, color: Colors.grey)
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                 ],
               ),
             ),
             
             Padding(
               padding: const EdgeInsets.all(24),
               child: SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: () {
                     Navigator.pop(context);
                     // Navigate to appointments...
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF2376F6),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     elevation: 0,
                   ),
                   child: const Text("Agendar Turno", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                 ),
               ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}
