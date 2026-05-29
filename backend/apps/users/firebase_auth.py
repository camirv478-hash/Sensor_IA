import firebase_admin

from firebase_admin import credentials
from firebase_admin import auth

from django.contrib.auth import get_user_model
from rest_framework.authentication import BaseAuthentication
from rest_framework import exceptions

User = get_user_model()

# Inicializar Firebase
if not firebase_admin._apps:

    cred = credentials.Certificate(
        "firebase-adminsdk.json"
    )

    firebase_admin.initialize_app(cred)


class FirebaseAuthentication(BaseAuthentication):

    def authenticate(self, request):

        auth_header = request.META.get("HTTP_AUTHORIZATION")

        if not auth_header:
            return None

        try:
            token = auth_header.split(" ").pop()

            decoded_token = auth.verify_id_token(token)

            uid = decoded_token["uid"]
            email = decoded_token.get("email", "")

            user, created = User.objects.get_or_create(
                username=uid,
                defaults={
                    "email": email,
                }
            )

            return (user, None)

        except Exception as e:
            raise exceptions.AuthenticationFailed(
                f"Firebase authentication failed: {e}"
            )