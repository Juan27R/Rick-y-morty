import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rickandmortyapp/home/models/video.dart';
import 'package:rickandmortyapp/services/video_service.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? _controller;
  List<Video> _videos = [];
  Map<String, Uint8List> _thumbnails = {};
  String? _currentVideoId;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    List<Video> videos = await VideoService().getVideos();
    Map<String, Uint8List> thumbnails = {};
    for (var video in videos) {
      Uint8List thumbnail = await _generateThumbnail(video.url);
      thumbnails[video.id] = thumbnail;
    }
    setState(() {
      _videos = videos;
      _thumbnails = thumbnails;
    });
  }

  Future<Uint8List> _generateThumbnail(String videoURL) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoURL,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200, // Tamaño más grande para la miniatura
      quality: 75, // Mayor calidad
    );
    return uint8list!;
  }

  Future<void> _deleteVideo(String videoId) async {
    try {
      await VideoService().deleteVideo(videoId);
      await _loadVideos();
      if (_currentVideoId == videoId) {
        setState(() {
          _currentVideoId = null;
          _controller?.dispose();
          _controller = null;
        });
      }
    } catch (e) {
      print('Error al eliminar el video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el video')),
      );
    }
  }

  Future<void> _uploadVideo(File file) async {
    try {
      String fileName = file.path.split('/').last;
      print('Subiendo archivo: $fileName');
      String downloadURL = await VideoService().uploadVideo(file, fileName);
      print('URL de descarga: $downloadURL');
      await VideoService().addVideo(downloadURL, fileName);
      await _loadVideos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video cargado exitosamente')),
      );
    } catch (e) {
      print('Error al cargar el video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el video: $e')),
      );
    }
  }

  void _playVideo(String url, String videoId) {
    if (_controller != null) {
      _controller!.dispose();
    }
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {
          _currentVideoId = videoId;
          _controller!.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/rickandmorty.jpg', // Ruta de la imagen de Rick y Morty
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_controller != null && _controller!.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          Expanded(
            child: Container(
              color: Color.fromARGB(255, 0, 255, 4), // Fondo verde
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Dos columnas
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  final video = _videos[index];
                  final thumbnail = _thumbnails[video.id];
                  return GestureDetector(
                    onTap: () {
                      _playVideo(video.url, video.id);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (thumbnail != null)
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                              child: Image.memory(
                                thumbnail,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 120,
                              ),
                            ),
                          Expanded(
                            child: Center(
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Eliminar Video'),
                                      content: Text('¿Estás seguro de que quieres eliminar este video?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteVideo(video.id);
                                          },
                                          child: Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
              if (result != null) {
                File file = File(result.files.single.path!);
                _uploadVideo(file);
              }
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              // Aquí debes implementar la lógica para reproducir un video en local
            },
            child: Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}
