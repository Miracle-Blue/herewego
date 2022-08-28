import 'package:flutter/cupertino.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/log_service.dart';
import 'package:herewego/services/store_service.dart';
import 'package:image_picker/image_picker.dart';

class PostVM extends ChangeNotifier {
  Post? post;
  Function(
    String title,
    String content,
    String? imageUrl,
    String? videoUrl,
  ) onDone;

  String? videoUrl;
  String? imageUrl;
  bool isUploading = false;
  bool? isEditing;

  PostVM(this.post, this.onDone);

  void init(
    TextEditingController _titleController,
    TextEditingController _contentController,
  ) {
    isEditing = post != null;

    if (post != null) {
      _titleController.text = post!.title!;
      _contentController.text = post!.content!;
    }
  }

  void load(bool value) {
    isUploading = value;
    notifyListeners();
  }

  void pickImage(ImageSource source) async {
    load(true);
    imageUrl = await StoreService.getImageUrl(source);
    videoUrl = '';
    load(false);
  }

  void pickVideo(ImageSource source) async {
    load(true);
    videoUrl = await StoreService.uploadToStorage(source);
    imageUrl = '';
    load(false);
  }

  void clearMedia() {
    imageUrl = null;
    videoUrl = null;

    notifyListeners();
  }

  void addFunction(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController _titleController,
    TextEditingController _contentController,
  ) {
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      final title = _titleController.text;
      final content = _contentController.text;

      imageUrl.toString().d;
      videoUrl.toString().d;

      onDone(title, content, imageUrl, videoUrl);
      Navigator.pop(context);
    }
  }

  void cancelFunction(BuildContext context) {
    Navigator.pop(context);
  }
}
