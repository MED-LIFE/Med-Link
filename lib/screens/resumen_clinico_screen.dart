import 'package:flutter/material.dart';
import '../widgets/patient/standard_header.dart';
import '../widgets/common/bouncing_card.dart';

class ResumenClinicoScreen extends StatelessWidget {
  const ResumenClinicoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FCFF),
          child: Column(
            children: [
              const StandardPageHeader(
                title: "Resumen Clínico",
                subtitle: "Evolución y diagnósticos",
                imagePath: "assets/images/ilustracion_resumen_clinico.png", // New asset
                isLarge: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Example content matching "Resumen Completo" context
                    _buildSectionTitle("Diagnósticos Activos"),
                    _buildInfoCard(
                      icon: Icons.monitor_heart_outlined,
                      title: "Hipertensión Arterial",
                      subtitle: "Controlada con medicación. Evolución favorable.",
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.bloodtype_outlined,
                      title: "Diabetes Tipo 2",
                      subtitle: "En tratamiento. Valores estables últimas 4 semanas.",
                      color: Colors.orange,
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle("Antecedentes"),
                     _buildInfoCard(
                      icon: Icons.history_edu_rounded,
                      title: "Cirugía Apendicitis (2015)",
                      subtitle: "Sin complicaciones post-operatorias.",
                      color: Colors.purple,
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle("Última Evolución (15/08/2025)"),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                           BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.08), blurRadius: 20, offset: const Offset(0,8))
                        ]
                      ),
                      child: const Text(
                        "Paciente acude a control anual. Refiere buena tolerancia a la medicación actual. Se solicitan estudios de laboratorio de rutina y electrocardiograma. Se indica continuar con el mismo esquema terapéutico.",
                        style: TextStyle(height: 1.5, color: Color(0xFF4B5563), fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return BouncingCard(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: color.withOpacity(0.1), blurRadius: 15, offset: const Offset(0,5))
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
