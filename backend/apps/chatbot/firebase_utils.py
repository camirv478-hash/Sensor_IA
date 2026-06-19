import os
import json
import firebase_admin
from firebase_admin import credentials, auth
from rest_framework import authentication, exceptions
from django.contrib.auth import get_user_model
from pathlib import Path

User = get_user_model()

# =====================================================================
# INICIALIZACIÓN HÍBRIDA DE FIREBASE (PRODUCCIÓN & LOCAL)
# =====================================================================
firebase_app = None

# 1. Intentar leer desde las variables de entorno de Render
firebase_creds_env = os.environ.get('FIREBASE_CREDENTIALS')

if firebase_creds_env:
    try:
        # Cargamos el string JSON de la variable de entorno
        creds_dict = json.loads(firebase_creds_env)
        cred = credentials.Certificate(creds_dict)
        firebase_app = firebase_admin.initialize_app(cred)
        print("✅ Firebase Admin inicializado correctamente desde variables de entorno")
    except Exception as e:
        print(f"⚠️ Error al parsear FIREBASE_CREDENTIALS desde entorno: {e}")
else:
    # 2. Si no hay variable, cae al método local con el archivo físico
    BASE_DIR = Path(__file__).resolve().parent.parent.parent
    CRED_PATH = BASE_DIR / 'credentials' / 'firebase-credentials.json'
    
    if CRED_PATH.exists():
        try:
            cred = credentials.Certificate(str(CRED_PATH))
            firebase_app = firebase_admin.initialize_app(cred)
            print("✅ Firebase Admin inicializado correctamente desde archivo local")
        except Exception as e:
            print(f"⚠️ Error al inicializar Firebase Admin desde archivo: {e}")
    else:
        print("⚠️ No se encontraron credenciales de Firebase en el entorno ni en el archivo local")

# =====================================================================

class FirebaseAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):

        auth_header = request.META.get("HTTP_AUTHORIZATION")

        if not auth_header:
            return None

        try:
            token = auth_header.split(" ")[1]
        except IndexError:
            return None

        try:
            decoded_token = auth.verify_id_token(token)

            uid = decoded_token["uid"]
            email = decoded_token.get("email", "")

            user, created = User.objects.get_or_create(
                username=uid,
                defaults={"email": email}
            )

            return (user, None)

        except Exception:
            # IMPORTANTE:
            # si NO es un token Firebase,
            # dejamos que JWTAuthentication lo procese.
            return None