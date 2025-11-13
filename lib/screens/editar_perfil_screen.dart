import 'package:flutter/material.dart';

class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  // Estados de la aplicación
  bool modoEdicion = false;
  bool dniValidado = false;
  bool selfieValidada = false;
  
  // Datos mock iniciales
  Map<String, String> datosPersonales = {
    "nombre": "Julián Lettieri",
    "dni": "12.345.678",
    "fechaNacimiento": "03/08/1988",
    "sexo": "Masculino",
    "telefono": "+54 9 11 1234 5678",
    "email": "julian@email.com",
    "direccion": "Av. Córdoba 5550, CABA",
    "grupoSanguineo": "A+",
    "contactoEmergencia": "Anto Lettieri - +54 9 11 8765 4321",
  };

  Map<String, String> datosCobertura = {
    "tipo": "Prepaga",
    "nombre": "Instituto Ángel H. Roffo",
    "numeroAfiliado": "987654321",
    "vencimiento": "31/12/2025",
  };

  Map<String, bool> preferencias = {
    "notificaciones": true,
    "email": true,
    "sms": false,
  };

  // Controladores para formulario editable
  late final TextEditingController nombreController;
  late final TextEditingController dniController;
  late final TextEditingController fechaNacController;
  late final TextEditingController sexoController;
  late final TextEditingController telefonoController;
  late final TextEditingController emailController;
  late final TextEditingController direccionController;
  late final TextEditingController grupoSanguineoController;
  late final TextEditingController contactoEmergenciaController;

  late final TextEditingController tipoCoberturaController;
  late final TextEditingController nombreCoberturaController;
  late final TextEditingController nroAfiliadoController;
  late final TextEditingController vencimientoController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(text: datosPersonales["nombre"]);
    dniController = TextEditingController(text: datosPersonales["dni"]);
    fechaNacController = TextEditingController(text: datosPersonales["fechaNacimiento"]);
    sexoController = TextEditingController(text: datosPersonales["sexo"]);
    telefonoController = TextEditingController(text: datosPersonales["telefono"]);
    emailController = TextEditingController(text: datosPersonales["email"]);
    direccionController = TextEditingController(text: datosPersonales["direccion"]);
    grupoSanguineoController = TextEditingController(text: datosPersonales["grupoSanguineo"]);
    contactoEmergenciaController = TextEditingController(text: datosPersonales["contactoEmergencia"]);

    tipoCoberturaController = TextEditingController(text: datosCobertura["tipo"]);
    nombreCoberturaController = TextEditingController(text: datosCobertura["nombre"]);
    nroAfiliadoController = TextEditingController(text: datosCobertura["numeroAfiliado"]);
    vencimientoController = TextEditingController(text: datosCobertura["vencimiento"]);
  }

  @override
  void dispose() {
    nombreController.dispose();
    dniController.dispose();
    fechaNacController.dispose();
    sexoController.dispose();
    telefonoController.dispose();
    emailController.dispose();
    direccionController.dispose();
    grupoSanguineoController.dispose();
    contactoEmergenciaController.dispose();

    tipoCoberturaController.dispose();
    nombreCoberturaController.dispose();
    nroAfiliadoController.dispose();
    vencimientoController.dispose();

    super.dispose();
  }

  void _guardarCambios() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        datosPersonales["nombre"] = nombreController.text.trim();
        datosPersonales["dni"] = dniController.text.trim();
        datosPersonales["fechaNacimiento"] = fechaNacController.text.trim();
        datosPersonales["sexo"] = sexoController.text.trim();
        datosPersonales["telefono"] = telefonoController.text.trim();
        datosPersonales["email"] = emailController.text.trim();
        datosPersonales["direccion"] = direccionController.text.trim();
        datosPersonales["grupoSanguineo"] = grupoSanguineoController.text.trim();
        datosPersonales["contactoEmergencia"] = contactoEmergenciaController.text.trim();

        datosCobertura["tipo"] = tipoCoberturaController.text.trim();
        datosCobertura["nombre"] = nombreCoberturaController.text.trim();
        datosCobertura["numeroAfiliado"] = nroAfiliadoController.text.trim();
        datosCobertura["vencimiento"] = vencimientoController.text.trim();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Perfil actualizado correctamente"),
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
          'Mi Perfil',
          style: TextStyle(
            color: Color(0xFF2376F6),
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              modoEdicion ? Icons.check_rounded : Icons.edit_rounded,
              color: const Color(0xFF2376F6),
              size: 24,
            ),
            onPressed: () {
              setState(() {
                modoEdicion = !modoEdicion;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(modoEdicion ? "Modo edición activado" : "Modo edición desactivado"),
                  backgroundColor: const Color(0xFF2376F6),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20,
                vertical: 16,
              ),
              children: [
                // Header del perfil
                _buildPerfilHeader(),
                
                // Validación de identidad (solo en modo edición)
                if (modoEdicion) ...[
                  const SizedBox(height: 24),
                  _buildValidacionIdentidad(),
                ],
                
                const SizedBox(height: 24),
                
                // Datos personales
                _buildDatosPersonales(),
                
                const SizedBox(height: 20),
                
                // Cobertura médica
                _buildCoberturaMedica(),
                
                const SizedBox(height: 20),
                
                // Preferencias
                _buildPreferencias(),
                
                const SizedBox(height: 24),
                
                // Acciones rápidas
                _buildAccionesRapidas(),
                
                const SizedBox(height: 24),
                
                // Botón guardar
                if (modoEdicion) _buildBotonGuardar(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          // Avatar con gradiente
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2376F6).withOpacity(0.2),
                  const Color(0xFF73BFFF).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2376F6).withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: const Color(0xFF2376F6).withOpacity(0.15),
              child: const Icon(
                Icons.person_rounded,
                size: 64,
                color: Color(0xFF2376F6),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Nombre con mejor tipografía
          Text(
            datosPersonales["nombre"] ?? "Usuario",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          
          // Email con estilo
          Text(
            datosPersonales["email"] ?? "email@ejemplo.com",
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          
          // Pills de información con mejor diseño
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoPill(
                Icons.cake_rounded,
                "37 años",
                const Color(0xFF2376F6),
              ),
              _buildInfoPill(
                Icons.bloodtype_rounded,
                datosPersonales["grupoSanguineo"] ?? "A+",
                const Color(0xFFDC2626),
              ),
              _buildInfoPill(
                Icons.local_hospital_rounded,
                "Roffo",
                const Color(0xFF059669),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Progreso mejorado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Perfil completo",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    Text(
                      "100%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatosPersonales() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Datos personales", Icons.person_outline_rounded),
          const SizedBox(height: 20),
          _buildTextField("Nombre completo", nombreController, Icons.person_rounded),
          _buildTextField("DNI", dniController, Icons.badge_rounded),
          _buildTextField("Fecha de nacimiento", fechaNacController, Icons.cake_rounded),
          _buildTextField("Sexo", sexoController, Icons.wc_rounded),
          _buildTextField("Teléfono", telefonoController, Icons.phone_rounded),
          _buildTextField("Email", emailController, Icons.email_rounded),
          _buildTextField("Dirección", direccionController, Icons.home_rounded),
          _buildTextField("Grupo sanguíneo", grupoSanguineoController, Icons.bloodtype_rounded),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildTextField("Contacto de emergencia", contactoEmergenciaController, Icons.emergency_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildCoberturaMedica() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Cobertura médica", Icons.local_hospital_rounded),
          const SizedBox(height: 20),
          _buildTextField("Tipo de cobertura", tipoCoberturaController, Icons.card_membership_rounded),
          _buildTextField("Nombre cobertura", nombreCoberturaController, Icons.business_rounded),
          _buildTextField("Número afiliado", nroAfiliadoController, Icons.confirmation_number_rounded),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildTextField("Vencimiento", vencimientoController, Icons.event_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencias() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Preferencias", Icons.settings_rounded),
          const SizedBox(height: 20),
          _buildSwitchTile(
            "Notificaciones activas",
            "Recibir avisos de turnos y resultados",
            preferencias["notificaciones"] ?? true,
            (value) {
              if (modoEdicion) {
                setState(() {
                  preferencias["notificaciones"] = value;
                });
              }
            },
          ),
          _buildSwitchTile(
            "Notificaciones por email",
            "Resúmenes semanales y recordatorios",
            preferencias["email"] ?? true,
            (value) {
              if (modoEdicion) {
                setState(() {
                  preferencias["email"] = value;
                });
              }
            },
          ),
          _buildSwitchTile(
            "Notificaciones por SMS",
            "Solo para emergencias y citas urgentes",
            preferencias["sms"] ?? false,
            (value) {
              if (modoEdicion) {
                setState(() {
                  preferencias["sms"] = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccionesRapidas() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Acciones rápidas", Icons.flash_on_rounded),
          const SizedBox(height: 20),
          
          // Botón ver documentos
          _buildActionButton(
            "Ver documentos médicos",
            "Historial completo de estudios y análisis",
            Icons.insert_drive_file_rounded,
            const Color(0xFF2376F6),
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Funcionalidad en desarrollo")),
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Botón compartir QR
          _buildActionButton(
            "Código QR médico",
            "Compartir datos con profesionales",
            Icons.qr_code_rounded,
            const Color(0xFF059669),
            () {
              _mostrarQRDialog();
            },
          ),
          const SizedBox(height: 16),
          
          // Botón compartir perfil
          _buildActionButton(
            "Compartir perfil",
            "Enviar información por email o SMS",
            Icons.share_rounded,
            const Color(0xFF7C3AED),
            () {
              _mostrarOpcionesCompartir();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2376F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 22,
            color: const Color(0xFF2376F6),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: modoEdicion,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F2937),
          letterSpacing: -0.1,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: modoEdicion ? const Color(0xFF2376F6) : const Color(0xFF9CA3AF),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2376F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF2376F6),
            ),
          ),
          filled: true,
          fillColor: modoEdicion ? const Color(0xFFF8FCFF) : const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2376F6), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FCFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: modoEdicion ? onChanged : null,
            activeColor: const Color(0xFF2376F6),
            activeTrackColor: const Color(0xFF2376F6).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFF9CA3AF),
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: color.withOpacity(0.7),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidacionIdentidad() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2376F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF2376F6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                "Validación de identidad",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Botón Escanear DNI - CORREGIDO
          _buildValidacionButton(
            "Escanear DNI",
            Icons.credit_card_rounded,
            dniValidado,
            () {
              setState(() {
                dniValidado = !dniValidado;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(dniValidado ? "DNI validado correctamente" : "Validación de DNI pendiente"),
                  backgroundColor: dniValidado ? const Color(0xFF10B981) : const Color(0xFFFF8F00),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Botón Sacar Selfie - CORREGIDO
          _buildValidacionButton(
            "Sacar Selfie",
            Icons.camera_alt_rounded,
            selfieValidada,
            () {
              setState(() {
                selfieValidada = !selfieValidada;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(selfieValidada ? "Selfie validada correctamente" : "Validación de selfie pendiente"),
                  backgroundColor: selfieValidada ? const Color(0xFF10B981) : const Color(0xFFFF8F00),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          
          if (dniValidado && selfieValidada) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Identidad completamente validada",
                      style: TextStyle(
                        color: Color(0xFF065F46),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // MÉTODO CORREGIDO - AHORA EL TEXTO SE VE
  Widget _buildValidacionButton(String texto, IconData icon, bool completado, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: completado ? const Color(0xFF10B981) : const Color(0xFF2376F6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (completado ? const Color(0xFF10B981) : const Color(0xFF2376F6)).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  completado ? Icons.check_rounded : icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                    color: Colors.white, // ← TEXTO BLANCO GARANTIZADO
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(completado ? 0.3 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  completado ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: completado ? Colors.white : const Color(0xFFFF8F00),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.qr_code_rounded, color: Color(0xFF2376F6)),
            const SizedBox(width: 12),
            const Text("Código QR Médico", style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FCFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2376F6).withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.qr_code_rounded,
                size: 120,
                color: Color(0xFF2376F6),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Mostrá este código a tu médico para acceso rápido a tus datos médicos",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _mostrarOpcionesCompartir() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Compartir perfil médico",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email_rounded, color: Color(0xFF2376F6)),
              title: const Text("Por email"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Funcionalidad en desarrollo")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sms_rounded, color: Color(0xFF059669)),
              title: const Text("Por SMS"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Funcionalidad en desarrollo")),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Color(0xFF7C3AED)),
              title: const Text("Otras apps"),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Funcionalidad en desarrollo")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonGuardar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2376F6), Color(0xFF1E6BF0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2376F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: _guardarCambios,
        icon: const Icon(Icons.save_rounded, color: Colors.white, size: 22),
        label: const Text(
          "Guardar cambios",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}