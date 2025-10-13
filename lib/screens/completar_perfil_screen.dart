import 'package:flutter/material.dart';

// ---- MOCK DATA ----
final especialidades = [
  "Clínica médica",
  "Cardiología",
  "Oncología",
  "Dermatología",
  "Ginecología",
  "Pediatría",
];

final medicos = [
  {"nombre": "Dra. Pérez", "especialidad": "Clínica médica"},
  {"nombre": "Dr. Adalberto Russo", "especialidad": "Clínica médica"},
  {"nombre": "Dr. Solari", "especialidad": "Clínica médica"},
  {"nombre": "Dra. Gómez", "especialidad": "Clínica médica"},
  {"nombre": "Dr. Ledesma", "especialidad": "Cardiología"},
  {"nombre": "Dr. Córdoba", "especialidad": "Cardiología"},
  {"nombre": "Dra. Batistuta", "especialidad": "Cardiología"},
  {"nombre": "Dra. López", "especialidad": "Oncología"},
  {"nombre": "Dr. Fernández", "especialidad": "Oncología"},
  {"nombre": "Dra. Romano", "especialidad": "Ginecología"},
  {"nombre": "Dra. Godoy", "especialidad": "Ginecología"},
  {"nombre": "Dra. González", "especialidad": "Ginecología"},
  {"nombre": "Dra. Torres", "especialidad": "Dermatología"},
  {"nombre": "Dr. Sánchez", "especialidad": "Dermatología"},
  {"nombre": "Dra. Díaz", "especialidad": "Dermatología"},
  {"nombre": "Dr. Leguizamón", "especialidad": "Pediatría"},
  {"nombre": "Dra. Alfonsina Russo", "especialidad": "Pediatría"},
  {"nombre": "Dr. Iglesias", "especialidad": "Pediatría"},
];

final turnosDisponibles = [
  {
    "fecha": "Martes 13/08",
    "hora": "09:30",
    "profesional": "Dra. Pérez (Clínica médica)",
    "especialidad": "Clínica médica",
    "consultorio": "1A",
    "direccion": "Av. Córdoba 5550, 1° piso",
    "notas": "Traer estudios anteriores.",
  },
  {
    "fecha": "Martes 13/08",
    "hora": "10:00",
    "profesional": "Dr. Adalberto Russo (Clínica médica)",
    "especialidad": "Clínica médica",
    "consultorio": "1B",
    "direccion": "Av. Córdoba 5550, 1° piso",
    "notas": "",
  },
  {
    "fecha": "Miércoles 14/08",
    "hora": "12:00",
    "profesional": "Dr. Ledesma (Cardiología)",
    "especialidad": "Cardiología",
    "consultorio": "2B",
    "direccion": "Av. Córdoba 5550, 2° piso",
    "notas": "Ayuno de 8hs.",
  },
  {
    "fecha": "Jueves 15/08",
    "hora": "11:00",
    "profesional": "Dra. López (Oncología)",
    "especialidad": "Oncología",
    "consultorio": "3C",
    "direccion": "Av. Córdoba 5550, 3° piso",
    "notas": "",
  },
  {
    "fecha": "Jueves 15/08",
    "hora": "13:00",
    "profesional": "Dr. Sánchez (Dermatología)",
    "especialidad": "Dermatología",
    "consultorio": "4A",
    "direccion": "Av. Córdoba 5550, 4° piso",
    "notas": "",
  },
  {
    "fecha": "Viernes 16/08",
    "hora": "09:00",
    "profesional": "Dra. Romano (Ginecología)",
    "especialidad": "Ginecología",
    "consultorio": "5A",
    "direccion": "Av. Córdoba 5550, 5° piso",
    "notas": "No usar cremas previo al turno.",
  },
  {
    "fecha": "Viernes 16/08",
    "hora": "10:00",
    "profesional": "Dr. Córdoba (Cardiología)",
    "especialidad": "Cardiología",
    "consultorio": "2B",
    "direccion": "Av. Córdoba 5550, 2° piso",
    "notas": "",
  },
  {
    "fecha": "Lunes 19/08",
    "hora": "14:30",
    "profesional": "Dra. Torres (Dermatología)",
    "especialidad": "Dermatología",
    "consultorio": "4B",
    "direccion": "Av. Córdoba 5550, 4° piso",
    "notas": "Llevar receta médica.",
  },
  {
    "fecha": "Lunes 19/08",
    "hora": "16:00",
    "profesional": "Dr. Leguizamón (Pediatría)",
    "especialidad": "Pediatría",
    "consultorio": "6C",
    "direccion": "Av. Córdoba 5550, 6° piso",
    "notas": "",
  },
  {
    "fecha": "Martes 20/08",
    "hora": "11:00",
    "profesional": "Dra. Godoy (Ginecología)",
    "especialidad": "Ginecología",
    "consultorio": "5A",
    "direccion": "Av. Córdoba 5550, 5° piso",
    "notas": "",
  },
  {
    "fecha": "Miércoles 21/08",
    "hora": "10:00",
    "profesional": "Dra. González (Ginecología)",
    "especialidad": "Ginecología",
    "consultorio": "5B",
    "direccion": "Av. Córdoba 5550, 5° piso",
    "notas": "",
  },
  {
    "fecha": "Miércoles 21/08",
    "hora": "12:00",
    "profesional": "Dra. Batistuta (Cardiología)",
    "especialidad": "Cardiología",
    "consultorio": "2C",
    "direccion": "Av. Córdoba 5550, 2° piso",
    "notas": "",
  },
];

