import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../repositories/medico_repository.dart';
import '../../models/agenda_item_model.dart';
import '../../widgets/patient/standard_header.dart';

class PatientIntakeWizardScreen extends StatefulWidget {
  const PatientIntakeWizardScreen({Key? key}) : super(key: key);

  @override
  State<PatientIntakeWizardScreen> createState() => _PatientIntakeWizardScreenState();
}

class _PatientIntakeWizardScreenState extends State<PatientIntakeWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Data Model
  final Map<String, dynamic> _patientData = {
    'dni': '', 
    'nationality': 'Argentina', 
    'name': '', 
    'dob': '',
    'contacts': [{'type': 'Celular', 'country': '+54', 'value': ''}], 
    'insurance': 'Particular', 
    'affiliate': '', // Optional
    'bloodType': 'O+', 
    'allergies': <String>[],
  };

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      _finishWizard();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _finishWizard() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final newItem = AgendaItem(
        id: "new_${DateTime.now().millisecondsSinceEpoch}",
        hora: "00:00", 
        paciente: _patientData['name'],
        dni: _patientData['dni'],
        age: _calculateAge(_patientData['dob']),
        motivo: "Nuevo Paciente",
        estado: "pendiente",
        img: "assets/images/user_placeholder.png",
      );
      
      await MedicoRepository().addNewPatient(newItem);

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Paciente creado exitosamente!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Close wizard
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        // Check for specific Firestore permission error to give better feedback
        String errorMessage = "Error al crear paciente: $e";
        if (e.toString().contains("permission-denied")) {
           errorMessage = "Error de Permisos: Revisa las reglas de Firebase o inicia sesión real.";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
        );
      }
    }
  }

  int _calculateAge(String dob) {
    if (dob.isEmpty) return 0;
    try {
      final parts = dob.split('/');
      final birthDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _IdentityStep(data: _patientData, onNext: _nextStep),
                  _ContactStep(data: _patientData, onNext: _nextStep),
                  _CoverageStep(data: _patientData, onNext: _nextStep),
                  _ClinicalStep(data: _patientData, onNext: _nextStep),
                  _ReviewStep(data: _patientData, onSubmit: _finishWizard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevStep,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF2376F6)),
            ),
          ),
          const SizedBox(width: 16),
          const Text("Alta de Paciente", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Paso ${_currentStep + 1} de $_totalSteps", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2376F6))),
              Text(_getStepTitle(_currentStep), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2376F6)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0: return "Identidad";
      case 1: return "Contacto";
      case 2: return "Cobertura";
      case 3: return "Clínico";
      case 4: return "Revisión";
      default: return "";
    }
  }
}

// --- STEPS ---

class _IdentityStep extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;
  const _IdentityStep({required this.data, required this.onNext});

  @override
  State<_IdentityStep> createState() => _IdentityStepState();
}

class _IdentityStepState extends State<_IdentityStep> {
  final TextEditingController _dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dobController.text = widget.data['dob'];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF2376F6))), child: child!)
    );
    if (picked != null) {
      setState(() {
        String formatted = "${picked.day.toString().padLeft(2,'0')}/${picked.month.toString().padLeft(2,'0')}/${picked.year}";
        _dobController.text = formatted;
        widget.data['dob'] = formatted;
        _formKey.currentState?.validate();
      });
    }
  }
  
  int _getMaxDniLength(String nationality) {
    if (nationality == 'Argentina') return 8;
    return 15; // Generic for others
  }

  @override
  Widget build(BuildContext context) {
    String currentNationality = widget.data['nationality'] ?? 'Argentina';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Datos de Identidad", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
          const SizedBox(height: 8),
          const Text("Ingrese nombre, nacionalidad y documento.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          
          // 1. NOMBRE (Moved first)
          _CustomTextField(
            label: "Nombre Completo", 
            icon: Icons.person_rounded, 
            initialValue: widget.data['name'],
            onChanged: (v) { widget.data['name'] = v; _formKey.currentState?.validate(); },
            validator: (v) => (v == null || v.isEmpty) ? "El nombre es obligatorio" : null,
          ),
          const SizedBox(height: 16),
          
          // 2. NACIONALIDAD (Added)
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: "Nacionalidad",
              prefixIcon: const Icon(Icons.flag_rounded, color: Color(0xFF2376F6)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true, fillColor: Colors.white,
            ),
            value: currentNationality,
            items: ["Argentina", "Uruguay", "Chile", "Brasil", "Paraguay", "Bolivia", "Otro"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() { widget.data['nationality'] = v; _formKey.currentState?.validate(); }),
          ),
          const SizedBox(height: 16),

          // 3. DNI (Validated by Nationality)
          TextFormField(
            initialValue: widget.data['dni'],
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(_getMaxDniLength(currentNationality))],
            onChanged: (v) => widget.data['dni'] = v,
            validator: (v) {
              if (v == null || v.isEmpty) return "El DNI es obligatorio";
              if (currentNationality == 'Argentina' && v.length < 7) return "DNI inválido (mínimo 7 dígitos)";
              return null;
            },
            decoration: InputDecoration(
              labelText: "DNI / Documento",
              prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFF2376F6)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              helperText: currentNationality == 'Argentina' ? "Máximo 8 dígitos" : null
            ),
          ),
          const SizedBox(height: 16),
          
          // 4. DOB
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: TextFormField(
                controller: _dobController,
                validator: (v) => (v == null || v.isEmpty) ? "Fecha requerida" : null,
                decoration: InputDecoration(
                  labelText: "Fecha de Nacimiento",
                  prefixIcon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF2376F6)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () {
                   if (_formKey.currentState!.validate()) {
                     widget.onNext();
                   }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2376F6), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Siguiente", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ContactStep extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;
  const _ContactStep({required this.data, required this.onNext});

  @override
  State<_ContactStep> createState() => _ContactStepState();
}

