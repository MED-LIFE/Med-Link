import 'package:flutter/material.dart';
import '../widgets/common/bouncing_card.dart';
import '../widgets/patient/standard_header.dart';
import '../repositories/farmacias_repository.dart';
import '../models/farmacia_model.dart';

class FarmaciasScreen extends StatefulWidget {
  const FarmaciasScreen({super.key});

  @override
  State<FarmaciasScreen> createState() => _FarmaciasScreenState();
}

class _FarmaciasScreenState extends State<FarmaciasScreen> {
  final FarmaciasRepository _repository = FarmaciasRepository();
  String searchQuery = "";
  String? selectedBarrio;
  Farmacia? selectedPharmacy;

  @override
  void initState() {
    super.initState();
    // Ensure data exists
    _repository.seedData();
  }

  // Helper to extract unique barrios from list of Farmacia
  List<String> _getBarrios(List<Farmacia> farmacias) {
    return ["Todos", ...farmacias.map((f) => f.barrio).toSet().toList()..sort()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      body: StreamBuilder<List<Farmacia>>(
        stream: _repository.getFarmaciasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final farmacias = snapshot.data ?? [];
          
          // Seed if empty and finished loading (double check)
          if (farmacias.isEmpty && snapshot.connectionState == ConnectionState.active) {
             _repository.seedData();
          }

          final barrios = _getBarrios(farmacias);

          final filtered = farmacias.where((f) {
             final matchesSearch = f.nombre.toLowerCase().contains(searchQuery.toLowerCase()) || 
                                   f.direccion.toLowerCase().contains(searchQuery.toLowerCase());
             final matchesBarrio = selectedBarrio == null || selectedBarrio == "Todos" || f.barrio == selectedBarrio;
             return matchesSearch && matchesBarrio;
          }).toList();

          return SafeArea(
            child: Container(
               color: const Color(0xFFF8FCFF),
               child: farmacias.isEmpty 
                 ? _buildEmptyStateOrLoadingStatus() 
                 : Column(
                  children: [
                    const StandardPageHeader(
                      title: "Farmacias cercanas",
                      subtitle: "Encontrá tu sucursal más próxima",
                      imagePath: "assets/images/ilustracion_mis_farmacias.png",
                      isLarge: false,
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        physics: const BouncingScrollPhysics(),
                        children: [
                           // Search Bar
                           Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2376F6).withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TextField(
                                onChanged: (val) => setState(() => searchQuery = val),
                                decoration: InputDecoration(
                                  hintText: "Buscar farmacia...",
                                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2376F6)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                ),
                              ),
                           ),
                           const SizedBox(height: 16),

                           // Barrio Filters
                           SingleChildScrollView(
                             scrollDirection: Axis.horizontal,
                             physics: const BouncingScrollPhysics(),
                             child: Row(
                               children: barrios.map((barrio) {
                                 final isSelected = selectedBarrio == barrio || (selectedBarrio == null && barrio == "Todos");
                                 return Padding(
                                   padding: const EdgeInsets.only(right: 8),
                                   child: FilterChip(
                                     label: Text(barrio),
                                     selected: isSelected,
                                     onSelected: (bool selected) {
                                       setState(() {
                                         selectedBarrio = (selected && barrio != "Todos") ? barrio : null;
                                       });
                                     },
                                     backgroundColor: Colors.white,
                                     selectedColor: const Color(0xFF2376F6).withOpacity(0.1),
                                     checkmarkColor: const Color(0xFF2376F6),
                                     labelStyle: TextStyle(
                                       color: isSelected ? const Color(0xFF2376F6) : const Color(0xFF6B7280),
                                       fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                     ),
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(20),
                                       side: BorderSide(
                                         color: isSelected ? const Color(0xFF2376F6) : Colors.transparent
                                       )
                                     ),
                                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                   ),
                                 );
                               }).toList(),
                             ),
                           ),

                           const SizedBox(height: 24),

                           // Interactive Simulated Map
                           Container(
                             height: 220,
                             width: double.infinity,
                             decoration: BoxDecoration(
                               color: const Color(0xFFE0E7FF),
                               borderRadius: BorderRadius.circular(24),
                               border: Border.all(color: Colors.white, width: 4),
                               boxShadow: [
                                 BoxShadow(
                                    color: const Color(0xFF2376F6).withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                 )
                               ],
                             ),
                             child: ClipRRect(
                               borderRadius: BorderRadius.circular(20),
                               child: Stack(
                                 children: [
                                   // Map Background (Mock lines)
                                   Positioned.fill(
                                     child: CustomPaint(
                                       painter: MapGridPainter(),
                                     ),
                                   ),
                                   // Pins
                                   ...filtered.map((f) {
                                      final isSelected = selectedPharmacy?.id == f.id;
                                      return Positioned(
                                        left: (MediaQuery.of(context).size.width - 48 - 4) * f.x, // 48 padding
                                        top: 220 * f.y, 
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() => selectedPharmacy = f);
                                            _showPharmacyDetail(context, f);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.elasticOut,
                                            transform: Matrix4.identity()..scale(isSelected ? 1.2 : 1.0),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.location_on_rounded, 
                                                  color: isSelected ? const Color(0xFFD32F2F) : const Color(0xFF2376F6), 
                                                  size: isSelected ? 36 : 28
                                                ),
                                                if (isSelected) 
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(8),
                                                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                                                    ),
                                                    child: Text(
                                                      f.nombre, 
                                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                   }).toList(),
                                   
                                   // "Ver mapa completo" button overlay
                                   Positioned(
                                     bottom: 12,
                                     right: 12,
                                     child: Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                       decoration: BoxDecoration(
                                         color: Colors.white,
                                         borderRadius: BorderRadius.circular(20),
                                         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]
                                       ),
                                       child: Row(
                                         mainAxisSize: MainAxisSize.min,
                                         children: const [
                                           Icon(Icons.map_rounded, size: 16, color: Color(0xFF2376F6)),
                                           SizedBox(width: 4),
                                           Text("Mapa Interactivo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2376F6))),
                                         ],
                                       ),
                                     ),
                                   )
                                 ],
                               ),
                             ),
                           ),
                           
                           const SizedBox(height: 24),

                           // List Title
                           Align(
                             alignment: Alignment.centerLeft,
                             child: Text(
                               "Resultados (${filtered.length})",
                               style: const TextStyle(
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold,
                                 color: Color(0xFF1F2937),
                               ),
                             ),
                           ),
                           
                           const SizedBox(height: 16),

                           // List Items
                           ...filtered.map((f) => Padding(
                             padding: const EdgeInsets.only(bottom: 16),
                             child: _buildPharmacyCard(f),
                           )),
                        ],
                      ),
                    ),
                 ],
               ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildEmptyStateOrLoadingStatus() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF2376F6)),
          const SizedBox(height: 16),
          const Text(
            "Guardando y actualizando farmacias...",
            style: TextStyle(color: Color(0xFF083866), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Esto puede tomar unos segundos.",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(Farmacia f) {
    bool isOpen = f.isOpen;
    bool isTurno = f.turno;

    return BouncingCard(
      onTap: () => _showPharmacyDetail(context, f),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF90A4AE).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isTurno ? const Color(0xFFFFF7ED) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.local_pharmacy_rounded, 
                color: isTurno ? const Color(0xFFF59E0B) : const Color(0xFF9CA3AF),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.nombre, 
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF1F2937)
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    f.direccion, 
                    style: const TextStyle(
                      fontSize: 14, 
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    )
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                       Container(
                         width: 8, height: 8,
                         decoration: BoxDecoration(
                           color: isOpen ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                           shape: BoxShape.circle
                         ),
                       ),
                       const SizedBox(width: 6),
                       Text(
                         f.horario,
                         style: TextStyle(
                           fontSize: 12,
                           fontWeight: FontWeight.w600,
                           color: isOpen ? const Color(0xFF059669) : const Color(0xFFDC2626),
                         ),
                       ),
                       const Spacer(),
                       Icon(Icons.near_me_rounded, size: 14, color: Colors.grey[400]),
                       const SizedBox(width: 4),
                       // Assuming we don't have real distance calc yet, using mock placeholder or random
                       Text(
                         "0.5 km", // Placeholder, ideally calculate distance if we had real user location
                         style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                       ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPharmacyDetail(BuildContext context, Farmacia f) {
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
                       color: f.turno ? const Color(0xFFFFF7ED) : const Color(0xFFF3F4F6),
                       shape: BoxShape.circle
                     ),
                     child: Icon(
                       Icons.local_pharmacy_rounded, 
                       size: 40, 
                       color: f.turno ? const Color(0xFFF59E0B) : const Color(0xFF9CA3AF)
                     ),
                   ),
                   const SizedBox(height: 16),
                   Text(
                     f.nombre,
                     textAlign: TextAlign.center,
                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     f.direccion,
                     textAlign: TextAlign.center,
                     style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                   ),
                   const SizedBox(height: 32),
                   
                   _buildDetailRow(Icons.access_time_filled_rounded, "Horarios", f.horario),
                   const Divider(height: 32),
                   _buildDetailRow(Icons.phone_rounded, "Teléfono", f.telefono),
                   const Divider(height: 32),
                   _buildDetailRow(Icons.medical_services_rounded, "Servicios", f.servicios.join(", ")),
                   
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
                         const Icon(Icons.map_outlined, color: Color(0xFF2376F6)),
                         const SizedBox(width: 12),
                         const Expanded(
                           child: Text(
                             "Tocá \"Cómo llegar\" para abrir en Google Maps.",
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
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                         side: const BorderSide(color: Color(0xFF2376F6))
                      ),
                      child: const Text("Cerrar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2376F6))),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {}, // Mock action
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2376F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Cómo llegar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
               Text(value, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2;

    // Draw grid lines
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw main streets
    paint
      ..color = Colors.white
      ..strokeWidth = 6;
      
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.4, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
