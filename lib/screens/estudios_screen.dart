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

  List<String> tiposEstudio = [
    "Todos",
    ...{
      for (var e in [...estudiosRealizados, ...estudiosPendientes])
        if (e["tipo"] != null) e["tipo"].toString()
    }.toList()
  ];

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        title: const Text(
          "Mis estudios",
          style: TextStyle(
            color: Color(0xFF2376F6),
            fontWeight: FontWeight.bold,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2376F6)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            if (estudiosConCritico.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(13),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF76B1C), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFF76B1C), size: 29),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Atención: Tenés ${estudiosConCritico.length} estudio${estudiosConCritico.length > 1 ? "s" : ""} con resultado crítico.",
                        style: const TextStyle(
                            color: Color(0xFFB65000), fontWeight: FontWeight.bold, fontSize: 15.5),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Buscar estudios, profesional, área o fecha...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
            const SizedBox(height: 12),
            Text(
              "Filtrar por:",
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2376F6)),
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filtroTipo,
                    items: tiposEstudio
                        .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                        .toList(),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    onChanged: (val) => setState(() => filtroTipo = val ?? "Todos"),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filtroEstado,
                    items: [
                      "Todos",
                      "Disponible",
                      "Pendiente",
                      "Turno asignado",
                      "Pendiente de autorización"
                    ].map((est) => DropdownMenuItem(value: est, child: Text(est))).toList(),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    onChanged: (val) => setState(() => filtroEstado = val ?? "Todos"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Estudios realizados",
              style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.w600, fontSize: 16.2),
            ),
            const SizedBox(height: 4),
            if (estudiosFiltrados.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "No se encontraron estudios con este filtro.",
                  style: TextStyle(color: Color(0xFF42506A)),
                ),
              ),
            ...estudiosFiltrados.map(
              (e) => Card(
                margin: const EdgeInsets.symmetric(vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleEstudioScreen(estudio: e),
                      )),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2376F6).withOpacity(0.13),
                    child: Icon(
                      Icons.description_rounded,
                      color: e["resultadoCritico"] == true ? const Color(0xFFF76B1C) : const Color(0xFF2376F6),
                    ),
                  ),
                  title: Text(e["tipo"].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.7)),
                  subtitle: Text(
                    "${e["fecha"]} • ${e["profesional"]} • ${e["area"]}",
                    style: const TextStyle(fontSize: 13, color: Color(0xFF42506A)),
                  ),
                  trailing: e["resultadoCritico"] == true
                      ? const Icon(Icons.warning_amber_rounded, color: Color(0xFFF76B1C), size: 26)
                      : const Icon(Icons.chevron_right, color: Color(0xFF2376F6)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Pendientes / Turnos asignados",
              style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.w600, fontSize: 16.2),
            ),
            ...estudiosPendientes.map(
              (e) => Card(
                margin: const EdgeInsets.symmetric(vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2376F6).withOpacity(0.10),
                    child: const Icon(Icons.schedule, color: Color(0xFF2376F6)),
                  ),
                  title: Text(e["tipo"].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
                  subtitle: Text(
                    "${e["fecha"]}${e["hora"] != null ? ' • ${e["hora"]}' : ''}${e["profesional"] != null ? ' • ${e["profesional"]}' : ''}",
                    style: const TextStyle(fontSize: 13, color: Color(0xFF42506A)),
                  ),
                  trailing: Text(e["estado"].toString(),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF2376F6))),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: Text(e["tipo"].toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Fecha: ${e["fecha"]}"),
                                  if (e["hora"] != null) Text("Hora: ${e["hora"]}"),
                                  if (e["lugar"] != null) Text("Lugar: ${e["lugar"]}"),
                                  if (e["profesional"] != null) Text("Profesional: ${e["profesional"]}"),
                                  if (e["notas"] != null && e["notas"]!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7.0),
                                      child: Text("Notas: ${e["notas"]}",
                                          style: const TextStyle(fontStyle: FontStyle.italic)),
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cerrar")),
                              ],
                            ));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------- DETALLE DE ESTUDIO -------
class DetalleEstudioScreen extends StatelessWidget {
  final Map<String, dynamic> estudio;
  const DetalleEstudioScreen({super.key, required this.estudio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle de estudio",
            style: const TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2376F6)),
      ),
      backgroundColor: const Color(0xFFF7FCFF),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(estudio["tipo"].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                const SizedBox(height: 8),
                Text("Fecha: ${estudio["fecha"]}", style: const TextStyle(fontSize: 15)),
                if (estudio["profesional"] != null)
                  Text("Profesional: ${estudio["profesional"]}", style: const TextStyle(fontSize: 15)),
                if (estudio["area"] != null)
                  Text("Área: ${estudio["area"]}", style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 15),
                if (estudio["estado"] != null)
                  Row(
                    children: [
                      Icon(
                        estudio["estado"] == "Disponible"
                            ? Icons.check_circle_rounded
                            : Icons.pending_actions_rounded,
                        color: estudio["estado"] == "Disponible"
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFF7B32B),
                        size: 22,
                      ),
                      const SizedBox(width: 7),
                      Text("Estado: ${estudio["estado"]}", style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                if (estudio["observaciones"] != null && estudio["observaciones"]!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 8),
                    child: Text("Observaciones: ${estudio["observaciones"]}",
                        style: const TextStyle(fontSize: 15, color: Color(0xFF42506A))),
                  ),
                if (estudio["archivo"] != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                    label: const Text("Ver resultado PDF", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2376F6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Abrir PDF: ${estudio["archivo"]} (mock)")));
                    },
                  ),
                if (estudio["resultadoCritico"] == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFF76B1C), size: 27),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            "¡Atención! Este resultado presenta un valor crítico. Por favor, consulte con su médico.",
                            style: TextStyle(color: Color(0xFFB65000), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
