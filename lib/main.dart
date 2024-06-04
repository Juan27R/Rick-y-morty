import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rickandmortyapp/auth/login.dart';
import 'package:rickandmortyapp/home/controllers/video_screen.dart';
import 'package:rickandmortyapp/home/screens/ui/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Inicializar Firebase y manejar errores
  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Manejar errores de inicialización de Firebase
      print('Error initializing Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Muestra un indicador de carga mientras se inicializa Firebase
          return CircularProgressIndicator();
        } else {
          // Una vez que Firebase se ha inicializado, muestra la aplicación
          return MaterialApp(
            title: 'My App',
            home: MyHome(),
          );
        }
      },
    );
  }
}
