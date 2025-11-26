import 'package:flutter/material.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
import 'package:doorpass/screens/Admin/EdicionAdminBoliche.dart';
import 'package:doorpass/screens/LoginScreen.dart';
import 'package:doorpass/models/admin/CrearBolicheDto.dart';
import 'package:doorpass/services/admin_service.dart';
import 'package:doorpass/services/productos_service.dart';
import 'package:google_fonts/google_fonts.dart';

// CONSTANTES
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_gradients.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';

class AdminBolichesScreen extends StatefulWidget {
  const AdminBolichesScreen({super.key});

  @override
  State<AdminBolichesScreen> createState() => _AdminBolichesScreenState();
}

class _AdminBolichesScreenState extends State<AdminBolichesScreen> {
  final ProductosService _productsService = ProductosService();
  final AdminService _adminService = AdminService();

  List<DetalleBolicheSimpleDto> boliches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarBoliches();
  }

  Future<void> _cargarBoliches() async {
    setState(() => _loading = true);
    try {
      final lista = await _productsService.getBoliches();
      setState(() => boliches = lista);
    } catch (e) {
      debugPrint('Error cargando boliches: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Imagen proporcional entre 40 y 70 px
    final imageSize = (screenWidth * 0.15).clamp(40.0, 70.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        centerTitle: true,
        elevation: 4,
        shadowColor: AppColors.primaryAccent.withOpacity(0.4),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Administrador de boliches',
          style: AppTextStyles.titleSection.copyWith(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.progress),
              )
              : RefreshIndicator(
                color: AppColors.progress,
                backgroundColor: AppColors.card,
                onRefresh: _cargarBoliches,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: boliches.length,
                  itemBuilder: (context, index) {
                    final boliche = boliches[index];
                    return Container(
                      margin:
                          const EdgeInsets.only(
                            bottom: AppSpacing.md,
                          ),
                      decoration: BoxDecoration(
                        color: AppColors.card.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        boxShadow: AppShadows.softCard,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        leading:
                            boliche.imagenUrl != null &&
                                    boliche.imagenUrl!.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.button,
                                  ),
                                  child: Image.network(
                                    boliche.imagenUrl!,
                                    width: imageSize,
                                    height: imageSize,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                          width: imageSize,
                                          height: imageSize,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.button,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white70,
                                          ),
                                        ),
                                  ),
                                )
                                : Container(
                                  width: imageSize,
                                  height: imageSize,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.button,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.local_bar,
                                    color: Colors.white70,
                                  ),
                                ),
                        title: Text(
                          boliche.nombre,
                          style: AppTextStyles.titleSection.copyWith(
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            boliche.direccion,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                              tooltip: 'Editar',
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => EdicionAdminBoliche(
                                          boliche: boliche,
                                        ),
                                  ),
                                );
                                _cargarBoliches();
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Eliminar',
                              onPressed: () => _confirmarEliminar(boliche),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildFab() {
    // FAB con gradiente "fake" usando Container
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        shape: BoxShape.circle,
        boxShadow: AppShadows.softCard,
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: _mostrarDialogoCrear,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _confirmarEliminar(DetalleBolicheSimpleDto boliche) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            title: Text(
              'Confirmar eliminación',
              style: AppTextStyles.titleSection.copyWith(fontSize: 18),
            ),
            content: Text(
              '¿Estás seguro de eliminar "${boliche.nombre}"?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Eliminar',
                  style: GoogleFonts.orbitron(fontSize: 13),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final ok = await _adminService.eliminarBoliche(boliche.id);
      if (ok) {
        _cargarBoliches();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryAccent,
            content: Text(
              'Boliche "${boliche.nombre}" eliminado',
              style: GoogleFonts.orbitron(color: AppColors.textPrimary),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Error al eliminar boliche',
              style: GoogleFonts.orbitron(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  void _mostrarDialogoCrear() {
    final nombreController = TextEditingController();
    final direccionController = TextEditingController();
    final descripcionController = TextEditingController();
    final imagenController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            title: Text(
              'Crear nuevo boliche',
              style: AppTextStyles.titleSection.copyWith(fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _campoTexto('Nombre', nombreController),
                  _campoTexto('Dirección', direccionController),
                  _campoTexto('Descripción', descripcionController),
                  _campoTexto(
                    'Imagen URL (opcional)',
                    imagenController,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
                onPressed: () async {
                  if (nombreController.text.isEmpty ||
                      direccionController.text.isEmpty ||
                      descripcionController.text.isEmpty) {
                    return;
                  }

                  final nuevoBoliche = await _adminService.crearBoliche(
                    CrearBolicheDto(
                      nombre: nombreController.text.trim(),
                      direccion: direccionController.text.trim(),
                      descripcion: descripcionController.text.trim(),
                      imagenUrl:
                          imagenController.text.isNotEmpty
                              ? imagenController.text.trim()
                              : null,
                    ),
                  );

                  if (nuevoBoliche != null) {
                    boliches.add(
                      DetalleBolicheSimpleDto(
                        id: nuevoBoliche.id,
                        nombre: nuevoBoliche.nombre,
                        direccion: nuevoBoliche.direccion ?? '',
                        imagenUrl: nuevoBoliche.imagenUrl ?? '',
                        descripcion: '',
                      ),
                    );
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primaryAccent,
                        content: Text(
                          'Boliche creado correctamente',
                          style: GoogleFonts.orbitron(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'Error al crear boliche',
                          style: GoogleFonts.orbitron(color: Colors.white),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'Guardar',
                  style: GoogleFonts.orbitron(fontSize: 13),
                ),
              ),
            ],
          ),
    );
  }

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          filled: true,
          fillColor: AppColors.background.withOpacity(0.6),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            borderSide: BorderSide(
              color: AppColors.primaryAccent.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            borderSide: const BorderSide(
              color: AppColors.primaryAccent,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
