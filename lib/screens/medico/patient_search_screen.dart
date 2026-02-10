import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../constants/medico_constants.dart';
import '../../models/agenda_item_model.dart';
import '../../repositories/medico_repository.dart';
import 'historia_clinica_medico_screen.dart';
import '../../widgets/common/bouncing_card.dart';
import '../../widgets/patient/standard_header.dart';

class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({Key? key}) : super(key: key);

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final MedicoRepository _repository = MedicoRepository();
  List<AgendaItem> _allPatients = [];
  List<AgendaItem> _filteredPatients = [];
  bool _isLoading = true;
  bool _showRecent = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patients = await _repository.getInitialAgenda();
    if (mounted) {
      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    }
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _showRecent = true;
        _filteredPatients = _allPatients;
      } else {
        _showRecent = false;
        _filteredPatients = _allPatients.where((patient) {
          final nameLower = patient.paciente.toLowerCase();
          final dni = patient.dni;
          final searchLower = query.toLowerCase();
          return nameLower.contains(searchLower) || dni.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F1), // Premium Cream Background
      body: Column(
        children: [
           // HEADER & BANNER SECTION (Premium Blue Gradient)
           Stack(
             clipBehavior: Clip.none,
             children: [
               const StandardPageHeader(
                 title: "Encuentra\na tu paciente",
                 subtitle: "Búsqueda rápida",
                 imagePath: 'assets/images/ilustracion_search_patient.png',
                 isLarge: true,
                 imageRightOffset: -80,
                 imageScale: 0.85,
               ),
               Positioned(
                 bottom: -24,
                 left: 24,
                 right: 24,
                 child: Hero(
                   tag: 'searchBar',
                   child: Container(
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(28),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.08),
                           blurRadius: 20,
                           offset: const Offset(0, 8),
                         ),
                       ],
                     ),
                     child: TextField(
                       controller: _searchController,
                       onChanged: _filterPatients,
                       style: const TextStyle(
                         fontSize: 16,
                         color: Color(0xFF083866),
                         fontWeight: FontWeight.w500,
                       ),
                       decoration: InputDecoration(
                         hintText: "Escribe aquí...",
                         hintStyle: TextStyle(fontSize: 15, color: Colors.grey[400]),
                         prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2376F6)),
                         suffixIcon: _searchController.text.isNotEmpty
                             ? IconButton(
                                 icon: const Icon(Icons.close_rounded, color: Colors.grey),
                                 onPressed: () {
                                   _searchController.clear();
                                   _filterPatients('');
                                 })
                             : null,
                         border: InputBorder.none,
                         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                       ),
                     ),
                   ),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 40),

           const SizedBox(height: 24),

           // CONTENT LIST
           Expanded(
             child: _showRecent 
              ? _buildRecentView()
              : _filteredPatients.isEmpty 
                  ? _buildEmptyState()
                  : _buildResultsList(),
           ),
        ],
      ),
    );
  }

  Widget _buildRecentView() {
    final directoryPatients = _allPatients.where((p) => p.paciente.toUpperCase().startsWith('A')).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Recientemente vistos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF083866))),
            TextButton(
              onPressed: () {}, 
              child: const Text("Borrar", style: TextStyle(color: Colors.grey))
            )
          ],
        ),
        
        if (_allPatients.isNotEmpty) _buildPatientCard(_allPatients[0], isRecent: true),
        if (_allPatients.length > 1) const SizedBox(height: 12),
        if (_allPatients.length > 1) _buildPatientCard(_allPatients[1], isRecent: true),
        
        const SizedBox(height: 32),
        
        // Directory Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
              child: const Text("A", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
            ),
            const SizedBox(width: 12),
            const Text("Directorio de Pacientes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF083866))),
          ],
        ),
        const SizedBox(height: 16),
        
        ...directoryPatients.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPatientCard(p),
        )).toList(),
        
        const SizedBox(height: 40),
        
        Center(
          child: OutlinedButton(
            onPressed: () {
               _searchController.clear();
               setState(() { _showRecent = false; _filteredPatients = _allPatients; });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              foregroundColor: const Color(0xFF2376F6),
              side: const BorderSide(color: Color(0xFF2376F6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Ver Directorio Completo"),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPatientCard(_filteredPatients[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text("No encontramos pacientes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        Text("Intenta con otro nombre o DNI", style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildPatientCard(AgendaItem patient, {bool isRecent = false}) {
    return BouncingCard(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoriaClinicaMedicoScreen(
              patient: {
                'name': patient.paciente,
                'id': patient.id,
                'dni': patient.dni,
                'age': patient.age,
                'img': patient.img
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(18),
                image: patient.img.contains('placeholder') ? null : DecorationImage(image: AssetImage(patient.img), fit: BoxFit.cover),
              ),
              child: patient.img.contains('placeholder') ? Center(child: Text(patient.paciente[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2376F6)))) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.paciente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D1C2E))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)), child: Text("DNI ${patient.dni}", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 6),
                      Text("${patient.age} años", style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            ),
            
            if (isRecent)
              const Icon(Icons.history_rounded, size: 20, color: Color(0xFFB0BEC5))
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF2376F6)),
              )
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
     return const Color(0xFF2376F6); // Not heavily used in this refined design
  }
}
