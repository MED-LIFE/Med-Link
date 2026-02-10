
import '../widgets/common/bouncing_card.dart';
import '../widgets/patient/standard_header.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:intl/intl.dart'; // Fechas
import 'package:image_picker/image_picker.dart'; // Para sacar foto
import 'dart:io'; // Para mostrar imagen local
import 'package:flutter/material.dart';
import '../services/session_manager.dart'; // Para kIsWeb
// Si corrés en Android/iOS, descomentá la siguiente línea y funcionará OCR real.
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'; // OCR para DNI (Solo Mobile)

class MiPerfilScreen extends StatefulWidget {
  final Map<String, String>? userData;
  const MiPerfilScreen({super.key, this.userData});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
  bool editMode = false;

  // --------- VALIDACIÓN DNI/SELFIE ---------
  File? _dniImage;
  File? _selfieImage;
  String _dniOcrResult = '';
  bool _dniValidado = false;
  bool _selfieValidada = false; // Solo mock, real es con IA

  Future<void> _pickDniImage() async {
    if (kIsWeb) {
      _showOnlyMobileDialog();
      return;
    }
    // Solo Android/iOS
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _dniImage = File(picked.path);
        _dniOcrResult = '';
        _dniValidado = false;
      });
      await _procesarDniConOcr(_dniImage!);
    }
  }

  Future<void> _procesarDniConOcr(File image) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _showOnlyMobileDialog();
      return;
    }
    
    try {
      /*
      // OCR LOGIC (Mobile Only) - Disabled for Web
      */
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OCR no disponible en WEB.")),
      );
    } catch (e) {
      print("Error OCR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Error al procesar: $e")),
      );
    }
  }

  Future<void> _pickSelfie() async {
    if (kIsWeb) {
      _showOnlyMobileDialog();
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _selfieImage = File(picked.path);
        _selfieValidada = true; // Solo mock
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selfie cargada. Validación biométrica en desarrollo.")),
      );
    }
  }

  void _showOnlyMobileDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Solo en la app móvil'),
        content: Text('La validación de DNI y selfie solo funciona desde la app móvil (Android/iOS).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Ok', style: TextStyle(color: Color(0xFF2376F6))),
          ),
        ],
      ),
    );
  }
  Future<void> _pickAvatarImage() async {
     final picker = ImagePicker();
     final picked = await picker.pickImage(source: ImageSource.gallery);
     if (picked != null) {
       // Update Singleton Persistence
       SessionManager().updateAvatar(picked.path);
       
       setState(() {
         // Local update for immediate feedback (though ListenableBuilder handles it too)
         datosPersonales["foto"] = picked.path; 
       });
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Foto de perfil actualizada")),
       );
     }
  }

  // --------- FIN VALIDACIÓN DNI/SELFIE ---------

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar cuenta?", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Esta acción es irreversible. Se borrarán todos tus datos médicos, turnos e historial de Zanoo."),
            SizedBox(height: 16),
            Text("Si estás seguro, confirmá abajo.", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              // Second confirmation for extra safety or just delete
              _processAccountDeletion();
            },
            child: const Text("Sí, eliminar"),
          ),
        ],
      ),
    );
  }

  void _processAccountDeletion() async {
    // Mock Deletion Logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Procesando baja de cuenta..."), duration: Duration(seconds: 2)),
    );
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tu cuenta ha sido eliminada."), backgroundColor: Colors.red),
      );
      // Redirect to Login
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  // Mock datos iniciales
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
    "alergias": "",
    "foto": "", // Path/local para simular
  };

  Map<String, String> datosCobertura = {
    "tipo": "Prepaga",
    "nombre": "Centro Médico",
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
  late final TextEditingController alergiasController;

  late final TextEditingController tipoCoberturaController;
  late final TextEditingController nombreCoberturaController;
  late final TextEditingController nroAfiliadoController;
  late final TextEditingController vencimientoController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Override with passed data (e.g. for Admin)
    if (widget.userData != null) {
      datosPersonales.addAll(widget.userData!);
    }

    nombreController = TextEditingController(text: datosPersonales["nombre"]);
    dniController = TextEditingController(text: datosPersonales["dni"]);
    fechaNacController = TextEditingController(text: datosPersonales["fechaNacimiento"]);
    sexoController = TextEditingController(text: datosPersonales["sexo"]);
    telefonoController = TextEditingController(text: datosPersonales["telefono"]);
    emailController = TextEditingController(text: datosPersonales["email"]);
    direccionController = TextEditingController(text: datosPersonales["direccion"]);
    grupoSanguineoController = TextEditingController(text: datosPersonales["grupoSanguineo"]);
    contactoEmergenciaController = TextEditingController(text: datosPersonales["contactoEmergencia"]);
    alergiasController = TextEditingController(text: datosPersonales["alergias"]);

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
    alergiasController.dispose();

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
        datosPersonales["alergias"] = alergiasController.text.trim();

        datosCobertura["tipo"] = tipoCoberturaController.text.trim();
        datosCobertura["nombre"] = nombreCoberturaController.text.trim();
        datosCobertura["numeroAfiliado"] = nroAfiliadoController.text.trim();
        datosCobertura["vencimiento"] = vencimientoController.text.trim();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado correctamente")),
      );
      setState(() {
        editMode = false;
      });
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // 13 -> 16
          borderSide: const BorderSide(color: Color(0xFF2376F6), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // 13 -> 16
          borderSide: const BorderSide(color: Color(0xFF083866), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), // 13 -> 16
          borderSide: const BorderSide(color: Color(0xFFB7D7F7), width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        fillColor: enabled ? null : Colors.grey.withOpacity(0.05),
        filled: !enabled,
      ),
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey[700],
      ),
    );
  }

  Widget _seccionTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(
          color: Color(0xFF2376F6),
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
    );
  }

  int _calcularEdad(String fechaNacimiento) {
    try {
      final df = DateFormat('dd/MM/yyyy');
      final fecha = df.parse(fechaNacimiento);
      final ahora = DateTime.now();
      int edad = ahora.year - fecha.year;
      if (ahora.month < fecha.month || (ahora.month == fecha.month && ahora.day < fecha.day)) {
        edad--;
      }
      return edad;
    } catch (_) {
      return 0;
    }
  }

  double _porcentajePerfilCompleto() {
    int completos = 0;
    final totales = 11;
    if ((datosPersonales["nombre"] ?? "").isNotEmpty) completos++;
    if ((datosPersonales["dni"] ?? "").isNotEmpty) completos++;
    if ((datosPersonales["fechaNacimiento"] ?? "").isNotEmpty) completos++;
    if ((datosPersonales["sexo"] ?? "").isNotEmpty) completos++;
    if ((datosPersonales["telefono"] ?? "").isNotEmpty) completos++;
    if ((datosPersonales["email"] ?? "").isNotEmpty) completos++;
    if ((datosPersonales["direccion"] ?? "").isNotEmpty) completos++;
    if ((datosPersonales["grupoSanguineo"] ?? "").isNotEmpty) completos++;
    if ((datosPersonales["contactoEmergencia"] ?? "").isNotEmpty) completos++;
    if ((datosCobertura["nombre"] ?? "").isNotEmpty) completos++;
    if ((datosCobertura["numeroAfiliado"] ?? "").isNotEmpty) completos++;
    return completos / totales;
  }

  @override
  Widget build(BuildContext context) {
    final edad = _calcularEdad(datosPersonales["fechaNacimiento"] ?? "");
    final grupo = datosPersonales["grupoSanguineo"] ?? "";
    final cobertura = datosCobertura["nombre"] ?? "";
    final perfilCompleto = (_porcentajePerfilCompleto() * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      body: Container(
        color: const Color(0xFFF7FCFF),
        child: Column(
          children: [
            Stack(
              children: [
                const StandardPageHeader(
                  title: 'Mi Perfil',
                  subtitle: 'Gestioná tus datos personales',
                  imagePath: 'assets/images/ilustracion_mi_perfil.png',
                  isLarge: false,
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      if (editMode) {
                        _guardarCambios();
                      } else {
                        setState(() {
                          editMode = true;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Icon(
                        editMode ? Icons.check : Icons.edit, 
                        color: const Color(0xFF2376F6), 
                        size: 24
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
            // --------------- BLOQUE VALIDACIÓN DNI/SELFIE ---------------
            if (editMode) ...[
              Card(
                color: Colors.blue[50],
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Validación de identidad", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2376F6), fontSize: 16)),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.credit_card, color: Colors.white),
                            label: Text("Escanear DNI"),
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2376F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                            onPressed: _pickDniImage,
                          ),
                          const SizedBox(width: 14),
                          if (_dniImage != null)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: _dniValidado ? Colors.green : Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_dniImage!, width: 70, height: 45, fit: BoxFit.cover),
                              ),
                            ),
                          if (_dniImage == null)
                            Container(
                              width: 70, height: 45,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.credit_card, color: Colors.grey[400]),
                            ),
                          const SizedBox(width: 12),
                          Icon(_dniValidado ? Icons.verified : Icons.error_outline, color: _dniValidado ? Colors.green : Colors.orange, size: 24),
                        ],
                      ),
                      if (_dniImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            _dniValidado ? "DNI validado por OCR." : "El DNI cargado no coincide con el número ingresado.",
                            style: TextStyle(color: _dniValidado ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            label: Text("Sacar Selfie"),
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2376F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                            onPressed: _pickSelfie,
                          ),
                          const SizedBox(width: 14),
                          if (_selfieImage != null)
                            ClipOval(
                              child: Image.file(_selfieImage!, width: 44, height: 44, fit: BoxFit.cover),
                            ),
                          if (_selfieImage == null)
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey[200],
                              child: Icon(Icons.camera_alt, color: Colors.grey[400]),
                            ),
                          const SizedBox(width: 12),
                          Icon(_selfieValidada ? Icons.verified : Icons.error_outline, color: _selfieValidada ? Colors.green : Colors.orange, size: 24),
                        ],
                      ),
                      if (_selfieImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            _selfieValidada ? "Selfie cargada (validación biométrica simulada)." : "Cargá una selfie nítida.",
                            style: TextStyle(color: _selfieValidada ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            // ---------------------------------------------------------------------

            Container(
              padding: const EdgeInsets.all(24), // 20 -> 24
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24), // 22 -> 24
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2376F6).withOpacity(0.08), // Soft shadow
                    blurRadius: 24, // 13 -> 24
                    offset: const Offset(0, 8), // 7 -> 8
                  )
                ],
              ),
              child: Column(
                children: [
                  // Avatar con opción de editar (mock)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4), // White border effect
                        decoration: const BoxDecoration(
                           color: Colors.white,
                           shape: BoxShape.circle,
                        ),
                        child: ListenableBuilder(
                          listenable: SessionManager(),
                          builder: (context, _) {
                            final currentAvatar = SessionManager().avatarPath ?? datosPersonales["foto"] ?? "";
                            return CircleAvatar(
                              radius: 48,
                              backgroundColor: const Color(0xFF2376F6).withOpacity(0.14),
                              backgroundImage: currentAvatar.isEmpty
                                  ? null
                                  : (currentAvatar.contains("assets/") 
                                      ? AssetImage(currentAvatar)
                                      : (kIsWeb 
                                          ? NetworkImage(currentAvatar) 
                                          : FileImage(File(currentAvatar)) as ImageProvider)),
                              child: currentAvatar.isEmpty
                                  ? const Icon(Icons.person, size: 54, color: Color(0xFF2376F6))
                                  : null,
                            );
                          }
                        ),
                      ),
                      if (editMode)
                        BouncingCard(
                          onTap: () async {
                             // Mock Picking Logic (for Web/Desktop simulation)
                             // In a real app, use ImagePicker().pickImage() 
                             // updating state with the file path.
                             
                             // Simulating a successful pick for user demo:
                             showDialog(
                               context: context,
                               builder: (ctx) => AlertDialog(
                                 title: const Text("Editar foto de perfil"),
                                 content: Column(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     const Text("Seleccioná el origen de la imagen:"),
                                     const SizedBox(height: 16),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                       children: [
                                         Column(
                                           children: [
                                             IconButton(
                                               icon: const Icon(Icons.camera_alt, color: Colors.blue, size: 32),
                                               onPressed: () {
                                                 Navigator.pop(ctx);
                                                 // MOCK UPDATE
                                                 setState(() {
                                                   // Using a placeholder "local file" or just a different asset to simulate change
                                                   // For this environment, we toggle to a specific asset or network image
                                                   datosPersonales["foto"] = ""; // Trigger network fallback or handle file
                                                   
                                                   // Temporarily using a public URL to demonstrate "Change"
                                                   // Ideally we use File(_image.path) but on web/desktop we need bytes/path.
                                                   
                                                   // Let's assume we picked a file and update the visual
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text("Foto actualizada (Simulación)")),
                                                    );
                                                 });
                                               },
                                             ),
                                             const Text("Cámara"),
                                           ],
                                         ),
                                         Column(
                                           children: [
                                             IconButton(
                                               icon: const Icon(Icons.photo_library, color: Colors.green, size: 32),
                                               onPressed: () {
                                                  Navigator.pop(ctx);
                                                  _pickAvatarImage(); // Call the real/mock picker function
                                               },
                                             ),
                                             const Text("Galería"),
                                           ],
                                         ),
                                       ],
                                     )
                                   ],
                                 ),
                               ),
                             );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2376F6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2376F6).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            ),
                            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16), // 12 -> 16
                  Text(
                    datosPersonales["nombre"] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF193A72)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    datosPersonales["email"] ?? '',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF42506A)),
                  ),
                  const SizedBox(height: 16), // 7 -> 16
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (edad > 0)
                        _buildTag(Icons.cake, "$edad años", Colors.grey[700]!, Colors.grey[200]! ),
                      if (grupo.isNotEmpty)
                        _buildTag(Icons.bloodtype, grupo, Colors.redAccent, Colors.red[50]! ),
                      if (cobertura.isNotEmpty)
                         _buildTag(Icons.local_hospital, cobertura, const Color(0xFF2376F6), const Color(0xFFE3F2FD) ),
                    ],
                  ),
                  const SizedBox(height: 24), // 17 -> 24
                  // Barra de perfil completo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _porcentajePerfilCompleto(),
                            color: const Color(0xFF2376F6),
                            backgroundColor: const Color(0xFFB7D7F7).withOpacity(0.35),
                            minHeight: 8, // 7 -> 8
                          ),
                        ),
                        const SizedBox(height: 8), // 5 -> 8
                        Text(
                          "Perfil ${perfilCompleto}% completo",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // --- SECCIONES ---
            _seccionTitulo("Datos personales"),
            _buildTextField("Nombre completo", nombreController,
                validator: (v) => v == null || v.isEmpty ? "Completar nombre" : null, enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("DNI", dniController,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Completar DNI" : null,
                enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Fecha de nacimiento", fechaNacController,
                keyboardType: TextInputType.datetime,
                validator: (v) => v == null || v.isEmpty ? "Completar fecha" : null,
                enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Sexo", sexoController,
                validator: (v) => v == null || v.isEmpty ? "Completar sexo" : null, enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Teléfono", telefonoController,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? "Completar teléfono" : null, enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Email", emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Completar email";
                  final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                  if (!regex.hasMatch(v)) return "Email inválido";
                  return null;
                },
                enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Dirección", direccionController, enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Grupo sanguíneo", grupoSanguineoController, enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Alergias importantes", alergiasController, enabled: editMode),
            const SizedBox(height: 12),
            // --- Emergencia destacado
            Container(
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent, width: 1.0)),
              margin: const EdgeInsets.symmetric(vertical: 7),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 27),
                title: Text(
                  "Contacto de emergencia",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[800], fontSize: 15),
                ),
                subtitle: _buildTextField(
                  "Contacto de emergencia",
                  contactoEmergenciaController,
                  enabled: editMode,
                ),
              ),
            ),
            _seccionTitulo("Cobertura médica"),
            _buildTextField("Tipo de cobertura", tipoCoberturaController, enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Nombre cobertura", nombreCoberturaController, enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Número afiliado", nroAfiliadoController, enabled: editMode),
            const SizedBox(height: 12),
            _buildTextField("Vencimiento", vencimientoController, enabled: editMode),
            _seccionTitulo("Preferencias"),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF2376F6),
              title: const Text("Notificaciones activas"),
              value: preferencias["notificaciones"] ?? true,
              onChanged: editMode
                  ? (val) {
                      setState(() {
                        preferencias["notificaciones"] = val;
                      });
                    }
                  : null,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF2376F6),
              title: const Text("Recibir notificaciones por email"),
              value: preferencias["email"] ?? true,
              onChanged: editMode
                  ? (val) {
                      setState(() {
                        preferencias["email"] = val ?? false;
                      });
                    }
                  : null,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF2376F6),
              title: const Text("Recibir notificaciones por SMS"),
              value: preferencias["sms"] ?? false,
              onChanged: editMode
                  ? (val) {
                      setState(() {
                        preferencias["sms"] = val ?? false;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 30),
            // ---- Botón de documentos médicos ----
            BouncingCard(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Funcionalidad en desarrollo (adjuntar/ver estudios médicos)")),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2376F6), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.insert_drive_file_rounded, color: Color(0xFF2376F6)),
                    SizedBox(width: 8),
                    Text(
                      "Ver documentos médicos",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF2376F6)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // ---- QR personal (solo visual) ----
            Center(
              child: Column(
                children: [
                  const Text(
                    "Acceso rápido para profesionales",
                    style: TextStyle(fontSize: 13, color: Color(0xFF2376F6), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFFB7D7F7)),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0,2))],
                    ),
                    padding: const EdgeInsets.all(9),
                    child: Icon(Icons.qr_code, size: 48, color: Color(0xFF2376F6)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Mostrale este QR a tu médico para\ncompartir tus datos clave al instante.",
                    style: TextStyle(fontSize: 11.5, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (editMode)
              BouncingCard(
                onTap: _guardarCambios,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2376F6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2376F6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.save_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Guardar cambios",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            
            // --- ZONA DE SEGURIDAD (Store Requirement) ---
            const Divider(height: 40, thickness: 1),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Link to real privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Abriendo Política de Privacidad...")));
                },
                child: const Text("Política de Privacidad", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: _showDeleteConfirmation,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text("Eliminar mi cuenta"),
              ),
            ),
            const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTag(IconData icon, String text, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
