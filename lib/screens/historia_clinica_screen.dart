import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_roffo/screens/completar_perfil_screen.dart';
import 'package:app_roffo/screens/sacar_turno_screen.dart';
import 'package:app_roffo/screens/mi_perfil_screen.dart';
import 'package:app_roffo/screens/estudios_screen.dart';
import 'dart:math' as math;

// =============== MODELOS DE DATOS ===================
class HistoriaClinicaData {
  final String dni;
  final String centro;
  final String edad;
  final String proximaCita;
  final String fechaActualizacion;
  final String resumen;
  final String diagnostico;
  final String medicamentos;
  final Map<String, dynamic> datosCompletos;

  HistoriaClinicaData({
    required this.dni,
    required this.centro,
    required this.edad,
    required this.proximaCita,
    required this.fechaActualizacion,
    required this.resumen,
    required this.diagnostico,
    required this.medicamentos,
    required this.datosCompletos,
  });

  factory HistoriaClinicaData.fromMap(Map<String, dynamic> data) {
    return HistoriaClinicaData(
      dni: data['dni'] ?? '-',
      centro: data['centro'] ?? 'Instituto Ángel H. Roffo',
      edad: data['edad']?.toString() ?? '-',
      proximaCita: data['proxima_cita'] ?? 'Sin datos',
      fechaActualizacion: data['fecha_actualizacion'] ?? '--/--/----',
      resumen: data['resumen'] ?? "Sin datos de resumen.",
      diagnostico: data['diagnostico'] ?? "Sin diagnóstico principal.",
      medicamentos: data['medicamentos'] ?? "Sin medicación activa.",
      datosCompletos: data,
    );
  }
}

// =============== CONSTANTES Y DATOS MOCK ===================
class HistoriaClinicaConstants {
  static const Color primaryColor = Color(0xFF2376F6);
  static const Color secondaryColor = Color(0xFF73BFFF);
  static const Color accentColor = Color(0xFF4FE1F3);
  static const Color darkBlue = Color(0xFF193A72);
  static const Color mediumGray = Color(0xFF42506A);
  static const Color lightGray = Color(0xFFB6BFC9);
  static const Color backgroundColor = Color(0xFFF7FCFF);
  static const Color cardColor = Color(0xFFF1F8FE);
  
  // Rutas de assets
  static const String bannerImagePath = 'assets/images/historia_clinica.png';
  static const String defaultIllustracion = 'assets/images/ilustracion_historia_clinica.png';
  
  // Datos mock mejorados
  static const List<Map<String, dynamic>> diagnosticosMock = [
    {
      "codigo": "I10",
      "nombre": "Hipertensión arterial esencial",
      "descripcion": "Elevación persistente de la presión arterial. Requiere control regular, adherencia a medicación y cambios en el estilo de vida.",
      "fechaDiagnostico": "15/03/2024",
      "medico": "Dr. Fernández",
      "severidad": "Moderada",
      "estado": "Activo",
      "indicadores": {
        "presionUltima": "142/92 mmHg",
        "riesgoCardiovascular": "Moderado",
        "ultimaMejora": "-5 mmHg"
      }
    },
    {
      "codigo": "E11",
      "nombre": "Diabetes mellitus tipo 2",
      "descripcion": "Diabetes tipo 2 con buen control glucémico mediante medicación y dieta.",
      "fechaDiagnostico": "22/08/2023",
      "medico": "Dra. González",
      "severidad": "Leve",
      "estado": "Controlado",
      "indicadores": {
        "glucemiaUltima": "126 mg/dl",
        "hba1c": "6.8%",
        "ultimaMejora": "-0.3% HbA1c"
      }
    }
  ];

  static const List<Map<String, dynamic>> turnosMock = [
    {
      "fecha": "10 de agosto, 2025",
      "profesional": "Dra. Pérez",
      "estado": "Realizado",
      "hora": "10:00 AM",
      "especialidad": "Clínica médica",
      "motivo": "Control rutinario",
      "consultorio": "1A",
      "observaciones": "Paciente concurrió puntualmente. Control satisfactorio."
    },
    {
      "fecha": "05 de julio, 2025",
      "profesional": "Dra. Gómez",
      "estado": "Ausente",
      "hora": "09:00 AM",
      "especialidad": "Cardiología",
      "motivo": "Control cardiológico",
      "consultorio": "2B",
      "observaciones": "Paciente no se presentó sin aviso previo."
    },
    {
      "fecha": "20 de junio, 2025",
      "profesional": "Dr. Ledesma",
      "estado": "Realizado",
      "hora": "11:30 AM",
      "especialidad": "Cardiología",
      "motivo": "Seguimiento hipertensión",
      "consultorio": "2A",
      "observaciones": "Excelente evolución. Continuar tratamiento actual."
    },
    {
      "fecha": "15 de agosto, 2025",
      "profesional": "Dr. Russo",
      "estado": "Próximo",
      "hora": "14:00 PM",
      "especialidad": "Clínica médica",
      "motivo": "Control trimestral",
      "consultorio": "1C",
      "observaciones": "Turno confirmado. Traer estudios recientes."
    }
  ];

  static const List<Map<String, dynamic>> medicamentosMock = [
    {
      "nombre": "Losartán 50mg",
      "principioActivo": "Losartán potásico",
      "indicacion": "1 comp. cada 12 hs",
      "viaAdministracion": "Oral",
      "fechaInicio": "15/03/2024",
      "fechaVencimiento": "15/03/2025",
      "medico": "Dr. Fernández",
      "pedidos": 7,
      "ordenes": 2,
      "categoria": "Antihipertensivo",
      "alertas": [],
      "activo": true
    },
    {
      "nombre": "Enalapril 10mg",
      "principioActivo": "Enalapril maleato",
      "indicacion": "1 comp. por la mañana",
      "viaAdministracion": "Oral",
      "fechaInicio": "22/08/2023",
      "fechaVencimiento": "22/08/2025",
      "medico": "Dra. González",
      "pedidos": 5,
      "ordenes": 1,
      "categoria": "IECA",
      "alertas": ["Controlar función renal"],
      "activo": true
    },
    {
      "nombre": "Metformina 850mg",
      "principioActivo": "Metformina clorhidrato",
      "indicacion": "1 comp. cada 12 hs con las comidas",
      "viaAdministracion": "Oral",
      "fechaInicio": "22/08/2023",
      "fechaVencimiento": "22/08/2025",
      "medico": "Dra. González",
      "pedidos": 8,
      "ordenes": 3,
      "categoria": "Antidiabético",
      "alertas": [],
      "activo": true
    }
  ];

