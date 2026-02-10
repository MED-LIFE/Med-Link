import 'package:flutter/material.dart';
import '../../../constants/medico_constants.dart';

class SpontaneousAppointmentContent extends StatefulWidget {
  final Function(String, String) onConfirm;

  const SpontaneousAppointmentContent({Key? key, required this.onConfirm}) : super(key: key);

  @override
  State<SpontaneousAppointmentContent> createState() => _SpontaneousAppointmentContentState();
}

class _SpontaneousAppointmentContentState extends State<SpontaneousAppointmentContent> {
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Optional, usually fetched by DNI
  bool _isLoading = false;
  bool _patientFound = false;

  void _searchPatient() async {
    if (_dniController.text.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingrese un DNI válido")));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API

    // Mock logic
    setState(() {
      _isLoading = false;
      _patientFound = true;
      // Auto-fill mock name if empty based on DNI seed
      if (_nameController.text.isEmpty) {
        _nameController.text = _dniController.text.endsWith("1") ? "Maria Gonzalez" : "Juan Perez";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Ingrese el DNI del paciente para asignarle un sobreturno inmediato.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          // DNI Input
          TextField(
            controller: _dniController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "DNI del Paciente",
              prefixIcon: const Icon(Icons.badge_rounded, color: MedicoConstants.primaryColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: IconButton(
                onPressed: _searchPatient,
                icon: const Icon(Icons.search_rounded),
              )
            ),
            onSubmitted: (_) => _searchPatient(),
          ),

          if (_isLoading) ...[
             const SizedBox(height: 20),
             const Center(child: CircularProgressIndicator())
          ],

          if (_patientFound) ...[
             const SizedBox(height: 20),
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: MedicoConstants.success.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: MedicoConstants.success)
               ),
               child: Row(
                 children: [
                   const Icon(Icons.check_circle, color: MedicoConstants.success),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text("Paciente Encontrado", style: TextStyle(fontSize: 12, color: MedicoConstants.success, fontWeight: FontWeight.bold)),
                         Text(_nameController.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                       ],
                     ),
                   )
                 ],
               ),
             ),
             const SizedBox(height: 20),
             const Text("Motivo de la consulta (Opcional)", style: TextStyle(fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
             TextField(
               decoration: InputDecoration(
                 hintText: "Ej. Dolor abdominal, fiebre...",
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
               ),
             ),
          ],

          const Spacer(),
          
          ElevatedButton(
            onPressed: _patientFound 
              ? () => widget.onConfirm(_nameController.text, _dniController.text)
              : _searchPatient,
            style: ElevatedButton.styleFrom(
              backgroundColor: MedicoConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4
            ),
            child: Text(
              _patientFound ? "Confirmar Turno Ahora" : "Buscar Paciente",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
