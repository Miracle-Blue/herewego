import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/ui/provider.dart';
import 'package:herewego/ui/providers/show_file_provider.dart';
import 'package:video_player/video_player.dart';

class ShowFilePage extends StatelessWidget {
  final String postKey;
  final Post post;

  const ShowFilePage({
    Key? key,
    required this.postKey,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      model: ShowFileVM(),
      child: _View(
        post: post,
        postKey: postKey,
      ),
    );
  }
}

class _View extends StatefulWidget {
  final String postKey;
  final Post post;

  const _View({
    Key? key,
    required this.postKey,
    required this.post,
  }) : super(key: key);

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  bool finishedPlaying = false;

  @override
  void initState() {
    super.initState();
    context.read<ShowFileVM>()!.initVideo(
          finishedPlaying: finishedPlaying,
          post: widget.post,
        );
  }

  @override
  void deactivate() {
    super.deactivate();
    context.read<ShowFileVM>()!.controller.dispose();
  }

  @override
  void dispose() {
    Future.microtask(() {

    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ShowFileVM>()!;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: widget.post.videoPath.isNotEmpty
            ? Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: model.controller.value.aspectRatio,
                      child: VideoPlayer(model.controller),
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
    );
  }
}

class PlayPauseReplayButtons extends StatelessWidget {
  const PlayPauseReplayButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final model = context.watch<ShowFileVM>()!;
    final state = context.findAncestorStateOfType<_ViewState>()!;
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.8),
      child: Center(
        child: GestureDetector(
          onTap: () => model.pressedPlayOrPause(
            controller: model.controller,
            finishedPlaying: state.finishedPlaying,
          ),
          child: state.finishedPlaying
              ? const Icon(
                  Icons.replay,
                  color: Colors.red,
                  size: 40.0,
                )
              : (model.controller.value.isPlaying
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
