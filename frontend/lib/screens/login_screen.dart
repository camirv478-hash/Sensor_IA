import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(email, password);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final isSmallScreen = width < 375;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          // Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 20),
              child: Column(
                children: [
                  SizedBox(height: height * 0.02),

                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, color: const Color(0xFF6CFF8F), size: isSmallScreen ? 24 : 32),
                      const SizedBox(width: 8),
                      Text(
                        "SensorIA",
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 24 : 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "RECICLA INTELIGENTE",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6CFF8F),
                      fontSize: isSmallScreen ? 10 : 12,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: height * 0.02),

                  // Robot
                  Image.asset('assets/images/robot2.png', width: isSmallScreen ? 100 : 140),
                  SizedBox(height: height * 0.02),

                  // Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Bienvenido a Sensor",
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: "IA",
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6CFF8F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Recicla inteligente y gana recompensas 🌱",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 13 : 15,
                    ),
                  ),
                  SizedBox(height: height * 0.04),

                  // Email field
                  _buildField(
                    icon: Icons.email_outlined,
                    hint: "Ingresa tu correo o usuario",
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  _buildField(
                    icon: Icons.lock_outline,
                    hint: "Ingresa tu contraseña",
                    controller: _passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 10),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implementar recuperación
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Recuperación en desarrollo')),
                        );
                      },
                      child: Text(
                        "¿Olvidaste tu contraseña?",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4DA3FF),
                          fontSize: isSmallScreen ? 11 : 13,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),

                  // Login button
                  GestureDetector(
                    onTap: _isLoading ? null : _login,
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF62FFB0), Color(0xFF458FFF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF62FFB0).withOpacity(0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Continuar",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                                ],
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.025),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("o continuar con",
                            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                    ],
                  ),
                  SizedBox(height: height * 0.025),

                  // Social buttons
                  Row(
                    children: [
                      Expanded(child: _socialButton(Icons.g_mobiledata, "Google")),
                      const SizedBox(width: 12),
                      Expanded(child: _socialButton(Icons.apple, "Apple")),
                    ],
                  ),
                  SizedBox(height: height * 0.03),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("¿No tienes cuenta? ",
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: Text("Crear cuenta",
                            style: GoogleFonts.poppins(
                                color: const Color(0xFF6CFF8F),
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6CFF8F), width: 1.2),
        color: Colors.white.withOpacity(0.05),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: const Color(0xFF6CFF8F)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, String text) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 28),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}