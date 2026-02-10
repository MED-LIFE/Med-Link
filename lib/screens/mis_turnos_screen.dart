import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repositories/medico_repository.dart';
import '../models/agenda_item_model.dart'; // Ensure this model exists and is correct
import '../widgets/patient/standard_header.dart';
import '../widgets/common/bouncing_card.dart';
import 'sacar_turno_screen.dart';

class MisTurnosScreen extends StatefulWidget {
  const MisTurnosScreen({super.key});

  @override
  State<MisTurnosScreen> createState() => _MisTurnosScreenState();
}

class _MisTurnosScreenState extends State<MisTurnosScreen> {
  String _filter = "todos"; // todos, proximos, realizados

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      body: Column(
        children: [
          const StandardPageHeader(
            title: "Historial de Turnos",
            subtitle: "Tus visitas y controles",
            imagePath: "assets/images/my_agenda_header.png", // Corrected image
            isLarge: false,
          ),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                _buildFilterChip("Todos", "todos"),
                const SizedBox(width: 8),
                _buildFilterChip("Próximos", "proximos"),
                const SizedBox(width: 8),
                _buildFilterChip("Realizados", "realizados"),
              ],
            ),
          ),

          // List
          Expanded(
            child: StreamBuilder<List<AgendaItem>>(
              stream: MedicoRepository().getMyAppointmentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTurns = snapshot.data ?? [];
                
                // Filter Logic
                final filteredTurns = allTurns.where((t) {
                   if (_filter == 'todos') return true;
                   if (_filter == 'proximos') return t.estado.toLowerCase() != 'realizado' && t.estado.toLowerCase() != 'cancelado';
                   if (_filter == 'realizados') return t.estado.toLowerCase() == 'realizado';
                   return true;
                }).toList();

                if (filteredTurns.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_note_rounded, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _filter == 'todos' ? "No tenés turnos registrados" : "No hay turnos en esta categoría",
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredTurns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final turno = filteredTurns[index];
                    return _buildTurnoCard(context, turno);
                  },
                );
              }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SacarTurnoScreen()),
          );
        },
        backgroundColor: const Color(0xFF2376F6),
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: const Text("Nuevo Turno", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return BouncingCard(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2376F6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2376F6) : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTurnoCard(BuildContext context, AgendaItem turno) {
    final isProximo = turno.estado.toLowerCase() != 'realizado' && turno.estado.toLowerCase() != 'cancelado';
    final color = isProximo ? const Color(0xFF2376F6) : (turno.estado.toLowerCase() == 'realizado' ? Colors.green : Colors.grey);
    final icon = isProximo ? Icons.calendar_today_rounded : (turno.estado.toLowerCase() == 'realizado' ? Icons.check_circle_rounded : Icons.history_rounded);

    return BouncingCard(
      onTap: () => _showTurnoDetail(context, turno),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: isProximo ? Border.all(color: const Color(0xFF2376F6).withOpacity(0.1)) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    turno.doctor,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Fecha y hora
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "${turno.hora} hs", // Simplificado por demo
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Ubicación breve
                   Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Instituto Roffo",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      turno.estado.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[300], size: 24),
          ],
        ),
      ),
    );
  }

  void _showTurnoDetail(BuildContext context, AgendaItem turno) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => TurnoDetailBottomSheet(turno: turno),
    );
  }
}

// Reusing the BottomSheet logic but ensuring it matches the new style
class TurnoDetailBottomSheet extends StatelessWidget {
  final AgendaItem turno;
  const TurnoDetailBottomSheet({super.key, required this.turno});

  @override
  Widget build(BuildContext context) {
    final isProximo = turno.estado.toLowerCase() != 'realizado' && turno.estado.toLowerCase() != 'cancelado';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isProximo ? const Color(0xFFE3F2FD) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isProximo ? Icons.calendar_month_rounded : Icons.check_circle_outline_rounded,
              size: 40,
              color: isProximo ? const Color(0xFF2376F6) : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            turno.specialty,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            turno.doctor,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          _buildDetailRow(Icons.event_available_rounded, "Fecha y Hora", "Hoy - ${turno.hora} hs"), // Assume today for demo
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.location_on_rounded, 
            "Lugar", 
            "Av. San Martín 5481\nConsultorio 4, Piso 2",
            isLink: true,
            onTap: () {
               launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=Instituto+de+Oncolog%C3%ADa+%C3%81ngel+H.+Roffo"), mode: LaunchMode.externalApplication);
            }
          ),
          const SizedBox(height: 16),
          if (turno.motivo.isNotEmpty)
             _buildDetailRow(Icons.notes_rounded, "Motivo", turno.motivo),

          const SizedBox(height: 32),

          if (isProximo) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                   // Video Call Logic
                   try {
                     launchUrl(Uri.parse('https://meet.jit.si/Zanoo_Consulta'), mode: LaunchMode.externalApplication);
                   } catch(e) {}
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED), // Violet
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.video_call_rounded),
                label: const Text("Ingresar a Video Consulta", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton. icon(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text("Cancelar Turno"),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: const Color(0xFF1F2937),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Cerrar", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isLink = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: Colors.grey[500]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(
                  value, 
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: FontWeight.w600, 
                    color: isLink ? const Color(0xFF2376F6) : const Color(0xFF1F2937), 
                    height: 1.3,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
          if (isLink)
             Padding(
               padding: const EdgeInsets.only(left: 8, top: 8),
               child: Icon(Icons.open_in_new_rounded, size: 16, color: const Color(0xFF2376F6)),
             )
        ],
      ),
    );
  }
}
