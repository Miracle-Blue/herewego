import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/log_service.dart';
import 'package:video_player/video_player.dart';

class ShowFilePage extends StatefulWidget {
  ShowFilePage({Key? key, required this.postKey, required this.post})
      : super(key: key);

  String postKey;
  Post post;

  @override
  _ShowFilePageState createState() => _ShowFilePageState();
}

class _ShowFilePageState extends State<ShowFilePage> {
  late VideoPlayerController controller;
  bool finishedPlaying = false;

  void initVideo() {
    if (widget.post.videoPath != null) {
      controller = VideoPlayerController.network(widget.post.videoPath!)
        ..initialize().then((value) {
          setState(() {});
        });
    } else {
      try {
        controller = VideoPlayerController.network("");
      } catch (e, s) {
        Log.d(s.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    initVideo();

    controller.addListener(() {
      if (controller.value.duration == controller.value.position) {
        setState(() {
          finishedPlaying = true;
        });
      } else {
        setState(() {
          finishedPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Hero(
          tag: widget.postKey,
          child: widget.post.videoPath != null
              ? Stack(
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    ),
                    SizedBox(
                        height: size.height,
                        width: size.width,
                        child: playPauseReplayButtons()),
                  ],
                )
              : CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.post.imagePath!,
                  placeholder: (context, url) => Container(
                    color: Colors.amber,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
        ),
      ),
    );
  }

  Widget playPauseReplayButtons() {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.8),
      child: Center(
        child: GestureDetector(
          onTap: () => setState(() {
            if (finishedPlaying) {
              controller.play(); // Replay the video
            } else {
              !controller.value.isPlaying
                  ? controller.play()
                  : controller.pause();
            }
          }),
          child: finishedPlaying
              ? const Icon(
                  Icons.replay,
                  color: Colors.red,
                  size: 40.0,
                )
              : (controller.value.isPlaying
                  ? const Icon(
                      Icons.pause,
                      color: Colors.red,
                      size: 40.0,
                    )
                  : const Icon(
                      Icons.play_arrow,
                      color: Colors.red,
                      size: 40.0,
                    )),
        ),
      ),
    );
  }
}
