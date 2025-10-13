import 'package:flutter/material.dart';

class MiPerfilScreen extends StatefulWidget {
  const MiPerfilScreen({super.key});

  @override
  State<MiPerfilScreen> createState() => _MiPerfilScreenState();
}

class _MiPerfilScreenState extends State<MiPerfilScreen> {
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
    "nombre": "Swiss Medical",
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
        const SnackBar(content: Text("Perfil actualizado correctamente")),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2376F6), width: 1.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF083866), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _seccionTitulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 14),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2376F6)),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Color(0xFF2376F6),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF2376F6).withOpacity(0.15),
                    child: const Icon(Icons.person, size: 54, color: Color(0xFF2376F6)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    datosPersonales["nombre"] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF193A72)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    datosPersonales["email"] ?? '',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF42506A)),
                  ),
                ],
              ),
            ),
            _seccionTitulo("Datos personales"),
            _buildTextField("Nombre completo", nombreController,
                validator: (v) => v == null || v.isEmpty ? "Completar nombre" : null),
            const SizedBox(height: 12),
            _buildTextField("DNI", dniController,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? "Completar DNI" : null),
            const SizedBox(height: 12),
            _buildTextField("Fecha de nacimiento", fechaNacController,
                keyboardType: TextInputType.datetime,
                validator: (v) => v == null || v.isEmpty ? "Completar fecha" : null),
            const SizedBox(height: 12),
            _buildTextField("Sexo", sexoController,
                validator: (v) => v == null || v.isEmpty ? "Completar sexo" : null),
            const SizedBox(height: 12),
            _buildTextField("Teléfono", telefonoController,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? "Completar teléfono" : null),
            const SizedBox(height: 12),
            _buildTextField("Email", emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Completar email";
                  final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                  if (!regex.hasMatch(v)) return "Email inválido";
                  return null;
                }),
            const SizedBox(height: 12),
            _buildTextField("Dirección", direccionController),
            const SizedBox(height: 12),
            _buildTextField("Grupo sanguíneo", grupoSanguineoController),
            const SizedBox(height: 12),
            _buildTextField("Contacto de emergencia", contactoEmergenciaController),
            _seccionTitulo("Cobertura médica"),
            _buildTextField("Tipo de cobertura", tipoCoberturaController),
            const SizedBox(height: 12),
            _buildTextField("Nombre cobertura", nombreCoberturaController),
            const SizedBox(height: 12),
            _buildTextField("Número afiliado", nroAfiliadoController),
            const SizedBox(height: 12),
            _buildTextField("Vencimiento", vencimientoController),
            _seccionTitulo("Preferencias"),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF2376F6),
              title: const Text("Notificaciones activas"),
              value: preferencias["notificaciones"] ?? true,
              onChanged: (val) {
                setState(() {
                  preferencias["notificaciones"] = val;
                });
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF2376F6),
              title: const Text("Recibir notificaciones por email"),
              value: preferencias["email"] ?? true,
              onChanged: (val) {
                setState(() {
                  preferencias["email"] = val ?? false;
                });
              },
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF2376F6),
              title: const Text("Recibir notificaciones por SMS"),
              value: preferencias["sms"] ?? false,
              onChanged: (val) {
                setState(() {
                  preferencias["sms"] = val ?? false;
                });
              },
            ),
            const SizedBox(height: 35),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2376F6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _guardarCambios,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                "Guardar cambios",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
