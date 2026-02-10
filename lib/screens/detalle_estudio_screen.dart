import 'package:flutter/material.dart';
import '../widgets/patient/standard_header.dart';

class DetalleEstudioScreen extends StatelessWidget {
  final Map<String, dynamic> estudio;
  
  const DetalleEstudioScreen({super.key, required this.estudio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F1),
      body: Column(
        children: [
          StandardPageHeader(
            title: "Detalle de Estudio",
            subtitle: estudio['tipo'] ?? "Estudio",
            imagePath: 'assets/images/ilustracion_historia_clinica.png', // Reusing illustration
            isLarge: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                     BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(Icons.calendar_today_rounded, "Fecha", estudio['fecha'] ?? "-"),
                    const Divider(height: 32),
                     _buildRow(Icons.person_outline_rounded, "Profesional", estudio['profesional'] ?? "-"),
                    const Divider(height: 32),
                     _buildRow(Icons.info_outline_rounded, "Estado", estudio['estado'] ?? "-"),
                    const Divider(height: 32),
                    const Text("Observaciones", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF083866))),
                    const SizedBox(height: 8),
                    Text(
                      estudio['observaciones'] ?? "Sin observaciones adicionales.",
                      style: TextStyle(color: Colors.grey[600], height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Descarga simulada de PDF...")));
                        },
                        icon: const Icon(Icons.download_rounded),
                        label: const Text("Descargar Informe"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2376F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2376F6), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Color(0xFF0D1C2E), fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        )
      ],
    );
  }
}
