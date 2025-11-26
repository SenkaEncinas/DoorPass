import 'package:doorpass/models/Auth/LoginDto.dart';
import 'package:doorpass/screens/Admin/AdminBolichesScreen.dart';
import 'package:doorpass/screens/RegisterScreen.dart';
import 'package:doorpass/screens/Staff/StaffScreen.dart';
import 'package:doorpass/screens/User/UserHomeScreen.dart';
import 'package:doorpass/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CONSTANTES
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_gradients.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';

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
        content: Text(
          message,
          style: GoogleFonts.orbitron(color: Colors.white),
        ),
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
      final loginDto = LoginDto(email: email, password: password);
      final usuario = await _authService.login(loginDto, password);

      if (usuario == null || usuario.token == null || usuario.token!.isEmpty) {
        _showError('Email o contraseña inválida');
        setState(() => _isLoading = false);
        return;
      }

      await _authService.saveToken(usuario.token);

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // “Logo” simple circular con gradiente
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.softCard,
                ),
                child: Center(
                  child: Text(
                    'DP',
                    style: AppTextStyles.titleLarge.copyWith(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'DoorPass',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tu acceso a la fiesta',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Card de login
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.card.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadows.softCard,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iniciar sesión',
                      style: AppTextStyles.titleSection.copyWith(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Email
                    Text(
                      'Email',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _emailController,
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
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password
                    Text(
                      'Contraseña',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _passwordController,
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
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Botón de login
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.progress,
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: _gradientButton(
                              text: 'Iniciar sesión',
                              onTap: _login,
                            ),
                          ),

                    const SizedBox(height: AppSpacing.md),

                    // Botón de registro
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          '¿No tienes cuenta? Regístrate',
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