  static const List<Map<String, dynamic>> signosVitalesMock = [
    {
      "fecha": "10/08/2025",
      "presionSistolica": 138,
      "presionDiastolica": 88,
      "frecuenciaCardiaca": 72,
      "temperatura": 36.5,
      "peso": 78.5,
      "altura": 170,
      "saturacionOxigeno": 98,
      "glucemia": 124
    },
    {
      "fecha": "05/07/2025",
      "presionSistolica": 142,
      "presionDiastolica": 92,
      "frecuenciaCardiaca": 76,
      "temperatura": 36.8,
      "peso": 79.2,
      "altura": 170,
      "saturacionOxigeno": 97,
      "glucemia": 132
    }
  ];
}

// =============== COMPONENTES REUTILIZABLES ===================
class LoadingCard extends StatelessWidget {
  final String message;
  
  const LoadingCard({
    Key? key,
    this.message = "Cargando información médica...",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(HistoriaClinicaConstants.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: HistoriaClinicaConstants.mediumGray,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ✅ NUEVO COMPONENTE: Banner Limpio (reemplaza los banners coloridos horribles)
class CleanInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  
  const CleanInfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF193A72),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF42506A),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============== PANTALLA DE CARGA TECH MEJORADA (CAP 1 FIX) ===================
class TechLoadingScreen extends StatefulWidget {
  const TechLoadingScreen({Key? key}) : super(key: key);

  @override
  State<TechLoadingScreen> createState() => _TechLoadingScreenState();
}

class _TechLoadingScreenState extends State<TechLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7FCFF), Color(0xFFE8F4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2376F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2376F6).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: Color(0xFF2376F6),
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Indicador de carga circular tech
              Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo externo giratorio
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2376F6).withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: CustomPaint(
                            painter: LoadingCirclePainter(),
                          ),
                        ),
                      );
                    },
                  ),
                  // Círculo interno pulsante
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2376F6),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Texto animado
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        const Text(
                          'Cargando información médica...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2376F6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Verificando credenciales y cargando datos...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Indicadores de progreso
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _fadeController,
                    builder: (context, child) {
                      final delay = index * 0.3;
                      final progress = (_fadeController.value + delay) % 1.0;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            const Color(0xFF2376F6).withOpacity(0.3),
                            const Color(0xFF2376F6),
                            progress,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2376F6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    const sweepAngle = math.pi / 2;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2 - 2),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =============== COMPONENTES TECH MEJORADOS (CAP 2/3 FIX) ===================
class TechInfoCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isVerified;
  
  const TechInfoCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    this.isVerified = false,
  }) : super(key: key);

  @override
  State<TechInfoCard> createState() => _TechInfoCardState();
}