List<Map<String, String>> turnosReservados = [];

class CompletarPerfilScreen extends StatefulWidget {
  const CompletarPerfilScreen({Key? key}) : super(key: key);

  @override
  State<CompletarPerfilScreen> createState() => _CompletarPerfilScreenState();
}

class _CompletarPerfilScreenState extends State<CompletarPerfilScreen> {
  String? especialidadSeleccionada;
  String? medicoSeleccionado;
  String medicoQuery = "";

  List<Map<String, String>> get medicosFiltrados {
    var lista = medicos;
    if (especialidadSeleccionada != null) {
      lista = lista
          .where((m) => m["especialidad"] == especialidadSeleccionada)
          .toList();
    }
    if (medicoQuery.trim().isNotEmpty) {
      lista = lista
          .where((m) =>
              m["nombre"]!.toLowerCase().contains(medicoQuery.toLowerCase()))
          .toList();
    }
    return lista.cast<Map<String, String>>();
  }

  List<Map<String, String>> get turnosFiltrados {
    var lista = turnosDisponibles;
    if (especialidadSeleccionada != null) {
      lista = lista
          .where((t) => t["especialidad"] == especialidadSeleccionada)
          .toList();
    }
    if (medicoSeleccionado != null && medicoSeleccionado!.isNotEmpty) {
      lista = lista
          .where((t) => t["profesional"]!
              .toLowerCase()
              .contains(medicoSeleccionado!.toLowerCase()))
          .toList();
    }
    if (medicoQuery.trim().isNotEmpty) {
      lista = lista
          .where((t) =>
              t["profesional"]!.toLowerCase().contains(medicoQuery.toLowerCase()))
          .toList();
    }
    return lista;
  }

