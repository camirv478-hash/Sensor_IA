import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final ApiService _api = ApiService();

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
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

    setState(() => _isLoading = true);

    final result = await _api.post(
      'http://127.0.0.1:8000/api/users/register/',
      {
        'username': email.split('@').first,
        'email': email,
        'password': password,
        'password2': confirm,
        'first_name': name.split(' ').first,
        'last_name': name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : '',
      },
    );

    setState(() => _isLoading = false);

    if (result != null && !result.containsKey('error')) {
      _showSnackBar('¡Cuenta creada! Ahora inicia sesión', isError: false);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      final error = result?['username']?.first ?? 
                    result?['email']?.first ?? 
                    result?['password']?.first ?? 
                    'Error al crear cuenta';
      _showSnackBar(error.toString());
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : const Color(0xFF6CFF8F),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isSmallScreen = width < 375;

    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          // Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          // Glow
          Positioned(
            top: -40,
            right: -20,
            child: Image.asset('assets/images/glow.png', width: width * 0.7),
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
                        width: 50, height: 50,
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

                  // Robot
                  Image.asset('assets/images/robot2.png', width: isSmallScreen ? 110 : width * 0.38),

                  SizedBox(height: isSmallScreen ? 12 : 18),

                  // Title
                  Text('Crear Cuenta',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: isSmallScreen ? 26 : 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Únete a SensorIA y ayuda al planeta',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: isSmallScreen ? 13 : 14)),

                  SizedBox(height: isSmallScreen ? 24 : 34),

                  // Form card
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
                        _buildInput(Icons.email_outlined, 'Correo electrónico', _emailController),
                        const SizedBox(height: 18),
                        _buildPasswordInput('Contraseña', _obscurePassword,
                            () => setState(() => _obscurePassword = !_obscurePassword), _passwordController),
                        const SizedBox(height: 18),
                        _buildPasswordInput('Confirmar contraseña', _obscureConfirm,
                            () => setState(() => _obscureConfirm = !_obscureConfirm), _confirmController),
                        const SizedBox(height: 28),

                        // Register button
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
                                    color: const Color(0xFF6CFF8F).withOpacity(0.35), blurRadius: 24),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                                    )
                                  : Text('Crear Cuenta',
                                      style: GoogleFonts.poppins(
                                          color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿Ya tienes cuenta? ', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: Text('Iniciar sesión',
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF6CFF8F), fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildPasswordInput(String hint, bool obscure, VoidCallback onTap, TextEditingController controller) {
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