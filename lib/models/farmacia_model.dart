class Farmacia {
  final String id;
  final String nombre;
  final String direccion;
  final String barrio;
  final double x; // Coordenada X relativa (0.0 - 1.0) para mapa simulado
  final double y; // Coordenada Y relativa (0.0 - 1.0) para mapa simulado
  final String horario;
  final String telefono;
  final List<String> servicios;
  final bool turno;
  final bool isOpen;

  Farmacia({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.barrio,
    required this.x,
    required this.y,
    required this.horario,
    required this.telefono,
    required this.servicios,
    required this.turno,
    required this.isOpen,
  });

  factory Farmacia.fromFirestore(Map<String, dynamic> map, String id) {
    return Farmacia(
      id: id,
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      barrio: map['barrio'] ?? '',
      x: (map['x'] ?? 0.0).toDouble(),
      y: (map['y'] ?? 0.0).toDouble(),
      horario: map['horario'] ?? '',
      telefono: map['telefono'] ?? '',
      servicios: List<String>.from(map['servicios'] ?? []),
      turno: map['turno'] ?? false,
      isOpen: map['isOpen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'barrio': barrio,
      'x': x,
      'y': y,
      'horario': horario,
      'telefono': telefono,
      'servicios': servicios,
      'turno': turno,
      'isOpen': isOpen,
    };
  }
}
