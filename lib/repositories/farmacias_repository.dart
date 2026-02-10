import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/farmacia_model.dart';

class FarmaciasRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream de farmacias (realtime)
  Stream<List<Farmacia>> getFarmaciasStream() {
    return _db.collection('farmacias')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Farmacia.fromFirestore(doc.data(), doc.id)).toList());
  }

  // Seed Data
  Future<void> seedData() async {
    final snap = await _db.collection('farmacias').get();
    
    // STRICT RESEED: If count is not EXACTLY 24 (the new full set), wipe and re-seed.
    bool needsSeeding = snap.docs.length != 24;
    
    // Also check for partial corruption if count matches (unlikely but safe)
    if (!needsSeeding) {
       for (var doc in snap.docs) {
          if (!doc.data().containsKey('barrio')) {
             needsSeeding = true;
             break;
          }
       }
    }

    if (needsSeeding) {
      print("Seeding/Reseeding Farmacias (Target: 20+ items)...");
      
      // Clear existing to ensure clean slate
      for (var doc in snap.docs) {
         await doc.reference.delete();
      }

      final List<Map<String, dynamic>> initialData = [
        // --- EXISTING / CORE ---
        {
          "nombre": "Farmacia Roffo Central",
          "direccion": "Av. San Martín 5481",
          "barrio": "Agronomía",
          "x": 0.35, "y": 0.45,
          "horario": "Abierto 24hs",
          "telefono": "011 4502-0000",
          "servicios": ["Vacunatorio", "Gabinete", "Perfumería"],
          "turno": true,
          "isOpen": true,
        },
        {
          "nombre": "Farmacity Nazca",
          "direccion": "Av. Nazca 3100",
          "barrio": "Villa del Parque",
          "x": 0.25, "y": 0.48,
          "horario": "Cierra a las 22:00",
          "telefono": "0800-666-4321",
          "servicios": ["Cajeros automáticos", "Cosmética", "Alimentos"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Azul",
          "direccion": "Cuenca 2800",
          "barrio": "Villa del Parque",
          "x": 0.28, "y": 0.52,
          "horario": "Cerrado",
          "telefono": "011 4503-4444",
          "servicios": ["Recetas magistrales"],
          "turno": false,
          "isOpen": false,
        },
         {
          "nombre": "Farmacia Social",
          "direccion": "Av. Beiró 4500",
          "barrio": "Devoto",
          "x": 0.15, "y": 0.40,
          "horario": "Abierto hasta 20:00",
          "telefono": "011 4501-2222",
          "servicios": ["PAMI", "IOMA"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Dr. Ahorro",
          "direccion": "Av. San Martín 2300",
          "barrio": "Paternal",
          "x": 0.45, "y": 0.55,
          "horario": "Abierto hasta 21:00",
          "telefono": "011 4581-9999",
          "servicios": ["Genéricos", "Ofertas"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia TKL",
          "direccion": "Av. Cabildo 2040",
          "barrio": "Belgrano",
          "x": 0.55, "y": 0.20,
          "horario": "Abierto 24hs",
          "telefono": "011 4781-5555",
          "servicios": ["Dermocosmética", "Atención 24hs"],
          "turno": true,
          "isOpen": true,
        },
        {
          "nombre": "OpenPharma",
          "direccion": "Av. Corrientes 5100",
          "barrio": "Villa Crespo",
          "x": 0.50, "y": 0.45,
          "horario": "Abierto hasta 23:00",
          "telefono": "011 4855-6666",
          "servicios": ["Envíos a domicilio", "Perfumería"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Vilela",
          "direccion": "Av. Congreso 3000",
          "barrio": "Coghlan",
          "x": 0.48, "y": 0.15,
          "horario": "Cierra a las 20:30",
          "telefono": "011 4545-7777",
          "servicios": ["Obras Sociales", "Atención Seniors"],
          "turno": false,
          "isOpen": true,
        },

        // --- NEW EXPANSION (20+ Total) ---
        {
          "nombre": "Farmacia Rex Palermo",
          "direccion": "Av. Santa Fe 3200",
          "barrio": "Palermo",
          "x": 0.60, "y": 0.35,
          "horario": "Abierto 24hs",
          "telefono": "011 4821-1111",
          "servicios": ["Perfumería", "Dermocosmética", "Vacunatorio"],
          "turno": true,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Suiza",
          "direccion": "Av. Callao 1500",
          "barrio": "Recoleta",
          "x": 0.65, "y": 0.40,
          "horario": "Abierto hasta 22:00",
          "telefono": "011 4801-2222",
          "servicios": ["Importados", "Atención VIP"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Del Pueblo",
          "direccion": "Av. Rivadavia 5000",
          "barrio": "Caballito",
          "x": 0.30, "y": 0.60,
          "horario": "Abierto 24hs",
          "telefono": "011 4901-3333",
          "servicios": ["PAMI", "Diabetes Center"],
          "turno": true,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Nueva Flores",
          "direccion": "Av. Juan B. Justo 6000",
          "barrio": "Flores",
          "x": 0.20, "y": 0.65,
          "horario": "Cierra a las 20:00",
          "telefono": "011 4601-4444",
          "servicios": ["Homeopatía", "Recetas"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Liniers Express",
          "direccion": "Av. Rivadavia 11000",
          "barrio": "Liniers",
          "x": 0.05, "y": 0.70,
          "horario": "Abierto 24hs",
          "telefono": "011 4651-5555",
          "servicios": ["Envíos GBA", "Vacunatorio"],
          "turno": true,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Saavedra",
          "direccion": "Av. Balbín 4000",
          "barrio": "Saavedra",
          "x": 0.35, "y": 0.10,
          "horario": "Cierra a las 21:00",
          "telefono": "011 4542-6666",
          "servicios": ["Nutrición", "Deportes"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Nuñez Norte",
          "direccion": "Av. Cabildo 3500",
          "barrio": "Nuñez",
          "x": 0.50, "y": 0.10,
          "horario": "Abierto hasta 23:00",
          "telefono": "011 4701-7777",
          "servicios": ["Perfumería", "Regalos"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Urquiza",
          "direccion": "Av. Triunvirato 4500",
          "barrio": "Villa Urquiza",
          "x": 0.25, "y": 0.25,
          "horario": "Abierto 24hs",
          "telefono": "011 4521-8888",
          "servicios": ["Vacunatorio", "PAMI"],
          "turno": true,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Colegiales",
          "direccion": "Av. Lacroze 2500",
          "barrio": "Colegiales",
          "x": 0.40, "y": 0.30,
          "horario": "Cierra a las 20:30",
          "telefono": "011 4551-9999",
          "servicios": ["Atención Pediátrica"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Chacarita",
          "direccion": "Av. Corrientes 6000",
          "barrio": "Chacarita",
          "x": 0.45, "y": 0.40,
          "horario": "Abierto 24hs",
          "telefono": "011 4851-0000",
          "servicios": ["Envíos Rápidos"],
          "turno": true,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Almagro",
          "direccion": "Av. Medrano 400",
          "barrio": "Almagro",
          "x": 0.55, "y": 0.55,
          "horario": "Cierra a las 21:00",
          "telefono": "011 4981-1111",
          "servicios": ["Ortopedia"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Boedo Sur",
          "direccion": "Av. Boedo 800",
          "barrio": "Boedo",
          "x": 0.60, "y": 0.65,
          "horario": "Cierra a las 20:00",
          "telefono": "011 4931-2222",
          "servicios": ["Homeopatía"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia San Telmo",
          "direccion": "Av. Paseo Colón 1000",
          "barrio": "San Telmo",
          "x": 0.75, "y": 0.70,
          "horario": "Abierto hasta 22:00",
          "telefono": "011 4301-3333",
          "servicios": ["Turismo", "Primeros Auxilios"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Centro 24",
          "direccion": "Av. Corrientes 800",
          "barrio": "Microcentro",
          "x": 0.80, "y": 0.50,
          "horario": "Abierto 24hs",
          "telefono": "011 4321-4444",
          "servicios": ["Empresas", "Envíos"],
          "turno": true,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Puerto Madero",
          "direccion": "Juana Manso 1500",
          "barrio": "Puerto Madero",
          "x": 0.90, "y": 0.60,
          "horario": "Abierto hasta 23:00",
          "telefono": "011 4311-5555",
          "servicios": ["Premium", "Importados"],
          "turno": false,
          "isOpen": true,
        },
        {
          "nombre": "Farmacia Retiro",
          "direccion": "Av. Libertador 100",
          "barrio": "Retiro",
          "x": 0.70, "y": 0.30,
          "horario": "Cierra a las 21:00",
          "telefono": "011 4312-6666",
          "servicios": ["Viajeros"],
          "turno": false,
          "isOpen": true,
        }
      ];

      final batch = _db.batch();
      for (var map in initialData) {
         final ref = _db.collection('farmacias').doc();
         batch.set(ref, map);
      }
      await batch.commit();
    }
  }
}
