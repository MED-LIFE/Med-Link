import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/medico_constants.dart';
import '../../repositories/history_repository.dart';
import '../../widgets/patient/standard_header.dart';

class HistoriaClinicaMedicoScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const HistoriaClinicaMedicoScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<HistoriaClinicaMedicoScreen> createState() => _HistoriaClinicaMedicoScreenState();
}

class _HistoriaClinicaMedicoScreenState extends State<HistoriaClinicaMedicoScreen> {
  final ScrollController _scrollController = ScrollController();
  final HistoryRepository _repository = HistoryRepository();
  bool _isFabExtended = true;
  
  late String _dni;

  @override
  void initState() {
    super.initState();
    _dni = widget.patient['dni']; // Ensure valid DNI from patient map
    
    // Seed data if empty (for smooth dev experience)
    _repository.seedPatientDataIfNeeded(_dni);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 50) {
        if (_isFabExtended) setState(() => _isFabExtended = false);
      } else {
        if (!_isFabExtended) setState(() => _isFabExtended = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      body: Column(
        children: [
          // STANDARD HEADER
           StandardPageHeader(
             title: widget.patient['name'],
             subtitle: "DNI: $_dni • ${widget.patient['age'] ?? 'Adulto'} años",
             imagePath: 'assets/images/ilustracion_historia_clinica.png',
             isLarge: false,
           ),
          
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionTitle("Resumen Clínico"),
                const SizedBox(height: 12),
                
                // 1. STREAM RESUMEN
                StreamBuilder<DocumentSnapshot>(
                  stream: _repository.getPatientSummaryStream(_dni),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    final resumen = data?['resumen'] ?? "Sin resumen clínico disponibilidad.";
                    
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Text(
                        resumen,
                        style: const TextStyle(color: Color(0xFF4A5568), height: 1.5, fontSize: 15),
                      ),
                    );
                  }
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle("Diagnósticos Activos"),
                const SizedBox(height: 12),
                
                // 2. STREAM DIAGNOSTICOS
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _repository.getDiagnosticosStream(_dni),
                  builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                     final list = snapshot.data ?? [];

                     if (list.isEmpty) {
                       return const Padding(padding: EdgeInsets.only(left: 8), child: Text("Sin diagnósticos registrados.", style: TextStyle(color: Colors.grey)));
                     }

                     return Column(
                       children: list.map((diag) => 
                         Padding(
                           padding: const EdgeInsets.only(bottom: 12),
                           child: _buildDiagnosisCard(
                             diag['nombre'] ?? 'Sin nombre', 
                             "Código: ${diag['codigo'] ?? '-'} - Sev: ${diag['severidad'] ?? 'N/A'}", 
                             (diag['severidad'] == 'Moderada' || diag['severidad'] == 'Grave')
                           ),
                         )
                       ).toList(),
                     );
                  }
                ),

                const SizedBox(height: 24),
                _buildSectionTitle("Medicación Actual"),
                const SizedBox(height: 12),
                
                // 3. STREAM MEDICAMENTOS
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _repository.getMedicamentosStream(_dni),
                  builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                     final list = snapshot.data ?? [];

                     if (list.isEmpty) {
                       return const Padding(padding: EdgeInsets.only(left: 8), child: Text("Sin medicación activa.", style: TextStyle(color: Colors.grey)));
                     }

                    return Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                      child: Column(
                        children: [
                            ...list.asMap().entries.map((entry) {
                                final index = entry.key;
                                final med = entry.value;
                                final isLast = index == list.length - 1;
                                return Column(
                                  children: [
                                    _buildMedicationItem(med['nombre'] ?? 'Droga desconocida', med['indicacion'] ?? '', "Activo", index == 0),
                                    if (!isLast) const Divider(height: 1, indent: 20, endIndent: 20),
                                  ],
                                );
                            }).toList()
                        ],
                      ),
                    );
                  }
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle("Estudios Recientes"),
                const SizedBox(height: 12),
                _buildStudyCard(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEvolutionDialog(context),
        backgroundColor: MedicoConstants.primaryColor,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Nueva Evolución", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        isExtended: _isFabExtended,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
    );
  }

  Widget _buildDiagnosisCard(String title, String subtitle, bool isWarning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isWarning ? const Color(0xFFFFF7ED) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.monitor_heart_outlined, color: isWarning ? const Color(0xFFF97316) : Colors.grey, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(String name, String dose, String freq, bool isFirst) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.medication_outlined, color: Color(0xFF4CAF50), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(dose, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ),
          Text(freq, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4CAF50), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStudyCard(BuildContext context) {
    return InkWell(
      onTap: () => _showAllStudies(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.2)),
        ),
        child: Row(
          children: [
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
               child: const Icon(Icons.science_rounded, color: Color(0xFF2376F6)),
             ),
             const SizedBox(width: 16),
             const Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text("Hemograma Completo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                   Text("10/08/2025 • Normal", style: TextStyle(color: Colors.grey, fontSize: 13)),
                 ],
               ),
             ),
             const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF2376F6))
          ],
        ),
      ),
    );
  }

  void _showAddEvolutionDialog(BuildContext context) {
    final TextEditingController _evolutionController = TextEditingController();
    bool _isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Nueva Evolución", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Paciente: ${widget.patient['name']}", style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: _evolutionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Escriba la evolución clínica...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                if (_isSaving) 
                   const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator())
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : () async {
                   if (_evolutionController.text.trim().isEmpty) return;
                   
                   setState(() => _isSaving = true);
                   try {
                     await _repository.addEvolution(_dni, _evolutionController.text.trim(), "Dr. Actual");
                     if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Evolución guardada exitosamente"),
                            backgroundColor: Colors.green,
                          )
                        );
                     }
                   } catch (e) {
                      setState(() => _isSaving = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                   }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2376F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Guardar"),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showAllStudies(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Historial de Estudios", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildLabRow("Hemograma Completo", "10/08/2025", "Normal"),
                  const Divider(),
                  _buildLabRow("Orina Completa", "10/08/2025", "Normal"),
                  const Divider(),
                  _buildLabRow("Ecocardiograma Doppler", "15/07/2025", "Normal"),
                  const Divider(),
                  _buildLabRow("Resonancia Magnética", "20/06/2025", "Observación"),
                  const Divider(),
                  _buildLabRow("Perfil Lipídico", "01/05/2025", "Elevado"),
                  const Divider(),
                  _buildLabRow("Glucemia en Ayunas", "01/05/2025", "Normal"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Solicitud de estudio creada")));
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text("Solicitar Nuevo Estudio"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabRow(String title, String date, String status) {
     return Row(
       children: [
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2D3748))),
               Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
             ],
           ),
         ),
         Container(
           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
           decoration: BoxDecoration(
             color: Colors.blue.withOpacity(0.1),
             borderRadius: BorderRadius.circular(20),
           ),
           child: Text(status, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
         ),
       ],
     );
  }
}

