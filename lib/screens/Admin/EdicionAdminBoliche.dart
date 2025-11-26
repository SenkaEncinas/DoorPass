// lib/screens/Admin/EdicionAdminBoliche.dart
import 'package:doorpass/models/Productos/DetalleComboDto.dart';
import 'package:doorpass/models/Productos/DetalleManillaTipoDto.dart';
import 'package:doorpass/models/Productos/DetalleMesaDto.dart';
import 'package:doorpass/models/admin/CrearComboDto.dart';
import 'package:doorpass/models/admin/CrearManillaTipoDto.dart';
import 'package:doorpass/models/admin/CrearMesaDto.dart';
import 'package:doorpass/models/admin/CrearStaffDto.dart';
import 'package:flutter/material.dart';
import 'package:doorpass/models/Productos/DetalleBolicheDto.dart';
import 'package:doorpass/models/Productos/DetalleBolichesSimpleDto.dart';
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
import 'package:doorpass/screens/constants/app_buttons.dart';
import 'package:doorpass/screens/constants/app_dialogs.dart';
import 'package:doorpass/screens/constants/app_admin_item_row.dart';

class EdicionAdminBoliche extends StatefulWidget {
  final DetalleBolicheSimpleDto boliche;
  const EdicionAdminBoliche({super.key, required this.boliche});

  @override
  State<EdicionAdminBoliche> createState() => _EdicionAdminBolicheState();
}

