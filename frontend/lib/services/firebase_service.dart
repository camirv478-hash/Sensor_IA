import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseService {
  // Singleton
  static final FirebaseService _instance =
      FirebaseService._internal();

  factory FirebaseService() => _instance;

  FirebaseService._internal();

  // Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inicializar Firebase
  Future<void> init() async {
    await Firebase.initializeApp();
  }

  // =========================
  // LOGIN CON GOOGLE
  // =========================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Nueva API de google_sign_in
      final GoogleSignIn googleSignIn =
          GoogleSignIn.instance;

      // Inicializar
      await googleSignIn.initialize();

      // Abrir selector de cuentas Google
      final GoogleSignInAccount googleUser =
          await googleSignIn.authenticate();

      // Obtener tokens
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // Credencial Firebase
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Login Firebase
      return await _auth.signInWithCredential(
        credential,
      );
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // =========================
  // LOGIN CON APPLE
  // =========================
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential =
          OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
      );

      return await _auth.signInWithCredential(
        oauthCredential,
      );
    } catch (e) {
      print("Apple Sign-In Error: $e");
      return null;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Logout Error: $e");
    }
  }

  // =========================
  // USUARIO ACTUAL
  // =========================
  User? get currentUser => _auth.currentUser;

  // =========================
  // STREAM DE AUTENTICACIÓN
  // =========================
  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();
}