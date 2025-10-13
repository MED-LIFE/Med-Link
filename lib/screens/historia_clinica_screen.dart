import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_roffo/screens/completar_perfil_screen.dart';

// =============== SUBPANTALLAS MOCK ===================
class DiagnosticoScreen extends StatelessWidget {
  const DiagnosticoScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Color(0xFF2376F6)),
        title: const Text('Diagnóstico', style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF73BFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_rounded, color: Colors.white, size: 28),
                SizedBox(width: 13),
                Expanded(
                  child: Text(
                    "Acá podés ver el diagnóstico principal, descripción, indicadores y evolución.",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.5),
                  ),
                ),
              ],
            ),
          ),
          const Text('Código CIE10: I10', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF193A72))),
          const SizedBox(height: 8),
          const Text('Diagnóstico: Hipertensión arterial esencial', style: TextStyle(fontSize: 16, color: Color(0xFF42506A))),
          const SizedBox(height: 17),
          const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2376F6))),
          const SizedBox(height: 7),
          const Text('Elevación persistente de la presión arterial. Requiere control regular, adherencia a medicación y cambios en el estilo de vida.', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 18),
          const Text('Indicadores recientes:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2376F6))),
          const SizedBox(height: 7),
          const Text('Presión última medición: 142/92 mmHg', style: TextStyle(fontSize: 15)),
          const Text('Riesgo cardiovascular: Moderado', style: TextStyle(fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.trending_up, color: Color(0xFF2376F6)),
              SizedBox(width: 5),
              Text('Última mejora: -5 mmHg', style: TextStyle(color: Color(0xFF2376F6))),
            ],
          ),
        ],
      ),
    );
  }
}

class TurnosScreen extends StatelessWidget {
  const TurnosScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> turnos = const [
    {
      "fecha": "10 de agosto, 2025",
      "profesional": "Dra. Pérez",
      "estado": "Realizado",
      "hora": "10:00 AM",
    },
    {
      "fecha": "05 de julio, 2025",
      "profesional": "Dra. Gómez",
      "estado": "Ausente",
      "hora": "09:00 AM",
    },
    {
      "fecha": "20 de junio, 2025",
      "profesional": "Dr. Ledesma",
      "estado": "Realizado",
      "hora": "11:30 AM",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Color(0xFF2376F6)),
        title: const Text('Turnos', style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18.0),
        itemCount: turnos.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF4FE1F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.event_note, color: Colors.white, size: 28),
                  SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      "Acá vas a encontrar el historial de turnos, estados y recordatorios.",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.5),
                    ),
                  ),
                ],
              ),
            );
          }
          final turno = turnos[i - 1];
          return TurnoTile(
            fecha: turno["fecha"],
            profesional: turno["profesional"],
            estado: turno["estado"],
            hora: turno["hora"],
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Color(0xFF2376F6)),
                    SizedBox(width: 10),
                    Text("Detalle de turno", style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Fecha: ${turno["fecha"]}", style: TextStyle(fontWeight: FontWeight.w500)),
                    Text("Hora: ${turno["hora"]}"),
                    Text("Profesional: ${turno["profesional"]}"),
                    SizedBox(height: 10),
                    Text("Estado: ${turno["estado"]}", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber, size: 20),
                        SizedBox(width: 7),
                        Expanded(child: Text("Por favor llegar 20 minutos antes de su horario.", style: TextStyle(fontSize: 14))),
                      ],
                    )
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text("Cerrar", style: TextStyle(color: Color(0xFF2376F6))),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TurnoTile extends StatelessWidget {
  final String fecha;
  final String profesional;
  final String estado;
  final String hora;
  final VoidCallback? onTap;
  const TurnoTile({
    required this.fecha,
    required this.profesional,
    required this.estado,
    required this.hora,
    this.onTap,
    Key? key}) : super(key: key);

  Color getEstadoColor() {
    switch (estado) {
      case "Realizado":
        return const Color(0xFF0EDB92);
      case "Ausente":
        return const Color(0xFFF76B1C);
      case "Pendiente":
        return const Color(0xFF73BFFF);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      color: const Color(0xFFF6FAFD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        title: Text(fecha, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF193A72))),
        subtitle: Text('$profesional – Estado: $estado', style: const TextStyle(fontSize: 15)),
        trailing: Icon(Icons.circle, color: getEstadoColor(), size: 14),
      ),
    );
  }
}

