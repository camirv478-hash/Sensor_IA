import firebase_admin
from firebase_admin import credentials, auth
from rest_framework import authentication, exceptions
from django.contrib.auth import get_user_model
from pathlib import Path

User = get_user_model()

# Construir la ruta absoluta al archivo de credenciales
BASE_DIR = Path(__file__).resolve().parent.parent.parent
CRED_PATH = BASE_DIR / 'credentials' / 'firebase-credentials.json'

try:
    cred = credentials.Certificate(str(CRED_PATH))
    firebase_app = firebase_admin.initialize_app(cred)
    print("✅ Firebase Admin inicializado correctamente")
except Exception as e:
    firebase_app = None
    print(f"⚠️ No se pudo inicializar Firebase Admin: {e}")

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