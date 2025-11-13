import 'package:flutter/material.dart';

// -------- MOCK DATA ---------
final estudiosRealizados = [
  {
    "tipo": "Hemograma completo",
    "fecha": "2025-08-01",
    "estado": "Disponible",
    "profesional": "Dr. Córdoba",
    "area": "Laboratorio",
    "archivo": "hemograma_20250801.pdf",
    "resultadoCritico": false,
    "observaciones": "Valores dentro de parámetros normales.",
  },
  {
    "tipo": "RX Tórax",
    "fecha": "2025-07-25",
    "estado": "Disponible",
    "profesional": "Dra. Torres",
    "area": "Diagnóstico por imagen",
    "archivo": "rx_torax_20250725.pdf",
    "resultadoCritico": true,
    "observaciones": "Infiltrado basal derecho.",
  },
  {
    "tipo": "Resonancia Magnética",
    "fecha": "2025-07-14",
    "estado": "Disponible",
    "profesional": "Dra. Pérez",
    "area": "Imágenes",
    "archivo": "rmn_20250714.pdf",
    "resultadoCritico": false,
    "observaciones": "Sin alteraciones relevantes.",
  },
];

final estudiosPendientes = [
  {
    "tipo": "Tomografía computada",
    "fecha": "2025-08-15",
    "estado": "Turno asignado",
    "profesional": "Dra. Gómez",
    "area": "Imágenes",
    "lugar": "Av. Córdoba 5550, 2° piso",
    "hora": "08:30",
    "notas": "Ayuno de 6hs.",
  },
  {
    "tipo": "Glucemia en ayunas",
    "fecha": "2025-08-17",
    "estado": "Pendiente de autorización",
    "profesional": "Dr. Fernández",
    "area": "Laboratorio",
    "notas": "Solicitado, aguarda aprobación.",
  },
];

// ------- SCREEN -------
class EstudiosScreen extends StatefulWidget {
  const EstudiosScreen({super.key});
  @override
  State<EstudiosScreen> createState() => _EstudiosScreenState();
}

class _EstudiosScreenState extends State<EstudiosScreen> {
  String filtroEstado = "Todos";
  String filtroTipo = "Todos";
  String searchQuery = "";
  bool isLoading = false;

  List<String> tiposEstudio = [
    "Todos",
    ...{
      for (var e in [...estudiosRealizados, ...estudiosPendientes])
        if (e["tipo"] != null) e["tipo"].toString()
    }.toList()
  ];

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Estudios actualizados"),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    final estudiosFiltrados = estudiosRealizados.where((e) {
      final tipo = (e["tipo"] ?? "").toString();
      final profesional = (e["profesional"] ?? "").toString();
      final area = (e["area"] ?? "").toString();
      final fecha = (e["fecha"] ?? "").toString();

      final matchEstado = filtroEstado == "Todos" || e["estado"] == filtroEstado;
      final matchTipo = filtroTipo == "Todos" || tipo == filtroTipo;

      final matchSearch = searchQuery.isEmpty ||
          tipo.toLowerCase().contains(searchQuery.toLowerCase()) ||
          profesional.toLowerCase().contains(searchQuery.toLowerCase()) ||
          area.toLowerCase().contains(searchQuery.toLowerCase()) ||
          fecha.contains(searchQuery);

