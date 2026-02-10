class MedicalHistoryModel {
  final String dni;
  final String centro;
  final String edad;
  final String proximaCita;
  final String fechaActualizacion;
  final String resumen;
  final String diagnostico;
  final String medicamentos;
  final Map<String, dynamic> datosCompletos;

  MedicalHistoryModel({
    required this.dni,
    required this.centro,
    required this.edad,
    required this.proximaCita,
    required this.fechaActualizacion,
    required this.resumen,
    required this.diagnostico,
    required this.medicamentos,
    required this.datosCompletos,
  });

  factory MedicalHistoryModel.fromMap(Map<String, dynamic> data) {
    return MedicalHistoryModel(
      dni: data['dni'] ?? '-',
      centro: data['centro'] ?? 'Centro Médico',
      edad: data['edad']?.toString() ?? '-',
      proximaCita: data['proxima_cita'] ?? 'Sin datos',
      fechaActualizacion: data['fecha_actualizacion'] ?? '--/--/----',
      resumen: data['resumen'] ?? "Sin datos de resumen.",
      diagnostico: data['diagnostico'] ?? "Sin diagnóstico principal.",
      medicamentos: data['medicamentos'] ?? "Sin medicación activa.",
      datosCompletos: data,
    );
  }
}
