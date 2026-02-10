import 'package:flutter/material.dart';
import '../../repositories/history_repository.dart';
import 'dart:math' as math;

// =============== LOADING CARD ===================
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
            valueColor: AlwaysStoppedAnimation<Color>(HistoryRepository.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: HistoryRepository.mediumGray,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =============== PANTALLA DE CARGA TECH MEJORADA ===================
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
    return Material(
      color: const Color(0xFFF7FCFF),
      child: Container(
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
