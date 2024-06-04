import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rickandmortyapp/home/models/video.dart';

class VideoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<Video>> getVideos() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('videos').get();
    return snapshot.docs.map((doc) => Video.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  Future<void> addVideo(String url, String title) async {
    try {
      await _firestore.collection('videos').add({
        'url': url,
        'title': title,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al agregar el video: $e');
      throw e;
    }
  }

  Future<void> deleteVideo(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).delete();
    } catch (e) {
      print('Error al eliminar el video: $e');
      throw e;
    }
  }

  Future<String> uploadVideo(File file, String fileName) async {
    try {
      final ref = _storage.ref().child('videos/$fileName'); // Corregido
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
      print('Error al subir el video: $e');
      throw e;
    }
  }
}
