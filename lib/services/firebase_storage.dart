import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Método para subir un archivo a Firebase Storage
  static Future<String> uploadFile(String filePath, String fileName) async {
    try {
      // Crear una referencia al archivo en Firebase Storage
      Reference ref = _storage.ref().child(fileName);
      
      // Subir el archivo a Firebase Storage
      await ref.putFile(File(filePath));
      
      // Obtener la URL de descarga del archivo
      String downloadURL = await ref.getDownloadURL();
      
      return downloadURL;
    } catch (e) {
      print('Error al subir el archivo: $e');
      rethrow; // Reenvía la excepción para que sea manejada fuera de este método si es necesario
    }
  }

  // Método para descargar un archivo de Firebase Storage
  static Future<String> downloadFile(String fileName) async {
    try {
      // Crear una referencia al archivo en Firebase Storage
      Reference ref = _storage.ref().child(fileName);
      
      // Obtener la URL de descarga del archivo
      String downloadURL = await ref.getDownloadURL();
      
      return downloadURL;
    } catch (e) {
      print('Error al descargar el archivo: $e');
      rethrow; // Reenvía la excepción para que sea manejada fuera de este método si es necesario
    }
  }
}