class _ContactStepState extends State<_ContactStep> {
  final _formKey = GlobalKey<FormState>();

  void _addContact() {
    setState(() {
      (widget.data['contacts'] as List).add({'type': 'Celular', 'country': '+54', 'value': ''});
    });
  }

  void _removeContact(int index) {
    if ((widget.data['contacts'] as List).length > 1) {
      setState(() {
        (widget.data['contacts'] as List).removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> contacts = widget.data['contacts'];

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Contacto", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
          const SizedBox(height: 8),
          const Text("Medios de contacto.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          ...contacts.asMap().entries.map((entry) {
            int idx = entry.key;
            Map<String, dynamic> item = entry.value;
            bool isPhone = item['type'] == 'Celular' || item['type'] == 'Teléfono';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type
                  SizedBox(
                    width: 90,
                    child: DropdownButtonFormField<String>(
                       decoration: InputDecoration(
                         contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                         filled: true, fillColor: Colors.white,
                       ),
                       value: item['type'],
                       items: ["Celular", "Email", "Teléfono"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(), 
                       onChanged: (v) => setState(() => item['type'] = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Country Code (only if phone)
                  if (isPhone)
                    Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 8),
                      child: DropdownButtonFormField<String>(
                         decoration: InputDecoration(
                           contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                           filled: true, fillColor: Colors.white,
                         ),
                         value: item['country'] ?? '+54',
                         items: ["+54", "+598", "+56", "+1", "Otro"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(), 
                         onChanged: (v) => setState(() => item['country'] = v),
                      ),
                    ),

                  // Value
                  Expanded(
                    child: TextFormField(
                      initialValue: item['value'],
                      validator: (v) => (v == null || v.isEmpty) ? "Requerido" : null,
                      onChanged: (v) => item['value'] = v,
                      decoration: InputDecoration(
                        hintText: isPhone ? "11 1234 5678" : "correo@ejemplo.com",
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  if (contacts.length > 1)IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => _removeContact(idx))
                ],
              ),
            );
          }).toList(),
          
          TextButton.icon(
            onPressed: _addContact,
            icon: const Icon(Icons.add_circle_rounded),
            label: const Text("Agregar otro contacto"),
          ),

          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Atrás", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () {
                   if(_formKey.currentState!.validate()) {
                     widget.onNext();
                   }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2376F6), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Siguiente", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _CoverageStep extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;
  const _CoverageStep({required this.data, required this.onNext});

  @override
  State<_CoverageStep> createState() => _CoverageStepState();
}

class _CoverageStepState extends State<_CoverageStep> {
  final TextEditingController _affiliateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _affiliateController.text = widget.data['affiliate'] ?? '';
  }

  void _realScan() async {
     // Show Scanner Dialog
     final result = await showDialog<String>(
       context: context,
       builder: (context) => Dialog(
         insetPadding: const EdgeInsets.all(16),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
         child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
               height: 400,
               width: double.infinity,
               child: Stack(
                 children: [
                    MobileScanner(
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                           final code = barcodes.first.rawValue;
                           if (code != null) {
                             Navigator.pop(context, code);
                           }
                        }
                      },
                    ),
                    // Overlay
                    // Overlay (Simple Border)
                    Container(
                      margin: const EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF2376F6), width: 4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    // Close Button
                    Positioned(
                      top: 10, right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Positioned(
                      bottom: 20, left: 0, right: 0,
                      child: Text(
                        "Enfocá el código de la credencial",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                      ),
                    )
                 ],
               ),
            ),
         ),
       ),
     );
     
     if (result != null) {
       setState(() {
         // Assuming result might be Affiliate Number for this demo
         widget.data['affiliate'] = result;
         _affiliateController.text = result;
         // Simulate insurance detection based on format if possible, else default
         if (widget.data['insurance'] == "Particular") {
            widget.data['insurance'] = "OSDE"; // Auto-select for demo effect
         }
       });
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("¡Código escaneado: $result!"), backgroundColor: Colors.green));
     }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Cobertura Médica", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
        const SizedBox(height: 8),
        const Text("Obra social o prepaga.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Obra Social / Prepaga",
            prefixIcon: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF2376F6)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true, fillColor: Colors.white,
          ),
          items: ["Particular", "OSDE", "Swiss Medical", "Galeno", "PAMI"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => widget.data['insurance'] = v,
          value: widget.data['insurance'],
        ),
        const SizedBox(height: 16),
        
        // Optional Affiliate
        TextFormField(
          controller: _affiliateController,
          onChanged: (v) => widget.data['affiliate'] = v,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Nro de Afiliado (Opcional)",
            prefixIcon: const Icon(Icons.numbers_rounded, color: Color(0xFF2376F6)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 24),
        
        // Scan Card Action
        GestureDetector(
          onTap: _realScan,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2376F6), style: BorderStyle.solid),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2376F6), size: 32),
                SizedBox(height: 8),
                Text("Escanear Credencial Digital", style: TextStyle(color: Color(0xFF2376F6), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: () {}, child: const Text("Atrás", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2376F6), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Siguiente", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }
}

class _ClinicalStep extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNext;
  const _ClinicalStep({required this.data, required this.onNext});

  @override
  State<_ClinicalStep> createState() => _ClinicalStepState();
}

