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
  {
    "fecha": "Jueves 15/08",
    "hora": "14:30",
    "profesional": "Dr. García (Traumatología)",
  },
  {
    "fecha": "Viernes 16/08",
    "hora": "11:00",
    "profesional": "Dra. Martínez (Dermatología)",
  },
];

// ---- PANTALLA PRINCIPAL ----
class SacarTurnoScreen extends StatefulWidget {
  const SacarTurnoScreen({Key? key}) : super(key: key);

  @override
  State<SacarTurnoScreen> createState() => _SacarTurnoScreenState();
}

class _SacarTurnoScreenState extends State<SacarTurnoScreen> {
  String especialidadSeleccionada = "Clínica médica";
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

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
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Sacar turno",
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
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 20, 
              vertical: 16
            ),
            children: [
              // Banner superior con imagen y saludo
              _buildBannerSuperior(),
              
              const SizedBox(height: 16),
              
              // Card azul título "Sacá tu turno"
              _buildTituloCard(),
              
              const SizedBox(height: 20),
              
              // Elegir especialidad/médico
              _buildEspecialidadSelector(),
              
              const SizedBox(height: 20),
              
              // Lista de turnos disponibles
              _buildListaTurnos(),
              
              const SizedBox(height: 20),
              
              // Política y leyenda
              _buildPoliticaCancelacion(),
              
              const SizedBox(height: 16),
              
              // Botón ver mis turnos
              _buildVerMisTurnos(),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSuperior() {
    return Container(
      padding: const EdgeInsets.all(0),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Imagen de fondo
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/ilustracion_historia_clinica.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            // Overlay gradient sutil
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2376F6).withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTituloCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E6BF0), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_available_rounded, 
              color: Colors.white, 
              size: 28
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Sacá tu turno",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEspecialidadSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: "Especialidad / Profesional",
          hintStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, 
            vertical: 18
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 16, right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2376F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Color(0xFF2376F6),
              size: 20,
            ),
          ),
        ),
        value: especialidadSeleccionada,
        dropdownColor: Colors.white,
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        items: const [
          DropdownMenuItem(
            value: "Clínica médica", 
            child: Text(
              "Clínica médica",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )
          ),
          DropdownMenuItem(
            value: "Cardiología", 
            child: Text(
              "Cardiología",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )
          ),
          DropdownMenuItem(
            value: "Traumatología", 
            child: Text(
              "Traumatología",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )
          ),
          DropdownMenuItem(
            value: "Dermatología", 
            child: Text(
              "Dermatología",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )
          ),
        ],
        onChanged: (val) {
          setState(() {
            especialidadSeleccionada = val ?? "Clínica médica";
          });
        },
        icon: Container(
          margin: const EdgeInsets.only(right: 12),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF2376F6),
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildListaTurnos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Turnos disponibles",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),
        ),
        ...turnosDisponibles.map((turno) => _buildTurnoCard(turno)),
      ],
    );
  }

  Widget _buildTurnoCard(Map<String, String> turno) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16, 
          horizontal: 20
        ),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2376F6).withOpacity(0.1),
                const Color(0xFF73BFFF).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.access_time_rounded, 
            color: Color(0xFF2376F6), 
            size: 26
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            "${turno['fecha']} • ${turno['hora']}",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              fontSize: 16,
              letterSpacing: -0.3,
            ),
          ),
        ),
        subtitle: Text(
          turno['profesional'] ?? "",
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          height: 44,
          child: ElevatedButton(
            onPressed: () {
              _mostrarDialogoConfirmacion(turno);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2376F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 20, 
                vertical: 12
              ),
              shadowColor: const Color(0xFF2376F6).withOpacity(0.3),
            ),
            child: const Text(
              "Reservar",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoliticaCancelacion() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2376F6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2376F6).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2376F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF2376F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Política de cancelación",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2376F6),
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Podés cancelar hasta 2hs antes del turno. Los turnos pueden ser tomados por otros usuarios hasta confirmar tu reserva.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFC107).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFF8F00),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: const Text(
                    "La disponibilidad se actualiza en tiempo real. En caso de superposición, el primer usuario en confirmar será el que reserve el turno.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B5000),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerMisTurnos() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          // Navegar a mis turnos
        },
        icon: const Icon(
          Icons.list_alt_rounded, 
          color: Color(0xFF2376F6),
          size: 22,
        ),
        label: const Text(
          "Ver mis turnos",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2376F6),
            fontSize: 16,
            letterSpacing: -0.3,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: 14, 
            horizontal: 24
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFF2376F6).withOpacity(0.05),
        ),
      ),
    );
  }

  void _mostrarDialogoConfirmacion(Map<String, String> turno) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Confirmar reserva",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¿Confirmas la reserva del turno?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2376F6).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${turno['fecha']} • ${turno['hora']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      turno['profesional'] ?? "",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmarReserva(turno);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2376F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Confirmar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmarReserva(Map<String, String> turno) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Turno reservado: ${turno['fecha']} ${turno['hora']}"),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}