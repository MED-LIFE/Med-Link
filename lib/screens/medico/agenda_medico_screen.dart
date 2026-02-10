import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/common/premium_access_dialog.dart';
import '../../constants/medico_constants.dart';
import '../../models/agenda_item_model.dart';
import '../../repositories/medico_repository.dart';
import 'historia_clinica_medico_screen.dart';
import '../../widgets/patient/standard_header.dart';

class AgendaMedicoScreen extends StatefulWidget {
  const AgendaMedicoScreen({Key? key}) : super(key: key);

  @override
  State<AgendaMedicoScreen> createState() => _AgendaMedicoScreenState();
}

class _AgendaMedicoScreenState extends State<AgendaMedicoScreen> {
  DateTime _selectedDate = DateTime.now();
  final MedicoRepository _repository = MedicoRepository();

  @override
  void initState() {
    super.initState();
    // _appointments will be handled by StreamBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicoConstants.backgroundColor,

      body: Column(
        children: [
          const StandardPageHeader(
            title: "Mi Agenda Médica",
            subtitle: "Gestión diaria",
            imagePath: 'assets/images/my_agenda_header.png',
            isLarge: false,
          ),
          // Date Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       DateFormat('EEEE, d MMMM', 'es_ES').format(_selectedDate).toUpperCase(),
                       style: const TextStyle(
                         color: MedicoConstants.primaryColor,
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                         letterSpacing: 0.5,
                       ),
                     ),
                     const SizedBox(height: 4),
                     const Text(
                       "Instituto Roffo - Sala 3",
                       style: TextStyle(
                         color: MedicoConstants.textLight,
                         fontSize: 14,
                       ),
                     ),
                   ],
                 ),
                 // Count badge will be updated inside StreamBuilder or removed/moved
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<AgendaItem>>(
              stream: _repository.getAgendaStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                
                final appointments = snapshot.data ?? [];
                
                if (appointments.isEmpty) {
                  return const Center(child: Text("No hay turnos para hoy"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: appointments.length,
                  separatorBuilder: (context, index) => Column(
                    children: [
                       const SizedBox(height: 12),
                       Divider(color: Colors.blueGrey.withOpacity(0.1), height: 1),
                       const SizedBox(height: 12),
                    ],
                  ),
                  itemBuilder: (context, index) {
                    final bool isEven = index % 2 == 0;
                    final Color cardColor = isEven ? Colors.white : const Color(0xFFE3E8EF);  
                    return _buildAppointmentCard(appointments[index], cardColor);
                  },
                );
              }
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBlockScheduleDialog(context),
        backgroundColor: MedicoConstants.primaryColor,
        icon: const Icon(Icons.lock_clock_rounded, color: Colors.white),
        label: const Text("Bloquear Horario", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showBlockScheduleDialog(BuildContext context) {
    TimeOfDay selectedTime = TimeOfDay.now();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Bloquear Horario", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Seleccione el motivo del bloqueo:"),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: "Personal",
                  items: ["Personal", "Reunión", "Guardia", "Congreso", "Otro"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 16),
                const Text("Horario de inicio:"),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: selectedTime);
                    if (time != null) setState(() => selectedTime = time);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Icon(Icons.access_time_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () async {
                  // Add logic to add the blocked slot to the list
                  final String timeString = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
                  
                  final newItem = AgendaItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(), 
                    hora: timeString, 
                    paciente: "HORARIO BLOQUEADO", 
                    dni: "", 
                    age: 0, 
                    motivo: "Bloqueo manual", 
                    estado: "bloqueado", 
                    img: ""
                  );

                  Navigator.pop(context); // Close dialog

                  await _repository.addNewPatient(newItem);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Horario bloqueado exitosamente"),
                      backgroundColor: MedicoConstants.primaryColor,
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MedicoConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Confirmar"),
              ),
            ],
          );
        }
      ),
    );
  }


  Widget _buildAppointmentCard(AgendaItem apt, Color backgroundColor) {
    bool isBlocked = apt.estado == 'bloqueado';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoriaClinicaMedicoScreen(patient: {
                    'name': apt.paciente,
                    'id': apt.id,
                    'dni': apt.dni,
                    'age': apt.age,
                    'img': apt.img,
                    'date': _selectedDate // Pass date context if needed
                  }),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Time (Blue)
                  Text(
                    apt.hora,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF2376F6) // Admin Blue
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD), // Light Blue
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBlocked ? Icons.lock_clock : Icons.person_rounded,
                      color: const Color(0xFF1565C0),
                      size: 20
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apt.paciente,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF0D1C2E)
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          apt.motivo,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600]
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Buttons
                  if (!isBlocked)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       // 1. VIDEO CALL (TELEMEDICINA)
                       InkWell(
                         onTap: () async {
                           // PREMIUM CHECK (God Mode Bypass enabled in Helper)
                           if (!PremiumAccessHelper.canAccessFeature()) {
                              PremiumAccessHelper.showPremiumDialog(context, "Telemedicina Pro");
                              return;
                           }

                           final Uri url = Uri.parse('https://meet.jit.si/Zanoo_Consulta_${apt.id}');
                           try {
                             if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                               throw 'Could not launch $url';
                             }
                           } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al iniciar videollamada")));
                           }
                         },
                         child: Container(
                           width: 36, height: 36,
                           margin: const EdgeInsets.only(right: 8),
                           decoration: BoxDecoration(
                             color: Colors.purple.withOpacity(0.1),
                             shape: BoxShape.circle,
                             border: Border.all(color: Colors.purple.withOpacity(0.3)),
                           ),
                           child: const Icon(Icons.video_call_rounded, color: Colors.purple, size: 20),
                         ),
                       ),
                       
                       // 2. CHECK IN
                       Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2376F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(), // Format: EN CONSULTORIO
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: MedicoConstants.primaryColor),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 13, color: MedicoConstants.primaryColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'atendido': return MedicoConstants.success;
      case 'en_consultorio': return MedicoConstants.primaryColor;
      case 'en_sala': return MedicoConstants.warning;
      case 'pendiente': return Colors.grey;
      case 'confirmado': return Colors.blueGrey;
      case 'cancelado': return MedicoConstants.error;
      default: return Colors.grey;
    }
  }
}
