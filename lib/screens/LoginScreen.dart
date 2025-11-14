import 'package:doorpass/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user/user_login_dto.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final dto = UserLoginDto(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    final success = await _authService.login(dto);

    setState(() {
      _loading = false;
    });

    if (success) {
      // Aquí puedes navegar a tu pantalla principal
      // Ejemplo:
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() {
        _error = "Credenciales incorrectas. Inténtalo de nuevo.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1A002B), // violeta oscuro base
      body: Center(
        child: Container(
          width: isWide ? 400 : double.infinity,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF2D014F).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback:
                      (bounds) => const LinearGradient(
                        colors: [Colors.purpleAccent, Colors.blueAccent],
                      ).createShader(bounds),
                  child: const Text(
                    'Party Login 🎉',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    labelStyle: const TextStyle(color: Colors.purpleAccent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.purpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Ingrese su correo' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: Colors.purpleAccent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.purpleAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Ingrese su contraseña' : null,
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                const SizedBox(height: 8),
                _loading
                    ? const CircularProgressIndicator(
                      color: Colors.purpleAccent,
                    )
                    : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.purpleAccent.withOpacity(0.6),
                        elevation: 10,
                      ),
                      child: const Text(
                        'Ingresar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
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
      ),
    );
  }
}
