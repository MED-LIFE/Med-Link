import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zanoo/screens/completar_perfil_screen.dart';
import 'package:zanoo/screens/sacar_turno_screen.dart';
import 'package:zanoo/screens/mi_perfil_screen.dart';
import 'package:zanoo/screens/estudios_screen.dart';
import 'package:zanoo/services/pdf_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zanoo/widgets/common/premium_access_dialog.dart';
import 'dart:math' as math;

import '../../models/medical_history_model.dart';
import '../../repositories/history_repository.dart';
import '../../widgets/patient/loading_widgets.dart';
import '../../widgets/patient/info_cards.dart';
import '../../widgets/patient/history_banners.dart';
import '../../widgets/patient/standard_header.dart';
import '../../widgets/common/bouncing_card.dart';

// =============== SUBPANTALLAS DETALLADAS ===================
class DiagnosticoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> diagnostico;
  
  const DiagnosticoDetailScreen({
    Key? key,
    required this.diagnostico,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoryRepository.backgroundColor,

      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FCFF),
          child: Column(
            children: [
               StandardPageHeader(
                  title: "Diagnóstico", 
                  subtitle: diagnostico["nombre"] ?? "Detalle médico",
                  imagePath: "assets/images/ilustracion_historia_clinica.png", 
                  isLarge: false,
               ),
               Expanded(
                 child: ListView(
                   padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                   children: [
                      // Información principal del diagnóstico
                      _buildDiagnosticCard(),
                      
                      const SizedBox(height: 20),
                      
                      // Indicadores y métricas
                      _buildIndicatorsSection(),
                      
                      const SizedBox(height: 20),
                      
                      // Evolución y tendencias
                      _buildEvolutionSection(),
                      
                      const SizedBox(height: 20),
                      
                      // Acciones y recomendaciones
                      _buildActionsSection(context),
                      
                      const SizedBox(height: 20), 
                   ],
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HistoryRepository.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    diagnostico["codigo"] ?? "N/A",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: HistoryRepository.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusChip(diagnostico["estado"] ?? "Activo"),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              diagnostico["nombre"] ?? "Sin nombre",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: HistoryRepository.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              diagnostico["descripcion"] ?? "Sin descripción disponible",
              style: const TextStyle(
                fontSize: 15,
                color: HistoryRepository.mediumGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            
            // Información adicional
            _buildInfoRow("Fecha diagnóstico", diagnostico["fechaDiagnostico"] ?? "N/A"),
            _buildInfoRow("Médico responsable", diagnostico["medico"] ?? "N/A"),
            _buildInfoRow("Severidad", diagnostico["severidad"] ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'activo':
        color = Colors.orange;
        break;
      case 'controlado':
        color = Colors.green;
        break;
      case 'en tratamiento':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // 6->8, 12->16 (8pt)
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16), // 12->16 (8pt)
          border: Border.all(color: color.withOpacity(0.3)),
        ),
      child: Text(
        status,
        style: TextStyle(
          color: Color.lerp(color, Colors.black, 0.3)!,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildIndicatorsSection() {
    final indicadores = diagnostico["indicadores"] as Map<String, dynamic>?;
    if (indicadores == null || indicadores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Indicadores recientes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HistoryRepository.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ...indicadores.entries.map((entry) => 
              _buildIndicatorTile(entry.key, entry.value.toString())
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorTile(String key, String value) {
    IconData icon;
    Color color;
    
    switch (key.toLowerCase()) {
      case 'presionultima':
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case 'riesgocardiovascular':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'glucemiaultima':
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      default:
        icon = Icons.analytics;
        color = HistoryRepository.primaryColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatKey(key),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: HistoryRepository.darkBlue,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: HistoryRepository.mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    switch (key.toLowerCase()) {
      case 'presionultima':
        return 'Presión arterial';
      case 'riesgocardiovascular':
        return 'Riesgo cardiovascular';
      case 'glucemiaultima':
        return 'Glucemia';
      case 'hba1c':
        return 'Hemoglobina glicosilada';
      case 'ultimamejora':
        return 'Última mejora';
      default:
        return key.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
    }
  }

  Widget _buildEvolutionSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: HistoryRepository.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Evolución",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoryRepository.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progreso simulado
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.green.shade400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "70% de mejora desde el diagnóstico inicial",
              style: TextStyle(
                color: HistoryRepository.mediumGray,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tendencia
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Tendencia positiva en los últimos controles",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Acciones recomendadas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HistoryRepository.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionButton(
              "Solicitar nuevo turno",
              Icons.calendar_today,
              HistoryRepository.primaryColor,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Redirigiendo a solicitud de turnos...")),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildActionButton(
              "Ver medicación actual",
              Icons.medication,
              Colors.green,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mostrando medicación actual...")),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildActionButton(
              "Descargar informe",
              Icons.download,
              Colors.orange,
              () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Generando informe PDF...")),
                );
                final user = FirebaseAuth.instance.currentUser;
                await PdfService().generateAndPrintClinicalHistory(
                  user?.displayName ?? "Paciente Zanoo",
                  "12.345.678", // Mock DNI for demo
                  [
                    {
                      'date': DateTime.now().toString().substring(0,10),
                      'title': diagnostico['nombre'].toString(),
                      'description': diagnostico['descripcion'].toString()
                    },
                    // Add some mock history context
                    {'date': '01/01/2025', 'title': 'Consulta Inicial', 'description': 'Evaluación general.'},
                  ]
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: HistoryRepository.mediumGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "No especificado",
              style: const TextStyle(
                color: HistoryRepository.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TurnosDetailScreen extends StatelessWidget {
  const TurnosDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoryRepository.backgroundColor,

      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FCFF), // Consistent background
          child: Column(
            children: [
               Stack(
                 children: [
                   const StandardPageHeader(
                      title: "Historial de Turnos", 
                      subtitle: "Tus visitas y controles",
                      imagePath: "assets/images/ilustracion_historia_clinica.png", 
                      isLarge: false,
                   ),
                   Positioned(
                     top: 24, 
                     right: 16,
                     child: GestureDetector(
                       onTap: () => _showFilterDialog(context),
                       child: Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.9),
                           shape: BoxShape.circle,
                           boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                         ),
                         child: const Icon(Icons.filter_list, color: HistoryRepository.primaryColor, size: 24),
                       ),
                     ),
                   )
                 ],
               ),
               Expanded(
                 child: ListView(
                   padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                   children: [
                     // Estadísticas rápidas
                     _buildStatsCards(),
                     
                     const SizedBox(height: 20),
          
                     // Lista de turnos
                     ...HistoryRepository.turnosMock.map((turno) => 
                       EnhancedTurnoTile(
                         turno: turno,
                         onTap: () => _showTurnoDetail(context, turno),
                       )
                     ).toList(),
                   ],
                 ),
               ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SacarTurnoScreen()),
          );
        },
        backgroundColor: HistoryRepository.primaryColor,
        label: const Text("Nuevo turno", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Total",
            "${HistoryRepository.turnosMock.length}",
            Icons.event,
            HistoryRepository.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Realizados",
            "${HistoryRepository.turnosMock.where((t) => t['estado'] == 'Realizado').length}",
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Próximos",
            "${HistoryRepository.turnosMock.where((t) => t['estado'] == 'Próximo').length}",
            Icons.schedule,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // 12 -> 16
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16, // 8 -> 16
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: HistoryRepository.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Filtrar turnos"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Todos los turnos"),
              leading: Radio(value: "todos", groupValue: "todos", onChanged: (_) {}),
            ),
            ListTile(
              title: const Text("Solo realizados"),
              leading: Radio(value: "realizados", groupValue: "todos", onChanged: (_) {}),
            ),
            ListTile(
              title: const Text("Solo próximos"),
              leading: Radio(value: "proximos", groupValue: "todos", onChanged: (_) {}),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Por Profesional", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
             ListTile(
              title: const Text("Dra. Pérez"),
              leading: Radio(value: "perez", groupValue: "todos", onChanged: (_) {}),
            ),
             ListTile(
              title: const Text("Dr. Ledesma"),
              leading: Radio(value: "ledesma", groupValue: "todos", onChanged: (_) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Aplicar"),
          ),
        ],
      ),
    );
  }

  void _showTurnoDetail(BuildContext context, Map<String, dynamic> turno) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TurnoDetailBottomSheet(turno: turno),
    );
  }
}

class EnhancedTurnoTile extends StatelessWidget {
  final Map<String, dynamic> turno;
  final VoidCallback onTap;

  const EnhancedTurnoTile({
    Key? key,
    required this.turno,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BouncingCard(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // 12 -> 16
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getEstadoColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12), // 8 -> 12
                    ),
                    child: Icon(
                      _getEstadoIcon(),
                      color: _getEstadoColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16), // 12 -> 16
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turno["fecha"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: HistoryRepository.darkBlue,
                          ),
                        ),
                        Text(
                          "${turno["hora"]} • ${turno["profesional"]}",
                          style: const TextStyle(
                            color: HistoryRepository.mediumGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEstadoColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      turno["estado"] ?? "",
                      style: TextStyle(
                        color: _getEstadoColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (turno["motivo"] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        turno["motivo"],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor() {
    switch (turno["estado"]) {
      case "Realizado":
        return Colors.green;
      case "Ausente":
        return Colors.red;
      case "Próximo":
        return Colors.orange;
      case "Pendiente":
        return HistoryRepository.primaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon() {
    switch (turno["estado"]) {
      case "Realizado":
        return Icons.check_circle;
      case "Ausente":
        return Icons.cancel;
      case "Próximo":
        return Icons.schedule;
      case "Pendiente":
        return Icons.pending;
      default:
        return Icons.circle;
    }
  }
}

class TurnoDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> turno;

  const TurnoDetailBottomSheet({
    Key? key,
    required this.turno,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HistoryRepository.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event_note,
                  color: HistoryRepository.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detalle del turno",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HistoryRepository.darkBlue,
                      ),
                    ),
                    Text(
                      turno["fecha"] ?? "",
                      style: const TextStyle(
                        color: HistoryRepository.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Detalles
          _buildDetailRow("Fecha", turno["fecha"]),
          _buildDetailRow("Hora", turno["hora"]),
          _buildDetailRow("Profesional", turno["profesional"]),
          _buildDetailRow("Especialidad", turno["especialidad"]),
          _buildDetailRow("Lugar", "Consultorio 4, Piso 2"), // Added
          _buildDetailRow("Dirección", "Av. San Martín 1234"), // Added
          _buildDetailRow("Estado", turno["estado"]),
          
          if (turno["motivo"] != null)
            _buildDetailRow("Motivo", turno["motivo"]),
          
          if (turno["consultorio"] != null)
            _buildDetailRow("Consultorio", turno["consultorio"]),
          
          if (turno["observaciones"] != null && turno["observaciones"].isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "Observaciones:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HistoryRepository.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                turno["observaciones"],
                style: const TextStyle(
                  color: HistoryRepository.mediumGray,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Acciones
          if (turno["estado"] == "Próximo") ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // PREMIUM LOCK
                  if (!PremiumAccessHelper.canAccessFeature()) {
                     PremiumAccessHelper.showPremiumDialog(context, "Video Consultas");
                     return;
                  }

                  final Uri url = Uri.parse('https://meet.jit.si/Zanoo_Consulta_Patient');
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al abrir sala virtual")));
                  }
                },
                icon: const Icon(Icons.video_camera_front_rounded),
                label: const Text("Entrar a Sala Virtual"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16), // Prominent
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: Colors.purple.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Mock Calendar Action
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agregado al calendario")));
                },
                icon: const Icon(Icons.calendar_today_rounded, size: 18),
                label: const Text("Agendar en Calendario"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: HistoryRepository.primaryColor),
                  foregroundColor: HistoryRepository.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // ✅ CORREGIDO: Función de cancelación implementada
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text("Cancelar turno"),
                      content: const Text("¿Estás seguro que deseas cancelar este turno? Esta acción no se puede deshacer."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("No"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Turno cancelado correctamente"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text("Sí, cancelar", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.cancel),
                label: const Text("Cancelar turno"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text("Cerrar"),
              style: OutlinedButton.styleFrom(
                foregroundColor: HistoryRepository.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: HistoryRepository.mediumGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(
                color: HistoryRepository.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicamentosDetailScreen extends StatefulWidget {
  const MedicamentosDetailScreen({Key? key}) : super(key: key);

  @override
  State<MedicamentosDetailScreen> createState() => _MedicamentosDetailScreenState();
}

class _MedicamentosDetailScreenState extends State<MedicamentosDetailScreen> {
  String _filtro = "todos";
  String _busqueda = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoryRepository.backgroundColor,
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FCFF),
          child: Column(
             children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,

              itemCount: _medicamentosFiltrados.length + 2, // +2 for header items
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const StandardPageHeader(
                    title: "Medicamentos",
                    subtitle: "Gestioná tu medicación",
                    imagePath: "assets/images/ilustracion_mis_recetas.png",
                    isLarge: false,
                  );
                }

                
                if (index == 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0).copyWith(bottom: 14),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, size: 20),
                            hintText: "Buscar medicamentos...",
                            hintStyle: const TextStyle(fontSize: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (value) => setState(() => _busqueda = value),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip("Todos", "todos"),
                              _buildFilterChip("Activos", "activos"),
                              _buildFilterChip("Con alertas", "alertas"),
                              _buildFilterChip("Próximos", "vencimiento"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Medicamentos list items
                final medicamentoIndex = index - 2;
                if (medicamentoIndex < 0 || medicamentoIndex >= _medicamentosFiltrados.length) return const SizedBox.shrink();
                
                final medicamento = _medicamentosFiltrados[medicamentoIndex];
                return EnhancedMedicamentoTile(
                  medicamento: medicamento,
                  onTap: () => _showMedicamentoDetail(medicamento),
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  List<Map<String, dynamic>> get _medicamentosFiltrados {
    var lista = HistoryRepository.medicamentosMock;
    
    // Aplicar filtro
    switch (_filtro) {
      case "activos":
        lista = lista.where((m) => m["activo"] == true).toList();
        break;
      case "alertas":
        lista = lista.where((m) => (m["alertas"] as List).isNotEmpty).toList();
        break;
      case "vencimiento":
        // Simulación de próximos a vencer
        lista = lista.where((m) => m["nombre"].toString().contains("Enalapril")).toList();
        break;
    }
    
    // Aplicar búsqueda
    if (_busqueda.isNotEmpty) {
      lista = lista.where((m) => 
        m["nombre"].toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
        m["principioActivo"].toString().toLowerCase().contains(_busqueda.toLowerCase())
      ).toList();
    }
    
    return lista;
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filtro == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6), // Reducido de 8 a 6
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _filtro = value),
        backgroundColor: Colors.white,
        selectedColor: HistoryRepository.primaryColor.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Agregado padding más compacto
        labelStyle: TextStyle(
          color: isSelected ? HistoryRepository.primaryColor : HistoryRepository.mediumGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12, // Reducido tamaño de fuente
        ),
      ),
    );
  }

  void _showMedicamentoDetail(Map<String, dynamic> medicamento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MedicamentoDetailBottomSheet(medicamento: medicamento),
    );
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Agregar medicamento"),
        content: const Text(
          "Para agregar un nuevo medicamento a tu lista, consulta con tu médico tratante.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }
}

class EnhancedMedicamentoTile extends StatelessWidget {
  final Map<String, dynamic> medicamento;
  final VoidCallback onTap;

  const EnhancedMedicamentoTile({
    Key? key,
    required this.medicamento,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alertas = medicamento["alertas"] as List;
    final hasAlertas = alertas.isNotEmpty;

    return BouncingCard(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // 10 -> 12
        padding: const EdgeInsets.all(16), // 14 -> 16
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8), // 6 -> 8
                    decoration: BoxDecoration(
                      color: HistoryRepository.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12), // 8 -> 12
                    ),
                    child: Icon(
                      Icons.medication,
                      color: HistoryRepository.primaryColor,
                      size: 20, // 18 -> 20
                    ),
                  ),
                  const SizedBox(width: 16), // 10 -> 16
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicamento["nombre"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // 14 -> 16
                            color: HistoryRepository.darkBlue,
                          ),
                        ),
                        Text(
                          medicamento["indicacion"] ?? "",
                          style: const TextStyle(
                            color: HistoryRepository.mediumGray,
                            fontSize: 13, // 12 -> 13
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasAlertas)
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.orange,
                      size: 20, // 18 -> 20
                    ),
                ],
              ),
              
              const SizedBox(height: 12), // 10 -> 12
              
              // Información adicional
              Row(
                children: [
                  _buildInfoChip(
                    Icons.category,
                    medicamento["categoria"] ?? "",
                    Colors.blue,
                  ),
                  const SizedBox(width: 8), // 6 -> 8
                  _buildInfoChip(
                    Icons.person,
                    medicamento["medico"] ?? "",
                    Colors.green,
                  ),
                ],
              ),
              
              const SizedBox(height: 8), // 6 -> 8
              
              // Pedidos y órdenes
              Row(
                children: [
                  Icon(Icons.shopping_cart, size: 16, color: Colors.orange[800]), // 14 -> 16
                  const SizedBox(width: 4), // 3 -> 4
                  Text(
                    "${medicamento["pedidos"]} pedidos",
                    style: TextStyle(fontSize: 12, color: Colors.orange[800]), // 11 -> 12
                  ),
                  const SizedBox(width: 16), // 12 -> 16
                  Icon(Icons.receipt_long, size: 16, color: Colors.teal[700]), // 14 -> 16
                  const SizedBox(width: 4), // 3 -> 4
                  Text(
                    "${medicamento["ordenes"]} órdenes",
                    style: TextStyle(fontSize: 12, color: Colors.teal[700]), // 11 -> 12
                  ),
                ],
              ),
              
              if (hasAlertas) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8), // 6 -> 8
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8), // 6 -> 8
                      Expanded(
                        child: Text(
                          alertas.first,
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reducido padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color), // Reducido de 12 a 10
          const SizedBox(width: 3), // Reducido de 4 a 3
          Text(
            text,
            style: TextStyle(
              fontSize: 10, // Reducido de 11 a 10
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MedicamentoDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> medicamento;

  const MedicamentoDetailBottomSheet({
    Key? key,
    required this.medicamento,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: HistoryRepository.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medication,
                        color: HistoryRepository.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicamento["nombre"] ?? "",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: HistoryRepository.darkBlue,
                            ),
                          ),
                          Text(
                            medicamento["principioActivo"] ?? "",
                            style: const TextStyle(
                              color: HistoryRepository.mediumGray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Secciones de información
                _buildInfoSection("Información general", [
                  _buildDetailRow("Indicación", medicamento["indicacion"]),
                  _buildDetailRow("Vía de administración", medicamento["viaAdministracion"]),
                  _buildDetailRow("Categoría", medicamento["categoria"]),
                  _buildDetailRow("Médico prescriptor", medicamento["medico"]),
                ]),
                
                const SizedBox(height: 20),
                
                _buildInfoSection("Fechas importantes", [
                  _buildDetailRow("Fecha de inicio", medicamento["fechaInicio"]),
                  _buildDetailRow("Fecha de vencimiento", medicamento["fechaVencimiento"]),
                ]),
                
                const SizedBox(height: 20),
                
                _buildInfoSection("Gestión", [
                  _buildDetailRow("Pedidos realizados", "${medicamento["pedidos"]}"),
                  _buildDetailRow("Órdenes generadas", "${medicamento["ordenes"]}"),
                ]),
                
                if ((medicamento["alertas"] as List).isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildAlertsSection(),
                ],
                
                const SizedBox(height: 24),
                
                // Acciones
                _buildActionsSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HistoryRepository.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: HistoryRepository.mediumGray,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(
                color: HistoryRepository.darkBlue,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    final alertas = medicamento["alertas"] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alertas importantes",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        ...alertas.map((alerta) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alerta.toString(),
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            // ✅ CORREGIDO: Función de solicitar receta implementada
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Solicitar receta"),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("¿Deseas solicitar una nueva receta para este medicamento?"),
                      SizedBox(height: 16),
                      Text(
                        "El médico recibirá tu solicitud y te contactará para coordinar la nueva prescripción.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Solicitud de receta enviada correctamente"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text("Solicitar"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.receipt),
            label: const Text("Solicitar receta"),
            style: ElevatedButton.styleFrom(
              backgroundColor: HistoryRepository.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            // ✅ CORREGIDO: Función de programar recordatorio implementada
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Programar recordatorio"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Configurar recordatorio para este medicamento"),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Frecuencia",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: "diario", child: Text("Diario")),
                          DropdownMenuItem(value: "12h", child: Text("Cada 12 horas")),
                          DropdownMenuItem(value: "8h", child: Text("Cada 8 horas")),
                          DropdownMenuItem(value: "semanal", child: Text("Semanal")),
                        ],
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Recordatorio programado correctamente"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text("Programar"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.alarm),
            label: const Text("Programar recordatorio"),
            style: OutlinedButton.styleFrom(
              foregroundColor: HistoryRepository.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text("Cerrar"),
            style: TextButton.styleFrom(
              foregroundColor: HistoryRepository.mediumGray,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class SignosVitalesScreen extends StatefulWidget {
  const SignosVitalesScreen({Key? key}) : super(key: key);

  @override
  State<SignosVitalesScreen> createState() => _SignosVitalesScreenState();
}

class _SignosVitalesScreenState extends State<SignosVitalesScreen> {
  String _periodoSeleccionado = "3m";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoryRepository.backgroundColor,
      appBar: AppBar(
        leading: BackButton(color: HistoryRepository.primaryColor),
        title: const Text(
          'Signos Vitales',
          style: TextStyle(
            color: HistoryRepository.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: HistoryRepository.primaryColor,
            onPressed: () => _showAddVitalSignDialog(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          CleanInfoCard(
            icon: Icons.favorite_outlined,
            title: "Monitoreo de signos vitales",
            description: "Seguimiento completo de tus parámetros de salud, tendencias y alertas médicas importantes.",
          ),

          // Selector de período
          _buildPeriodSelector(),
          
          const SizedBox(height: 20),

          // Resumen actual
          _buildCurrentSummary(),
          
          const SizedBox(height: 20),

          // Gráficos de tendencias (simulados)
          _buildTrendsSection(),
          
          const SizedBox(height: 20),

          // Historial detallado
          _buildHistorySection(),
          
          const SizedBox(height: 20), // Extra padding
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Período de visualización",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HistoryRepository.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip("1 mes", "1m"),
                  _buildPeriodChip("3 meses", "3m"),
                  _buildPeriodChip("6 meses", "6m"),
                  _buildPeriodChip("1 año", "1a"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _periodoSeleccionado == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _periodoSeleccionado = value),
        backgroundColor: Colors.grey.shade100,
        selectedColor: HistoryRepository.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? HistoryRepository.primaryColor : HistoryRepository.mediumGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCurrentSummary() {
    final ultimoRegistro = HistoryRepository.signosVitalesMock.first;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 12,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Último registro",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: HistoryRepository.darkBlue,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  ultimoRegistro["fecha"],
                  style: const TextStyle(
                    color: HistoryRepository.mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Grid de signos vitales
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildVitalSignCard(
                  "Presión arterial",
                  "${ultimoRegistro["presionSistolica"]}/${ultimoRegistro["presionDiastolica"]}",
                  "mmHg",
                  Icons.favorite,
                  Colors.red,
                ),
                _buildVitalSignCard(
                  "Frecuencia cardíaca",
                  "${ultimoRegistro["frecuenciaCardiaca"]}",
                  "bpm",
                  Icons.monitor_heart,
                  Colors.orange,
                ),
                _buildVitalSignCard(
                  "Temperatura",
                  "${ultimoRegistro["temperatura"]}",
                  "°C",
                  Icons.thermostat,
                  Colors.blue,
                ),
                _buildVitalSignCard(
                  "Peso",
                  "${ultimoRegistro["peso"]}",
                  "kg",
                  Icons.scale,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: HistoryRepository.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tendencias",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HistoryRepository.darkBlue,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Simulación de gráfico de presión arterial
            // Real LineChart for Blood Pressure
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: const Color(0xff37434d), strokeWidth: 0.5);
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(color: const Color(0xff37434d), strokeWidth: 0.5);
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                             // Simple index-based date mapping logic
                             // Reverse list to show oldest to newest
                             final sorted = List.from(HistoryRepository.signosVitalesMock.reversed);
                             if (value.toInt() >= 0 && value.toInt() < sorted.length) {
                               return Padding(
                                 padding: const EdgeInsets.only(top: 8.0),
                                 child: Text(
                                   sorted[value.toInt()]["fecha"].substring(0,5), // "DD/MM"
                                   style: const TextStyle(color: Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 10),
                                 ),
                               );
                             }
                             return const Text('');
                          },
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Color(0xff67727d),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.left,
                            );
                          },
                          reservedSize: 40,
                          interval: 20,
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d), width: 1),
                    ),
                    minX: 0,
                    maxX: (HistoryRepository.signosVitalesMock.length - 1).toDouble(),
                    minY: 40,
                    maxY: 180,
                    lineBarsData: [
                      // Systolic
                      LineChartBarData(
                        spots: HistoryRepository.signosVitalesMock.reversed.toList().asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), (e.value["presionSistolica"] as num).toDouble());
                        }).toList(),
                        isCurved: true,
                        color: Colors.redAccent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Diastolic
                      LineChartBarData(
                        spots: HistoryRepository.signosVitalesMock.reversed.toList().asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), (e.value["presionDiastolica"] as num).toDouble());
                        }).toList(),
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 12, height: 12, color: Colors.redAccent),
                const SizedBox(width: 4),
                const Text("Sistólica", style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Container(width: 12, height: 12, color: Colors.blueAccent),
                const SizedBox(width: 4),
                const Text("Diastólica", style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Historial detallado",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HistoryRepository.darkBlue,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...HistoryRepository.signosVitalesMock.map((registro) => 
              _buildHistoryItem(registro)
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> registro) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: HistoryRepository.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                registro["fecha"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HistoryRepository.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildHistoryValueChip("PA", "${registro["presionSistolica"]}/${registro["presionDiastolica"]}", Colors.red),
              _buildHistoryValueChip("FC", "${registro["frecuenciaCardiaca"]}", Colors.orange),
              _buildHistoryValueChip("T°", "${registro["temperatura"]}", Colors.blue),
              _buildHistoryValueChip("Peso", "${registro["peso"]}", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryValueChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddVitalSignDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Registrar signos vitales"),
        content: const Text(
          "Para registrar nuevos signos vitales, utiliza los dispositivos de medición disponibles en la consulta médica.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }
}

// ============== RESUMEN CLÍNICO MEJORADO ==============
class ResumenDetailScreen extends StatelessWidget {
  final MedicalHistoryModel data;
  
  const ResumenDetailScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoryRepository.backgroundColor,
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FCFF),
          child: Column(
            children: [
               StandardPageHeader(
                 title: "Resumen Clínico",
                 subtitle: "Historia clínica digital",
                 imagePath: "assets/images/ilustracion_historia_clinica.png",
                 isLarge: false,
                 trailing: IconButton(
                   icon: const Icon(Icons.share, color: Color(0xFF2376F6)),
                   onPressed: () => _shareResumen(context),
                 ),
               ),
               Expanded(
                 child: ListView(
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                   children: [
                     // Banner eliminado (IdentificationBanner)
          const SizedBox(height: 20),

          // Información principal
          _buildMainInfoSection(),
          
          const SizedBox(height: 20),

          // Diagnósticos activos
          _buildDiagnosticosSection(),
          
          const SizedBox(height: 20),

          // Medicación actual
          _buildMedicacionSection(),
          
          const SizedBox(height: 20),

          // Próximas citas y seguimiento
          _buildSeguimientoSection(),
          
          const SizedBox(height: 20),

          // Alertas y recomendaciones
          _buildAlertasSection(context),
          
          const SizedBox(height: 20),

          // Acciones rápidas
          _buildAccionesRapidas(context),
          
          const SizedBox(height: 20),

          // Información de actualización
          _buildUpdateInfo(),
          
                  const SizedBox(height: 20), // Extra padding at bottom
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildMainInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HistoryRepository.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: HistoryRepository.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Información del paciente",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoryRepository.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Datos principales en grid
            _buildPatientDataGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDataGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDataItem("Centro médico", data.centro, Icons.local_hospital)),
            const SizedBox(width: 16),
            Expanded(child: _buildDataItem("Edad", "${data.edad} años", Icons.cake)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDataItem("DNI", data.dni, Icons.badge)),
            const SizedBox(width: 16),
            Expanded(child: _buildDataItem("Última actualización", data.fechaActualizacion, Icons.update)),
          ],
        ),
      ],
    );
  }

  Widget _buildDataItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: HistoryRepository.primaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HistoryRepository.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: HistoryRepository.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticosSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Diagnósticos activos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoryRepository.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lista de diagnósticos
            ...HistoryRepository.diagnosticosMock.map((diag) => 
              _buildDiagnosticoItem(diag)
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticoItem(Map<String, dynamic> diagnostico) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HistoryRepository.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  diagnostico["codigo"],
                  style: const TextStyle(
                    color: HistoryRepository.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              _buildEstadoChip(diagnostico["estado"]),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            diagnostico["nombre"],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: HistoryRepository.darkBlue,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            "Dr. ${diagnostico["medico"]} • ${diagnostico["fechaDiagnostico"]}",
            style: const TextStyle(
              color: HistoryRepository.mediumGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'activo':
        color = Colors.orange;
        break;
      case 'controlado':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildMedicacionSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Medicación actual",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoryRepository.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lista de medicamentos activos
            ...HistoryRepository.medicamentosMock
                .where((med) => med["activo"] == true)
                .map((med) => _buildMedicamentoResumenItem(med))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicamentoResumenItem(Map<String, dynamic> medicamento) {
    final alertas = medicamento["alertas"] as List;
    final hasAlertas = alertas.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: hasAlertas ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicamento["nombre"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: HistoryRepository.darkBlue,
                  ),
                ),
                Text(
                  medicamento["indicacion"],
                  style: const TextStyle(
                    color: HistoryRepository.mediumGray,
                    fontSize: 12,
                  ),
                ),
                if (hasAlertas)
                  Text(
                    "⚠️ ${alertas.first}",
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeguimientoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HistoryRepository.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.event_available_rounded,
                    color: HistoryRepository.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Seguimiento médico",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoryRepository.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Próxima cita
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HistoryRepository.accentColor.withOpacity(0.1),
                    HistoryRepository.secondaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: HistoryRepository.accentColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: HistoryRepository.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Próxima cita médica",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: HistoryRepository.darkBlue,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          data.proximaCita,
                          style: TextStyle(
                            color: HistoryRepository.accentColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Controles recomendados
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.checklist, color: Colors.blue, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        "Controles recomendados",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: HistoryRepository.darkBlue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• Control de presión arterial mensual\n• Análisis de laboratorio trimestral\n• Consulta cardiológica semestral",
                    style: TextStyle(
                      color: HistoryRepository.mediumGray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertasSection(BuildContext context) {
    // Generar alertas dinámicas basadas en los datos
    final alertas = _generarAlertas();
    
    if (alertas.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Alertas y recomendaciones",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoryRepository.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ...alertas.map((alerta) => _buildAlertaItem(context, alerta)).toList(),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _generarAlertas() {
    List<Map<String, String>> alertas = [];
    
    // Verificar medicamentos con alertas
    for (var medicamento in HistoryRepository.medicamentosMock) {
      if ((medicamento["alertas"] as List).isNotEmpty) {
        alertas.add({
          "tipo": "medicamento",
          "titulo": "Control de medicación",
          "descripcion": "${medicamento["alertas"].first} - ${medicamento["nombre"]}",
          "prioridad": "media",
        });
      }
    }
    
    // Verificar diagnósticos activos
    for (var diagnostico in HistoryRepository.diagnosticosMock) {
      if (diagnostico["estado"] == "Activo") {
        alertas.add({
          "tipo": "seguimiento",
          "titulo": "Seguimiento de ${diagnostico["nombre"]}",
          "descripcion": "Mantener controles regulares y adherencia al tratamiento",
          "prioridad": "alta",
        });
      }
    }
    
    // Alerta de próxima cita
    if (data.proximaCita.contains("Sin datos")) {
      alertas.add({
        "tipo": "cita",
        "titulo": "Programar próxima consulta",
        "descripcion": "No tienes citas médicas programadas",
        "prioridad": "alta",
      });
    }
    
    return alertas.take(3).toList(); // Limitar a 3 alertas principales
  }

  Widget _buildAlertaItem(BuildContext context, Map<String, String> alerta) {
    Color color;
    IconData icon;
    
    switch (alerta["prioridad"]) {
      case "alta":
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case "media":
        color = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta["titulo"]! as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.lerp(color, Colors.black, 0.3)!,
                    fontSize: 14,
                  ),
                ),
                Text(
                  alerta["descripcion"]! as String,
                  style: TextStyle(
                    color: Color.lerp(color, Colors.black, 0.2)!,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesRapidas(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Acciones rápidas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HistoryRepository.darkBlue,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Exportar PDF",
                    Icons.picture_as_pdf,
                    Colors.red,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Generando PDF de historia clínica...")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    "Compartir",
                    Icons.share,
                    Colors.green,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Preparando para compartir...")),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Solicitar estudios",
                    Icons.science,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EstudiosScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    "Emergencia",
                    Icons.emergency,
                    Colors.red,
                    () {
                      _showEmergencyDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildUpdateInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Última actualización: ${data.fechaActualizacion}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8), // Replaces Spacer
          Icon(
            Icons.verified,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            "Verificado",
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _shareResumen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Compartir resumen clínico",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Enviar por email"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preparando email...")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Generar PDF"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Generando PDF...")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text("Mostrar código QR"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Generando código QR...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text(
              "Información de emergencia",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Datos médicos importantes:"),
            SizedBox(height: 8),
            Text("• Grupo sanguíneo: A+"),
            Text("• Alergias: Ninguna conocida"),
            Text("• Medicación actual: Losartán 50mg"),
            Text("• Contacto emergencia: Anto Lettieri"),
            Text("• Teléfono: +54 9 11 8765 4321"),
            SizedBox(height: 12),
            Text("En caso de emergencia, mostrar esta información al personal médico."),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.call),
            label: const Text("Llamar emergencia"),
          ),
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}

// ========== BLOQUE RESUMEN REUTILIZABLE ==========
class _ResumenBlock extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _ResumenBlock({
    required this.title,
    required this.content,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HistoryRepository.cardColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: HistoryRepository.primaryColor.withOpacity(0.1),
          child: Icon(icon, color: HistoryRepository.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: HistoryRepository.primaryColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15, color: HistoryRepository.mediumGray),
          ),
        ),
      ),
    );
  }
}

// ======================= HOME HISTORIA CLÍNICA (PRINCIPAL) ========================
class HistoriaClinicaScreen extends StatefulWidget {
  const HistoriaClinicaScreen({Key? key}) : super(key: key);

  @override
  State<HistoriaClinicaScreen> createState() => _HistoriaClinicaScreenState();
}

class _HistoriaClinicaScreenState extends State<HistoriaClinicaScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  void _initUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userDataFuture = FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    } else {
      // FORCE MOCK DATA FALLBACK: Trigger the 'permission-denied' error handler in FutureBuilder
      _userDataFuture = Future.error('permission-denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auth check bypassed for testing
    // final user = FirebaseAuth.instance.currentUser;
    // if (user == null) return ...

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // CAP 1 FIX: Usar loader simple para descartar errores de layout en TechLoadingScreen
          return const Scaffold(
            backgroundColor: HistoryRepository.backgroundColor,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          // Si es error de permisos, usar datos mock para desarrollo
          if (snapshot.error.toString().contains('permission-denied')) {
            final mockData = {
              'dni': '12.345.678',
              'centro': 'Instituto Ángel H. Roffo',
              'edad': '35',
              'proxima_cita': '15 de agosto, 2025 - Dr. Pérez',
              'fecha_actualizacion': '25/07/2025',
              'resumen': 'Paciente con hipertensión arterial controlada. Evolución favorable con medicación actual.',
              'diagnostico': 'Hipertensión arterial',
              'medicamentos': 'Losartán 50mg + Enalapril 10mg',
            };
            
            final data = MedicalHistoryModel.fromMap(mockData);
            return _buildHistoriaClinicaContent(context, data);
          }
          
          return Scaffold(
            backgroundColor: HistoryRepository.backgroundColor,
            appBar: _buildAppBar(context),
            body: ErrorCard(
              message: "Error al cargar los datos: ${snapshot.error}",
              onRetry: () {
                setState(() {
                  _initUserData();
                });
              },
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Usar datos mock para desarrollo si no hay datos en Firestore
          final mockData = {
            'dni': '12.345.678',
            'centro': 'Instituto Ángel H. Roffo',
            'edad': '35',
            'proxima_cita': '15 de agosto, 2025 - Dr. Pérez',
            'fecha_actualizacion': '25/07/2025',
            'resumen': 'Paciente con hipertensión arterial controlada. Evolución favorable con medicación actual.',
            'diagnostico': 'Hipertensión arterial',
            'medicamentos': 'Losartán 50mg + Enalapril 10mg',
          };
          
          final data = MedicalHistoryModel.fromMap(mockData);
          return _buildHistoriaClinicaContent(context, data);
        }

        final data = MedicalHistoryModel.fromMap(snapshot.data!.data()!);
        return _buildHistoriaClinicaContent(context, data);
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      // ✅ FIX: Título simplificado para evitar errores de layout
      title: const Text(
        'Historia clínica',
        style: TextStyle(
          color: HistoryRepository.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          color: HistoryRepository.primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
            );
          },
        ),
      ],
      iconTheme: const IconThemeData(color: HistoryRepository.primaryColor),
    );
  }

  Widget _buildEmptyDataScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoryRepository.backgroundColor,
      appBar: _buildAppBar(context),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HistoryRepository.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: HistoryRepository.primaryColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Completá tus datos",
                  style: TextStyle(
                    color: HistoryRepository.darkBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Para acceder a tu historia clínica completa, necesitamos que completes tu información personal.",
                  style: TextStyle(
                    color: HistoryRepository.mediumGray,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CompletarPerfilScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Completar perfil"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HistoryRepository.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoriaClinicaContent(BuildContext context, MedicalHistoryModel data) {
    return Scaffold(
      backgroundColor: HistoryRepository.backgroundColor,
      // No AppBar - using visual header
      body: SafeArea(
        child: Container( // Wrap in Container for background color consistency if needed
           color: const Color(0xFFF8FCFF),
           child: Column(
             children: [
               Stack(
                 children: [
                   const StandardPageHeader(
                      title: "Historia clínica",
                      subtitle: "Tu salud al día",
                      imagePath: "assets/images/ilustracion_historia_clinica.png",
                      isLarge: false,
                      imageScale: 0.85,
                   ),
                   Positioned(
                     top: 40, // Match typical AppBar height
                     right: 16,
                     child: GestureDetector(
                       onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
                          );
                       },
                       child: Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.9),
                           shape: BoxShape.circle,
                           boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                         ),
                         child: const Icon(Icons.edit, color: HistoryRepository.primaryColor, size: 20),
                       ),
                     ),
                   )
                 ],
               ),
               
               Expanded(
                 child: RefreshIndicator(
                  onRefresh: () async {
                    // Simular refresh
                    await Future.delayed(const Duration(seconds: 1));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Información actualizada")),
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), // 18 -> 24 (Platinum)
                    children: [
                        // Identificación del paciente (Keep as is, user mentioned Cap2 banner which is now fixed by Header)
                        BouncingCard(
                          onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
                              );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16), // 12 -> 16 (8pt grid)
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24), // 16 -> 24 (Platinum)
                              border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.1)), // Soft border
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2376F6).withOpacity(0.08),
                                  blurRadius: 24, // 8 -> 24 (Soft shadow)
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2376F6).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16), // 12 -> 16
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_rounded,
                                    color: Color(0xFF2376F6),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Flexible(
                                            child: Text(
                                              "Identificación del paciente",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF193A72),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 2->4
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.green.withOpacity(0.2)),
                                            ),
                                            child: const Text(
                                              'Verificado',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8), // 4->8
                                      Text(
                                        "DNI: ${data.dni} • ${data.centro} • ${data.edad} años",
                                        style: const TextStyle(
                                          color: Color(0xFF42506A),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Ícono de navegación
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF2376F6),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
        
                        const SizedBox(height: 16), 
        
                        // Próxima cita médica  
                        BouncingCard(
                          onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SacarTurnoScreen()),
                              );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF4FE1F3).withOpacity(0.3), width: 1),
                              boxShadow: [
                                 BoxShadow(
                                    color: const Color(0xFF4FE1F3).withOpacity(0.08), 
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                 ),
                              ]
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4FE1F3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.event_available_rounded,
                                    color: Color(0xFF4FE1F3),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Próxima cita médica",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF193A72),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        data.proximaCita,
                                        style: const TextStyle(
                                          color: Color(0xFF42506A),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Agregar ícono de navegación
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF4FE1F3),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
        
                        // Información de actualización
                        _buildUpdateInfoBanner(data.fechaActualizacion),
        
                        const SizedBox(height: 20),
        
                        // Grid de secciones principales
                        _buildMainSectionsGrid(context, data),
        
                        const SizedBox(height: 20),
        
                        // Secciones adicionales
                        _buildAdditionalSections(context),
        
                        const SizedBox(height: 20),
        
                        // Footer con información del centro
                        _buildFooterInfo(),
                        
                        const SizedBox(height: 30), // Espacio final extra
                      ],
                    ),
                  ),
               ),
             ],
           ),
        ),
      ),
    );
  }




  Widget _buildUpdateInfoBanner(String fechaActualizacion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity, // FIX: Ensure constrained width for Spacer
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            "Actualizado el $fechaActualizacion",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.verified,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            "Verificado",
            style: TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSectionsGrid(BuildContext context, MedicalHistoryModel data) {
    // CAP 5 FIX: Calculate explicit width to avoid Expanded layout errors
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 36.0; // 18 * 2
    final gap = 16.0;
    final cardWidth = (screenWidth - padding - gap) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primera fila - Resumen destacado
        _CardAcceso(
          icon: Icons.dashboard_rounded,
          title: "Resumen completo",
          content: data.resumen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ResumenDetailScreen(data: data)),
          ),
          tag: "Ver detalle",
          bgColor: HistoryRepository.cardColor,
          iconColor: HistoryRepository.primaryColor,
          gradient: true,
        ),

        // Segunda fila - Diagnóstico y Medicamentos
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             SizedBox(
              width: cardWidth,
              child: _CardAcceso(
                icon: Icons.assignment_turned_in_rounded,
                title: "Diagnósticos",
                content: "${data.diagnostico}\nÚltima actualización: 15/07/2025",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiagnosticoDetailScreen(
                      diagnostico: HistoryRepository.diagnosticosMock.first,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CardAcceso(
                icon: Icons.medication_rounded,
                title: "Medicamentos",
                content: "2 activos • Losartán 50mg + Enalapril 10mg",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MedicamentosDetailScreen()),
                ),
              ),
            ),
          ],
        ),

        // Tercera fila - Turnos y Signos Vitales
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: cardWidth,
              child: _CardAcceso(
                icon: Icons.calendar_today_rounded,
                title: "Turnos",
                content: "15 de agosto, 2025 • 10:00 AM\nDr. Pérez - Clínica médica",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TurnosDetailScreen()),
                ),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CardAcceso(
                icon: Icons.favorite_rounded,
                title: "Signos vitales",
                content: "Último registro: 142/92 mmHg\nMonitoreo de salud y tendencias",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignosVitalesScreen()),
                ),
                iconColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalSections(BuildContext context) {
    // FIX: Calculate button width explicitly
    final screenWidth = MediaQuery.of(context).size.width;
    final listViewPadding = 36.0;
    final cardPadding = 40.0;
    final gap = 24.0;
    // Ancho disponible real = Screen - ListViewPadding - CardMargin(default 4x2=8) - CardPadding
    // Simplificado: Screen - 36 - 40 - 24 (gap)
    final buttonWidth = (screenWidth - listViewPadding - cardPadding - gap - 8) / 2;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Herramientas adicionales",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HistoryRepository.darkBlue,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: _buildActionButton(
                    "Exportar PDF",
                    Icons.picture_as_pdf,
                    Colors.red,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Generando PDF de historia clínica...")),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: buttonWidth, // Usando SizedBox en lugar de Expanded
                  child: _buildActionButton(
                    "Compartir",
                    Icons.share,
                    Colors.green,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Preparando para compartir...")),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: _buildActionButton(
                    "Solicitar estudios",
                    Icons.science,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EstudiosScreen()),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: _buildActionButton(
                    "Emergencia",
                    Icons.emergency,
                    Colors.red,
                    () {
                      _showEmergencyDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text(
              "Información de emergencia",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Datos médicos importantes:"),
            SizedBox(height: 8),
            Text("• Grupo sanguíneo: A+"),
            Text("• Alergias: Ninguna conocida"),
            Text("• Medicación actual: Losartán 50mg"),
            Text("• Contacto emergencia: Anto Lettieri"),
            Text("• Teléfono: +54 9 11 8765 4321"),
            SizedBox(height: 12),
            Text("En caso de emergencia, mostrar esta información al personal médico."),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.call),
            label: const Text("Llamar emergencia"),
          ),
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      width: double.infinity, // FIX: Ensure explicit width
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: HistoryRepository.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: HistoryRepository.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Centro Médico",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: HistoryRepository.darkBlue,
                      ),
                    ),
                    Text(
                      "Centro de excelencia en medicina",
                      style: TextStyle(
                        color: HistoryRepository.mediumGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFooterAction(Icons.phone, "Contacto", () {}),
              _buildFooterAction(Icons.location_on, "Ubicación", () {}),
              _buildFooterAction(Icons.schedule, "Horarios", () {}),
              _buildFooterAction(Icons.help, "Ayuda", () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(
              icon,
              color: HistoryRepository.primaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: HistoryRepository.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== CARD ACCESO MEJORADA ==========
class _CardAcceso extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final VoidCallback? onTap;
  final Color? bgColor;
  final Color? iconColor;
  final String? tag;
  final bool gradient;

  const _CardAcceso({
    required this.icon,
    required this.title,
    required this.content,
    this.onTap,
    this.bgColor,
    this.iconColor,
    this.tag,
    this.gradient = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BouncingCard(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), // 10 -> 16 (8pt grid)
        decoration: BoxDecoration(
          color: gradient ? null : (bgColor ?? Colors.white),
          borderRadius: BorderRadius.circular(24), // 16 -> 24 (Platinum)
          gradient: gradient
              ? LinearGradient(
                  colors: [
                    HistoryRepository.primaryColor.withOpacity(0.1),
                    HistoryRepository.secondaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: [
             BoxShadow(
               color: (iconColor ?? HistoryRepository.primaryColor).withOpacity(0.08), 
               blurRadius: 24, 
               offset: const Offset(0, 8)
             )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16), // 14 -> 16
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12), // 10 -> 12
                decoration: BoxDecoration(
                  color: (iconColor ?? HistoryRepository.primaryColor).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16), // 12 -> 16
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? HistoryRepository.primaryColor,
                  size: 24, 
                ),
              ),
              const SizedBox(width: 16), // 12 -> 16
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: HistoryRepository.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8), // 4 -> 8
                    Text(
                      content,
                      style: const TextStyle(
                        color: HistoryRepository.mediumGray,
                        fontSize: 12,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tag != null) ...[
                      const SizedBox(height: 8), // 6 -> 8
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                        decoration: BoxDecoration(
                          color: (iconColor ?? HistoryRepository.primaryColor).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag!,
                          style: TextStyle(
                            color: iconColor ?? HistoryRepository.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11, 
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8), 
              Icon(
                Icons.chevron_right_rounded,
                color: HistoryRepository.lightGray,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}