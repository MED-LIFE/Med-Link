import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/agenda_item_model.dart';
import 'dart:math';

class MedicoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de la agenda (realtime)
  Stream<List<AgendaItem>> getAgendaStream() {
    return _db.collection('agenda')
      .orderBy('hora')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => AgendaItem.fromFirestore((doc.data() as Map<String, dynamic>)..['id'] = doc.id)).toList());
  }

  // Fetch initial agenda (One-time future)
  Future<List<AgendaItem>> getInitialAgenda() async {
    final snapshot = await _db.collection('agenda').orderBy('hora').get();
    return snapshot.docs.map((doc) => AgendaItem.fromFirestore((doc.data() as Map<String, dynamic>)..['id'] = doc.id)).toList();
  }

  // Stream de turnos disponibles para el Paciente
  Stream<List<AgendaItem>> getAvailableTurnsStream() {
    return _db.collection('agenda')
      .where('estado', isEqualTo: 'disponible')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => AgendaItem.fromFirestore((doc.data() as Map<String, dynamic>)..['id'] = doc.id)).toList());
  }

  // Reservar Turno
  Future<void> reserveTurno(String turnoId, String specialty) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuario no logueado");

    String userName = user.displayName ?? "Paciente App";
    
    // We update the existing 'disponible' slot to be 'confirmado' (or 'pendiente')
    // and assign it to the current user.
    await _db.collection('agenda').doc(turnoId).update({
      'estado': 'confirmado', // Auto-confirm for this demo
      'paciente': userName,
      'dni': '12.345.678', // Mock/Placeholder DNI until we pull from profile
      'motivo': "Consulta $specialty",
      'reserva_uid': user.uid,
      'img': 'assets/images/user_placeholder.png' // Assign default or user image
    });
  }

  // Add new patient / Slot
  Future<void> addNewPatient(AgendaItem item) async {
    await _db.collection('agenda').doc(item.id.isNotEmpty ? item.id : null).set(item.toMap());
  }

  // Stream de Mis Turnos (para el paciente logueado)
  Stream<List<AgendaItem>> getMyAppointmentsStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    
    // NOTE: Requires composite index if we mix where() and orderBy().
    // For now, we filter by uid and sort in memory to avoid breaking the app if index is missing.
    return _db.collection('agenda')
      .where('reserva_uid', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
         final list = snapshot.docs.map((doc) => AgendaItem.fromFirestore((doc.data() as Map<String, dynamic>)..['id'] = doc.id)).toList();
         list.sort((a, b) => a.hora.compareTo(b.hora)); 
         return list;
      });
  }

  // Seed Data (solo si está vacía)
  Future<void> seedData() async {
    final snap = await _db.collection('agenda').limit(1).get();
    if (snap.docs.isEmpty) {
      final List<Map<String, dynamic>> initialData = [];

      // 1. Existing Appointments (examples)
      initialData.add({
          'hora': '09:00', 'paciente': 'Juan Pérez', 'dni': '33.123.456', 'age': 45, 
          'motivo': 'Control post-operatorio', 'estado': 'en_consultorio', 
          'img': 'assets/images/patient_1.png', 'doctor': 'Dr. René Favaloro', 'specialty': 'Cardiología'
      });
      initialData.add({
          'hora': '09:30', 'paciente': 'María González', 'dni': '28.987.654', 'age': 32, 
          'motivo': 'Primera consulta', 'estado': 'en_sala', 
          'img': 'assets/images/patient_2.png', 'doctor': 'Dr. René Favaloro', 'specialty': 'Cardiología'
      });

      // 2. Generate 5 Doctors with 15 slots each
      final doctors = [
        {'name': 'Dr. René Favaloro', 'spec': 'Cardiología'},
        {'name': 'Dra. Cecilia Grierson', 'spec': 'Clínica médica'},
        {'name': 'Dr. Salvador Mazza', 'spec': 'Traumatología'},
        {'name': 'Dra. Julieta Lanteri', 'spec': 'Ginecología'},
        {'name': 'Dr. Ramón Carrillo', 'spec': 'Neurología'},
      ];

      final startHour = 10; // Start at 10:00 AM

      for (var doc in doctors) {
        for (int i = 0; i < 15; i++) {
          final hour = startHour + (i ~/ 2); // Every 2 slots = 1 hour
          final minute = (i % 2) * 30; // 00 or 30
          final timeStr = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
          
          initialData.add({
            'hora': timeStr,
            'paciente': 'DISPONIBLE',
            'dni': '',
            'age': 0,
            'motivo': '',
            'estado': 'disponible',
            'img': '',
            'doctor': doc['name'],
            'specialty': doc['spec']
          });
        }
      }

      // Batch write for performance
      final batch = _db.batch();
      for (var map in initialData) {
         final ref = _db.collection('agenda').doc();
         batch.set(ref, map);
      }
      await batch.commit();
    }
  }
}
