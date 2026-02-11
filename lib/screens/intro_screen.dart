import 'package:flutter/material.dart';


class IntroScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const IntroScreen({super.key, required this.onFinish});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      "title": "EL PRIMER SISTEMA DE GESTIÓN DE SALUD PÚBLICA, GRATUITO DE LATAM",
      "subtitle": "Una revolución en el acceso a la salud.",
      "image": "assets/images/intro_1.png", // Placeholder
      "icon": "public", // Material Icon name fallback
    },
    {
      "title": "Historia Clínica Digital Unificada",
      "subtitle": "Tu información médica, segura y siempre disponible.",
      "image": "assets/images/intro_2.png",
      "icon": "assignment_ind",
    },
    {
      "title": "Gestión Simple de Turnos y Recetas",
      "subtitle": "Sacá turnos y gestioná tus medicamentos en segundos.",
      "image": "assets/images/intro_3.png",
      "icon": "calendar_today",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return _buildSlide(_slides[index]);
            },
          ),
          
          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFF2376F6)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        widget.onFinish();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF083866),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1 ? "Comenzar" : "Siguiente",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildSlide(Map<String, String> slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image / Icon Placeholder
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              // Using Icon as fallback since images aren't generated yet
              child: Icon(
                _getIconData(slide['icon']!),
                size: 100,
                color: const Color(0xFF2376F6),
              ),
            ),
          ),
          const SizedBox(height: 48),
          
          // Title
          Text(
            slide['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF083866),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            slide['subtitle']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'public': return Icons.public;
      case 'assignment_ind': return Icons.assignment_ind_rounded;
      case 'calendar_today': return Icons.calendar_today_rounded;
      default: return Icons.image;
    }
  }
}
