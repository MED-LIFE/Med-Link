import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/receta_model.dart';

class RecetasRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Receta>> getRecetasStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    // Using root 'recetas' collection filtering by userId, matching firestore.rules
    return _db.collection('recetas')
        .where('userId', isEqualTo: user.uid)
        // .orderBy('fecha', descending: true) // Needs composite index, skipping order for now to avoid error
        .snapshots()
        .map((snapshot) {
           final list = snapshot.docs.map((doc) => Receta.fromFirestore(doc)).toList();
           // Sort in memory to avoid index requirement
           list.sort((a, b) => b.fecha.compareTo(a.fecha));
           return list;
        });
  }

  // Legacy/Unused but kept for reference if needed, now identical logic basically
  Stream<List<Receta>> getRecetasByUserIdStream() {
     return getRecetasStream();
  }

  Future<void> seedRecetasIfEmpty() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final ref = _db.collection('recetas');
    // Check if THIS user has recipes
    final snap = await ref.where('userId', isEqualTo: user.uid).limit(1).get();
    
    if (snap.docs.isEmpty) {
      print("Seeding Recetas for user ${user.uid}...");
      // Create some mock real data
      await ref.add({
        'userId': user.uid,
        'medicamento': 'Ibuprofeno 600mg',
        'medico': 'Dr. René Favaloro',
        'fecha': Timestamp.now(),
        'vencimiento': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'dosis': '1 cada 8hs',
        'duracion': '5 dias',
        'active': true, 
        'esValida': true,
      });
       await ref.add({
        'userId': user.uid,
        'medicamento': 'Amoxicilina 500mg',
        'medico': 'Dra. Cecilia Grierson',
        'fecha': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 60))),
        'vencimiento': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
        'dosis': '1 cada 12hs',
        'duracion': '7 dias',
        'active': false,
        'esValida': false,
      });
    }
  }
}
