import 'package:cloud_firestore/cloud_firestore.dart';

class OrdenMedica {
  final String id;
  final String tipo; // e.g., 'Tomografía computada', 'Laboratorio'
  final DateTime fecha; // Fecha de solicitud
  final String estado; // 'Turno asignado', 'Pendiente de autorización', 'Solicitado'
  final String profesional;
  final String area;
  final String? lugar;
  final String? hora;
  final String? notas;

  OrdenMedica({
    required this.id,
    required this.tipo,
    required this.fecha,
    required this.estado,
    required this.profesional,
    required this.area,
    this.lugar,
    this.hora,
    this.notas,
  });

  factory OrdenMedica.fromFirestore(Map<String, dynamic> map, String id) {
    return OrdenMedica(
      id: id,
      tipo: map['tipo'] ?? '',
      fecha: (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: map['estado'] ?? 'Solicitado',
      profesional: map['profesional'] ?? '',
      area: map['area'] ?? '',
      lugar: map['lugar'],
      hora: map['hora'],
      notas: map['notas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'fecha': Timestamp.fromDate(fecha),
      'estado': estado,
      'profesional': profesional,
      'area': area,
      'lugar': lugar,
      'hora': hora,
      'notas': notas,
    };
  }
}
