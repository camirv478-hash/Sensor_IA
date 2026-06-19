import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String _passwordStrength = "";

  final ApiService _api = ApiService();

  // ==================== LÓGICA DE FORTALEZA ====================
  String _getPasswordStrength(String password) {
    if (password.isEmpty) return "";
    if (password.length < 6) return "Débil";

    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return "Débil";
    if (score == 3 || score == 4) return "Media";
    return "Fuerte";
  }

  Color _getPasswordColor(String strength) {
    switch (strength) {
      case "Débil": return Colors.red;
      case "Media": return Colors.orange;
      case "Fuerte": return Colors.green;
      default: return Colors.grey;
    }
  }

  double _getPasswordProgress(String strength) {
    switch (strength) {
      case "Débil": return 0.3;
      case "Media": return 0.6;
      case "Fuerte": return 1.0;
      default: return 0.0;
    }
  }

  // ==================== INICIALIZACIÓN ====================
  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      final value = _passwordController.text;
      setState(() {
        _passwordStrength = _getPasswordStrength(value);
      });
    });
  }

  // ==================== REGISTRO ====================
  Future<void> _register() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    // Validaciones
    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnackBar('Completa todos los campos');
      return;
    }
    if (password != confirm) {
      _showSnackBar('Las contraseñas no coinciden');
      return;
    }
    if (password.length < 8) {
      _showSnackBar('La contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (username.length < 3) {
      _showSnackBar('El nombre de usuario debe tener al menos 3 caracteres');
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      _showSnackBar('El nombre de usuario solo puede contener letras, números y guión bajo');
      return;
    }
    if (_passwordStrength == "Débil") {
      _showSnackBar('La contraseña es demasiado débil. Usa mayúsculas, números y símbolos.');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _api.post(
      ApiConstants.register,
      {
        'username': username,
        'email': email,
        'password': password,
        'password2': confirm,
        'first_name': name.split(' ').first,
        'last_name': name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : '',
      },
    );

    setState(() => _isLoading = false);

    // ✅ NUEVA CONDICIÓN DE ÉXITO
    // Si la respuesta NO contiene un campo de error, asumimos éxito.
    final hasError = result != null && (
      result.containsKey('error') ||
      result.containsKey('detail') ||
      result.containsKey('non_field_errors')
    );

    if (!hasError && result != null) {
      // ✅ Éxito: mostrar mensaje y redirigir a login
      _showSnackBar(
        '🎉 ¡Cuenta creada exitosamente! Redirigiendo al login...',
        isError: false,
      );
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // ❌ Error: mostrar mensaje
      String errorMsg = 'Error al crear cuenta';
      if (result != null) {
        if (result.containsKey('username')) {
          errorMsg = result['username']?.first ?? 'Nombre de usuario no disponible';
        } else if (result.containsKey('email')) {
          errorMsg = result['email']?.first ?? 'Correo ya registrado';
        } else if (result.containsKey('password')) {
          errorMsg = result['password']?.first ?? 'Contraseña inválida';
        } else if (result.containsKey('non_field_errors')) {
          errorMsg = result['non_field_errors']?.first ?? 'Error en los datos';
        } else if (result.containsKey('detail')) {
          errorMsg = result['detail']?.toString() ?? 'Error desconocido';
        } else if (result.containsKey('error')) {
          errorMsg = result['error']?.toString() ?? 'Error en el servidor';
        }
      }
      _showSnackBar(errorMsg);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : const Color(0xFF6CFF8F),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 375;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.15)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 14 : 20),
                  Image.asset('assets/images/robot2.png', width: isSmallScreen ? 110 : width * 0.38),
                  SizedBox(height: isSmallScreen ? 12 : 18),
                  Text('Crear Cuenta',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: isSmallScreen ? 26 : 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Únete a SensorIA y ayuda al planeta',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: isSmallScreen ? 13 : 14)),
                  SizedBox(height: isSmallScreen ? 24 : 34),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        _buildInput(Icons.person_outline, 'Nombre completo', _nameController),
                        const SizedBox(height: 18),
                        _buildInput(Icons.person, 'Nombre de usuario', _usernameController),
                        const SizedBox(height: 18),
                        _buildInput(Icons.email_outlined, 'Correo electrónico', _emailController),
                        const SizedBox(height: 18),
                        _buildPasswordInput(
                          'Contraseña',
                          _obscurePassword,
                          () => setState(() => _obscurePassword = !_obscurePassword),
                          _passwordController,
                        ),
                        // MOSTRAR FORTALEZA SOLO SI HAY TEXTO
                        if (_passwordStrength.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: _getPasswordProgress(_passwordStrength),
                                  backgroundColor: Colors.grey.shade800,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getPasswordColor(_passwordStrength),
                                  ),
                                  minHeight: 6,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Seguridad: $_passwordStrength",
                                  style: TextStyle(
                                    color: _getPasswordColor(_passwordStrength),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 18),
                        _buildPasswordInput(
                          'Confirmar contraseña',
                          _obscureConfirm,
                          () => setState(() => _obscureConfirm = !_obscureConfirm),
                          _confirmController,
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: _isLoading ? null : _register,
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF6CFF8F), Color(0xFF00BCD4)]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6CFF8F).withOpacity(0.35),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                                    )
                                  : Text(
                                      'Crear Cuenta',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes cuenta? ',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: Text(
                          'Iniciar sesión',
                            style: GoogleFonts.poppins(
                            color: const Color(0xFF6CFF8F),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(IconData icon, String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF112019),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: const Color(0xFF6CFF8F)),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white38),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordInput(
    String hint,
    bool obscure,
    VoidCallback onTap,
    TextEditingController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF112019),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6CFF8F).withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        // ❌ onChanged eliminado, el listener lo maneja
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6CFF8F)),
          suffixIcon: GestureDetector(
            onTap: onTap,
            child: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white38),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}