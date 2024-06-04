import 'package:flutter/material.dart';
import 'package:rickandmortyapp/home/models/character.dart';
import 'package:rickandmortyapp/home/screens/widgets/display-image.dart';
import 'package:video_player/video_player.dart';

class CharacterCard extends StatefulWidget {
  final CharacterDTO character;
  final String? videoUrl;

  const CharacterCard({Key? key, required this.character, this.videoUrl}) : super(key: key);

  @override
  _CharacterCardState createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  late VideoPlayerController? _controller;
  late Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _controller = VideoPlayerController.network(widget.videoUrl!);
      _initializeVideoPlayerFuture = _controller!.initialize();
    }
  }

  @override
  void dispose() {
    if (widget.videoUrl != null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 0, 255, 34).withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          DisplayImage(urlImage: widget.character.image ?? ""),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.character.name ?? " ",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black.withOpacity(0.8),
                  ),
                  softWrap: true,
                ),
                SizedBox(height: 3),
                Text(
                  widget.character.species ?? " ",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  softWrap: true,
                ),
                SizedBox(height: 3),
                Text(
                  widget.character.status ?? " ",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          if (widget.videoUrl != null)
            SizedBox(
              width: 100,
              height: 100,
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
