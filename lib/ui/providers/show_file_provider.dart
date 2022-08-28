import 'package:flutter/cupertino.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/log_service.dart';
import 'package:video_player/video_player.dart';

class ShowFileVM extends ChangeNotifier {
  late VideoPlayerController controller;

  void initVideo({
    required Post post,
    required bool finishedPlaying,
  }) {
    if (post.videoPath.isNotEmpty) {
      controller = VideoPlayerController.network(post.videoPath)
        ..initialize().then((value) {
          notifyListeners();
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
      notifyListeners();
    });
  }

  void pressedPlayOrPause({
    required VideoPlayerController controller,
    required bool finishedPlaying,
  }) {
    if (finishedPlaying) {
      controller.play(); // Replay the video
    } else {
      !controller.value.isPlaying ? controller.play() : controller.pause();
    }
    notifyListeners();
  }
}
