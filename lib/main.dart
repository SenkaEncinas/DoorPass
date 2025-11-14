import 'package:doorpass/screens/Admin/AdminBolichesScreen.dart';
import 'package:doorpass/screens/LoginScreen.dart';
import 'package:doorpass/screens/Staff/StaffScreen.dart';
import 'package:doorpass/screens/User/UserHomeScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoorPass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 140, 9, 221),
        ), //https://ibb.co/cSctKMXV
        useMaterial3: true,
      ),
      home: const StaffScreen(),
    );
  }
}
