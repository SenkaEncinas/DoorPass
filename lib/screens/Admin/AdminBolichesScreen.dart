// lib/screens/admin_boliches_screen.dart
import 'package:doorpass/screens/Admin/EditarBolicheScreen.dart';
import 'package:flutter/material.dart';
import 'package:doorpass/screens/LoginScreen.dart';

class AdminBolichesScreen extends StatefulWidget {
  const AdminBolichesScreen({super.key});

  @override
  State<AdminBolichesScreen> createState() => _AdminBolichesScreenState();
}

class _AdminBolichesScreenState extends State<AdminBolichesScreen> {
  // Lista temporal de boliches (frontend)
  final List<Map<String, dynamic>> boliches = [
    {
      'nombre': 'Boliche Eclipse',
      'precio': 120,
      'imagen': 'https://picsum.photos/200',
      'manillas': {'Normal': 120, 'VIP': 200, 'Super VIP': 350, 'Mesa': 500},
      'combos': {'Pack 1': 50, 'Pack 2': 80},
    },
    {
      'nombre': 'Club Nocturno Lunar',
      'precio': 150,
      'imagen': 'https://picsum.photos/201',
      'manillas': {'Normal': 150, 'VIP': 250, 'Super VIP': 400, 'Mesa': 600},
      'combos': {'Pack 1': 60, 'Pack 2': 90},
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0014),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A0DAD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
        title: const Text(
          'Administrador de Boliches',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9D00FF),
        onPressed: () => _mostrarDialogoCrear(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: boliches.length,
        itemBuilder: (context, index) {
          final item = boliches[index];
          return Card(
            color: const Color(0xFF1A0026),
            elevation: 6,
            shadowColor: Colors.purpleAccent,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              textColor: Colors.white,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item['imagen'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.black26,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                        ),
                      ),
                ),
              ),
              title: Text(
                item['nombre'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                'Precio base: Bs. ${item['precio']}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => EditarBolicheScreen(boliche: item),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmarEliminar(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A0026),
            title: const Text(
              'Eliminar boliche',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              '¿Estás seguro que quieres eliminar este boliche?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  setState(() => boliches.removeAt(index));
                  Navigator.pop(context);
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _mostrarDialogoCrear() {
    final nombreController = TextEditingController();
    final precioController = TextEditingController();
    final imagenController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => _dialogBase(
            titulo: 'Crear nuevo boliche',
            nombreController: nombreController,
            precioController: precioController,
            imagenController: imagenController,
            onConfirm: () {
              setState(() {
                boliches.add({
                  'nombre':
                      nombreController.text.isEmpty
                          ? 'Sin nombre'
                          : nombreController.text,
                  'precio': int.tryParse(precioController.text) ?? 0,
                  'imagen':
                      imagenController.text.isEmpty
                          ? 'https://placehold.co/200x200'
                          : imagenController.text,
                  'manillas': {
                    'Normal': 0,
                    'VIP': 0,
                    'Super VIP': 0,
                    'Mesa': 0,
                  },
                  'combos': {},
                });
              });
              Navigator.pop(context);
            },
          ),
    );
  }

  Widget _dialogBase({
    required String titulo,
    required TextEditingController nombreController,
    required TextEditingController precioController,
    required TextEditingController imagenController,
    required VoidCallback onConfirm,
  }) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A0026),
      title: Text(titulo, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _campoTexto('Nombre', nombreController),
          _campoTexto('Precio base', precioController, isNumber: true),
          _campoTexto('URL de imagen', imagenController),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9D00FF),
          ),
          onPressed: onConfirm,
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white38),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.purpleAccent),
          ),
        ),
      ),
    );
  }
}
