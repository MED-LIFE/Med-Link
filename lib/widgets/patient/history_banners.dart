import 'package:flutter/material.dart';
import '../../models/medical_history_model.dart';
import '../../repositories/history_repository.dart';

// =============== BANNER DE IDENTIFICACION ===================
// =============== BANNER DE IDENTIFICACION ===================
class IdentificationBanner extends StatelessWidget {
  final MedicalHistoryModel data;
  
  const IdentificationBanner({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Bar with Gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Colors.white], // Light blue to white fade
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: const Icon(Icons.medical_information, size: 20, color: Color(0xFF2376F6)),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Historia Clínica Digital", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF083866), fontSize: 16)
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34C759).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("ACTIVO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF34C759))),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 // Avatar Large
                 Container(
                   width: 60, height: 60,
                   decoration: BoxDecoration(
                     color: const Color(0xFFF5F7FA),
                     borderRadius: BorderRadius.circular(16),
                     border: Border.all(color: Colors.grey.shade200),
                   ),
                   child: const Icon(Icons.person_rounded, size: 30, color: Color(0xFFB0BEC5)),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(data.dni, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 2),
                       Text("Paciente ${data.dni}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
                       const SizedBox(height: 8),
                       Row(
                         children: [
                           _buildTag(Icons.cake_rounded, "${data.edad} años"),
                           const SizedBox(width: 8),
                           _buildTag(Icons.local_hospital_rounded, data.centro.length > 15 ? "Centro Med." : data.centro),
                         ],
                       )
                     ],
                   ),
                 )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF546E7A)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF546E7A))),
        ],
      ),
    );
  }
}

// =============== BANNER DE PRÓXIMA CITA ===================
class NextAppointmentBanner extends StatelessWidget {
  final String proximaCita;
  
  const NextAppointmentBanner({
    Key? key,
    required this.proximaCita,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HistoryRepository.accentColor, HistoryRepository.secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 22,
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
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  proximaCita,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
