import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rickandmortyapp/home/models/video.dart';

class VideoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Obtener la lista de videos desde Firestore
  Future<List<Video>> getVideos() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('videos').get();
      // Mapear los documentos a objetos Video y devolver una lista
      return snapshot.docs.map((doc) => Video.fromJson({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      // Manejar errores e imprimir mensaje de error
      print('Error al obtener los videos: $e');
      throw Exception('Error al obtener los videos');
    }
  }

  // Agregar un nuevo video a Firestore
  Future<void> addVideo(String url, String title) async {
    try {
      await _firestore.collection('videos').add({
        'url': url,
        'title': title,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Manejar errores e imprimir mensaje de error
      print('Error al agregar el video: $e');
      throw Exception('Error al agregar el video');
    }
  }

  // Eliminar un video de Firestore
  Future<void> deleteVideo(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).delete();
    } catch (e) {
      // Manejar errores e imprimir mensaje de error
      print('Error al eliminar el video: $e');
      throw Exception('Error al eliminar el video');
    }
  }

  // Subir un video a Firebase Storage
  Future<String> uploadVideo(File file, String fileName) async {
    try {
      final ref = _storage.ref('videos/$fileName');
      TaskSnapshot snapshot = await ref.putFile(file);

      if (snapshot.state == TaskState.success) {
        String downloadURL = await ref.getDownloadURL();
        return downloadURL;
      } else {
        throw FirebaseException(
          plugin: 'firebase_storage',
          message: 'Error al subir el archivo: ${snapshot.state}',
        );
      }
    } catch (e) {
      // Manejar errores e imprimir mensaje de error
      print('Error al subir el video: $e');
      throw Exception('Error al subir el video');
    }
  }
}
