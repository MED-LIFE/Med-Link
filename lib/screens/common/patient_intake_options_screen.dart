import 'package:flutter/material.dart';
import '../../widgets/patient/standard_header.dart';
import '../../widgets/common/bouncing_card.dart';
import 'patient_intake_wizard_screen.dart';
import '../admin/admin_patient_import_screen.dart';

class PatientIntakeOptionsScreen extends StatelessWidget {
  const PatientIntakeOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      body: SafeArea(
        child: Column(
          children: [
            const StandardPageHeader(
              title: "Alta de Paciente",
              subtitle: "Seleccione el método de carga",
              imagePath: 'assets/images/ilustracion_search_patient.png',
              isLarge: false,
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildOptionCard(
                      context,
                      title: "Carga Individual",
                      subtitle: "Formulario paso a paso para un nuevo paciente.",
                      icon: Icons.person_add_rounded,
                      color: const Color(0xFF2376F6),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientIntakeWizardScreen())),
                    ),
                    const SizedBox(height: 24),
                    _buildOptionCard(
                      context,
                      title: "Carga Masiva",
                      subtitle: "Importar lista desde Excel o CSV.",
                      icon: Icons.upload_file_rounded,
                      color: const Color(0xFF7E57C2),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPatientImportScreen())),
                    ),
                    
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return BouncingCard(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
