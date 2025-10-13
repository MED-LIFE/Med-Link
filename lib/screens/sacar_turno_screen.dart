import 'package:flutter/material.dart';

// ---- MOCK DATA ----
final List<Map<String, String>> turnosDisponibles = [
  {
    "fecha": "Martes 13/08",
    "hora": "09:30",
    "profesional": "Dra. Pérez (Clínica)",
  },
  {
    "fecha": "Martes 13/08",
    "hora": "10:00",
    "profesional": "Dra. Pérez (Clínica)",
  },
  {
    "fecha": "Miércoles 14/08",
    "hora": "12:00",
    "profesional": "Dr. Ledesma (Cardio)",
  },
];

// ---- PANTALLA PRINCIPAL ----
class SacarTurnoScreen extends StatelessWidget {
  const SacarTurnoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD8F0FF), Color(0xFFE8FBFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: width > 400 ? 24 : 12, vertical: 10),
            children: [
              // Banner superior con imagen y saludo
              Container(
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.only(bottom: 14),
                height: 125,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('assets/images/ilustracion_historia_clinica.png'), // Cambiá por la que prefieras
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: Offset(0, 4),
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
                    Icon(Icons.event_available_rounded, color: Colors.white, size: 32),
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
              // Elegir especialidad/médico
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Especialidad / Profesional",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.local_hospital_rounded),
                  ),
                  value: "Clínica médica",
                  items: [
                    DropdownMenuItem(value: "Clínica médica", child: Text("Clínica médica")),
                    DropdownMenuItem(value: "Cardiología", child: Text("Cardiología")),
                  ],
                  onChanged: (val) {},
                ),
              ),
              // Lista de turnos disponibles
              ...turnosDisponibles.map((t) => Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFF2376F6).withOpacity(0.09),
                        child: Icon(Icons.schedule, color: Color(0xFF2376F6), size: 27),
                      ),
                      title: Text(
                        "${t['fecha']} • ${t['hora']}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF193A72)),
                      ),
                      subtitle: Text(
                        t['profesional'] ?? "",
                        style: const TextStyle(color: Color(0xFF42506A)),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2376F6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text("Reservar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
              // Política y leyenda
              Container(
                margin: const EdgeInsets.symmetric(vertical: 7),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Color(0xFF73BFFF).withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Política de cancelación:",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2376F6)),
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
              // Botón ver mis turnos
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.list_alt_rounded, color: Color(0xFF2376F6)),
                  label: Text(
                    "Ver mis turnos",
                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2376F6), fontSize: 16.5),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