class _ClinicalStepState extends State<_ClinicalStep> {
  final List<String> _availableAllergies = ["Penicilina", "Latex", "Polen", "Maní", "Ninguna"];

  @override
  Widget build(BuildContext context) {
    List<String> selectedAllergies = List<String>.from(widget.data['allergies'] ?? []);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Datos Clínicos", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
        const SizedBox(height: 8),
        const Text("Información inicial. (Opcional)", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Grupo Sanguíneo",
            prefixIcon: const Icon(Icons.bloodtype_rounded, color: Color(0xFF2376F6)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true, fillColor: Colors.white,
          ),
          items: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => widget.data['bloodType'] = v,
          value: widget.data['bloodType'],
        ),
        const SizedBox(height: 16),
        const Text("Alergias (Selección Múltiple)", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableAllergies.map((allergy) {
            bool isSelected = selectedAllergies.contains(allergy);
            return FilterChip(
              label: Text(allergy),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    if (allergy == "Ninguna") {
                      selectedAllergies.clear();
                      selectedAllergies.add("Ninguna");
                    } else {
                       selectedAllergies.remove("Ninguna");
                       selectedAllergies.add(allergy);
                    }
                  } else {
                    selectedAllergies.remove(allergy);
                  }
                  widget.data['allergies'] = selectedAllergies;
                });
              },
              selectedColor: const Color(0xFFE3F2FD),
              checkmarkColor: const Color(0xFF2376F6),
              labelStyle: TextStyle(color: isSelected ? const Color(0xFF1565C0) : Colors.black87),
            );
          }).toList(),
        ),

        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: () {}, child: const Text("Atrás", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2376F6), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Revisar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onSubmit;
  const _ReviewStep({required this.data, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    String nac = data['nationality'] ?? 'Argentina';
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text("Revisión Final", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D1C2E))),
        const SizedBox(height: 8),
        const Text("Confirme los datos antes de crear.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        
        _buildInfoCard("Identidad", [
          "Nombre: ${data['name']}",
          "Nacionalidad: $nac",
          "DNI: ${data['dni']}",
          "Nacimiento: ${data['dob']}"
        ]),
        const SizedBox(height: 16),
        _buildInfoCard("Contacto", 
          (data['contacts'] as List).map((c) => "${c['type']} (${c['country'] ?? ''}) : ${c['value']}").toList().cast<String>()
        ),
        const SizedBox(height: 16),
        _buildInfoCard("Cobertura", [
          "Seguro: ${data['insurance']}",
          "Afiliado: ${data['affiliate'].toString().isEmpty ? 'No informado' : data['affiliate']}"
        ]),

        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF34C759), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text("Crear Paciente", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildInfoCard(String title, List<String> lines) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2376F6))),
          const Divider(),
          ...lines.map((l) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Text(l, style: const TextStyle(fontSize: 14, color: Color(0xFF0D1C2E))))).toList()
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final String? initialValue;
  final TextInputType inputType;

  const _CustomTextField({required this.label, required this.icon, required this.onChanged, this.validator, this.initialValue, this.inputType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2376F6)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