  void resetMedicoSeleccionado() {
    medicoSeleccionado = null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF2376F6)),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: Text(
          'Reservá un turno',
          style: TextStyle(
              color: Color(0xFF2376F6), fontWeight: FontWeight.bold, fontSize: 27),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: width > 400 ? 24 : 12, vertical: 10),
          children: [
            // Banner superior
            Container(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.only(bottom: 14),
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                image: const DecorationImage(
                  image: AssetImage('assets/images/ilustracion_historia_clinica.png'),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),

            // Card azul título "Sacá tu turno"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2376F6), Color(0xFF73BFFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.event_available_rounded,
                      color: Colors.white, size: 32),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Sacá tu turno",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),
            Text("Elegí especialidad",
                style: TextStyle(
                    color: Color(0xFF2376F6),
                    fontWeight: FontWeight.w500,
                    fontSize: 15)),
            const SizedBox(height: 3),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.local_hospital_rounded),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              value: especialidadSeleccionada,
              hint: Text("Seleccioná una especialidad"),
              items: [
                ...especialidades.map((esp) => DropdownMenuItem(
                      value: esp,
                      child: Text(esp),
                    )),
              ],
              onChanged: (val) {
                setState(() {
                  especialidadSeleccionada = val;
                  medicoSeleccionado = null;
                  medicoQuery = "";
                });
              },
            ),

            if (especialidadSeleccionada != null) ...[
              const SizedBox(height: 16),
              Text("Elegí médico",
                  style: TextStyle(
                      color: Color(0xFF2376F6),
                      fontWeight: FontWeight.w500,
                      fontSize: 15)),
              const SizedBox(height: 3),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                value: medicoSeleccionado,
                hint: Text("Seleccioná un médico"),
                items: medicosFiltrados
                    .map((med) => DropdownMenuItem(
                          value: med["nombre"],
                          child: Text(med["nombre"]!),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() => medicoSeleccionado = val);
                },
              ),
              const SizedBox(height: 16),
              Text("Buscar médico (opcional)",
                  style: TextStyle(
                      color: Color(0xFF2376F6),
                      fontWeight: FontWeight.w500,
                      fontSize: 15)),
              const SizedBox(height: 3),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (txt) {
                  setState(() {
                    medicoQuery = txt;
                    medicoSeleccionado = null;
                  });
                },
              ),
            ],

            const SizedBox(height: 16),

            if (especialidadSeleccionada != null)
              turnosFiltrados.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Text(
                        "No hay turnos disponibles para esa especialidad/médico.",
                        style: TextStyle(
                            color: Color(0xFF42506A), fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: turnosFiltrados.map((t) {
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 9, horizontal: 15),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor:
                                  const Color(0xFF2376F6).withOpacity(0.09),
                              child: const Icon(Icons.schedule,
                                  color: Color(0xFF2376F6), size: 27),
                            ),
                            title: Text(
                              "${t['fecha']} • ${t['hora']}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF193A72)),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['profesional'] ?? "",
                                  style: const TextStyle(
                                      color: Color(0xFF42506A)),
                                ),
                                if ((t['direccion'] ?? '').isNotEmpty)
                                  Text(
                                    t['direccion'] ?? "",
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[600]),
                                  ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    title: const Text(
                                      "Confirmar reserva",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                        "¿Deseás reservar el turno de ${t['fecha']} a las ${t['hora']} con ${t['profesional']}?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text("Cancelar")),
                                      ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF2376F6),
                                              foregroundColor: Colors.white),
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text("Confirmar")),
                                    ],
                                  ),
                                );

                                if (confirmar == true) {
                                  turnosReservados.add(Map.from(t));
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ConfirmacionTurnoScreen(turno: t)));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2376F6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                              child: const Text("Reservar",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

            const SizedBox(height: 10),
Container(
  margin: const EdgeInsets.symmetric(vertical: 7),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: const Color(0xFF73BFFF).withOpacity(0.13),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        "Política de cancelación:",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2376F6),
        ),
      ),
      SizedBox(height: 4),
      Text(
        "Podés cancelar hasta 2hs antes del turno. Los turnos pueden ser tomados por otros usuarios hasta confirmar tu reserva.",
        style: TextStyle(fontSize: 13.2, color: Color(0xFF193A72)),
      ),
      SizedBox(height: 5),
      Text(
        "⚠️ La disponibilidad se actualiza en tiempo real. En caso de superposición, el primer usuario en confirmar será el que reserve el turno.",
        style: TextStyle(fontSize: 13, color: Color(0xFFF76B1C)),
      ),
    ],
  ),
),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              MisTurnosScreen(turnos: turnosReservados)));
                },
                icon: const Icon(Icons.list_alt_rounded,
                    color: Color(0xFF2376F6)),
                label: const Text(
                  "Ver mis turnos",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2376F6),
                      fontSize: 16.5),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

