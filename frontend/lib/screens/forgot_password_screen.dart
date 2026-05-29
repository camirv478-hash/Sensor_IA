import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiService();
  
  bool _isLoading = false;
  bool _codeSent = false;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Ingresa tu correo');
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await _api.post(
      ApiConstants.passwordReset,
      {'email': email},
    );
    
    setState(() {
      _isLoading = false;
      if (result != null && !result.containsKey('error')) {
        _codeSent = true;
        _showError('Código enviado a tu correo (revisa la terminal del servidor)', isError: false);
      } else {
        _showError('No se pudo enviar el código. Verifica el correo.');
      }
    });
  }

  Future<void> _resetPassword() async {
    final codigo = _codigoController.text.trim();
    final password = _passwordController.text.trim();
    
    if (codigo.isEmpty || password.isEmpty) {
      _showError('Completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await _api.post(
      ApiConstants.passwordResetConfirm,
      {
        'email': _emailController.text.trim(),
        'codigo': codigo,
        'new_password': password,
      },
    );
    
    setState(() => _isLoading = false);
    
    if (result != null && !result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada'), backgroundColor: Color(0xFF6CFF8F)),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showError('Código inválido o expirado');
    }
  }

  void _showError(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade800 : const Color(0xFF6CFF8F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFF07110B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset('assets/images/robot2.png', width: 100),
            const SizedBox(height: 30),
            Text('Recuperar contraseña',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Correo electrónico', Icons.email),
              enabled: !_codeSent,
            ),

            if (_codeSent) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _codigoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Código de 6 dígitos', Icons.pin),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Nueva contraseña', Icons.lock),
                obscureText: true,
              ),
            ],

            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6CFF8F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLoading ? null : (_codeSent ? _resetPassword : _sendCode),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(_codeSent ? 'Cambiar contraseña' : 'Enviar código',
                        style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: const Color(0xFF6CFF8F)),
      filled: true,
      fillColor: const Color(0xFF112019),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}