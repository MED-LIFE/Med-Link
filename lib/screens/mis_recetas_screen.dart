import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/common/bouncing_card.dart';
import '../widgets/patient/standard_header.dart';
import '../models/receta_model.dart';
import '../repositories/recetas_repository.dart';

class MisRecetasScreen extends StatefulWidget {
  const MisRecetasScreen({super.key});

  @override
  State<MisRecetasScreen> createState() => _MisRecetasScreenState();
}

class _MisRecetasScreenState extends State<MisRecetasScreen> {
  final RecetasRepository _repository = RecetasRepository();

  @override
  void initState() {
    super.initState();
    _repository.seedRecetasIfEmpty();
  }

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
                title: "Mis recetas",
                subtitle: "Gestioná tu medicación",
                imagePath: "assets/images/ilustracion_mis_recetas.png",
                isLarge: false,
              ),
              Expanded(
                child: StreamBuilder<List<Receta>>(
                  stream: _repository.getRecetasStream(),
                  builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) {
                       return const Center(child: CircularProgressIndicator());
                     }
                     
                     if (!snapshot.hasData || snapshot.data!.isEmpty) {
                       return Center(
                         child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Icon(Icons.medication_outlined, size: 60, color: Colors.grey.withOpacity(0.5)),
                               const SizedBox(height: 16),
                               Text(
                                 "No tenés recetas cargadas", 
                                 style: TextStyle(color: Colors.grey[600], fontSize: 16)
                               ),
                            ],
                         ),
                       );
                     }

                     final recetas = snapshot.data!;

                     return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: recetas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final rec = recetas[index];
                        final isValid = rec.esValida;
                        
                        return BouncingCard(
                          onTap: () => _showRecetaDetail(context, rec),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: isValid 
                                      ? const Color(0xFF2376F6).withOpacity(0.08)
                                      : Colors.red.withOpacity(0.05),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: !isValid ? Border.all(color: Colors.red.withOpacity(0.3)) : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isValid ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.medication_rounded, 
                                    color: isValid ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F), 
                                    size: 24
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rec.medicamento, 
                                        style: const TextStyle(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.w700, 
                                          color: Color(0xFF1F2937),
                                          letterSpacing: -0.3,
                                        )
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        rec.medico, 
                                        style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                         decoration: BoxDecoration(
                                           color: isValid ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isValid ? Icons.check_circle_rounded : Icons.error_rounded, 
                                              color: isValid ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F), 
                                              size: 14
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isValid 
                                                ? "Vence: ${DateFormat('dd MMM').format(rec.vencimiento ?? DateTime.now())}"
                                                : "Vencida / Inactiva",
                                              style: TextStyle(
                                                fontSize: 12, 
                                                fontWeight: FontWeight.bold, 
                                                color: isValid ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F)
                                              )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 24),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecetaDetail(BuildContext context, Receta rec) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Center(
               child: Container(
                 width: 40, height: 4,
                 margin: const EdgeInsets.only(top: 12, bottom: 20),
                 decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
               ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                   Container(
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       color: const Color(0xFFF3F4F6),
                       shape: BoxShape.circle
                     ),
                     child: const Icon(Icons.medication_rounded, size: 40, color: Color(0xFF2376F6)),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     rec.medicamento,
                     textAlign: TextAlign.center,
                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     rec.medico,
                     textAlign: TextAlign.center,
                     style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                   ),
                   const SizedBox(height: 32),
                   
                   _buildDetailRow(Icons.event_available, "Fecha Emisión", DateFormat('dd/MM/yyyy').format(rec.fecha)),
                   const SizedBox(height: 16),
                   if (rec.vencimiento != null)
                     _buildDetailRow(Icons.event_busy, "Vencimiento", DateFormat('dd/MM/yyyy').format(rec.vencimiento!)),
                   
                   const Divider(height: 32),
                   _buildDetailRow(Icons.local_pharmacy_rounded, "Dosis", rec.dosis.isNotEmpty ? rec.dosis : "Según indicación médica"),
                   const Divider(height: 32),
                   _buildDetailRow(Icons.history, "Duración", rec.duracion.isNotEmpty ? rec.duracion : "Única vez"),
                   
                   const SizedBox(height: 32),
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: const Color(0xFFEBF4FF),
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.3))
                     ),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Icon(Icons.info_outline, color: Color(0xFF2376F6)),
                         const SizedBox(width: 12),
                         const Expanded(
                           child: Text(
                             "Recuerde tomar la medicación con abundante agua y después de las comidas.",
                             style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 14),
                           ),
                         )
                       ],
                     ),
                   )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2376F6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Cerrar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.grey[600], size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
             Text(value, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}
