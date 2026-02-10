class AgendaItem {
  final String id;
  final String hora;
  final String paciente;
  final String dni;
  final int age;
  final String motivo;
  final String estado; // 'atendido', 'en_consultorio', 'en_sala', 'confirmado', 'pendiente', 'disponible', 'bloqueado'
  final String img;
  final bool prioridad;
  final String doctor; // New field
  final String specialty; // New field

  AgendaItem({
    required this.id,
    required this.hora,
    required this.paciente,
    required this.dni,
    required this.age,
    required this.motivo,
    required this.estado,
    required this.img,
    this.prioridad = false,
    this.doctor = '', // Default empty if not present
    this.specialty = '', // Default empty if not present
  });

  factory AgendaItem.fromFirestore(Map<String, dynamic> map) {
    return AgendaItem(
      id: map['id'] ?? '0',
      hora: map['hora'] ?? '',
      paciente: map['paciente'] ?? 'Desconocido',
      dni: map['dni'] ?? '',
      age: map['age'] ?? 0,
      motivo: map['motivo'] ?? '',
      estado: map['estado'] ?? 'pendiente',
      img: map['img'] ?? 'assets/images/user_placeholder.png',
      prioridad: map['prioridad'] ?? false,
      doctor: map['doctor'] ?? '',
      specialty: map['specialty'] ?? '',
    );
  }

  // Alias for legacy support if needed, but prefer fromFirestore for semantics
  factory AgendaItem.fromMap(Map<String, dynamic> map) => AgendaItem.fromFirestore(map);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hora': hora,
      'paciente': paciente,
      'dni': dni,
      'age': age,
      'motivo': motivo,
      'estado': estado,
      'img': img,
      'prioridad': prioridad,
      'doctor': doctor,
      'specialty': specialty,
    };
  }
}
