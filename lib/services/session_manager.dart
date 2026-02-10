import 'package:flutter/foundation.dart';

/// Singleton to manage session state (Avatar, Turns, etc.)
/// This persists data in memory while the app runs, solving the issue of data being lost on navigation pops.
class SessionManager extends ChangeNotifier {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  // --- AVATAR STATE ---
  String? _avatarPath;
  String? get avatarPath => _avatarPath;

  void updateAvatar(String path) {
    _avatarPath = path;
    notifyListeners();
  }

  // --- TURNS STATE ---
  // Initial Mock Data
  List<Map<String, String>> _availableTurns = [
    {
      "id": "1",
      "fecha": "Martes 13/08",
      "hora": "09:30",
      "profesional": "Dra. Pérez (Clínica)",
      "doctor": "Dra. Laura Pérez",
      "image": "assets/images/doctors/doctor_1.png",
    },
    {
      "id": "2",
      "fecha": "Martes 13/08",
      "hora": "10:00",
      "profesional": "Dra. Pérez (Clínica)",
      "doctor": "Dra. Laura Pérez",
      "image": "assets/images/doctors/doctor_1.png",
    },
    {
      "id": "3",
      "fecha": "Miércoles 14/08",
      "hora": "12:00",
      "profesional": "Dr. Rossi (Cirugía)",
      "doctor": "Dr. Miguel Ángel Rossi",
      "image": "assets/images/doctors/doctor_2.png",
    },
    {
      "id": "4",
      "fecha": "Jueves 15/08",
      "hora": "14:30",
      "profesional": "Dr. Rossi (Cirugía)",
      "doctor": "Dr. Miguel Ángel Rossi",
      "image": "assets/images/doctors/doctor_2.png",
    },
    {
       "id": "5",
      "fecha": "Viernes 16/08",
      "hora": "11:00",
      "profesional": "Dra. Martínez (Dermatología)",
      "doctor": "Dra. Sofía Martínez",
      "image": "assets/images/doctors/doctor_3.png",
    },
  ];

  List<Map<String, String>> get availableTurns => List.unmodifiable(_availableTurns);

  void confirmTurn(String turnId) {
    _availableTurns.removeWhere((turn) => turn['id'] == turnId);
    notifyListeners();
  }
}