class _TechInfoCardState extends State<TechInfoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Shimmer pasa solo UNA vez
    if (widget.isVerified) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ARREGLO DEFINITIVO: Container con constraints estrictos
    return Container(
      height: 80, // ALTURA MÁS ESTRICTA
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Efecto shimmer - SOLO UNA VEZ
          if (widget.isVerified)
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          transform: GradientTransformation(_shimmerAnimation.value),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          // Contenido principal - PADDING FIJO
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), // PADDING FIJO
            child: Row(
              children: [
                Container(
                  width: 42, // TAMAÑO FIJO
                  height: 42, // TAMAÑO FIJO
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 22, // TAMAÑO FIJO
                  ),
                ),
                const SizedBox(width: 14), // SPACING FIJO
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // CENTRADO PERFECTO
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15, // TAMAÑO FIJO
                                height: 1.2, // LINE HEIGHT FIJO
                              ),
                              maxLines: 1, // UNA SOLA LÍNEA
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Verificado',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3), // SPACING FIJO
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12, // TAMAÑO FIJO
                          height: 1.2, // LINE HEIGHT FIJO
                        ),
                        maxLines: 1, // UNA SOLA LÍNEA FORZADA
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GradientTransformation extends GradientTransform {
  final double progress;
  
  const GradientTransformation(this.progress);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * progress, 0, 0);
  }
}

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorCard({
    Key? key,
    this.message = "Error al cargar la información",
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Reintentar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class IdentificationBanner extends StatelessWidget {
  final HistoriaClinicaData data;
  
  const IdentificationBanner({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HistoriaClinicaConstants.primaryColor, HistoriaClinicaConstants.secondaryColor],
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Identificación del paciente",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildInfoChip("DNI: ${data.dni}"),
                    const SizedBox(width: 8),
                    _buildInfoChip(data.centro.length > 15 ? "Roffo" : data.centro),
                    const SizedBox(width: 8),
                    _buildInfoChip("${data.edad} años"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

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
          colors: [HistoriaClinicaConstants.accentColor, HistoriaClinicaConstants.secondaryColor],
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

// =============== SUBPANTALLAS DETALLADAS ===================
class DiagnosticoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> diagnostico;
  
  const DiagnosticoDetailScreen({
    Key? key,
    required this.diagnostico,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoriaClinicaConstants.backgroundColor,
      appBar: AppBar(
        leading: BackButton(color: HistoriaClinicaConstants.primaryColor),
        title: const Text(
          'Diagnóstico Detallado',
          style: TextStyle(
            color: HistoriaClinicaConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ CORREGIDO: Banner limpio en lugar del horrible azul
            CleanInfoCard(
              icon: Icons.info_outlined,
              title: "Información del diagnóstico",
              description: "Detalles completos sobre tu diagnóstico principal, evolución médica y recomendaciones del especialista.",
            ),

            // Información principal del diagnóstico
            _buildDiagnosticCard(),
            
            const SizedBox(height: 20),
            
            // Indicadores y métricas
            _buildIndicatorsSection(),
            
            const SizedBox(height: 20),
            
            // Evolución y tendencias
            _buildEvolutionSection(),
            
            const SizedBox(height: 20),
            
            // Acciones y recomendaciones
            _buildActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    diagnostico["codigo"] ?? "N/A",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: HistoriaClinicaConstants.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                _buildStatusChip(diagnostico["estado"] ?? "Activo"),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              diagnostico["nombre"] ?? "Sin nombre",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: HistoriaClinicaConstants.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              diagnostico["descripcion"] ?? "Sin descripción disponible",
              style: const TextStyle(
                fontSize: 15,
                color: HistoriaClinicaConstants.mediumGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            
            // Información adicional
            _buildInfoRow("Fecha diagnóstico", diagnostico["fechaDiagnostico"] ?? "N/A"),
            _buildInfoRow("Médico responsable", diagnostico["medico"] ?? "N/A"),
            _buildInfoRow("Severidad", diagnostico["severidad"] ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'activo':
        color = Colors.orange;
        break;
      case 'controlado':
        color = Colors.green;
        break;
      case 'en tratamiento':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Color.lerp(color, Colors.black, 0.3)!,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildIndicatorsSection() {
    final indicadores = diagnostico["indicadores"] as Map<String, dynamic>?;
    if (indicadores == null || indicadores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Indicadores recientes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HistoriaClinicaConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ...indicadores.entries.map((entry) => 
              _buildIndicatorTile(entry.key, entry.value.toString())
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorTile(String key, String value) {
    IconData icon;
    Color color;
    
    switch (key.toLowerCase()) {
      case 'presionultima':
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case 'riesgocardiovascular':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'glucemiaultima':
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      default:
        icon = Icons.analytics;
        color = HistoriaClinicaConstants.primaryColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatKey(key),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: HistoriaClinicaConstants.darkBlue,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: HistoriaClinicaConstants.mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    switch (key.toLowerCase()) {
      case 'presionultima':
        return 'Presión arterial';
      case 'riesgocardiovascular':
        return 'Riesgo cardiovascular';
      case 'glucemiaultima':
        return 'Glucemia';
      case 'hba1c':
        return 'Hemoglobina glicosilada';
      case 'ultimamejora':
        return 'Última mejora';
      default:
        return key.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
    }
  }

  Widget _buildEvolutionSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: HistoriaClinicaConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Evolución",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoriaClinicaConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progreso simulado
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.green.shade400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "70% de mejora desde el diagnóstico inicial",
              style: TextStyle(
                color: HistoriaClinicaConstants.mediumGray,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tendencia
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Tendencia positiva en los últimos controles",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Acciones recomendadas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HistoriaClinicaConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionButton(
              "Solicitar nuevo turno",
              Icons.calendar_today,
              HistoriaClinicaConstants.primaryColor,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Redirigiendo a solicitud de turnos...")),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildActionButton(
              "Ver medicación actual",
              Icons.medication,
              Colors.green,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mostrando medicación actual...")),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildActionButton(
              "Descargar informe",
              Icons.download,
              Colors.orange,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Generando informe PDF...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: HistoriaClinicaConstants.mediumGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: HistoriaClinicaConstants.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TurnosDetailScreen extends StatelessWidget {
  const TurnosDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoriaClinicaConstants.backgroundColor,
      appBar: AppBar(
        leading: BackButton(color: HistoriaClinicaConstants.primaryColor),
        title: const Text(
          'Historial de Turnos',
          style: TextStyle(
            color: HistoriaClinicaConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            color: HistoriaClinicaConstants.primaryColor,
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18.0),
        children: [
          // ✅ CORREGIDO: Banner limpio en lugar del horrible cyan
          CleanInfoCard(
            icon: Icons.event_note_outlined,
            title: "Historial de turnos",
            description: "Registro completo de tus citas médicas, estados de asistencia y observaciones del profesional.",
          ),

          // Estadísticas rápidas
          _buildStatsCards(),
          
          const SizedBox(height: 20),

          // Lista de turnos
          ...HistoriaClinicaConstants.turnosMock.map((turno) => 
            EnhancedTurnoTile(
              turno: turno,
              onTap: () => _showTurnoDetail(context, turno),
            )
          ).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // ✅ CORREGIDO: Ahora navega a SacarTurnoScreen en lugar de SnackBar fake
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SacarTurnoScreen()),
          );
        },
        backgroundColor: HistoriaClinicaConstants.primaryColor,
        label: const Text("Nuevo turno"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Total",
            "${HistoriaClinicaConstants.turnosMock.length}",
            Icons.event,
            HistoriaClinicaConstants.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Realizados",
            "${HistoriaClinicaConstants.turnosMock.where((t) => t['estado'] == 'Realizado').length}",
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            "Próximos",
            "${HistoriaClinicaConstants.turnosMock.where((t) => t['estado'] == 'Próximo').length}",
            Icons.schedule,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: HistoriaClinicaConstants.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Filtrar turnos"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Todos los turnos"),
              leading: Radio(value: "todos", groupValue: "todos", onChanged: (_) {}),
            ),
            ListTile(
              title: const Text("Solo realizados"),
              leading: Radio(value: "realizados", groupValue: "todos", onChanged: (_) {}),
            ),
            ListTile(
              title: const Text("Solo próximos"),
              leading: Radio(value: "proximos", groupValue: "todos", onChanged: (_) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Aplicar"),
          ),
        ],
      ),
    );
  }

  void _showTurnoDetail(BuildContext context, Map<String, dynamic> turno) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TurnoDetailBottomSheet(turno: turno),
    );
  }
}

class EnhancedTurnoTile extends StatelessWidget {
  final Map<String, dynamic> turno;
  final VoidCallback onTap;

  const EnhancedTurnoTile({
    Key? key,
    required this.turno,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getEstadoColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getEstadoIcon(),
                      color: _getEstadoColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turno["fecha"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: HistoriaClinicaConstants.darkBlue,
                          ),
                        ),
                        Text(
                          "${turno["hora"]} • ${turno["profesional"]}",
                          style: const TextStyle(
                            color: HistoriaClinicaConstants.mediumGray,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEstadoColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      turno["estado"] ?? "",
                      style: TextStyle(
                        color: _getEstadoColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              if (turno["motivo"] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        turno["motivo"],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor() {
    switch (turno["estado"]) {
      case "Realizado":
        return Colors.green;
      case "Ausente":
        return Colors.red;
      case "Próximo":
        return Colors.orange;
      case "Pendiente":
        return HistoriaClinicaConstants.primaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon() {
    switch (turno["estado"]) {
      case "Realizado":
        return Icons.check_circle;
      case "Ausente":
        return Icons.cancel;
      case "Próximo":
        return Icons.schedule;
      case "Pendiente":
        return Icons.pending;
      default:
        return Icons.circle;
    }
  }
}

class TurnoDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> turno;

  const TurnoDetailBottomSheet({
    Key? key,
    required this.turno,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event_note,
                  color: HistoriaClinicaConstants.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detalle del turno",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HistoriaClinicaConstants.darkBlue,
                      ),
                    ),
                    Text(
                      turno["fecha"] ?? "",
                      style: const TextStyle(
                        color: HistoriaClinicaConstants.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Detalles
          _buildDetailRow("Fecha", turno["fecha"]),
          _buildDetailRow("Hora", turno["hora"]),
          _buildDetailRow("Profesional", turno["profesional"]),
          _buildDetailRow("Especialidad", turno["especialidad"]),
          _buildDetailRow("Estado", turno["estado"]),
          
          if (turno["motivo"] != null)
            _buildDetailRow("Motivo", turno["motivo"]),
          
          if (turno["consultorio"] != null)
            _buildDetailRow("Consultorio", turno["consultorio"]),
          
          if (turno["observaciones"] != null && turno["observaciones"].isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              "Observaciones:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HistoriaClinicaConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                turno["observaciones"],
                style: const TextStyle(
                  color: HistoriaClinicaConstants.mediumGray,
                  fontSize: 14,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Acciones
          if (turno["estado"] == "Próximo") ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // ✅ CORREGIDO: Función de cancelación implementada
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text("Cancelar turno"),
                      content: const Text("¿Estás seguro que deseas cancelar este turno? Esta acción no se puede deshacer."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("No"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Turno cancelado correctamente"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text("Sí, cancelar", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.cancel),
                label: const Text("Cancelar turno"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text("Cerrar"),
              style: OutlinedButton.styleFrom(
                foregroundColor: HistoriaClinicaConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: HistoriaClinicaConstants.mediumGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(
                color: HistoriaClinicaConstants.darkBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicamentosDetailScreen extends StatefulWidget {
  const MedicamentosDetailScreen({Key? key}) : super(key: key);

  @override
  State<MedicamentosDetailScreen> createState() => _MedicamentosDetailScreenState();
}

class _MedicamentosDetailScreenState extends State<MedicamentosDetailScreen> {
  String _filtro = "todos";
  String _busqueda = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoriaClinicaConstants.backgroundColor,
      appBar: AppBar(
        leading: BackButton(color: HistoriaClinicaConstants.primaryColor),
        title: const Text(
          'Medicamentos',
          style: TextStyle(
            color: HistoriaClinicaConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: HistoriaClinicaConstants.primaryColor,
            onPressed: () => _showAddMedicationDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner informativo mejorado
          Container(
            margin: const EdgeInsets.all(16), // Reducido de 18 a 16
            padding: const EdgeInsets.all(14), // Reducido de 16 a 14
            decoration: BoxDecoration(
              color: HistoriaClinicaConstants.accentColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.medical_services, color: Colors.white, size: 24), // Reducido de 28 a 24
                SizedBox(width: 12), // Reducido de 16 a 12
                Expanded(
                  child: Text(
                    "Gestión completa de tu medicación actual, historial y pedidos.",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Reducido de 15 a 14
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filtros y búsqueda mejorados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // Reducido de 18 a 16
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 20), // Reducido tamaño de ícono
                    hintText: "Buscar medicamentos...",
                    hintStyle: const TextStyle(fontSize: 14), // Agregado tamaño de fuente
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reducido padding
                  ),
                  style: const TextStyle(fontSize: 14), // Agregado tamaño de fuente
                  onChanged: (value) => setState(() => _busqueda = value),
                ),
                
                const SizedBox(height: 10), // Reducido de 12 a 10
                
                // Filtros
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("Todos", "todos"),
                      _buildFilterChip("Activos", "activos"),
                      _buildFilterChip("Con alertas", "alertas"),
                      _buildFilterChip("Próximos a vencer", "vencimiento"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14), // Reducido de 16 a 14

          // Lista de medicamentos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16), // Reducido de 18 a 16
              itemCount: _medicamentosFiltrados.length,
              itemBuilder: (context, index) {
                final medicamento = _medicamentosFiltrados[index];
                return EnhancedMedicamentoTile(
                  medicamento: medicamento,
                  onTap: () => _showMedicamentoDetail(medicamento),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _medicamentosFiltrados {
    var lista = HistoriaClinicaConstants.medicamentosMock;
    
    // Aplicar filtro
    switch (_filtro) {
      case "activos":
        lista = lista.where((m) => m["activo"] == true).toList();
        break;
      case "alertas":
        lista = lista.where((m) => (m["alertas"] as List).isNotEmpty).toList();
        break;
      case "vencimiento":
        // Simulación de próximos a vencer
        lista = lista.where((m) => m["nombre"].toString().contains("Enalapril")).toList();
        break;
    }
    
    // Aplicar búsqueda
    if (_busqueda.isNotEmpty) {
      lista = lista.where((m) => 
        m["nombre"].toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
        m["principioActivo"].toString().toLowerCase().contains(_busqueda.toLowerCase())
      ).toList();
    }
    
    return lista;
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filtro == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6), // Reducido de 8 a 6
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _filtro = value),
        backgroundColor: Colors.white,
        selectedColor: HistoriaClinicaConstants.primaryColor.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Agregado padding más compacto
        labelStyle: TextStyle(
          color: isSelected ? HistoriaClinicaConstants.primaryColor : HistoriaClinicaConstants.mediumGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12, // Reducido tamaño de fuente
        ),
      ),
    );
  }

  void _showMedicamentoDetail(Map<String, dynamic> medicamento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MedicamentoDetailBottomSheet(medicamento: medicamento),
    );
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Agregar medicamento"),
        content: const Text(
          "Para agregar un nuevo medicamento a tu lista, consulta con tu médico tratante.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }
}

class EnhancedMedicamentoTile extends StatelessWidget {
  final Map<String, dynamic> medicamento;
  final VoidCallback onTap;

  const EnhancedMedicamentoTile({
    Key? key,
    required this.medicamento,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alertas = medicamento["alertas"] as List;
    final hasAlertas = alertas.isNotEmpty;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10), // Reducido de 12 a 10
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14), // Reducido de 16 a 14
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6), // Reducido de 8 a 6
                    decoration: BoxDecoration(
                      color: HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medication,
                      color: HistoriaClinicaConstants.primaryColor,
                      size: 18, // Reducido de 20 a 18
                    ),
                  ),
                  const SizedBox(width: 10), // Reducido de 12 a 10
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicamento["nombre"] ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // Reducido de 16 a 14
                            color: HistoriaClinicaConstants.darkBlue,
                          ),
                        ),
                        Text(
                          medicamento["indicacion"] ?? "",
                          style: const TextStyle(
                            color: HistoriaClinicaConstants.mediumGray,
                            fontSize: 12, // Reducido de 14 a 12
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasAlertas)
                    Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: 18, // Reducido de 20 a 18
                    ),
                ],
              ),
              
              const SizedBox(height: 10), // Reducido de 12 a 10
              
              // Información adicional
              Row(
                children: [
                  _buildInfoChip(
                    Icons.category,
                    medicamento["categoria"] ?? "",
                    Colors.blue,
                  ),
                  const SizedBox(width: 6), // Reducido de 8 a 6
                  _buildInfoChip(
                    Icons.person,
                    medicamento["medico"] ?? "",
                    Colors.green,
                  ),
                ],
              ),
              
              const SizedBox(height: 6), // Reducido de 8 a 6
              
              // Pedidos y órdenes
              Row(
                children: [
                  Icon(Icons.shopping_cart, size: 14, color: Colors.orange[800]), // Reducido de 16 a 14
                  const SizedBox(width: 3), // Reducido de 4 a 3
                  Text(
                    "${medicamento["pedidos"]} pedidos",
                    style: TextStyle(fontSize: 11, color: Colors.orange[800]), // Reducido de 12 a 11
                  ),
                  const SizedBox(width: 12), // Reducido de 16 a 12
                  Icon(Icons.receipt_long, size: 14, color: Colors.teal[700]), // Reducido de 16 a 14
                  const SizedBox(width: 3), // Reducido de 4 a 3
                  Text(
                    "${medicamento["ordenes"]} órdenes",
                    style: TextStyle(fontSize: 11, color: Colors.teal[700]), // Reducido de 12 a 11
                  ),
                ],
              ),
              
              if (hasAlertas) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          alertas.first,
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reducido padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color), // Reducido de 12 a 10
          const SizedBox(width: 3), // Reducido de 4 a 3
          Text(
            text,
            style: TextStyle(
              fontSize: 10, // Reducido de 11 a 10
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MedicamentoDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> medicamento;

  const MedicamentoDetailBottomSheet({
    Key? key,
    required this.medicamento,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medication,
                        color: HistoriaClinicaConstants.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicamento["nombre"] ?? "",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: HistoriaClinicaConstants.darkBlue,
                            ),
                          ),
                          Text(
                            medicamento["principioActivo"] ?? "",
                            style: const TextStyle(
                              color: HistoriaClinicaConstants.mediumGray,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Secciones de información
                _buildInfoSection("Información general", [
                  _buildDetailRow("Indicación", medicamento["indicacion"]),
                  _buildDetailRow("Vía de administración", medicamento["viaAdministracion"]),
                  _buildDetailRow("Categoría", medicamento["categoria"]),
                  _buildDetailRow("Médico prescriptor", medicamento["medico"]),
                ]),
                
                const SizedBox(height: 20),
                
                _buildInfoSection("Fechas importantes", [
                  _buildDetailRow("Fecha de inicio", medicamento["fechaInicio"]),
                  _buildDetailRow("Fecha de vencimiento", medicamento["fechaVencimiento"]),
                ]),
                
                const SizedBox(height: 20),
                
                _buildInfoSection("Gestión", [
                  _buildDetailRow("Pedidos realizados", "${medicamento["pedidos"]}"),
                  _buildDetailRow("Órdenes generadas", "${medicamento["ordenes"]}"),
                ]),
                
                if ((medicamento["alertas"] as List).isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildAlertsSection(),
                ],
                
                const SizedBox(height: 24),
                
                // Acciones
                _buildActionsSection(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HistoriaClinicaConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: HistoriaClinicaConstants.mediumGray,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(
                color: HistoriaClinicaConstants.darkBlue,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    final alertas = medicamento["alertas"] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Alertas importantes",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 12),
        ...alertas.map((alerta) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alerta.toString(),
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            // ✅ CORREGIDO: Función de solicitar receta implementada
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Solicitar receta"),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("¿Deseas solicitar una nueva receta para este medicamento?"),
                      SizedBox(height: 16),
                      Text(
                        "El médico recibirá tu solicitud y te contactará para coordinar la nueva prescripción.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Solicitud de receta enviada correctamente"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text("Solicitar"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.receipt),
            label: const Text("Solicitar receta"),
            style: ElevatedButton.styleFrom(
              backgroundColor: HistoriaClinicaConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            // ✅ CORREGIDO: Función de programar recordatorio implementada
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Programar recordatorio"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Configurar recordatorio para este medicamento"),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Frecuencia",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: "diario", child: Text("Diario")),
                          DropdownMenuItem(value: "12h", child: Text("Cada 12 horas")),
                          DropdownMenuItem(value: "8h", child: Text("Cada 8 horas")),
                          DropdownMenuItem(value: "semanal", child: Text("Semanal")),
                        ],
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Recordatorio programado correctamente"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text("Programar"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.alarm),
            label: const Text("Programar recordatorio"),
            style: OutlinedButton.styleFrom(
              foregroundColor: HistoriaClinicaConstants.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text("Cerrar"),
            style: TextButton.styleFrom(
              foregroundColor: HistoriaClinicaConstants.mediumGray,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class SignosVitalesScreen extends StatefulWidget {
  const SignosVitalesScreen({Key? key}) : super(key: key);

  @override
  State<SignosVitalesScreen> createState() => _SignosVitalesScreenState();
}

class _SignosVitalesScreenState extends State<SignosVitalesScreen> {
  String _periodoSeleccionado = "3m";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoriaClinicaConstants.backgroundColor,
      appBar: AppBar(
        leading: BackButton(color: HistoriaClinicaConstants.primaryColor),
        title: const Text(
          'Signos Vitales',
          style: TextStyle(
            color: HistoriaClinicaConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: HistoriaClinicaConstants.primaryColor,
            onPressed: () => _showAddVitalSignDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ CORREGIDO: Banner limpio en lugar del HORRIBLE gradiente
            CleanInfoCard(
              icon: Icons.favorite_outlined,
              title: "Monitoreo de signos vitales",
              description: "Seguimiento completo de tus parámetros de salud, tendencias y alertas médicas importantes.",
            ),

            // Selector de período
            _buildPeriodSelector(),
            
            const SizedBox(height: 20),

            // Resumen actual
            _buildCurrentSummary(),
            
            const SizedBox(height: 20),

            // Gráficos de tendencias (simulados)
            _buildTrendsSection(),
            
            const SizedBox(height: 20),

            // Historial detallado
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Período de visualización",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HistoriaClinicaConstants.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip("1 mes", "1m"),
                  _buildPeriodChip("3 meses", "3m"),
                  _buildPeriodChip("6 meses", "6m"),
                  _buildPeriodChip("1 año", "1a"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _periodoSeleccionado == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _periodoSeleccionado = value),
        backgroundColor: Colors.grey.shade100,
        selectedColor: HistoriaClinicaConstants.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? HistoriaClinicaConstants.primaryColor : HistoriaClinicaConstants.mediumGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCurrentSummary() {
    final ultimoRegistro = HistoriaClinicaConstants.signosVitalesMock.first;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 12,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Último registro",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: HistoriaClinicaConstants.darkBlue,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  ultimoRegistro["fecha"],
                  style: const TextStyle(
                    color: HistoriaClinicaConstants.mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Grid de signos vitales
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildVitalSignCard(
                  "Presión arterial",
                  "${ultimoRegistro["presionSistolica"]}/${ultimoRegistro["presionDiastolica"]}",
                  "mmHg",
                  Icons.favorite,
                  Colors.red,
                ),
                _buildVitalSignCard(
                  "Frecuencia cardíaca",
                  "${ultimoRegistro["frecuenciaCardiaca"]}",
                  "bpm",
                  Icons.monitor_heart,
                  Colors.orange,
                ),
                _buildVitalSignCard(
                  "Temperatura",
                  "${ultimoRegistro["temperatura"]}",
                  "°C",
                  Icons.thermostat,
                  Colors.blue,
                ),
                _buildVitalSignCard(
                  "Peso",
                  "${ultimoRegistro["peso"]}",
                  "kg",
                  Icons.scale,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: HistoriaClinicaConstants.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tendencias",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HistoriaClinicaConstants.darkBlue,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Simulación de gráfico de presión arterial
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Gráfico de tendencias de presión arterial",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Funcionalidad en desarrollo",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Historial detallado",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: HistoriaClinicaConstants.darkBlue,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...HistoriaClinicaConstants.signosVitalesMock.map((registro) => 
              _buildHistoryItem(registro)
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> registro) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: HistoriaClinicaConstants.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                registro["fecha"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HistoriaClinicaConstants.primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildHistoryValueChip("PA", "${registro["presionSistolica"]}/${registro["presionDiastolica"]}", Colors.red),
              _buildHistoryValueChip("FC", "${registro["frecuenciaCardiaca"]}", Colors.orange),
              _buildHistoryValueChip("T°", "${registro["temperatura"]}", Colors.blue),
              _buildHistoryValueChip("Peso", "${registro["peso"]}", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryValueChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showAddVitalSignDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Registrar signos vitales"),
        content: const Text(
          "Para registrar nuevos signos vitales, utiliza los dispositivos de medición disponibles en la consulta médica.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }
}

// ============== RESUMEN CLÍNICO MEJORADO ==============
class ResumenDetailScreen extends StatelessWidget {
  final HistoriaClinicaData data;
  
  const ResumenDetailScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoriaClinicaConstants.backgroundColor,
      appBar: AppBar(
        leading: BackButton(color: HistoriaClinicaConstants.primaryColor),
        title: const Text(
          'Resumen Clínico',
          style: TextStyle(
            color: HistoriaClinicaConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            color: HistoriaClinicaConstants.primaryColor,
            onPressed: () => _shareResumen(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de identificación del paciente
            IdentificationBanner(data: data),
            
            const SizedBox(height: 20),

            // Información principal
            _buildMainInfoSection(),
            
            const SizedBox(height: 20),

            // Diagnósticos activos
            _buildDiagnosticosSection(),
            
            const SizedBox(height: 20),

            // Medicación actual
            _buildMedicacionSection(),
            
            const SizedBox(height: 20),

            // Próximas citas y seguimiento
            _buildSeguimientoSection(),
            
            const SizedBox(height: 20),

            // Alertas y recomendaciones
            _buildAlertasSection(context),
            
            const SizedBox(height: 20),

            // Acciones rápidas
            _buildAccionesRapidas(context),
            
            const SizedBox(height: 20),

            // Información de actualización
            _buildUpdateInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: HistoriaClinicaConstants.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Información del paciente",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoriaClinicaConstants.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Datos principales en grid
            _buildPatientDataGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientDataGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDataItem("Centro médico", data.centro, Icons.local_hospital)),
            const SizedBox(width: 16),
            Expanded(child: _buildDataItem("Edad", "${data.edad} años", Icons.cake)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildDataItem("DNI", data.dni, Icons.badge)),
            const SizedBox(width: 16),
            Expanded(child: _buildDataItem("Última actualización", data.fechaActualizacion, Icons.update)),
          ],
        ),
      ],
    );
  }

  Widget _buildDataItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: HistoriaClinicaConstants.primaryColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: HistoriaClinicaConstants.mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: HistoriaClinicaConstants.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticosSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Diagnósticos activos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoriaClinicaConstants.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lista de diagnósticos
            ...HistoriaClinicaConstants.diagnosticosMock.map((diag) => 
              _buildDiagnosticoItem(diag)
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticoItem(Map<String, dynamic> diagnostico) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  diagnostico["codigo"],
                  style: const TextStyle(
                    color: HistoriaClinicaConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              _buildEstadoChip(diagnostico["estado"]),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            diagnostico["nombre"],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: HistoriaClinicaConstants.darkBlue,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            "Dr. ${diagnostico["medico"]} • ${diagnostico["fechaDiagnostico"]}",
            style: const TextStyle(
              color: HistoriaClinicaConstants.mediumGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'activo':
        color = Colors.orange;
        break;
      case 'controlado':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildMedicacionSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Medicación actual",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoriaClinicaConstants.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lista de medicamentos activos
            ...HistoriaClinicaConstants.medicamentosMock
                .where((med) => med["activo"] == true)
                .map((med) => _buildMedicamentoResumenItem(med))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicamentoResumenItem(Map<String, dynamic> medicamento) {
    final alertas = medicamento["alertas"] as List;
    final hasAlertas = alertas.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: hasAlertas ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicamento["nombre"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: HistoriaClinicaConstants.darkBlue,
                  ),
                ),
                Text(
                  medicamento["indicacion"],
                  style: const TextStyle(
                    color: HistoriaClinicaConstants.mediumGray,
                    fontSize: 12,
                  ),
                ),
                if (hasAlertas)
                  Text(
                    "⚠️ ${alertas.first}",
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeguimientoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HistoriaClinicaConstants.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.event_available_rounded,
                    color: HistoriaClinicaConstants.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Seguimiento médico",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoriaClinicaConstants.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Próxima cita
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HistoriaClinicaConstants.accentColor.withOpacity(0.1),
                    HistoriaClinicaConstants.secondaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: HistoriaClinicaConstants.accentColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: HistoriaClinicaConstants.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Próxima cita médica",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: HistoriaClinicaConstants.darkBlue,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          data.proximaCita,
                          style: TextStyle(
                            color: HistoriaClinicaConstants.accentColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Controles recomendados
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.checklist, color: Colors.blue, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        "Controles recomendados",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: HistoriaClinicaConstants.darkBlue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "• Control de presión arterial mensual\n• Análisis de laboratorio trimestral\n• Consulta cardiológica semestral",
                    style: TextStyle(
                      color: HistoriaClinicaConstants.mediumGray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertasSection(BuildContext context) {
    // Generar alertas dinámicas basadas en los datos
    final alertas = _generarAlertas();
    
    if (alertas.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Alertas y recomendaciones",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HistoriaClinicaConstants.darkBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ...alertas.map((alerta) => _buildAlertaItem(context, alerta)).toList(),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _generarAlertas() {
    List<Map<String, String>> alertas = [];
    
    // Verificar medicamentos con alertas
    for (var medicamento in HistoriaClinicaConstants.medicamentosMock) {
      if ((medicamento["alertas"] as List).isNotEmpty) {
        alertas.add({
          "tipo": "medicamento",
          "titulo": "Control de medicación",
          "descripcion": "${medicamento["alertas"].first} - ${medicamento["nombre"]}",
          "prioridad": "media",
        });
      }
    }
    
    // Verificar diagnósticos activos
    for (var diagnostico in HistoriaClinicaConstants.diagnosticosMock) {
      if (diagnostico["estado"] == "Activo") {
        alertas.add({
          "tipo": "seguimiento",
          "titulo": "Seguimiento de ${diagnostico["nombre"]}",
          "descripcion": "Mantener controles regulares y adherencia al tratamiento",
          "prioridad": "alta",
        });
      }
    }
    
    // Alerta de próxima cita
    if (data.proximaCita.contains("Sin datos")) {
      alertas.add({
        "tipo": "cita",
        "titulo": "Programar próxima consulta",
        "descripcion": "No tienes citas médicas programadas",
        "prioridad": "alta",
      });
    }
    
    return alertas.take(3).toList(); // Limitar a 3 alertas principales
  }

  Widget _buildAlertaItem(BuildContext context, Map<String, String> alerta) {
    Color color;
    IconData icon;
    
    switch (alerta["prioridad"]) {
      case "alta":
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case "media":
        color = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta["titulo"]! as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.lerp(color, Colors.black, 0.3)!,
                    fontSize: 14,
                  ),
                ),
                Text(
                  alerta["descripcion"]! as String,
                  style: TextStyle(
                    color: Color.lerp(color, Colors.black, 0.2)!,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesRapidas(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Acciones rápidas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HistoriaClinicaConstants.darkBlue,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Exportar PDF",
                    Icons.picture_as_pdf,
                    Colors.red,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Generando PDF de historia clínica...")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    "Compartir",
                    Icons.share,
                    Colors.green,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Preparando para compartir...")),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Solicitar estudios",
                    Icons.science,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EstudiosScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    "Emergencia",
                    Icons.emergency,
                    Colors.red,
                    () {
                      _showEmergencyDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildUpdateInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            "Última actualización: ${data.fechaActualizacion}",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.verified,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            "Verificado",
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _shareResumen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Compartir resumen clínico",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Enviar por email"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preparando email...")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Generar PDF"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Generando PDF...")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text("Mostrar código QR"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Generando código QR...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text(
              "Información de emergencia",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Datos médicos importantes:"),
            SizedBox(height: 8),
            Text("• Grupo sanguíneo: A+"),
            Text("• Alergias: Ninguna conocida"),
            Text("• Medicación actual: Losartán 50mg"),
            Text("• Contacto emergencia: Anto Lettieri"),
            Text("• Teléfono: +54 9 11 8765 4321"),
            SizedBox(height: 12),
            Text("En caso de emergencia, mostrar esta información al personal médico."),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.call),
            label: const Text("Llamar emergencia"),
          ),
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}

// ========== BLOQUE RESUMEN REUTILIZABLE ==========
class _ResumenBlock extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _ResumenBlock({
    required this.title,
    required this.content,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HistoriaClinicaConstants.cardColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
          child: Icon(icon, color: HistoriaClinicaConstants.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: HistoriaClinicaConstants.primaryColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15, color: HistoriaClinicaConstants.mediumGray),
          ),
        ),
      ),
    );
  }
}

// ======================= HOME HISTORIA CLÍNICA (PRINCIPAL) ========================
class HistoriaClinicaScreen extends StatelessWidget {
  const HistoriaClinicaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: HistoriaClinicaConstants.backgroundColor,
        appBar: _buildAppBar(context),
        body: const Center(child: Text("No logueado", style: TextStyle(color: Colors.black54))),
      );
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const TechLoadingScreen(); // CAP 1 FIX: Pantalla de carga tech mejorada
        }

        if (snapshot.hasError) {
          // Si es error de permisos, usar datos mock para desarrollo
          if (snapshot.error.toString().contains('permission-denied')) {
            final mockData = {
              'dni': '12.345.678',
              'centro': 'Instituto Ángel H. Roffo',
              'edad': '35',
              'proxima_cita': '15 de agosto, 2025 - Dr. Pérez',
              'fecha_actualizacion': '25/07/2025',
              'resumen': 'Paciente con hipertensión arterial controlada. Evolución favorable con medicación actual.',
              'diagnostico': 'Hipertensión arterial',
              'medicamentos': 'Losartán 50mg + Enalapril 10mg',
            };
            
            final data = HistoriaClinicaData.fromMap(mockData);
            return _buildHistoriaClinicaContent(context, data);
          }
          
          return Scaffold(
            backgroundColor: HistoriaClinicaConstants.backgroundColor,
            appBar: _buildAppBar(context),
            body: ErrorCard(
              message: "Error al cargar los datos: ${snapshot.error}",
              onRetry: () {
                // Forzar rebuild del widget
                (context as Element).markNeedsBuild();
              },
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Usar datos mock para desarrollo si no hay datos en Firestore
          final mockData = {
            'dni': '12.345.678',
            'centro': 'Instituto Ángel H. Roffo',
            'edad': '35',
            'proxima_cita': '15 de agosto, 2025 - Dr. Pérez',
            'fecha_actualizacion': '25/07/2025',
            'resumen': 'Paciente con hipertensión arterial controlada. Evolución favorable con medicación actual.',
            'diagnostico': 'Hipertensión arterial',
            'medicamentos': 'Losartán 50mg + Enalapril 10mg',
          };
          
          final data = HistoriaClinicaData.fromMap(mockData);
          return _buildHistoriaClinicaContent(context, data);
        }

        final data = HistoriaClinicaData.fromMap(snapshot.data!.data()!);
        return _buildHistoriaClinicaContent(context, data);
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      // ✅ FIX: Título simplificado para evitar errores de layout
      title: const Text(
        'Historia clínica',
        style: TextStyle(
          color: HistoriaClinicaConstants.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          color: HistoriaClinicaConstants.primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
            );
          },
        ),
      ],
      iconTheme: const IconThemeData(color: HistoriaClinicaConstants.primaryColor),
    );
  }

  Widget _buildEmptyDataScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: HistoriaClinicaConstants.backgroundColor,
      appBar: _buildAppBar(context),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: HistoriaClinicaConstants.primaryColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Completá tus datos",
                  style: TextStyle(
                    color: HistoriaClinicaConstants.darkBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Para acceder a tu historia clínica completa, necesitamos que completes tu información personal.",
                  style: TextStyle(
                    color: HistoriaClinicaConstants.mediumGray,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CompletarPerfilScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Completar perfil"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HistoriaClinicaConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildHistoriaClinicaContent(BuildContext context, HistoriaClinicaData data) {
    return Scaffold(
      backgroundColor: HistoriaClinicaConstants.backgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Simular refresh
            await Future.delayed(const Duration(seconds: 1));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Información actualizada")),
            );
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner de ilustración
                _buildIllustrationBanner(),
                
                const SizedBox(height: 16),

                // NUEVO DISEÑO LEGIBLE - Identificación del paciente
                Card(
                  elevation: 3, // Ligeramente más elevado
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MiPerfilScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.3), width: 1.5), // Borde más visible
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2376F6).withOpacity(0.08), // Sombra muy sutil
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2376F6).withOpacity(0.12), // Ligeramente más intenso
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: Color(0xFF2376F6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        "Identificación del paciente",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF193A72),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green.withOpacity(0.2)),
                                      ),
                                      child: const Text(
                                        'Verificado',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "DNI: ${data.dni} • ${data.centro} • ${data.edad} años",
                                  style: const TextStyle(
                                    color: Color(0xFF42506A),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Ícono de navegación
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF2376F6),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16), // Aumentado de 12 a 16 para más separación

                // NUEVO DISEÑO LEGIBLE - Próxima cita médica  
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SacarTurnoScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF4FE1F3).withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4FE1F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.event_available_rounded,
                              color: Color(0xFF4FE1F3),
                              size: 24,
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF193A72),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data.proximaCita,
                                  style: const TextStyle(
                                    color: Color(0xFF42506A),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Agregar ícono de navegación
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF4FE1F3),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Información de actualización
                _buildUpdateInfoBanner(data.fechaActualizacion),

                const SizedBox(height: 20),

                // Grid de secciones principales
                _buildMainSectionsGrid(context, data),

                const SizedBox(height: 20),

                // Secciones adicionales
                _buildAdditionalSections(context),

                const SizedBox(height: 20),

                // Footer con información del centro
                _buildFooterInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustrationBanner() {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        HistoriaClinicaConstants.defaultIllustracion,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                HistoriaClinicaConstants.secondaryColor.withOpacity(0.1),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.medical_services,
              size: 48,
              color: HistoriaClinicaConstants.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateInfoBanner(String fechaActualizacion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            "Actualizado el $fechaActualizacion",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.verified,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            "Verificado",
            style: TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSectionsGrid(BuildContext context, HistoriaClinicaData data) {
    return Column(
      children: [
        // Primera fila - Resumen destacado
        _CardAcceso(
          icon: Icons.dashboard_rounded,
          title: "Resumen completo",
          content: data.resumen,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ResumenDetailScreen(data: data)),
          ),
          tag: "Ver detalle",
          bgColor: HistoriaClinicaConstants.cardColor,
          iconColor: HistoriaClinicaConstants.primaryColor,
          gradient: true,
        ),

        // Segunda fila - Diagnóstico y Medicamentos
        Row(
          children: [
            Expanded(
              child: _CardAcceso(
                icon: Icons.assignment_turned_in_rounded,
                title: "Diagnósticos",
                content: "${data.diagnostico}\nÚltima actualización: 15/07/2025",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiagnosticoDetailScreen(
                      diagnostico: HistoriaClinicaConstants.diagnosticosMock.first,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CardAcceso(
                icon: Icons.medication_rounded,
                title: "Medicamentos",
                content: "2 activos • Losartán 50mg + Enalapril 10mg",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MedicamentosDetailScreen()),
                ),
              ),
            ),
          ],
        ),

        // Tercera fila - Turnos y Signos Vitales
        Row(
          children: [
            Expanded(
              child: _CardAcceso(
                icon: Icons.calendar_today_rounded,
                title: "Turnos",
                content: "15 de agosto, 2025 • 10:00 AM\nDr. Pérez - Clínica médica",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TurnosDetailScreen()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CardAcceso(
                icon: Icons.favorite_rounded,
                title: "Signos vitales",
                content: "Último registro: 142/92 mmHg\nMonitoreo de salud y tendencias",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignosVitalesScreen()),
                ),
                iconColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalSections(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Herramientas adicionales",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HistoriaClinicaConstants.darkBlue,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Exportar PDF",
                    Icons.picture_as_pdf,
                    Colors.red,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Generando PDF de historia clínica...")),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    "Compartir",
                    Icons.share,
                    Colors.green,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Preparando para compartir...")),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Solicitar estudios",
                    Icons.science,
                    Colors.blue,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EstudiosScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    "Emergencia",
                    Icons.emergency,
                    Colors.red,
                    () {
                      _showEmergencyDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text(
              "Información de emergencia",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Datos médicos importantes:"),
            SizedBox(height: 8),
            Text("• Grupo sanguíneo: A+"),
            Text("• Alergias: Ninguna conocida"),
            Text("• Medicación actual: Losartán 50mg"),
            Text("• Contacto emergencia: Anto Lettieri"),
            Text("• Teléfono: +54 9 11 8765 4321"),
            SizedBox(height: 12),
            Text("En caso de emergencia, mostrar esta información al personal médico."),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.call),
            label: const Text("Llamar emergencia"),
          ),
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: HistoriaClinicaConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Instituto Ángel H. Roffo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: HistoriaClinicaConstants.darkBlue,
                      ),
                    ),
                    Text(
                      "Centro de excelencia en medicina",
                      style: TextStyle(
                        color: HistoriaClinicaConstants.mediumGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFooterAction(Icons.phone, "Contacto", () {}),
              _buildFooterAction(Icons.location_on, "Ubicación", () {}),
              _buildFooterAction(Icons.schedule, "Horarios", () {}),
              _buildFooterAction(Icons.help, "Ayuda", () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(
              icon,
              color: HistoriaClinicaConstants.primaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: HistoriaClinicaConstants.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== CARD ACCESO MEJORADA ==========
class _CardAcceso extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final VoidCallback? onTap;
  final Color? bgColor;
  final Color? iconColor;
  final String? tag;
  final bool gradient;

  const _CardAcceso({
    required this.icon,
    required this.title,
    required this.content,
    this.onTap,
    this.bgColor,
    this.iconColor,
    this.tag,
    this.gradient = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: gradient ? null : (bgColor ?? Colors.white),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10), // CAP 4 FIX: Reducido de 12 a 10
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: gradient
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HistoriaClinicaConstants.primaryColor.withOpacity(0.1),
                    HistoriaClinicaConstants.secondaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14), // CAP 4 FIX: Reducido de 18 a 14
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // CAP 4 FIX: Reducido de 12 a 10
                  decoration: BoxDecoration(
                    color: (iconColor ?? HistoriaClinicaConstants.primaryColor).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? HistoriaClinicaConstants.primaryColor,
                    size: 24, // CAP 4 FIX: Reducido de 28 a 24
                  ),
                ),
                const SizedBox(width: 12), // CAP 4 FIX: Reducido de 16 a 12
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // CAP 4 FIX: Reducido de 15 a 14
                          color: HistoriaClinicaConstants.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4), // CAP 4 FIX: Reducido de 6 a 4
                      Text(
                        content,
                        style: const TextStyle(
                          color: HistoriaClinicaConstants.mediumGray,
                          fontSize: 12, // CAP 4 FIX: Reducido de 13 a 12
                          height: 1.3,
                        ),
                        maxLines: 2, // CAP 4 FIX: Reducido de 3 a 2
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tag != null) ...[
                        const SizedBox(height: 6), // CAP 4 FIX: Reducido de 8 a 6
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // CAP 4 FIX: Reducido
                          decoration: BoxDecoration(
                            color: (iconColor ?? HistoriaClinicaConstants.primaryColor).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag!,
                            style: TextStyle(
                              color: iconColor ?? HistoriaClinicaConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11, // CAP 4 FIX: Reducido de 12 a 11
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6), // CAP 4 FIX: Reducido de 8 a 6
                Icon(
                  Icons.chevron_right_rounded,
                  color: HistoriaClinicaConstants.lightGray,
                  size: 24, // CAP 4 FIX: Reducido de 28 a 24
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}