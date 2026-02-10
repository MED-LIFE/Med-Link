import 'package:cloud_firestore/cloud_firestore.dart';

class Receta {
  final String id;
  final String medicamento;
  final String medico;
  final DateTime fecha;
  final DateTime? vencimiento;
  final String dosis;
  final String duracion;
  final bool activo;

  Receta({
    required this.id,
    required this.medicamento,
    required this.medico,
    required this.fecha,
    this.vencimiento,
    this.dosis = "",
    this.duracion = "",
    this.activo = true,
  });

  factory Receta.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Receta(
      id: doc.id,
      medicamento: data['medicamento'] ?? 'Desconocido',
      medico: data['medico'] ?? 'Desconocido',
      fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vencimiento: (data['vencimiento'] as Timestamp?)?.toDate(),
      dosis: data['dosis'] ?? '',
      duracion: data['duracion'] ?? '',
      activo: data['activo'] ?? true,
    );
  }

  bool get esValida {
    if (!activo) return false;
    if (vencimiento != null && vencimiento!.isBefore(DateTime.now())) return false;
    return true;
  }
}
