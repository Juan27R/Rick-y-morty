import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoUploadForm extends StatefulWidget {
  @override
  _VideoUploadFormState createState() => _VideoUploadFormState();
}

class _VideoUploadFormState extends State<VideoUploadForm> {
  String? _filePath;
  bool _uploading = false;

  Future<void> _selectVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path!;
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_filePath == null) {
      return;
    }

    setState(() {
      _uploading = true;
    });

    try {
      File file = File(_filePath!);
      String fileName = file.path.split('/').last;
      Reference storageRef = FirebaseStorage.instance.ref().child('video/$fileName'); // Corregido
      UploadTask uploadTask = storageRef.putFile(file);
      await uploadTask.whenComplete(() => print('Video uploaded successfully'));

      // Obtener la URL de descarga del video
      String downloadURL = await storageRef.getDownloadURL();
      print('Download URL: $downloadURL');

      // Guardar la referencia del video en Firestore
      await FirebaseFirestore.instance.collection('video').add({
        'name': fileName,
        'url': downloadURL,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Video reference saved to Firestore');
    } catch (error) {
      print('Error uploading video: $error');
    }

    setState(() {
      _uploading = false;
      _filePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _uploading ? null : _selectVideo,
            child: _uploading ? CircularProgressIndicator() : Text('Select Video'),
          ),
          SizedBox(height: 20),
          _filePath != null
              ? Text('Selected Video: $_filePath')
              : SizedBox(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _uploading || _filePath == null ? null : _uploadVideo,
            child: Text('Upload Video'),
          ),
        ],
      ),
    );
  }
}