// -------- CONFIRMACIÓN TURNO ---------
class ConfirmacionTurnoScreen extends StatelessWidget {
  final Map<String, String> turno;
  const ConfirmacionTurnoScreen({super.key, required this.turno});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8FBFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF2376F6)),
        title: Text('¡Turno reservado!',
            style: TextStyle(
                color: Color(0xFF2376F6), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Color(0xFF2376F6), size: 66),
                SizedBox(height: 16),
                Text(
                  "¡Listo! Reservaste tu turno para:",
                  style: TextStyle(
                      color: Color(0xFF193A72),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "${turno['fecha']} a las ${turno['hora']}\n${turno['profesional']}",
                  style: TextStyle(
                      color: Color(0xFF42506A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                if ((turno['direccion'] ?? '').isNotEmpty) ...[
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 20, color: Colors.grey[700]),
                      SizedBox(width: 5),
                      Text(turno['direccion']!, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    ],
                  ),
                ],
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Turno agregado a tu calendario.")));
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: Icon(Icons.calendar_today_rounded, color: Colors.white),
                  label: Text("Agendar en mi calendario",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2376F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 6),
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text("Volver al inicio"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------- MIS TURNOS ---------
class MisTurnosScreen extends StatelessWidget {
  final List<Map<String, String>> turnos;
  const MisTurnosScreen({super.key, required this.turnos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7FCFF),
      appBar: AppBar(
        title: Text("Mis turnos",
            style: TextStyle(
                color: Color(0xFF2376F6), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF2376F6)),
      ),
      body: turnos.isEmpty
          ? Center(
              child: Text(
                "No tenés turnos reservados.",
                style: TextStyle(color: Color(0xFF42506A), fontSize: 17),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(18),
              itemCount: turnos.length,
              itemBuilder: (_, i) {
                final t = turnos[i];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    leading: Icon(Icons.event_available_rounded,
                        color: Color(0xFF2376F6), size: 30),
                    title: Text(
                      "${t['fecha']} • ${t['hora']}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF193A72)),
                    ),
                    subtitle: Text(
                      t['profesional'] ?? "",
                      style: const TextStyle(color: Color(0xFF42506A)),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: Color(0xFF2376F6)),
                              SizedBox(width: 6),
                              Text(
                                "Detalles del turno",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
                                  SizedBox(width: 6),
                                  Text("Fecha: ", style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text("${t['fecha']}"),
                                ],
                              ),
                              SizedBox(height: 7),
                              Row(
                                children: [
                                  Icon(Icons.schedule, size: 18, color: Colors.grey[700]),
                                  SizedBox(width: 6),
                                  Text("Hora: ", style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text("${t['hora']}"),
                                ],
                              ),
                              SizedBox(height: 7),
                              Row(
                                children: [
                                  Icon(Icons.person, size: 18, color: Colors.grey[700]),
                                  SizedBox(width: 6),
                                  Text("Profesional: ", style: TextStyle(fontWeight: FontWeight.w600)),
                                  Expanded(child: Text("${t['profesional']}")),
                                ],
                              ),
                              SizedBox(height: 7),
                              if ((t['especialidad'] ?? '').isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.local_hospital, size: 18, color: Colors.grey[700]),
                                    SizedBox(width: 6),
                                    Text("Especialidad: ", style: TextStyle(fontWeight: FontWeight.w600)),
                                    Text("${t['especialidad']}"),
                                  ],
                                ),
                              if ((t['consultorio'] ?? '').isNotEmpty) ...[
                                SizedBox(height: 7),
                                Row(
                                  children: [
                                    Icon(Icons.meeting_room, size: 18, color: Colors.grey[700]),
                                    SizedBox(width: 6),
                                    Text("Consultorio: ", style: TextStyle(fontWeight: FontWeight.w600)),
                                    Text("${t['consultorio']}"),
                                  ],
                                ),
                              ],
                              if ((t['direccion'] ?? '').isNotEmpty) ...[
                                SizedBox(height: 7),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 18, color: Colors.grey[700]),
                                    SizedBox(width: 6),
                                    Text("Dirección: ", style: TextStyle(fontWeight: FontWeight.w600)),
                                    Expanded(child: Text("${t['direccion']}")),
                                  ],
                                ),
                              ],
                              if ((t['notas'] ?? '').isNotEmpty) ...[
                                SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF7FCFF),
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(
                                          color: Color(0xFF73BFFF), width: 1)),
                                  padding: EdgeInsets.all(9),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info, color: Color(0xFF2376F6), size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Notas: ${t['notas']}",
                                          style: TextStyle(
                                              color: Color(0xFF2376F6),
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text("Cerrar")),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
