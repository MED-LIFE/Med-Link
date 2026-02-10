import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryRepository {
  static const Color primaryColor = Color(0xFF2376F6);
  static const Color secondaryColor = Color(0xFF73BFFF);
  static const Color accentColor = Color(0xFF4FE1F3);
  static const Color darkBlue = Color(0xFF193A72);
  static const Color mediumGray = Color(0xFF42506A);
  static const Color lightGray = Color(0xFFB6BFC9);
  static const Color backgroundColor = Color(0xFFF7FCFF);
  static const Color cardColor = Color(0xFFF1F8FE);
  
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Real Firestore Implementation ---

  // 1. Resumen / Datos Principales
  Stream<DocumentSnapshot> getPatientSummaryStream(String dni) {
    return _db.collection('pacientes').doc(dni).snapshots();
  }

  // 2. Diagnósticos
  Stream<List<Map<String, dynamic>>> getDiagnosticosStream(String dni) {
    return _db.collection('pacientes').doc(dni).collection('diagnosticos')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // 3. Medicamentos
  Stream<List<Map<String, dynamic>>> getMedicamentosStream(String dni) {
    return _db.collection('pacientes').doc(dni).collection('medicamentos')
      .where('activo', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // 4. Agregar Evolución
  Future<void> addEvolution(String dni, String text, String doctorName) async {
    // 1. Guardar en subcolección 'evoluciones' para historial
    await _db.collection('pacientes').doc(dni).collection('evoluciones').add({
      'fecha': Timestamp.now(),
      'texto': text,
      'medico': doctorName,
    });

    // 2. Actualizar el resumen en el doc principal (opcional, para tener lo último a mano)
    await _db.collection('pacientes').doc(dni).set({
      'resumen': text, // Actualizamos el resumen con la última evolución p/ simplicidad actual
      'ultima_actualizacion': Timestamp.now()
    }, SetOptions(merge: true));
  }

  // --- Seed Mock Data (Helper to init DB if empty) ---
  Future<void> seedPatientDataIfNeeded(String dni) async {
    final docRef = _db.collection('pacientes').doc(dni);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Create Base Doc
      await docRef.set({
        'resumen': 'Paciente ingresado recientemente. Sin antecedentes cargados.',
        'creado_el': Timestamp.now(),
      });

      // Seed Diagnostico
      await docRef.collection('diagnosticos').add({
        'nombre': 'Control Inicial',
        'codigo': 'Z00.0',
        'severidad': 'Leve',
        'fecha': Timestamp.now(),
      });
      
      // Seed Medicamento
      await docRef.collection('medicamentos').add({
        'nombre': 'Ibuprofeno 400mg',
        'indicacion': 'SOS Dolor',
        'activo': true,
      });
    }
  }

  // Rutas de assets
  static const String bannerImagePath = 'assets/images/historia_clinica.png';
  static const String defaultIllustracion = 'assets/images/ilustracion_historia_clinica.png';

  // Datos mock mejorados
  static const List<Map<String, dynamic>> diagnosticosMock = [
    {
      "codigo": "I10",
      "nombre": "Hipertensión arterial esencial",
      "descripcion": "Elevación persistente de la presión arterial. Requiere control regular, adherencia a medicación y cambios en el estilo de vida.",
      "fechaDiagnostico": "15/03/2024",
      "medico": "Dr. Fernández",
      "severidad": "Moderada",
      "estado": "Activo",
      "indicadores": {
        "presionUltima": "142/92 mmHg",
        "riesgoCardiovascular": "Moderado",
        "ultimaMejora": "-5 mmHg"
      }
    },
    {
      "codigo": "E11",
      "nombre": "Diabetes mellitus tipo 2",
      "descripcion": "Diabetes tipo 2 con buen control glucémico mediante medicación y dieta.",
      "fechaDiagnostico": "22/08/2023",
      "medico": "Dra. González",
      "severidad": "Leve",
      "estado": "Controlado",
      "indicadores": {
        "glucemiaUltima": "126 mg/dl",
        "hba1c": "6.8%",
        "ultimaMejora": "-0.3% HbA1c"
      }
    }
  ];

  static const List<Map<String, dynamic>> turnosMock = [
    {
      "fecha": "10 de agosto, 2025",
      "profesional": "Dra. Pérez",
      "estado": "Realizado",
      "hora": "10:00 AM",
      "especialidad": "Clínica médica",
      "motivo": "Control rutinario",
      "consultorio": "1A",
      "observaciones": "Paciente concurrió puntualmente. Control satisfactorio."
    },
    {
      "fecha": "05 de julio, 2025",
      "profesional": "Dra. Gómez",
      "estado": "Ausente",
      "hora": "09:00 AM",
      "especialidad": "Cardiología",
      "motivo": "Control cardiológico",
      "consultorio": "2B",
      "observaciones": "Paciente no se presentó sin aviso previo."
    },
    {
      "fecha": "20 de junio, 2025",
      "profesional": "Dr. Ledesma",
      "estado": "Realizado",
      "hora": "11:30 AM",
      "especialidad": "Cardiología",
      "motivo": "Seguimiento hipertensión",
      "consultorio": "2A",
      "observaciones": "Excelente evolución. Continuar tratamiento actual."
    },
    {
      "fecha": "15 de agosto, 2025",
      "profesional": "Dr. Russo",
      "estado": "Próximo",
      "hora": "14:00 PM",
      "especialidad": "Clínica médica",
      "motivo": "Control trimestral",
      "consultorio": "1C",
      "observaciones": "Turno confirmado. Traer estudios recientes."
    }
  ];

  static const List<Map<String, dynamic>> medicamentosMock = [
    {
      "nombre": "Losartán 50mg",
      "principioActivo": "Losartán potásico",
      "indicacion": "1 comp. cada 12 hs",
      "viaAdministracion": "Oral",
      "fechaInicio": "15/03/2024",
      "fechaVencimiento": "15/03/2025",
      "medico": "Dr. Fernández",
      "pedidos": 7,
      "ordenes": 2,
      "categoria": "Antihipertensivo",
      "alertas": [],
      "activo": true
    },
    {
      "nombre": "Enalapril 10mg",
      "principioActivo": "Enalapril maleato",
      "indicacion": "1 comp. por la mañana",
      "viaAdministracion": "Oral",
      "fechaInicio": "22/08/2023",
      "fechaVencimiento": "22/08/2025",
      "medico": "Dra. González",
      "pedidos": 5,
      "ordenes": 1,
      "categoria": "IECA",
      "alertas": ["Controlar función renal"],
      "activo": true
    },
    {
      "nombre": "Metformina 850mg",
      "principioActivo": "Metformina clorhidrato",
      "indicacion": "1 comp. cada 12 hs con las comidas",
      "viaAdministracion": "Oral",
      "fechaInicio": "22/08/2023",
      "fechaVencimiento": "22/08/2025",
      "medico": "Dra. González",
      "pedidos": 8,
      "ordenes": 3,
      "categoria": "Antidiabético",
      "alertas": [],
      "activo": true
    }
  ];

  static const List<Map<String, dynamic>> signosVitalesMock = [
    {
      "fecha": "10/08/2025",
      "presionSistolica": 138,
      "presionDiastolica": 88,
      "frecuenciaCardiaca": 72,
      "temperatura": 36.5,
      "peso": 78.5,
      "altura": 170,
      "saturacionOxigeno": 98,
      "glucemia": 124
    },
    {
      "fecha": "05/07/2025",
      "presionSistolica": 142,
      "presionDiastolica": 92,
      "frecuenciaCardiaca": 76,
      "temperatura": 36.8,
      "peso": 79.2,
      "altura": 170,
      "saturacionOxigeno": 97,
      "glucemia": 132
    }
  ];
}