      return matchEstado && matchTipo && matchSearch;
    }).toList();

    final estudiosConCritico = estudiosFiltrados.where((e) => e["resultadoCritico"] == true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF2376F6),
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Mis estudios",
          style: TextStyle(
            color: Color(0xFF2376F6),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEBF4FF), Color(0xFFF8FCFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF2376F6),
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20,
                vertical: 16,
              ),
              children: [
                // Alerta de estudios críticos
                if (estudiosConCritico.isNotEmpty) _buildAlertaCritica(estudiosConCritico),
                
                // Campo de búsqueda
                _buildCampoBusqueda(),
                
                const SizedBox(height: 20),
                
                // Filtros
                _buildFiltros(),
                
                const SizedBox(height: 24),
                
                // Lista de estudios realizados
                _buildEstudiosRealizados(estudiosFiltrados),
                
                const SizedBox(height: 32),
                
                // Estudios pendientes
                _buildEstudiosPendientes(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertaCritica(List estudiosConCritico) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF8F00).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8F00).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8F00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFF8F00),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Atención: Tenés ${estudiosConCritico.length} estudio${estudiosConCritico.length > 1 ? "s" : ""} con resultado crítico.",
              style: const TextStyle(
                color: Color(0xFF8B5000),
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
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
            child: const Icon(
              Icons.search_rounded,
              color: Color(0xFF2376F6),
              size: 20,
            ),
          ),
          hintText: "Buscar estudios, profesional, área o fecha...",
          hintStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
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
          child: Text(
            "Filtrar por:",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2376F6),
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: _buildDropdownFiltro("Tipo", filtroTipo, tiposEstudio, (val) => setState(() => filtroTipo = val ?? "Todos"))),
            const SizedBox(width: 12),
            Expanded(child: _buildDropdownFiltro("Estado", filtroEstado, ["Todos", "Disponible", "Pendiente", "Turno asignado", "Pendiente de autorización"], (val) => setState(() => filtroEstado = val ?? "Todos"))),
          ],
        ),
        
        // Chips de filtros activos
        if (_hasActiveFilters()) ...[
          const SizedBox(height: 12),
          _buildActiveFiltersChips(),
        ],
      ],
    );
  }

  bool _hasActiveFilters() {
    return filtroTipo != "Todos" || filtroEstado != "Todos" || searchQuery.isNotEmpty;
  }

  Widget _buildActiveFiltersChips() {
    List<Widget> chips = [];
    
    if (searchQuery.isNotEmpty) {
      chips.add(_buildFilterChip("Búsqueda: $searchQuery", () => setState(() => searchQuery = "")));
    }
    
    if (filtroTipo != "Todos") {
      chips.add(_buildFilterChip("Tipo: $filtroTipo", () => setState(() => filtroTipo = "Todos")));
    }
    
    if (filtroEstado != "Todos") {
      chips.add(_buildFilterChip("Estado: $filtroEstado", () => setState(() => filtroEstado = "Todos")));
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2376F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2376F6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFF2376F6),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFiltro(String label, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        )).toList(),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF2376F6),
          size: 24,
        ),
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
            "Estudios realizados",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (estudiosFiltrados.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2376F6).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "No se encontraron estudios con este filtro.",
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          )
        else
          ...estudiosFiltrados.map((e) => _buildEstudioCard(e)),
      ],
    );
  }

  Widget _buildEstudioCard(Map<String, dynamic> estudio) {
    final isCritico = estudio["resultadoCritico"] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isCritico 
              ? const Color(0xFFFF8F00).withOpacity(0.1)
              : const Color(0xFF2376F6).withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: isCritico 
          ? Border.all(color: const Color(0xFFFF8F00).withOpacity(0.3), width: 1)
          : null,
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              DetalleEstudioScreen(estudio: estudio),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getEstudioColors(estudio["area"]?.toString() ?? "", isCritico),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getEstudioIcon(estudio["area"]?.toString() ?? ""),
            color: isCritico ? const Color(0xFFFF8F00) : const Color(0xFF2376F6),
            size: 26,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            estudio["tipo"].toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),
        ),
        subtitle: Text(
          "${estudio["fecha"]} • ${estudio["profesional"]} • ${estudio["area"]}",
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isCritico
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8F00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF8F00),
                size: 20,
              ),
            )
          : const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF2376F6),
              size: 24,
            ),
      ),
    );
  }

  Widget _buildEstudiosPendientes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            "Pendientes / Turnos asignados",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),
        ),
        ...estudiosPendientes.map((e) => _buildEstudioPendienteCard(e)),
      ],
    );
  }

  Widget _buildEstudioPendienteCard(Map<String, dynamic> estudio) {
    final esAsignado = estudio["estado"] == "Turno asignado";
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (esAsignado ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withOpacity(0.1),
                (esAsignado ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            esAsignado ? Icons.event_available_rounded : Icons.schedule_rounded,
            color: esAsignado ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            size: 26,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            estudio["tipo"].toString(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),
        ),
        subtitle: Text(
          "${estudio["fecha"]}${estudio["hora"] != null ? ' • ${estudio["hora"]}' : ''}${estudio["profesional"] != null ? ' • ${estudio["profesional"]}' : ''}",
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (esAsignado ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            estudio["estado"].toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: esAsignado ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
            ),
          ),
        ),
        onTap: () => _mostrarDetallePendiente(estudio),
      ),
    );
  }

  List<Color> _getEstudioColors(String area, bool isCritico) {
    if (isCritico) {
      return [
        const Color(0xFFFF8F00).withOpacity(0.1),
        const Color(0xFFFF8F00).withOpacity(0.2),
      ];
    }
    
    switch (area.toLowerCase()) {
      case 'laboratorio':
        return [
          const Color(0xFF10B981).withOpacity(0.1),
          const Color(0xFF10B981).withOpacity(0.2),
        ];
      case 'diagnóstico por imagen':
      case 'imágenes':
        return [
          const Color(0xFF3B82F6).withOpacity(0.1),
          const Color(0xFF3B82F6).withOpacity(0.2),
        ];
      default:
        return [
          const Color(0xFF2376F6).withOpacity(0.1),
          const Color(0xFF2376F6).withOpacity(0.2),
        ];
    }
  }

  IconData _getEstudioIcon(String area) {
    switch (area.toLowerCase()) {
      case 'laboratorio':
        return Icons.science_rounded;
      case 'diagnóstico por imagen':
      case 'imágenes':
        return Icons.medical_services_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  void _mostrarDetallePendiente(Map<String, dynamic> estudio) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estudio["tipo"].toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetalleRow("Fecha", estudio["fecha"]),
                if (estudio["hora"] != null) _buildDetalleRow("Hora", estudio["hora"]),
                if (estudio["lugar"] != null) _buildDetalleRow("Lugar", estudio["lugar"]),
                if (estudio["profesional"] != null) _buildDetalleRow("Profesional", estudio["profesional"]),
                if (estudio["notas"] != null && estudio["notas"]!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2376F6).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notas:",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2376F6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          estudio["notas"],
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2376F6).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(
                        color: Color(0xFF2376F6),
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildDetalleRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------- DETALLE DE ESTUDIO MEJORADO -------
class DetalleEstudioScreen extends StatelessWidget {
  final Map<String, dynamic> estudio;
  const DetalleEstudioScreen({super.key, required this.estudio});

  @override
  Widget build(BuildContext context) {
    final isCritico = estudio["resultadoCritico"] == true;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF2376F6),
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Detalle de estudio",
          style: TextStyle(
            color: Color(0xFF2376F6),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEBF4FF), Color(0xFFF8FCFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2376F6).withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y badge de estado
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              estudio["tipo"].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: Color(0xFF1F2937),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          if (estudio["estado"] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    estudio["estado"] == "Disponible"
                                        ? Icons.check_circle_rounded
                                        : Icons.pending_actions_rounded,
                                    color: estudio["estado"] == "Disponible"
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    estudio["estado"].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: estudio["estado"] == "Disponible"
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Información básica
                      _buildInfoRow("Fecha", estudio["fecha"], Icons.calendar_today_rounded),
                      if (estudio["profesional"] != null)
                        _buildInfoRow("Profesional", estudio["profesional"], Icons.person_rounded),
                      if (estudio["area"] != null)
                        _buildInfoRow("Área", estudio["area"], Icons.local_hospital_rounded),
                      
                      const SizedBox(height: 20),
                      
                      // Observaciones
                      if (estudio["observaciones"] != null && estudio["observaciones"]!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2376F6).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.note_alt_rounded,
                                    color: Color(0xFF2376F6),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Observaciones",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2376F6),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                estudio["observaciones"],
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF374151),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Botón PDF
                      if (estudio["archivo"] != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              "Ver resultado PDF",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2376F6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Abrir PDF: ${estudio["archivo"]} (mock)"),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      // Alerta crítica
                      if (isCritico)
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8F1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFF8F00).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF8F00).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Color(0xFFFF8F00),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "¡Atención! Este resultado presenta un valor crítico. Por favor, consulte con su médico.",
                                  style: TextStyle(
                                    color: Color(0xFF8B5000),
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildInfoRow(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2376F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2376F6),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}