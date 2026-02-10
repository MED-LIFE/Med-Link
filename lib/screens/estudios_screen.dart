import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../repositories/ordenes_repository.dart';
import '../models/orden_medica_model.dart';
import '../widgets/common/bouncing_card.dart';
import '../widgets/patient/standard_header.dart';

class EstudiosScreen extends StatefulWidget {
  const EstudiosScreen({super.key});
  @override
  State<EstudiosScreen> createState() => _EstudiosScreenState();
}

class _EstudiosScreenState extends State<EstudiosScreen> {
  final StorageService _storageService = StorageService();
  final OrdenesRepository _ordenesRepository = OrdenesRepository();
  
  List<Map<String, dynamic>> _estudiosList = [];
  bool isLoading = false;
  
  String filtroEstado = "Todos";
  String filtroTipo = "Todos";
  String searchQuery = "";

  List<String> get tiposEstudio => ["Todos", ..._estudiosList.map((e) => e['tipo'].toString()).toSet()];

  @override
  void initState() {
    super.initState();
    _loadStudies();
    // Ensure seed data for pending orders
    _ordenesRepository.seedData();
  }

  Future<void> _loadStudies() async {
    setState(() => isLoading = true);
    final realStudies = await _storageService.getUserStudies();
    
    setState(() {
      _estudiosList = realStudies;
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _loadStudies();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Lista actualizada"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _uploadStudy() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      // Ask for study type
      String? tipo = await _showTypeDialog();
      if (tipo == null) return;

      setState(() => isLoading = true);
      try {
        await _storageService.uploadStudy(result.files.single, tipo);
        await _loadStudies(); // Reload list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Estudio subido exitosamente"), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al subir: $e"), backgroundColor: Colors.red));
        }
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<String?> _showTypeDialog() async {
    String? selected = "Laboratorio";
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tipo de Estudio"),
        content: DropdownButtonFormField<String>(
          value: selected,
          items: ["Laboratorio", "Radiografía", "Resonancia", "Tomografía", "Otro"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => selected = v,
          decoration: const InputDecoration(labelText: "Seleccione categoría"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, selected), child: const Text("Subir")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    final estudiosFiltrados = _estudiosList.where((e) {
      final tipo = (e["tipo"] ?? "").toString();
      final fecha = (e["fecha"] ?? "").toString();
      final archivo = (e["archivo"] ?? "").toString();

      final matchEstado = filtroEstado == "Todos" || e["estado"] == filtroEstado;
      final matchTipo = filtroTipo == "Todos" || tipo == filtroTipo;

      final matchSearch = searchQuery.isEmpty ||
          tipo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          archivo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          fecha.contains(searchQuery);

      return matchEstado && matchTipo && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadStudy,
        backgroundColor: const Color(0xFF2376F6),
        icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
        label: const Text("Subir Estudio", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF8FCFF),
          child: Column(
            children: [
               const StandardPageHeader(
                  title: "Mis estudios", 
                  subtitle: "Consultá tus resultados médicos",
                  imagePath: "assets/images/mis_estudios.png",
                  isLarge: false,
                  imageScale: 0.8,
               ),
               if (isLoading) const LinearProgressIndicator(),
               Expanded(
                 child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: const Color(0xFF2376F6),
                  backgroundColor: Colors.white,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 24,
                      vertical: 24,
                    ),
                    children: [
                      // Campo de búsqueda
                      _buildCampoBusqueda(),
                      const SizedBox(height: 20),
                      
                      // Filtros
                      _buildFiltros(),
                      const SizedBox(height: 24),
                      
                      // Lista de estudios realizados
                      _buildEstudiosRealizados(estudiosFiltrados),
                      
                      const SizedBox(height: 32),
                      
                      // Estudios pendientes (Realtime from Firestore)
                      _buildEstudiosPendientesSection(),
                      
                      const SizedBox(height: 80), // Space for FAB
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

  Widget _buildCampoBusqueda() {
    return Container(
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
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2376F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search_rounded, color: Color(0xFF2376F6), size: 20),
          ),
          hintText: "Buscar archivo, tipo o fecha...",
          hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        onChanged: (val) => setState(() => searchQuery = val),
      ),
    );
  }

  Widget _buildFiltros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text("Filtrar por:", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2376F6), fontSize: 16)),
        ),
        Row(
          children: [
            Expanded(child: _buildDropdownFiltro("Tipo", filtroTipo, tiposEstudio, (val) => setState(() => filtroTipo = val ?? "Todos"))),
            const SizedBox(width: 12),
            Expanded(child: _buildDropdownFiltro("Estado", filtroEstado, ["Todos", "Disponible", "Pendiente"], (val) => setState(() => filtroEstado = val ?? "Todos"))),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownFiltro(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: items.contains(value) ? value : items.first, 
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))).toList(),
        decoration: InputDecoration(
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2376F6)),
      ),
    );
  }

  Widget _buildEstudiosRealizados(List estudiosFiltrados) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            "Mis Estudios (Nube)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
          ),
        ),
        if (estudiosFiltrados.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text("Aún no subiste ningún estudio.", style: TextStyle(color: Color(0xFF6B7280)))),
          )
        else
          ...estudiosFiltrados.map((e) => _buildEstudioCard(e)),
      ],
    );
  }

  Widget _buildEstudioCard(Map<String, dynamic> estudio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF2376F6).withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: BouncingCard(
        onTap: () async {
           final url = estudio['url'];
           if (url != null && await canLaunchUrl(Uri.parse(url))) {
             await launchUrl(Uri.parse(url));
           } else {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se puede abrir el archivo")));
           }
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          leading: Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF2376F6)),
          ),
          title: Text(estudio["tipo"], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("${estudio["fecha"]} • ${estudio["archivo"]}", maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.download_rounded, color: Colors.grey),
        ),
      ),
    );
  }

  // --- NEW: Real-time Pending Studies Section ---
  Widget _buildEstudiosPendientesSection() {
    return StreamBuilder<List<OrdenMedica>>(
      stream: _ordenesRepository.getOrdenesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16),
              child: Text("Pendientes (Sistema)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
            ),
            if (orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text("No tenés órdenes médicas pendientes.", style: TextStyle(color: Colors.grey))),
              )
            else
              ...orders.map((order) => _buildOrdenMedicaCard(order)),
          ],
        );
      }
    );
  }

  Widget _buildOrdenMedicaCard(OrdenMedica order) {
    bool esAsignado = order.estado == "Turno asignado";
    final dateStr = DateFormat('dd/MM/yyyy').format(order.fecha);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: BouncingCard(
        onTap: () {
          // Future expansion: Show full order details dialog
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: esAsignado ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                  shape: BoxShape.circle
                ),
                child: Icon(
                  Icons.assignment_ind_rounded, 
                  color: esAsignado ? Colors.green : Colors.orange,
                  size: 24
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.tipo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text("Solicitado por: ${order.profesional}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    if (order.notas != null)
                      Text("Nota: ${order.notas}", style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: esAsignado ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Text(
                      order.estado, 
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        color: esAsignado ? Colors.green : Colors.orange
                      )
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}