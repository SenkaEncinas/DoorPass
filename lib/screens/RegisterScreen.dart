import 'package:doorpass/models/Auth/RegistroDto.dart';
import 'package:doorpass/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _birthdayCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _loading = false;
  String? _error;

  bool _isAdult(DateTime birthday) {
    final today = DateTime.now();
    int years = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) years--;
    return years >= 18;
  }

  Future<void> _pickBirthday() async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 20));
    DateTime first = DateTime(1900);
    DateTime last = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.purpleAccent,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) _birthdayCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final birthday = DateTime.tryParse(_birthdayCtrl.text);
    if (birthday == null || !_isAdult(birthday)) {
      setState(() => _error = "Debes ser mayor de 18 años para registrarte.");
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
    setState(() => _loading = false);

    if (result != null) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() => _error = "No se pudo registrar. Inténtalo nuevamente.");
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
    return Scaffold(
      backgroundColor: const Color(0xFF100018),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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

                // NOMBRE
                TextFormField(
                  controller: _nombreCtrl,
                  style: GoogleFonts.orbitron(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nombre',
                    hintStyle: GoogleFonts.orbitron(color: Colors.purpleAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese su nombre' : null,
                ),
                const SizedBox(height: 20),

                // EMAIL
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.orbitron(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: GoogleFonts.orbitron(color: Colors.purpleAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese su correo' : null,
                ),
                const SizedBox(height: 20),

                // PASSWORD
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: GoogleFonts.orbitron(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    hintStyle: GoogleFonts.orbitron(color: Colors.purpleAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 20),

                // CUMPLEAÑOS
                TextFormField(
                  controller: _birthdayCtrl,
                  readOnly: true,
                  style: GoogleFonts.orbitron(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Fecha de nacimiento',
                    hintStyle: GoogleFonts.orbitron(color: Colors.purpleAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: _pickBirthday,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Seleccione su fecha de nacimiento' : null,
                ),
                const SizedBox(height: 30),

                if (_error != null)
                  Text(
                    _error!,
                    style: GoogleFonts.orbitron(color: Colors.redAccent),
                  ),
                if (_error != null) const SizedBox(height: 8),

                _loading
                    ? const CircularProgressIndicator(color: Colors.purpleAccent)
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Registrarme',
                            style: GoogleFonts.orbitron(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: GoogleFonts.orbitron(color: Colors.purpleAccent),
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
