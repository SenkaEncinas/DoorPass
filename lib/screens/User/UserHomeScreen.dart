import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
import 'package:doorpass/screens/LoginScreen.dart';
import 'package:doorpass/screens/User/ComprasScreen.dart';
import 'package:doorpass/screens/User/TrendScreen.dart';
import 'package:doorpass/services/productos_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HistorialComprasScreen.dart' hide ComprasScreen;

// NUEVAS IMPORTACIONES DE CONSTANTES
import 'package:doorpass/screens/constants/app_colors.dart';
import 'package:doorpass/screens/constants/app_gradients.dart';
import 'package:doorpass/screens/constants/app_text_styles.dart';
import 'package:doorpass/screens/constants/app_spacing.dart';
import 'package:doorpass/screens/constants/app_radius.dart';
import 'package:doorpass/screens/constants/app_shadows.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductosService _productsService = ProductosService();

  List<DetalleBolicheSimpleDto> boliches = [];
  DetalleBolicheDto? _seleccionado;
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

  void _seleccionarBoliche(
    DetalleBolicheSimpleDto bolicheSimple,
    bool isWide,
  ) async {
    final detalle = await _productsService.getBolicheDetalle(bolicheSimple.id);
    if (detalle == null) return;

    if (isWide) {
      setState(() => _seleccionado = detalle);
    } else {
      _mostrarDetalleModal(detalle);
    }
  }

  void _mostrarDetalleModal(DetalleBolicheDto detalle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.modalTop),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: _detalleContenido(detalle),
            );
          },
        );
      },
    );
  }

  Widget _detalleContenido(DetalleBolicheDto detalle) {
    final textStyleTitulo = AppTextStyles.titleSection;
    final textStyleNormal = AppTextStyles.body;
    final textStyleNombre = AppTextStyles.titleLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detalle.imagenUrl != null && detalle.imagenUrl!.isNotEmpty)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.image),
              child: Image.network(
                detalle.imagenUrl!,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(detalle.nombre, style: textStyleNombre),
        const SizedBox(height: AppSpacing.sm),
        if (detalle.direccion != null && detalle.direccion!.isNotEmpty)
          Text(detalle.direccion!, style: textStyleNormal),
        const SizedBox(height: AppSpacing.lg),

        if (detalle.manillas.isNotEmpty) ...[
          Text('Manillas:', style: textStyleTitulo),
          const SizedBox(height: AppSpacing.xs),
          ...detalle.manillas.map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text(
                '${m.nombre}: Bs. ${m.precio}',
                style: textStyleNormal,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        if (detalle.mesas.isNotEmpty) ...[
          Text('Mesas:', style: textStyleTitulo),
          const SizedBox(height: AppSpacing.xs),
          ...detalle.mesas.map(
            (m) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Text(
                '${m.nombreONumero}: Bs. ${m.precioReserva}',
                style: textStyleNormal,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        if (detalle.combos.isNotEmpty) ...[
          Text('Combos:', style: textStyleTitulo),
          const SizedBox(height: AppSpacing.xs),
          ...detalle.combos.map(
            (c) => Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.comboCard,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadows.softCard,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.nombre,
                      style: textStyleNombre.copyWith(fontSize: 18),
                    ),
                    if (c.descripcion != null && c.descripcion!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          c.descripcion!,
                          style: textStyleNormal.copyWith(
                            color: AppColors.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Precio: Bs. ${c.precio}', style: textStyleNormal),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppRadius.button),
              boxShadow: AppShadows.softCard,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.button),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ComprasScreen(
                      bolicheId: detalle.id,
                      bolicheNombre: detalle.nombre,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                child: Text(
                  'Comprar 🎟️',
                  style: AppTextStyles.button.copyWith(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        elevation: 4,
        shadowColor: AppColors.primaryAccent.withOpacity(0.4),
        title: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.searchBar,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: TextField(
            controller: _searchController,
            style: AppTextStyles.searchText,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              hintText: 'Buscar boliche...',
              hintStyle: AppTextStyles.searchHint,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.trending_up, color: AppColors.textPrimary),
            tooltip: 'Tendencias',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TrendsScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistorialComprasScreen(),
                  ),
                );
              },
              child: Text(
                "HISTORIAL DE COMPRAS",
                style: AppTextStyles.historyButton,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
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
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.progress,
                ),
              )
            : isWide
                ? Row(
                    children: [
                      _buildListaBoliches(isWide),
                      Expanded(
                        flex: 3,
                        child: _seleccionado == null
                            ? Center(
                                child: Text(
                                  'Selecciona un boliche 🎉',
                                  style: AppTextStyles.emptyState.copyWith(
                                    fontSize: 22,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: _detalleContenido(_seleccionado!),
                              ),
                      ),
                    ],
                  )
                : _buildListaBoliches(isWide),
      ),
    );
  }

  Widget _buildListaBoliches(bool isWide) {
    // Filtramos una sola vez para poder mostrar estado vacío bonito
    final query = _searchController.text.toLowerCase();
    final filtered = boliches.where((b) {
      return b.nombre.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      final content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.music_note,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No encontramos boliches con ese nombre',
              style: AppTextStyles.emptyState,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
      return isWide ? Expanded(flex: 2, child: content) : content;
    }

    final list = ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, index) {
        final b = filtered[index];

        final inicial =
            b.nombre.isNotEmpty ? b.nombre[0].toUpperCase() : '?';

        return Container(
          margin: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.85),
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.softCard,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryAccent.withOpacity(0.9),
              child: Text(
                inicial,
                style: AppTextStyles.button.copyWith(fontSize: 14),
              ),
            ),
            title: Text(
              b.nombre,
              style: GoogleFonts.orbitron(color: AppColors.textPrimary),
            ),
            subtitle: Text(
              b.direccion,
              style: AppTextStyles.subtitle,
            ),
            trailing: isWide ? null : _buildVerMasButton(b, isWide),
            onTap: () => _seleccionarBoliche(b, isWide),
          ),
        );
      },
    );

    return isWide ? Expanded(flex: 2, child: list) : list;
  }

  Widget _buildVerMasButton(DetalleBolicheSimpleDto b, bool isWide) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: () => _seleccionarBoliche(b, isWide),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            'Ver más',
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
