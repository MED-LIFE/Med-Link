import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/orden_medica_model.dart';

class OrdenesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de órdenes médicas pendientes para el usuario actual
  Stream<List<OrdenMedica>> getOrdenesStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db.collection('pacientes')
      .doc(user.uid)
      .collection('ordenes_medicas')
      .orderBy('fecha', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => OrdenMedica.fromFirestore(doc.data(), doc.id)).toList());
  }

  // Seed Data (mock inicial)
  Future<void> seedData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final collection = _db.collection('pacientes').doc(user.uid).collection('ordenes_medicas');
    final snap = await collection.limit(1).get();
    
    if (snap.docs.isEmpty) {
      final List<Map<String, dynamic>> initialData = [
        {
          "tipo": "Tomografía computada",
          "fecha": Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
          "estado": "Turno asignado",
          "profesional": "Dra. Gómez",
          "area": "Imágenes",
          "lugar": "Av. Córdoba 5550, 2° piso",
          "hora": "08:30",
          "notas": "Ayuno de 6hs.",
        },
        {
          "tipo": "Glucemia en ayunas",
          "fecha": Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
          "estado": "Pendiente de autorización",
          "profesional": "Dr. Fernández",
          "area": "Laboratorio",
          "notas": "Solicitado, aguarda aprobación.",
        },
      ];

      for (var map in initialData) {
         await collection.add(map);
      }
    }
  }
}
