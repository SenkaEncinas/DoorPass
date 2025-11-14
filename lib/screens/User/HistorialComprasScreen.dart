import 'package:flutter/material.dart';

class HistorialComprasScreen extends StatelessWidget {
  const HistorialComprasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D014F),
        title: const Text("Historial de Compras"),
      ),
      body: const Center(
        child: Text(
          "Aquí irá tu historial ✨",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
