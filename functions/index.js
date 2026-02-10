/**
 * BACKEND LOGIC (Cloud Functions for Firebase)
 * 
 * Este archivo demuestra cómo se envían notificaciones Push automáticas
 * desde el servidor de Google cuando ocurren eventos en la base de datos.
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// 1. TRIGGER: Nuevo Turno Asignado
// Escucha cuando se crea un documento en la colección 'turnos'
exports.onNewTurno = functions.firestore
    .document('turnos/{turnoId}')
    .onCreate(async (snapshot, context) => {
        const turno = snapshot.data();
        const pacienteId = turno.pacienteId;

        // Obtener Token del Paciente
        const userDoc = await admin.firestore().collection('users').doc(pacienteId).get();
        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) {
            console.log("El usuario no tiene Token Push");
            return;
        }

        // Configurar Notificación
        const payload = {
            notification: {
                title: '¡Turno Confirmado!',
                body: `Tenés un turno con ${turno.medico} el ${turno.fecha}.`,
                sound: 'default'
            },
            data: {
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                screen: '/mis_turnos'
            }
        };

        // Enviar a Google (FCM)
        return admin.messaging().sendToDevice(fcmToken, payload);
    });

// 2. TRIGGER: Resultado Disponible
exports.onNewResult = functions.firestore
    .document('estudios/{estudioId}')
    .onUpdate(async (change, context) => {
        const newValue = change.after.data();
        const oldValue = change.before.data();

        // Solo notificar si cambió a "Disponible"
        if (newValue.estado === 'Disponible' && oldValue.estado !== 'Disponible') {
            const userDoc = await admin.firestore().collection('users').doc(newValue.pacienteId).get();
            const fcmToken = userDoc.data().fcmToken;

            if (fcmToken) {
                await admin.messaging().sendToDevice(fcmToken, {
                    notification: {
                        title: 'Resultado Disponible',
                        body: `Tu ${newValue.tipo} ya está listo para ver en la app.`
                    }
                });
            }
        }
    });