class MedicamentosScreen extends StatelessWidget {
  const MedicamentosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Color(0xFF2376F6)),
        title: const Text('Medicamentos', style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF4FE1F3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.medical_services, color: Colors.white, size: 28),
                SizedBox(width: 13),
                Expanded(
                  child: Text(
                    "Listado de los medicamentos actuales, pedidos y órdenes recientes.",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.5),
                  ),
                ),
              ],
            ),
          ),
          const MedicamentoTile(nombre: "Losartán 50mg", indicacion: "1 comp. cada 12 hs", pedidos: 7, ordenes: 2),
          const MedicamentoTile(nombre: "Enalapril 10mg", indicacion: "1 comp. por la mañana", pedidos: 5, ordenes: 1),
        ],
      ),
    );
  }
}

class MedicamentoTile extends StatelessWidget {
  final String nombre;
  final String indicacion;
  final int pedidos;
  final int ordenes;

  const MedicamentoTile({
    required this.nombre,
    required this.indicacion,
    this.pedidos = 0,
    this.ordenes = 0,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: const Color(0xFFF1F8FE),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.medical_services_rounded, color: Color(0xFF2376F6)),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF193A72))),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(indicacion, style: const TextStyle(fontSize: 14)),
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 16, color: Colors.orange[800]),
                SizedBox(width: 4),
                Text("$pedidos pedidos", style: TextStyle(fontSize: 13, color: Colors.orange[800])),
                SizedBox(width: 10),
                Icon(Icons.receipt_long, size: 16, color: Colors.teal[700]),
                SizedBox(width: 4),
                Text("$ordenes órdenes", style: TextStyle(fontSize: 13, color: Colors.teal[700])),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ============== RESUMEN CLÍNICO ==============

class ResumenScreen extends StatelessWidget {
  const ResumenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Color(0xFF2376F6)),
        title: const Text('Resumen Clínico',
            style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          _ResumenBlock(
            title: "Diagnóstico principal",
            icon: Icons.assignment_turned_in_rounded,
            content: "Hipertensión arterial esencial.",
          ),
          _ResumenBlock(
            title: "Situación actual",
            icon: Icons.favorite_rounded,
            content:
                "Paciente en seguimiento regular. Sin signos de daño a órganos diana.",
          ),
          _ResumenBlock(
            title: "Plan terapéutico",
            icon: Icons.local_hospital_rounded,
            content:
                "Mantener control periódico, adherencia a medicación y hábitos saludables.",
          ),
          _ResumenBlock(
            title: "Próxima revisión",
            icon: Icons.event_available_rounded,
            content: "10 de agosto, 2025 con Dra. Pérez.",
          ),
          const SizedBox(height: 12),
          Divider(),
          const SizedBox(height: 8),
          const Text("Última actualización: 25/07/2025",
              style: TextStyle(fontSize: 14, color: Color(0xFF888FA2))),
        ],
      ),
    );
  }
}

class _ResumenBlock extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _ResumenBlock(
      {required this.title, required this.content, required this.icon, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF6FAFD),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE6F2FD),
          child: Icon(icon, color: const Color(0xFF2376F6)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF2376F6),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15, color: Color(0xFF42506A)),
          ),
        ),
      ),
    );
  }
}

// ======================= HOME HISTORIA CLÍNICA (FIRESTORE + DISEÑO) ========================

