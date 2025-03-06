#include <WiFi.h>
#include <FirebaseESP32.h>

// Configurar Wi-Fi
#define WIFI_SSID "TuSSID"
#define WIFI_PASSWORD "TuContraseña"

// Configurar Firebase
#define FIREBASE_HOST "https://tu-proyecto.firebaseio.com/"  // Realtime Database
#define FIREBASE_AUTH "Tu_Token"

// Inicializar Firebase
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
    Serial.begin(115200);  // UART principal
    Serial2.begin(9600);   // UART en ESP32 (RX2: GPIO16, TX2: GPIO17)
    
    // Conectar a Wi-Fi
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }
    Serial.println("\nConectado a WiFi");

    // Configurar Firebase
    config.api_key = FIREBASE_AUTH;
    config.database_url = FIREBASE_HOST;
    Firebase.begin(&config, &auth);
}

void loop() {
    if (Serial2.available()) {  // Si hay datos en UART
        String dato = Serial2.readStringUntil('\n');  // Leer hasta nueva línea
        Serial.print("Recibido: ");
        Serial.println(dato);
        
        // Enviar dato a Firebase
        if (Firebase.RTDB.pushString(&fbdo, "/uart/datos", dato)) {
            Serial.println("Dato enviado a Firebase");
        } else {
            Serial.println("Error: " + fbdo.errorReason());
        }
    }
}
