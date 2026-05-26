#include <WiFi.h>
#include <WebServer.h>
#include <ESP32Servo.h>

// ── Credenciales WiFi ──────────────────────────────
#define WIFI_SSID     "Tu_red"
#define WIFI_PASSWORD "tu_contraseña"

// ── Pines servos ───────────────────────────────────
#define PIN_SERVO_VERDE  4   // GPIO4 → caneca orgánicos------------
#define PIN_SERVO_AZUL   5    // GPIO5  → caneca reciclables----------NUMEROS DE LOS PINES GPIO DEL ESP32, NO LOS DE LOS SERVOS
#define PIN_SERVO_GRIS   14  // GPIO14 → caneca no aprovechable-----

// ── Configuración servos ───────────────────────────
#define ANGULO_ABIERTO  90
#define ANGULO_CERRADO  0
#define TIEMPO_ABIERTO  5000  // ms que permanece abierta

// ── Objetos ────────────────────────────────────────
Servo servoVerde;
Servo servoAzul;
Servo servoGris;
WebServer server(80);  // servidor en puerto 80

// ── Función abrir caneca ───────────────────────────
void abrirCaneca(Servo &servo, String nombre) {
  Serial.println("Abriendo caneca: " + nombre);
  servo.write(ANGULO_ABIERTO);
  delay(TIEMPO_ABIERTO);
  servo.write(ANGULO_CERRADO);
  Serial.println("Caneca cerrada: " + nombre);
}

// ── Manejadores de rutas HTTP ──────────────────────
void handleVerde() {
  abrirCaneca(servoVerde, "VERDE - Organicos");
  server.send(200, "text/plain", "Caneca verde abierta");
}

void handleAzul() {
  abrirCaneca(servoAzul, "AZUL - Reciclables");
  server.send(200, "text/plain", "Caneca azul abierta");
}

void handleGris() {
  abrirCaneca(servoGris, "GRIS - No aprovechable");
  server.send(200, "text/plain", "Caneca gris abierta");
}

void handleRoot() {
  // Página de prueba desde el navegador
  String html = "<h2>Sistema de Canecas</h2>";
  html += "<p><a href='/verde'>Abrir VERDE (Organicos)</a></p>";
  html += "<p><a href='/azul'>Abrir AZUL (Reciclables)</a></p>";
  html += "<p><a href='/gris'>Abrir GRIS (No aprovechable)</a></p>";
  server.send(200, "text/html", html);
}

void handleNotFound() {
  server.send(404, "text/plain", "Ruta no encontrada");
}

// ── Setup ──────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  Serial.println("");
  Serial.println("=== Sistema de Canecas Iniciando ===");

  // Conectar servos
  servoVerde.attach(PIN_SERVO_VERDE);
  servoAzul.attach(PIN_SERVO_AZUL);
  servoGris.attach(PIN_SERVO_GRIS);

  // Cerrar todas las tapas al inicio
  servoVerde.write(ANGULO_CERRADO);
  servoAzul.write(ANGULO_CERRADO);
  servoGris.write(ANGULO_CERRADO);
  Serial.println("Tapas en posicion cerrada");

  // Conectar al WiFi
  Serial.print("Conectando a WiFi: ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi conectado");
  Serial.print("IP del ESP: ");
  Serial.println(WiFi.localIP());
  Serial.println("Copia esa IP y prueba en el navegador");

  // Definir rutas del servidor
  server.on("/",      handleRoot);
  server.on("/verde", handleVerde);
  server.on("/azul",  handleAzul);
  server.on("/gris",  handleGris);
  server.onNotFound(handleNotFound);

  // Iniciar servidor
  server.begin();
  Serial.println("Servidor HTTP iniciado");
  Serial.println("====================================");
}

// ── Loop ───────────────────────────────────────────
void loop() {
  server.handleClient();  // escucha peticiones entrantes
}