class _EdicionAdminBolicheState extends State<EdicionAdminBoliche> {
  final ProductosService _productsService = ProductosService();
  final AdminService _adminService = AdminService();
  DetalleBolicheDto? _detalle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    final detalle = await _productsService.getBolicheDetalle(widget.boliche.id);
    setState(() {
      _detalle = detalle;
      _loading = false;
    });
  }

  // ---------------- APP BAR & LAYOUT ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        centerTitle: true,
        elevation: 4,
        shadowColor: AppColors.primaryAccent.withOpacity(0.4),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.boliche.nombre,
          style: AppTextStyles.titleSection.copyWith(
            color: AppColors.textSecondary,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.progress),
            )
          : _detalle == null
              ? Center(
                  child: Text(
                    'No se pudo cargar el detalle',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _cabeceraBoliche(),
                      const SizedBox(height: AppSpacing.lg),
                      _seccionManillas(),
                      const SizedBox(height: AppSpacing.lg),
                      _seccionMesas(),
                      const SizedBox(height: AppSpacing.lg),
                      _seccionStaff(),
                      const SizedBox(height: AppSpacing.lg),
                      _seccionCombos(),
                    ],
                  ),
                ),
    );
  }

  // ---------------- CABECERA BOLICHE ----------------

  Widget _cabeceraBoliche() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.98),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.softCard,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _detalle!.nombre,
            style: AppTextStyles.titleLarge.copyWith(fontSize: 24),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _detalle!.direccion ?? '',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_detalle!.descripcion != null &&
              _detalle!.descripcion!.trim().isNotEmpty)
            Text(
              _detalle!.descripcion!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButtons.primary(
              text: 'Editar boliche',
              icon: Icons.edit,
              onTap: _editarBoliche,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SECCIONES GENÉRICAS ----------------

  Widget _seccionCard(
    String titulo,
    VoidCallback onCrear,
    List<Widget> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.98),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.softCard,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: AppTextStyles.titleSection.copyWith(fontSize: 18),
              ),
              AppButtons.smallGradient(
                text: 'Nuevo',
                icon: Icons.add,
                onTap: onCrear,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            Text(
              'Sin registros aún',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            )
          else
            Column(
              children: items
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: w,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  // ---------------- SECCIONES ESPECÍFICAS ----------------

  Widget _seccionManillas() {
    final items = _detalle?.manillas
            .map(
              (m) => AppAdminItemRow(
                text: '${m.nombre}: Bs. ${m.precio}  (Stock: ${m.stock})',
                onEdit: () => _editarManilla(m),
                onDelete: () => _eliminarManilla(m.id),
              ),
            )
            .toList() ??
        [];
    return _seccionCard('Manillas', _crearManilla, items);
  }

  Widget _seccionMesas() {
    final items = _detalle?.mesas
            .map(
              (m) => AppAdminItemRow(
                text: '${m.nombreONumero}: Bs. ${m.precioReserva}',
                onEdit: () => _editarMesa(m),
                onDelete: () => _eliminarMesa(m.id),
              ),
            )
            .toList() ??
        [];
    return _seccionCard('Mesas', _crearMesa, items);
  }

  Widget _seccionStaff() {
    final items = <Widget>[
      Text(
        'Crear cuentas de staff vinculadas a este boliche.',
        style: AppTextStyles.body.copyWith(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
    ];
    return _seccionCard('Staff', _crearStaff, items);
  }

  Widget _seccionCombos() {
    final items = _detalle?.combos
            .map(
              (c) => AppAdminItemRow(
                text: '${c.nombre}: Bs. ${c.precio}',
                onEdit: () => _editarCombo(c),
                onDelete: () => _eliminarCombo(c.id),
              ),
            )
            .toList() ??
        [];
    return _seccionCard('Combos', _crearCombo, items);
  }

  // ---------------- EDITAR BOLICHE (DIALOG) ----------------

  void _editarBoliche() {
    final nombreController = TextEditingController(text: _detalle!.nombre);
    final direccionController =
        TextEditingController(text: _detalle!.direccion ?? '');
    final descripcionController =
        TextEditingController(text: _detalle!.descripcion ?? '');
    final imagenController =
        TextEditingController(text: _detalle!.imagenUrl ?? '');

    AppDialogs.showCrudDialog(
      context: context,
      title: 'Editar boliche',
      confirmText: 'Guardar cambios',
      fields: [
        _campoTexto('Nombre', nombreController),
        _campoTexto('Dirección', direccionController),
        _campoTexto('Descripción', descripcionController),
        _campoTexto('URL de imagen', imagenController),
      ],
      onConfirm: () async {
        final nombre = nombreController.text.trim();
        final direccion = direccionController.text.trim();
        final descripcion = descripcionController.text.trim();
        final imagen = imagenController.text.trim();

        if (nombre.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El nombre es obligatorio')),
          );
          return;
        }

        final dto = CrearBolicheDto(
          nombre: nombre,
          direccion: direccion,
          descripcion: descripcion.isNotEmpty ? descripcion : '',
          imagenUrl: imagen.isNotEmpty ? imagen : null,
        );

        final success =
            await _adminService.actualizarBoliche(_detalle!.id, dto);

        if (success) {
          await _cargarDetalle();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Boliche actualizado correctamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al actualizar el boliche')),
          );
        }
      },
    );
  }

  // ---------------- INPUT REUTILIZABLE ----------------

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isPassword,
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
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
            borderSide: BorderSide(
              color: AppColors.primaryAccent,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- CRUD MANILLAS ----------------

  void _crearManilla() {
    final nombre = TextEditingController();
    final precio = TextEditingController();
    final stock = TextEditingController();

    AppDialogs.showCrudDialog(
      context: context,
      title: "Nueva manilla",
      confirmText: "Crear",
      fields: [
        _campoTexto("Nombre", nombre),
        _campoTexto("Precio", precio, isNumber: true),
        _campoTexto("Stock", stock, isNumber: true),
      ],
      onConfirm: () async {
        if (nombre.text.isEmpty ||
            precio.text.isEmpty ||
            stock.text.isEmpty) return;

        final dto = CrearManillaTipoDto(
          nombre: nombre.text.trim(),
          precio: double.parse(precio.text),
          stock: int.parse(stock.text),
        );

        final r = await _adminService.crearManilla(_detalle!.id, dto);
        if (r != null) {
          Navigator.pop(context);
          await _cargarDetalle();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Manilla creada')),
          );
        }
      },
    );
  }

  void _editarManilla(DetalleManillaTipoDto m) {
    final nombre = TextEditingController(text: m.nombre);
    final precio = TextEditingController(text: m.precio.toString());
    final stock = TextEditingController(text: m.stock.toString());

    AppDialogs.showCrudDialog(
      context: context,
      title: "Editar manilla",
      confirmText: "Guardar",
      fields: [
        _campoTexto("Nombre", nombre),
        _campoTexto("Precio", precio, isNumber: true),
        _campoTexto("Stock", stock, isNumber: true),
      ],
      onConfirm: () async {
        final dto = CrearManillaTipoDto(
          nombre: nombre.text.trim(),
          precio: double.parse(precio.text),
          stock: int.parse(stock.text),
        );

        final ok = await _adminService.actualizarManilla(m.id, dto);
        if (ok) {
          Navigator.pop(context);
          await _cargarDetalle();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Manilla actualizada")),
          );
        }
      },
    );
  }

  void _eliminarManilla(int id) async {
    final ok = await _adminService.eliminarManilla(id);
    if (ok) {
      await _cargarDetalle();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Manilla eliminada")),
      );
    }
  }

  // ---------------- CRUD MESAS ----------------

  void _crearMesa() {
    final nombre = TextEditingController();
    final precio = TextEditingController();
    final ubicacion = TextEditingController();

    AppDialogs.showCrudDialog(
      context: context,
      title: "Nueva mesa",
      confirmText: "Crear",
      fields: [
        _campoTexto("Nombre o número", nombre),
        _campoTexto("Precio de reserva", precio, isNumber: true),
        _campoTexto("Ubicación (opcional)", ubicacion),
      ],
      onConfirm: () async {
        final nombreText = nombre.text.trim();
        final precioText = precio.text.trim();

        if (nombreText.isEmpty || precioText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nombre y precio son obligatorios'),
            ),
          );
          return;
        }

        double? precioVal;
        try {
          precioVal = double.parse(precioText);
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Precio inválido')),
          );
          return;
        }

        final dto = CrearMesaDto(
          nombreONumero: nombreText,
          precioReserva: precioVal,
          ubicacion: ubicacion.text.trim().isNotEmpty
              ? ubicacion.text.trim()
              : null,
        );

        final r = await _adminService.crearMesa(_detalle!.id, dto);
        if (r != null) {
          Navigator.pop(context);
          await _cargarDetalle();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mesa creada')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al crear mesa')),
          );
        }
      },
    );
  }

  void _editarMesa(DetalleMesaDto m) {
    final nombre = TextEditingController(text: m.nombreONumero);
    final precio = TextEditingController(text: m.precioReserva.toString());
    final ubicacion = TextEditingController(text: m.ubicacion ?? '');

    AppDialogs.showCrudDialog(
      context: context,
      title: "Editar mesa",
      confirmText: "Guardar",
      fields: [
        _campoTexto("Nombre o número", nombre),
        _campoTexto("Precio reserva", precio, isNumber: true),
        _campoTexto("Ubicación (opcional)", ubicacion),
      ],
      onConfirm: () async {
        final nombreText = nombre.text.trim();
        final precioText = precio.text.trim();

        if (nombreText.isEmpty || precioText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nombre y precio son obligatorios'),
            ),
          );
          return;
        }

        double? precioVal;
        try {
          precioVal = double.parse(precioText);
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Precio inválido')),
          );
          return;
        }

        final dto = CrearMesaDto(
          nombreONumero: nombreText,
          precioReserva: precioVal,
          ubicacion: ubicacion.text.trim().isNotEmpty
              ? ubicacion.text.trim()
              : null,
        );

        final ok = await _adminService.actualizarMesa(m.id, dto);
        if (ok) {
          Navigator.pop(context);
          await _cargarDetalle();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Mesa actualizada")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al actualizar mesa")),
          );
        }
      },
    );
  }

  void _eliminarMesa(int id) async {
    final ok = await _adminService.eliminarMesa(id);
    if (ok) {
      await _cargarDetalle();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mesa eliminada")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar mesa")),
      );
    }
  }

  // ---------------- STAFF ----------------

  void _crearStaff() {
    final nombre = TextEditingController();
    final email = TextEditingController();
    final password = TextEditingController();

    AppDialogs.showCrudDialog(
      context: context,
      title: "Nuevo staff",
      confirmText: "Crear",
      fields: [
        _campoTexto("Nombre", nombre),
        _campoTexto("Email", email),
        _campoTexto("Contraseña", password, isPassword: true),
      ],
      onConfirm: () async {
        final dto = CrearStaffDto(
          nombre: nombre.text.trim(),
          email: email.text.trim(),
          password: password.text.trim(),
        );

        final r = await _adminService.crearStaff(dto);
        if (r != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Staff creado")),
          );
        }
      },
    );
  }

  // ---------------- CRUD COMBOS ----------------

  void _crearCombo() {
    final nombre = TextEditingController();
    final descripcion = TextEditingController();
    final precio = TextEditingController();
    final imagenUrl = TextEditingController();

    AppDialogs.showCrudDialog(
      context: context,
      title: "Nuevo combo",
      confirmText: "Crear",
      fields: [
        _campoTexto("Nombre", nombre),
        _campoTexto("Descripción (opcional)", descripcion),
        _campoTexto("Precio", precio, isNumber: true),
        _campoTexto("Imagen URL (opcional)", imagenUrl),
      ],
      onConfirm: () async {
        if (nombre.text.trim().isEmpty || precio.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Nombre y precio son obligatorios"),
            ),
          );
          return;
        }

        double? precioVal;
        try {
          precioVal = double.parse(precio.text.trim());
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Precio inválido")),
          );
          return;
        }

        final dto = CrearComboDto(
          nombre: nombre.text.trim(),
          descripcion: descripcion.text.trim().isEmpty
              ? null
              : descripcion.text.trim(),
          precio: precioVal,
          imagenUrl: imagenUrl.text.trim().isEmpty
              ? null
              : imagenUrl.text.trim(),
        );

        final r = await _adminService.crearCombo(_detalle!.id, dto);

        if (r != null) {
          Navigator.pop(context);
          await _cargarDetalle();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Combo creado")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al crear combo")),
          );
        }
      },
    );
  }

  void _editarCombo(DetalleComboDto combo) {
    final nombre = TextEditingController(text: combo.nombre);
    final descripcion = TextEditingController(text: combo.descripcion ?? '');
    final precio = TextEditingController(text: combo.precio.toString());
    final imagenUrl = TextEditingController(text: combo.imagenUrl ?? '');

    AppDialogs.showCrudDialog(
      context: context,
      title: "Editar combo",
      confirmText: "Guardar",
      fields: [
        _campoTexto("Nombre", nombre),
        _campoTexto("Descripción (opcional)", descripcion),
        _campoTexto("Precio", precio, isNumber: true),
        _campoTexto("Imagen URL (opcional)", imagenUrl),
      ],
      onConfirm: () async {
        if (nombre.text.trim().isEmpty || precio.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Nombre y precio son obligatorios"),
            ),
          );
          return;
        }

        double? precioVal;
        try {
          precioVal = double.parse(precio.text.trim());
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Precio inválido")),
          );
          return;
        }

        final dto = CrearComboDto(
          nombre: nombre.text.trim(),
          descripcion: descripcion.text.trim().isEmpty
              ? null
              : descripcion.text.trim(),
          precio: precioVal,
          imagenUrl: imagenUrl.text.trim().isEmpty
              ? null
              : imagenUrl.text.trim(),
        );

        final ok = await _adminService.updateCombo(combo.id, dto);

        if (ok) {
          Navigator.pop(context);
          await _cargarDetalle();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Combo actualizado")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al actualizar combo")),
          );
        }
      },
    );
  }

  void _eliminarCombo(int id) async {
    final ok = await _adminService.deleteCombo(id);

    if (ok) {
      await _cargarDetalle();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Combo eliminado")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar combo")),
      );
    }
  }
}