class HistoriaClinicaScreen extends StatelessWidget {
  const HistoriaClinicaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FCFF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Historia clínica',
            style: TextStyle(
              color: Color(0xFF2376F6),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2376F6)),
              tooltip: 'Editar perfil',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompletarPerfilScreen()),
                );
              },
            ),
          ],
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Color(0xFF2376F6)),
        ),
        body: const Center(child: Text("No logueado", style: TextStyle(color: Colors.black54))),
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7FCFF),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Historia clínica',
                style: TextStyle(
                  color: Color(0xFF2376F6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF2376F6)),
                  tooltip: 'Editar perfil',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CompletarPerfilScreen()),
                    );
                  },
                ),
              ],
              automaticallyImplyLeading: true,
              iconTheme: const IconThemeData(color: Color(0xFF2376F6)),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: const Color(0xFFF7FCFF),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Historia clínica',
                style: TextStyle(
                  color: Color(0xFF2376F6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF2376F6)),
                  tooltip: 'Editar perfil',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CompletarPerfilScreen()),
                    );
                  },
                ),
              ],
              automaticallyImplyLeading: true,
              iconTheme: const IconThemeData(color: Color(0xFF2376F6)),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2376F6), size: 42),
                  const SizedBox(height: 16),
                  const Text(
                    "Completá tus datos para ver la historia clínica.",
                    style: TextStyle(
                        color: Color(0xFF2376F6),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CompletarPerfilScreen()),
                      );
                    },
                    child: const Text("Completar perfil"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2376F6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!.data()!;

        return Scaffold(
          backgroundColor: const Color(0xFFF7FCFF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Historia clínica',
              style: TextStyle(
                color: Color(0xFF2376F6),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF2376F6)),
                tooltip: 'Editar perfil',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CompletarPerfilScreen()),
                  );
                },
              ),
            ],
            automaticallyImplyLeading: true,
            iconTheme: const IconThemeData(color: Color(0xFF2376F6)),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Ilustración
                  Container(
                    height: 120,
                    margin: const EdgeInsets.only(top: 5, bottom: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/ilustracion_historia_clinica.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) => const Center(child: Text("No se encontró la imagen")),
                    ),
                  ),
                  // Banner Identificación
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2376F6), Color(0xFF73BFFF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.17),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 29),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Identificación del paciente",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text("DNI: ${data['dni'] ?? '-'}", style: const TextStyle(color: Colors.white70, fontSize: 14.5)),
                                  const SizedBox(width: 13),
                                  Text(data['centro'] ?? 'Roffo', style: const TextStyle(color: Colors.white70, fontSize: 14.5)),
                                  const SizedBox(width: 13),
                                  Text("${data['edad'] ?? '-'} años", style: const TextStyle(color: Colors.white70, fontSize: 14.5)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PRÓXIMA CITA
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4FE1F3), Color(0xFF73BFFF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            "Próxima cita: ${data['proxima_cita'] ?? 'Sin datos'}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Fecha de actualización
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Text(
                      "Actualizado el ${data['fecha_actualizacion'] ?? '--/--/----'}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  // Bloques de acceso a secciones (cards alineadas)
                  _CardAcceso(
                    icon: Icons.menu_rounded,
                    title: "Resumen",
                    content: data['resumen'] ?? "Sin datos de resumen.",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResumenScreen())),
                    tag: "Ver más",
                    bgColor: const Color(0xFFF1F8FE),
                    iconColor: const Color(0xFF2376F6),
                  ),
                  _CardAcceso(
                    icon: Icons.science_rounded,
                    title: "Diagnóstico",
                    content: data['diagnostico'] ?? "Sin diagnóstico principal.",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiagnosticoScreen())),
                  ),
                  _CardAcceso(
                    icon: Icons.calendar_today_rounded,
                    title: "Turnos",
                    content: data['proxima_cita'] ?? "Sin próximos turnos.",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TurnosScreen())),
                  ),
                  _CardAcceso(
                    icon: Icons.medication_rounded,
                    title: "Medicamentos",
                    content: data['medicamentos'] ?? "Sin medicación activa.",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicamentosScreen())),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ========== CARD ACCESO GENÉRICA ==========

class _CardAcceso extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final VoidCallback? onTap;
  final Color? bgColor;
  final Color? iconColor;
  final String? tag;

  const _CardAcceso({
    required this.icon,
    required this.title,
    required this.content,
    this.onTap,
    this.bgColor,
    this.iconColor,
    this.tag,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: bgColor ?? Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: (bgColor ?? const Color(0xFFF1F8FE)).withOpacity(0.38),
                child: Icon(icon, color: iconColor ?? const Color(0xFF193A72), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF193A72),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      content,
                      style: const TextStyle(
                        color: Color(0xFF42506A),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (tag != null)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          tag!,
                          style: TextStyle(
                            color: iconColor ?? const Color(0xFF2376F6),
                            fontWeight: FontWeight.w600,
                            fontSize: 13.2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: Color(0xFFB6BFC9)),
            ],
          ),
        ),
      ),
    );
  }
}
