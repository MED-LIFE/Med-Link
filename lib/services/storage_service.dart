import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload a file selected by user
  Future<String?> uploadStudy(PlatformFile file, String tipoEstudio) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    try {
      final String filePath = 'estudios/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = _storage.ref().child(filePath);
      
      UploadTask uploadTask;
      if (file.bytes != null) {
        // Web or when bytes are available
        uploadTask = ref.putData(file.bytes!, SettableMetadata(
          contentType: 'application/pdf', 
          customMetadata: {'tipo': tipoEstudio, 'originalName': file.name}
        ));
      } else {
        // Mobile with path
        uploadTask = ref.putFile(File(file.path!), SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {'tipo': tipoEstudio, 'originalName': file.name}
        ));
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      rethrow;
    }
  }

  // List all studies for current user
  Future<List<Map<String, dynamic>>> getUserStudies() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final ListResult result = await _storage.ref().child('estudios/${user.uid}').listAll();
      
      final List<Map<String, dynamic>> studies = [];
      
      for (var ref in result.items) {
        final metadata = await ref.getMetadata();
        final url = await ref.getDownloadURL();
        
        studies.add({
          "tipo": metadata.customMetadata?['tipo'] ?? "Estudio",
          "fecha": metadata.timeCreated?.toIso8601String().split('T')[0] ?? "Fecha desc.",
          "estado": "Disponible",
          "archivo": metadata.name,
          "url": url,
          "size": metadata.size,
          "area": "Subido por paciente"
        });
      }
      
      return studies;
    } catch (e) {
      print("Error listing studies: $e");
      return [];
    }
  }
}
