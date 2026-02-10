import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../../widgets/patient/standard_header.dart';
import '../../models/agenda_item_model.dart';
import '../../repositories/medico_repository.dart';

class AdminPatientImportScreen extends StatefulWidget {
  const AdminPatientImportScreen({Key? key}) : super(key: key);

  @override
  State<AdminPatientImportScreen> createState() => _AdminPatientImportScreenState();
}

class _AdminPatientImportScreenState extends State<AdminPatientImportScreen> {
  bool _isUploading = false;
  bool _isFileSelected = false;
  String? _fileName;
  List<Map<String, dynamic>> _parsedData = [];
  
  void _pickFile() async {
    setState(() => _isUploading = true);
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'], // Added txt just in case
        withData: true, 
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        setState(() => _fileName = file.name);
        
        String csvString = "";
        
        // SAFE DECODING
        if (file.bytes != null) {
             try {
               csvString = utf8.decode(file.bytes!);
             } catch (e) {
               // Fallback for latin1 or other encodings if utf8 fails
               print("UTF8 Decode failed, trying Latin1: $e");
               csvString = latin1.decode(file.bytes!);
             }
        }
        
        // Parse CSV
        List<List<dynamic>> rows = const CsvToListConverter().convert(csvString, eol: '\n');
        
        // Skip header heuristic
        if (rows.isNotEmpty && rows.first.isNotEmpty && rows.first.first.toString().toLowerCase().contains('nombre')) {
           rows.removeAt(0);
        }

        List<Map<String, dynamic>> parsedList = [];
        final existingPatients = await MedicoRepository().getInitialAgenda();
        
        for (var row in rows) {
           if (row.isEmpty) continue;
           
           String name = row.length > 0 ? row[0].toString().trim() : "";
           String dni = row.length > 1 ? row[1].toString().trim() : "";
           String dob = row.length > 2 ? row[2].toString().trim() : "";
           
           String status = "valid";
           String msg = "";

           if (name.isEmpty) { status = "error"; msg = "Falta Nombre"; }
           else if (dni.isEmpty) { status = "error"; msg = "Falta DNI"; }
           else if (dob.isEmpty) { status = "error"; msg = "Falta Fecha Nac."; }
           
           // REAL DUPLICATE CHECK
           // 1. Check against loaded list (Internal Duplicate)
           if (parsedList.any((e) => e['dni'] == dni)) {
              status = "error";
              msg = "Duplicado en este archivo";
           }
           // 2. Check against Repository (External Duplicate)
           else {
             final existing = existingPatients.where((p) => p.dni == dni || p.paciente.toLowerCase() == name.toLowerCase());
             if (existing.isNotEmpty) {
               status = "duplicate"; // Special status for valid but existing
               msg = "Ya existe en Zanoo";
             }
           }

           parsedList.add({
             'name': name,
             'dni': dni,
             'dob': dob,
             'status': status,
             'msg': msg
           });
        }
        
        if (parsedList.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("El archivo está vacío o mal formado.")));
           setState(() => _isUploading = false);
           return;
        }

        setState(() {
          _isFileSelected = true;
          _parsedData = parsedList;
          _isUploading = false;
        });

      } else {
        setState(() => _isUploading = false);
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al leer archivo: $e"), backgroundColor: Colors.red));
      setState(() => _isUploading = false);
    }
  }

  void _showResolveDialog(int index) {
    final row = _parsedData[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Resolver Duplicado"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("El paciente ${row['name']} (DNI: ${row['dni']}) ya figura en la base de datos."),
            const SizedBox(height: 16),
            const Text("¿Qué desea hacer?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // "Skip" logic: Mark as ignored/skipped
              setState(() {
                _parsedData[index]['status'] = 'skipped';
                _parsedData[index]['msg'] = 'Omitido por usuario';
              });
              Navigator.pop(context);
            },
            child: const Text("Omitir"),
          ),
          ElevatedButton(
            onPressed: () {
               // "Update/Merge" logic (For now just treat as Valid to 'overwrite' conceptually)
               setState(() {
                _parsedData[index]['status'] = 'valid';
                _parsedData[index]['msg'] = 'Actualización confirmada'; // Visual cue
              });
              Navigator.pop(context);
            },
            child: const Text("Actualizar / Unificar"),
          )
        ],
      )
    );
  }

  void _confirmImport() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 1)); 

    int count = 0;
    for (var row in _parsedData) {
      if (row['status'] == 'valid') {
        final newItem = AgendaItem(
          id: "bulk_${DateTime.now().millisecondsSinceEpoch}_$count",
          hora: "00:00",
          paciente: row['name'],
          dni: row['dni'],
          age: _calculateAge(row['dob']),
          motivo: "Importado Masivamente",
          estado: "pendiente",
          img: "assets/images/user_placeholder.png"
        );
        await MedicoRepository().addNewPatient(newItem);
        count++;
      }
    }

    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("¡Éxito! Se procesaron $count registros."), backgroundColor: Colors.green),
    );
    Navigator.pop(context); 
    Navigator.pop(context); 
  }

  int _calculateAge(String dob) {
    if (dob.isEmpty) return 0;
    try {
      final parts = dob.trim().split('/');
      return DateTime.now().year - int.parse(parts[2]);
    } catch (e) { return 0; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFF),
      body: SafeArea(
        child: Column(
          children: [
            const StandardPageHeader(
               title: "Carga Masiva",
               subtitle: "Importar Pacientes",
               imagePath: 'assets/images/ilustracion_search_patient.png',
               isLarge: false,
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_isFileSelected) _buildUploadZone()
                    else _buildPreviewList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadZone() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _isUploading ? null : _pickFile,
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD).withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2376F6), width: 2), 
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isUploading 
                      ? const CircularProgressIndicator(color: Color(0xFF2376F6))
                      : const Icon(Icons.cloud_upload_rounded, size: 64, color: Color(0xFF2376F6)),
                    const SizedBox(height: 16),
                    Text(
                      _isUploading ? "Analizando archivo..." : "Toca para subir CSV",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    if (!_isUploading)
                      Text("Tamaño máx: 10MB", style: TextStyle(color: Colors.grey[500])),
                  ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () {}, 
            icon: const Icon(Icons.download_rounded),
            label: const Text("Descargar Plantilla Modelo"),
          )
        ],
      ),
    );
  }

  void _deleteRow(int index) {
    setState(() {
      _parsedData.removeAt(index);
    });
  }

  void _editRow(int index) {
    final row = _parsedData[index];
    final nameCtrl = TextEditingController(text: row['name']);
    final dniCtrl = TextEditingController(text: row['dni']);
    final dobCtrl = TextEditingController(text: row['dob']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Paciente"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Nombre y Apellido")),
            TextField(controller: dniCtrl, decoration: const InputDecoration(labelText: "DNI")),
            TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: "Fecha Nac. (DD/MM/AAAA)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
               // Simple validation re-check
               String status = "valid";
               String msg = "";
               String name = nameCtrl.text.trim();
               String dni = dniCtrl.text.trim();
               String dob = dobCtrl.text.trim();

               if (name.isEmpty) { status = "error"; msg = "Falta Nombre"; }
               else if (dni.isEmpty) { status = "error"; msg = "Falta DNI"; }
               else if (dob.isEmpty) { status = "error"; msg = "Falta Fecha Nac."; }
               
               // Check internal duplicates (excluding self)
                bool internalDup = _parsedData.asMap().entries.any((e) => e.key != index && e.value['dni'] == dni);
                if (internalDup) { status = "error"; msg = "Duplicado en archivo"; }

               // Check external
               // Note: Should re-check against repo, but for now assuming user knows what they are doing if editing manually 
               // or we can keep the duplicate status if it matches existing.
               final existingPatients = await MedicoRepository().getInitialAgenda();
               final existing = existingPatients.where((p) => p.dni == dni);
               if (existing.isNotEmpty) {
                   status = "duplicate";
                   msg = "Ya existe en Zanoo";
               }

               setState(() {
                 _parsedData[index] = {
                   'name': name,
                   'dni': dni,
                   'dob': dob,
                   'status': status,
                   'msg': msg
                 };
               });
               Navigator.pop(context);
            },
            child: const Text("Guardar"),
          )
        ],
      )
    );
  }

  Widget _buildPreviewList() {
    int validCount = _parsedData.where((e) => e['status'] == 'valid').length;
    int errorCount = _parsedData.where((e) => e['status'] == 'error').length;
    int dupCount = _parsedData.where((e) => e['status'] == 'duplicate').length;

    return Expanded(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Vista Previa", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            Row(
              children: [
                if (validCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withOpacity(0.5))),
                  child: Text("$validCount OK", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                if (dupCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.orange.withOpacity(0.5))),
                  child: Text("$dupCount Dups", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                if (errorCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.withOpacity(0.5))),
                  child: Text("$errorCount Err", style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _parsedData.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (context, index) {
                final row = _parsedData[index];
                final status = row['status'];
                
                Color bgColor;
                IconData icon;
                Color contentColor;

                switch(status) {
                  case 'valid': bgColor = Colors.green[100]!; icon = Icons.check; contentColor = Colors.green; break;
                  case 'error': bgColor = Colors.red[100]!; icon = Icons.close; contentColor = Colors.red; break;
                  case 'duplicate': bgColor = Colors.orange[100]!; icon = Icons.warning_rounded; contentColor = Colors.orange[800]!; break;
                  case 'skipped': bgColor = Colors.grey[200]!; icon = Icons.block; contentColor = Colors.grey; break;
                  default: bgColor = Colors.blue[100]!; icon = Icons.question_mark; contentColor = Colors.blue;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: bgColor,
                    child: Icon(icon, color: contentColor, size: 20),
                  ),
                  title: Text(row['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text("DNI: ${row['dni']} - Nac: ${row['dob']}"),
                       if (status != 'valid' && status != 'skipped')
                         Padding(
                           padding: const EdgeInsets.only(top: 4),
                           child: Text(row['msg'], style: TextStyle(color: contentColor, fontWeight: FontWeight.bold, fontSize: 12)),
                         )
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editRow(index),
                        tooltip: "Editar",
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () => _deleteRow(index),
                        tooltip: "Eliminar",
                      ),
                      // Resolve Button (Specific for duplicates)
                      if (status == 'duplicate') 
                        TextButton(
                          onPressed: () => _showResolveDialog(index),
                          child: const Text("Resolver"),
                          style: TextButton.styleFrom(foregroundColor: Colors.orange[800]),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _isFileSelected = false),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Cancelar"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isUploading ? null : _confirmImport,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2376F6), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("Importar ($validCount)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        )
        ],
      ),
    );
  }
}
