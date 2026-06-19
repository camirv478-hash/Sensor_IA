from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.password_validation import validate_password
from django.db.models import Q
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers
from rest_framework_simplejwt.exceptions import AuthenticationFailed
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

User = get_user_model()


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """JWT serializer que permite login con username o email."""

    def validate(self, attrs):
        username = attrs.get(self.username_field)
        password = attrs.get('password')

        if username:
            if '@' in username:
                users = User.objects.filter(Q(username__iexact=username) | Q(email__iexact=username))
            else:
                users = User.objects.filter(
                    Q(username__iexact=username) |
                    Q(email__iexact=username) |
                    Q(first_name__iexact=username) |
                    Q(last_name__iexact=username)
                )

                if not users.exists() and ' ' in username:
                    first_part, last_part = username.rsplit(' ', 1)
                    users = User.objects.filter(
                        Q(first_name__iexact=first_part, last_name__iexact=last_part) |
                        Q(first_name__iexact=username) |
                        Q(last_name__iexact=username)
                    )

            if users.count() == 1:
                attrs[self.username_field] = users.first().username
            elif users.count() > 1:
                raise AuthenticationFailed(
                    _("Hay varios usuarios con ese identificador. Inicia sesión con tu nombre de usuario o correo."),
                    'multiple_users_found',
                )

        self.user = authenticate(self.context['request'], **{
            self.username_field: attrs.get(self.username_field),
            'password': password,
        })

        if self.user is None:
            raise AuthenticationFailed(
                _("No active account found with the given credentials"),
                'no_active_account',
            )

        return super().validate(attrs)


class RegisterSerializer(serializers.ModelSerializer):
    """Serializador para registrar un nuevo usuario."""
    username = serializers.CharField(required=False, allow_null=False, allow_blank=False)
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password]
    )
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'password2', 'first_name', 'last_name')
        extra_kwargs = {
            'email': {'required': True},
        }

    def _generate_unique_username(self, base_username):
        """Genera un username único agregando un número si existe."""
        username = base_username
        suffix = 1
        while User.objects.filter(username=username).exists():
            username = f"{base_username}{suffix}"
            suffix += 1
        return username

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Las contraseñas no coinciden."})

        email = attrs.get('email', '').strip()
        if email and User.objects.filter(email__iexact=email).exists():
            raise serializers.ValidationError({"email": "Este correo ya está registrado."})

        username = attrs.get('username', '').strip()
        if username:
            if User.objects.filter(username__iexact=username).exists():
                raise serializers.ValidationError({"username": "Este nombre de usuario ya está en uso."})
            attrs['username'] = username
        else:
            base_username = email.split('@')[0] if email else 'usuario'
            attrs['username'] = self._generate_unique_username(base_username)

        return attrs

    def create(self, validated_data):
        validated_data.pop('password2')
        user = User.objects.create_user(
            username=validated_data.get('username'),
            email=validated_data.get('email'),
            password=validated_data.get('password'),
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = (
            'id', 'username', 'email', 'first_name', 'last_name',
            'puntos', 'nivel', 'avatar', 'biografia', 'fecha_nacimiento',
            'rol',
        )
        read_only_fields = ('id', 'puntos', 'nivel', 'rol')
        extra_kwargs = {
            'avatar': {'required': False}
        }