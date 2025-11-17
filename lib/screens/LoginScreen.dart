import 'package:doorpass/models/Auth/LoginDto.dart';
import 'package:doorpass/screens/Admin/AdminBolichesScreen.dart';
import 'package:doorpass/screens/RegisterScreen.dart';
import 'package:doorpass/screens/Staff/StaffScreen.dart';
import 'package:doorpass/screens/User/UserHomeScreen.dart';
import 'package:doorpass/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Debes completar todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Adaptado a tu AuthService actual
      final loginDto = LoginDto(email: email, password: password);
      final usuario = await _authService.login(loginDto, password);

      if (usuario == null || usuario.token == null || usuario.token!.isEmpty) {
        _showError('Email o contraseña inválida');
        setState(() => _isLoading = false);
        return;
      }

      // Guardamos token localmente
      await _authService.saveToken(usuario.token);

      // Navegar según rol
      switch (usuario.rol) {
        case 'Usuario':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserHomeScreen()),
          );
          break;
        case 'Staff':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StaffScreen()),
          );
          break;
        case 'Administrador':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminBolichesScreen()),
          );
          break;
        default:
          _showError('Rol no reconocido');
      }
    } catch (e) {
      _showError('Error de login: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100018),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'DoorPass',
                style: GoogleFonts.orbitron(
                  color: Colors.purpleAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: Colors.purpleAccent),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: const TextStyle(color: Colors.purpleAccent),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ... todo tu código anterior permanece igual hasta el ElevatedButton de login ...
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.purpleAccent)
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Iniciar sesión',
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

              const SizedBox(height: 16),

              // 🔹 Botón de registro
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate',
                  style: TextStyle(color: Colors.purpleAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
