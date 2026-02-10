import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repositories/medico_repository.dart';
import '../models/agenda_item_model.dart';
import '../widgets/common/bouncing_card.dart';
import '../widgets/patient/standard_header.dart';

// ---- PANTALLA PRINCIPAL ----
class SacarTurnoScreen extends StatefulWidget {
  const SacarTurnoScreen({Key? key}) : super(key: key);

  @override
  State<SacarTurnoScreen> createState() => _SacarTurnoScreenState();
}

class _SacarTurnoScreenState extends State<SacarTurnoScreen> {
  String especialidadSeleccionada = "Clínica médica";
  String? doctorSeleccionado;
  final MedicoRepository _repository = MedicoRepository();

  @override
  void initState() {
    super.initState();
    // Ensure we have some data to show (seeds 'disponible' slots if empty)
    _repository.seedData(); 
  }
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FCFF),
          child: Column(
             children: [
                _buildBannerSuperior(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24, 
                      vertical: 24, 
                    ),
                    children: [
                      // Elegir especialidad
                      _buildEspecialidadSelector(),

                      const SizedBox(height: 16),

                      // Elegir profesional
                      _buildProfesionalSelector(),
                      
                      const SizedBox(height: 20),
                      
                      // Lista de turnos disponibles REALES
                      StreamBuilder<List<AgendaItem>>(
                        stream: _repository.getAvailableTurnsStream(),
                        builder: (context, snapshot) {
                           if (snapshot.connectionState == ConnectionState.waiting) {
                             return const Center(child: CircularProgressIndicator());
                           }

                           final allTurns = snapshot.data ?? [];
                           
                           if (allTurns.isEmpty) {
                             return const Center(child: Padding(
                               padding: EdgeInsets.all(32),
                               child: Text("No hay turnos disponibles por hoy.", style: TextStyle(color: Colors.grey)),
                             ));
                           }
                           
                           // Extract unique doctors
                           final uniqueDoctors = allTurns.map((t) => t.doctor).toSet().toList();
                           
                           // Filter logic
                           final filteredTurns = allTurns.where((t) {
                             final matchesDoctor = doctorSeleccionado == null || t.doctor == doctorSeleccionado;
                             // We could also filter by specialty if 'especialidadSeleccionada' matched data, 
                             // but for now let's prioritize showing existing data.
                             return matchesDoctor;
                           }).toList();
                           
                           if (filteredTurns.isEmpty && doctorSeleccionado != null) {
                              return Center(child: Text("No hay turnos para $doctorSeleccionado"));
                           }
                           
                           return Column(
                             children: filteredTurns.map((turno) => _buildTurnoCard(turno)).toList(),
                           );
                        }
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Política y leyenda
                      _buildPoliticaCancelacion(),
                      
                      const SizedBox(height: 16),
                      
                      // Botón ver mis turnos
                      _buildVerMisTurnos(),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
             ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSuperior() {
    return const StandardPageHeader(
      title: "Sacar turno",
      subtitle: "Gestioná tus próximas visitas",
      imagePath: "assets/images/my_agenda_header.png", // Corrected path
      isLarge: false,
    );
  }

  Widget _buildEspecialidadSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Especialidad / Profesional",
          hintStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, 
            vertical: 18
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2376F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Color(0xFF2376F6),
              size: 20,
            ),
          ),
        ),
        value: especialidadSeleccionada,
        dropdownColor: Colors.white,
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        items: const [
          DropdownMenuItem(value: "Clínica médica", child: Text("Clínica médica", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          DropdownMenuItem(value: "Cardiología", child: Text("Cardiología", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          DropdownMenuItem(value: "Traumatología", child: Text("Traumatología", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          DropdownMenuItem(value: "Dermatología", child: Text("Dermatología", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
        ],
        onChanged: (val) {
          setState(() {
            especialidadSeleccionada = val ?? "Clínica médica";
          });
        },
        icon: Container(
          margin: const EdgeInsets.only(right: 12),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF2376F6),
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildProfesionalSelector() {
    return StreamBuilder<List<AgendaItem>>(
      stream: _repository.getAvailableTurnsStream(),
      builder: (context, snapshot) {
        final turns = snapshot.data ?? [];
        // Extract unique doctor names, filter out empty ones
        final uniqueDoctors = turns
            .map((t) => t.doctor)
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();
        uniqueDoctors.sort();

        // If currently selected doctor is not in the new list (e.g. data changed), reset it
        if (doctorSeleccionado != null && !uniqueDoctors.contains(doctorSeleccionado)) {
           // We might want to keep it if it's "Cualquiera" (null), but if it's a specific name not found, reset.
           // However, to prevent UI jumping during loading, we'll be careful.
           // For now, let's just ensure the items list includes the current selection or null.
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Profesional",
              labelStyle: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Container(
                padding: const EdgeInsets.all(10),
                child: Container(
                   padding: const EdgeInsets.all(6),
                   decoration: BoxDecoration(
                     color: const Color(0xFF2376F6).withOpacity(0.1),
                     borderRadius: BorderRadius.circular(8),
                   ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF2376F6),
                    size: 20,
                  ),
                ),
              ),
            ),
            value: uniqueDoctors.contains(doctorSeleccionado) ? doctorSeleccionado : null,
            dropdownColor: Colors.white,
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            items: [
              const DropdownMenuItem(value: null, child: Text("Cualquiera", style: TextStyle(color: Colors.grey))),
              ...uniqueDoctors.map((docName) => DropdownMenuItem(
                value: docName, 
                child: Text(docName, overflow: TextOverflow.ellipsis)
              )),
            ],
            onChanged: (val) {
              setState(() {
                doctorSeleccionado = val;
              });
            },
            icon: Container(
              margin: const EdgeInsets.only(right: 12),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF2376F6),
                size: 28,
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildTurnoCard(AgendaItem turno) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2376F6).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                      color: const Color(0xFFE3F2FD),
                      child: const Icon(Icons.access_time_rounded, color: Color(0xFF2376F6), size: 26),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    turno.doctor.isNotEmpty ? turno.doctor : "Dr. Generico",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937), // Dark text
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    turno.specialty.isNotEmpty ? turno.specialty : "Especialidad",
                     style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF2376F6)),
                      const SizedBox(width: 4),
                      Text(
                        "Hoy • ${turno.hora}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2376F6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            BouncingCard(
              onTap: () => _mostrarDialogoConfirmacion(turno),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2376F6),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                     BoxShadow(
                       color: const Color(0xFF2376F6).withOpacity(0.3),
                       blurRadius: 12,
                       offset: const Offset(0, 4),
                     )
                  ]
                ),
                child: const Text(
                  "Reservar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoliticaCancelacion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2376F6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2376F6).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2376F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF2376F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Política de cancelación",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2376F6),
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Podés cancelar hasta 2hs antes del turno. Los turnos pueden ser tomados por otros usuarios hasta confirmar tu reserva.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerMisTurnos() {
    return Center(
      child: BouncingCard(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16, 
            horizontal: 32
          ),
          decoration: BoxDecoration(
             color: const Color(0xFF2376F6).withOpacity(0.05),
             borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.list_alt_rounded, 
                color: Color(0xFF2376F6),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                "Ver mis turnos",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2376F6),
                  fontSize: 16,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoConfirmacion(AgendaItem turno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2376F6), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.event_available_rounded, size: 48, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      "Confirmar Reserva",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                     Text(
                      "Verificá los datos del turno",
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Date & Time Row
                    _buildInfoRow(
                      Icons.calendar_month_rounded, 
                      "Fecha y Hora", 
                      "Hoy • ${turno.hora} hs"
                    ),
                    const SizedBox(height: 16),
                    
                    // Location Row with Map Link
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.location_on_rounded, color: Color(0xFF1565C0), size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ubicación",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                "Av. San Martín 5481, CABA",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () {
                                  // Open generic Google Maps location for Roffo
                                  // In a real app, this would be dynamic
                                  final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=Instituto+de+Oncolog%C3%ADa+%C3%81ngel+H.+Roffo");
                                  launchUrl(uri, mode: LaunchMode.externalApplication);
                                },
                                child: Row(
                                  children: const [
                                    Text("Ver en mapa", style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold, fontSize: 12)),
                                    SizedBox(width: 4),
                                    Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFF2376F6))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Price info
                     _buildInfoRow(
                      Icons.attach_money_rounded, 
                      "Valor de la consulta", 
                      "Sin cargo (Cobertura total)"
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                  ],
                ),
              ),
              
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _confirmarReserva(turno);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2376F6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: const Color(0xFF2376F6).withOpacity(0.4),
                        ),
                        child: const Text("Confirmar Turno", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmarReserva(AgendaItem turno) async {
    try {
      await _repository.reserveTurno(turno.id, especialidadSeleccionada);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Turno reservado exitosamente: ${turno.hora}"),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al reservar: $e"),
            backgroundColor: Colors.red,
          ),
        );
       }
    }
  }
}