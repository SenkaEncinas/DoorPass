// lib/screens/editar_boliche_screen.dart
import 'package:flutter/material.dart';

class EditarBolicheScreen extends StatefulWidget {
  final Map<String, dynamic> boliche;
  const EditarBolicheScreen({super.key, required this.boliche});

  @override
  State<EditarBolicheScreen> createState() => _EditarBolicheScreenState();
}

class _EditarBolicheScreenState extends State<EditarBolicheScreen> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _imagenCtrl;
  late Map<String, dynamic> _manillas;
  late Map<String, dynamic> _combos;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.boliche['nombre']);
    _precioCtrl = TextEditingController(
      text: widget.boliche['precio'].toString(),
    );
    _imagenCtrl = TextEditingController(text: widget.boliche['imagen']);
    _manillas = Map<String, dynamic>.from(widget.boliche['manillas']);
    _combos = Map<String, dynamic>.from(widget.boliche['combos']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A0DAD),
        title: const Text(
          'Editar Boliche',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _campo('Nombre', _nombreCtrl),
            _campo('Precio base', _precioCtrl, isNumber: true),
            _campo('URL de imagen', _imagenCtrl),
            const SizedBox(height: 16),
            const Text(
              'Manillas',
              style: TextStyle(color: Colors.purpleAccent, fontSize: 18),
            ),
            ..._manillas.entries.map(
              (e) => _campo(
                e.key,
                TextEditingController(text: e.value.toString()),
                isNumber: true,
                onChanged: (val) => _manillas[e.key] = int.tryParse(val) ?? 0,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Combos',
              style: TextStyle(color: Colors.purpleAccent, fontSize: 18),
            ),
            ..._combos.entries.map(
              (e) => _campo(
                e.key,
                TextEditingController(text: e.value.toString()),
                isNumber: true,
                onChanged: (val) => _combos[e.key] = int.tryParse(val) ?? 0,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Guardar cambios solo frontend
                widget.boliche['nombre'] = _nombreCtrl.text;
                widget.boliche['precio'] = int.tryParse(_precioCtrl.text) ?? 0;
                widget.boliche['imagen'] = _imagenCtrl.text;
                widget.boliche['manillas'] = _manillas;
                widget.boliche['combos'] = _combos;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
              ),
              child: const Text(
                'Guardar Cambios',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.purpleAccent),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purpleAccent),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
