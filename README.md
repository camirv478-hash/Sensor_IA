# SensorIA 

Sistema inteligente de reciclaje con clasificación por IA y control automático de canecas.

## Tecnologías
- **Flutter** → App móvil (Android)
- **Django REST Framework** → Backend y API
- **PostgreSQL** → Base de datos
- **TensorFlow Lite** → Clasificación offline de residuos
- **Gemini AI** → Chatbot ecológico
- **ESP32 + Arduino** → Control físico de canecas con servos
- **HTTP/WiFi** → Comunicación app ↔ ESP32

## Arquitectura

[App Flutter] ──HTTP──> [ESP32] ──> [Servos/Canecas]
│
└──HTTP──> [Backend Django] ──> [PostgreSQL]
│
└──> [IA TFLite / Gemini]

## Estructura del proyecto

Sensor_IA/
├── frontend/     → App Flutter (Android)
├── backend/      → API Django + IA
├── ml_models/    → Modelos de machine learning
├── firmware/     → Código ESP32 (Arduino IDE)
└── README.md

## Cómo correr el proyecto en caso de linux 

### Base de datos

sudo systemctl start postgresql


### Backend

cd backend
source venv/bin/activate
python manage.py runserver 0.0.0.0:8000


### Frontend

cd frontend
flutter run

### Firmware ESP32
1. Abrir `firmware/canecas_servo/canecas_servo.ino` en Arduino IDE
2. Cambiar `WIFI_SSID` y `WIFI_PASSWORD`
3. Subir al ESP32
4. Copiar la IP del monitor serial a la app

## Librerías ESP32 necesarias
- `ESP32Servo` → Gestor de librerías de Arduino IDE
- `WiFi` → Incluida en el core ESP32
- `WebServer` → Incluida en el core ESP32