import 'package:doorpass/models/Auth/RegistroDto.dart';
import 'package:doorpass/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _birthdayCtrl = TextEditingController(); // campo de fecha

  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  /// Verificar si el usuario es mayor de edad (>= 18 años)
  bool _isAdult(DateTime birthday) {
    final today = DateTime.now();
    int years = today.year - birthday.year;
    // si aún no cumplió este año, restar 1
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      years--;
    }
    return years >= 18;
  }

  /// Mostrar selector de fecha
  Future<void> _pickBirthday() async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 20));
    DateTime first = DateTime(1900);
    DateTime last = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.purpleAccent,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _birthdayCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar edad (frontend solamente)
    final birthday = DateTime.tryParse(_birthdayCtrl.text);
    if (birthday == null || !_isAdult(birthday)) {
      setState(() {
        _error = "Debes ser mayor de 18 años para registrarte.";
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final dto = RegistroDto(
      nombre: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    final result = await _authService.register(dto);

    setState(() {
      _loading = false;
    });

    if (result != null) {
      // Si tu AuthService devuelve UsuarioDto (como en el diseño anterior), usar eso.
      // Aquí navego a la pantalla principal (ajusta la ruta si lo deseas)
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() {
        _error = "No se pudo registrar. Inténtalo nuevamente.";
      });
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _birthdayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1A002B),
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [Colors.purpleAccent, Colors.blueAccent],
                        ).createShader(bounds),
                    child: const Text(
                      'Regístrate 🎈',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // NOMBRE
                  TextFormField(
                    controller: _nombreCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: const TextStyle(color: Colors.purpleAccent),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.purpleAccent,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Ingrese su nombre'
                                : null,
                  ),

                  const SizedBox(height: 16),

                  // EMAIL
                  TextFormField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: const TextStyle(color: Colors.purpleAccent),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.purpleAccent,
                        ),
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
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Ingrese su correo'
                                : null,
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: Colors.purpleAccent),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.purpleAccent,
                        ),
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
                            value == null || value.length < 6
                                ? 'Mínimo 6 caracteres'
                                : null,
                  ),

                  const SizedBox(height: 16),

                  // CUMPLEAÑOS
                  TextFormField(
                    controller: _birthdayCtrl,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Fecha de nacimiento',
                      labelStyle: const TextStyle(color: Colors.purpleAccent),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.purpleAccent,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.cake,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    onTap: _pickBirthday,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Seleccione su fecha de nacimiento'
                                : null,
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
                        onPressed: _register,
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
                          'Registrarme',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(color: Colors.purpleAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
