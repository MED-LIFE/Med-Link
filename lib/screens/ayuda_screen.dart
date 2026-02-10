import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F1),
      appBar: AppBar(
        title: const Text(
          'Ayuda y Soporte',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF083866)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2376F6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preguntas Frecuentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF083866),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildFaqItem(
                    '¿Cómo solicito un turno?',
                    'Desde la pantalla principal, presiona el botón "Sacar turno". Podrás seleccionar la especialidad, el profesional y el horario que más te convenga.',
                  ),
                  _buildFaqItem(
                    '¿Dónde veo mi historia clínica?',
                    'Puedes acceder a tu historial médico completo presionando el botón "Historia clínica" en el menú principal.',
                  ),
                  _buildFaqItem(
                    '¿Cómo visualizo mis estudios?',
                    'En la sección "Ver estudios" de la pantalla de inicio, encontrarás tus resultados de laboratorio, imágenes y otros informes médicos.',
                  ),
                  _buildFaqItem(
                    '¿Cómo puedo editar mis datos personales?',
                    'Dirígete a "Editar perfil" desde el menú principal para actualizar tu información de contacto y preferencias.',
                  ),
                  _buildFaqItem(
                    'No puedo ver mis turnos próximos',
                    'Asegúrate de tener una conexión estable a internet. Tus próximos turnos aparecen automáticamente en la tarjeta superior de la pantalla de inicio.',
                  ),
                  const SizedBox(height: 30),
                  _buildContactCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2376F6), Color(0xFF73BFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.help_rounded, size: 60, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            '¿Cómo podemos ayudarte?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estamos aquí para asistirte en todo momento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.04),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF083866),
          ),
        ),
        iconColor: const Color(0xFF2376F6),
        collapsedIconColor: Colors.grey[400],
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Text(
            answer,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Text(
            '¿Aún tienes dudas?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF083866),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildContactButton(Icons.mail_outline_rounded, 'Email', Colors.orange),
              const SizedBox(width: 12),
              _buildContactButton(Icons.forum_rounded, 'WhatsApp', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label, Color color) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
        },
        icon: Icon(icon, color: color, size: 20),
        label: Text(label, style: const TextStyle(color: Color(0xFF083866))),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: color.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
