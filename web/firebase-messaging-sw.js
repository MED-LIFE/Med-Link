importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyD...", // Placeholder, will inherit from standard config execution context usually or needs explicit simple config here
    authDomain: "medlinkapp-d7030.firebaseapp.com",
    projectId: "medlinkapp-d7030",
    storageBucket: "medlinkapp-d7030.appspot.com",
    messagingSenderId: "955637915614",
    appId: "1:955637915614:web:..."
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/icons/Icon-192.png'
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});
