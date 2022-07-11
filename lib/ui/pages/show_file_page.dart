import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/log_service.dart';
import 'package:video_player/video_player.dart';

class ShowFilePage extends StatefulWidget {
  final String postKey;
  final Post post;

  const ShowFilePage({
    Key? key,
    required this.postKey,
    required this.post,
  }) : super(key: key);

  @override
  _ShowFilePageState createState() => _ShowFilePageState();
}

class _ShowFilePageState extends State<ShowFilePage> {
  late VideoPlayerController controller;
  bool finishedPlaying = false;

  void initVideo() {
    if (widget.post.videoPath.isNotEmpty) {
      controller = VideoPlayerController.network(widget.post.videoPath)
        ..initialize().then((value) {
          setState(() {});
        });
    } else {
      try {
        controller = VideoPlayerController.network("");
      } catch (e, s) {
        s.toString().e;
      }
    }

    controller.addListener(() {
      if (controller.value.duration == controller.value.position) {
        finishedPlaying = true;
      } else {
        finishedPlaying = false;
      }
      setState(() {});
    });
  }

  void pressedPlayOrPause() {
    if (finishedPlaying) {
      controller.play(); // Replay the video
    } else {
      !controller.value.isPlaying ? controller.play() : controller.pause();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initVideo();
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
          child: widget.post.videoPath.isNotEmpty
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
                      child: const PlayPauseReplayButtons(),
                    ),
                  ],
                )
              : CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.post.imagePath,
                  placeholder: (context, url) => const ColoredBox(
                    color: Colors.amber,
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
        ),
      ),
    );
  }
}

class PlayPauseReplayButtons extends StatelessWidget {
  const PlayPauseReplayButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final state = context.findAncestorStateOfType<_ShowFilePageState>()!;
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.8),
      child: Center(
        child: GestureDetector(
          onTap: state.pressedPlayOrPause,
          child: state.finishedPlaying
              ? const Icon(
                  Icons.replay,
                  color: Colors.red,
                  size: 40.0,
                )
              : (state.controller.value.isPlaying
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
