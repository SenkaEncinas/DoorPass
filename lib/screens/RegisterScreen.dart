import 'package:doorpass/models/Auth/RegistroDto.dart';
import 'package:doorpass/screens/LoginScreen.dart';
import 'package:doorpass/screens/User/UserHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:doorpass/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// CONSTANTES
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_gradients.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';

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
        (today.month == birthday.month && today.day < birthday.day)) {
      years--;
    }
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryAccent,
              onSurface: AppColors.textPrimary,
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

    final birthday = DateTime.tryParse(_birthdayCtrl.text);
    if (birthday == null || !_isAdult(birthday)) {
      setState(
        () => _error = "Debes ser mayor de 18 años para registrarte.",
      );
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomeScreen()),
      );
    } else {
      setState(
        () => _error = "No se pudo registrar. Inténtalo nuevamente.",
      );
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
    final inputDecorationBase = InputDecoration(
      filled: true,
      fillColor: AppColors.card.withOpacity(0.6),
      hintStyle: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: BorderSide(
          color: AppColors.primaryAccent.withOpacity(0.4),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        borderSide: const BorderSide(
          color: AppColors.primaryAccent,
          width: 1.5,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header similar al login
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.softCard,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_add_alt_1,
                      color: AppColors.textPrimary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Crea tu cuenta',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Regístrate para acceder a DoorPass',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Card de registro
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 460),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.softCard,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // NOMBRE
                      Text(
                        'Nombre',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _nombreCtrl,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: inputDecorationBase.copyWith(
                          hintText: 'Tu nombre',
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Ingrese su nombre'
                                : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // EMAIL
                      Text(
                        'Email',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: inputDecorationBase.copyWith(
                          hintText: 'tucorreo@ejemplo.com',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Ingrese su correo'
                                : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // PASSWORD
                      Text(
                        'Contraseña',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: inputDecorationBase.copyWith(
                          hintText: '••••••••',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.length < 6
                                ? 'Mínimo 6 caracteres'
                                : null,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // CUMPLEAÑOS
                      Text(
                        'Fecha de nacimiento',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextFormField(
                        controller: _birthdayCtrl,
                        readOnly: true,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: inputDecorationBase.copyWith(
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: const Icon(
                            Icons.cake_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onTap: _pickBirthday,
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Seleccione su fecha de nacimiento'
                                : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.progress,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: _gradientButton(
                                text: 'Registrarme',
                                onTap: _register,
                              ),
                            ),
                      const SizedBox(height: AppSpacing.md),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            '¿Ya tienes cuenta? Inicia sesión',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: AppShadows.softCard,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.orbitron(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
