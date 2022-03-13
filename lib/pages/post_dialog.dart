import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/log_service.dart';
import 'package:herewego/services/store_service.dart';
import 'package:image_picker/image_picker.dart';

class PostDialog extends StatefulWidget {
  final Post? post;
  final Function(String title, String content, String? imageUrl, String? videoUrl) onDone;

  const PostDialog({Key? key, this.post, required this.onDone})
      : super(key: key);

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  final formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  File? _image;
  String? _video;
  String? imageUrl;
  bool isUploading = false;
  late final bool isEditing;

  void pickImage(ImageSource source) async {
    try {
      ImagePicker().pickImage(source: source).then((value) async {
        if (value != null) {
          Log.d(value.path);

          setState(() {
            _image = File(value.path);
            isUploading = true;
          });

          if (_image != null) {
            await StoreService.getImageUrl(_image!).then((value) {
              if (value != null) {
                imageUrl = value;
              }
            });

            if (mounted) {
              setState(() {
                isUploading = false;
              });
            }
          }
        }
      });
    } on PlatformException catch (e) {
      Log.e("Failed to pick image $e");
    }
  }

  void pickVideo()  async {
    await StoreService.uploadToStorage().then((value) {
      _video = value;
    });
  }

  void addFunction() {
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      final title = _titleController.text;
      final content = _contentController.text;

      Log.d(imageUrl.toString());
      Log.d(_video.toString());

      widget.onDone(title, content, imageUrl, _video);
      Navigator.pop(context);
    }
  }

  void cancelFunction() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    isEditing = widget.post != null;

    if (widget.post != null) {
      final post = widget.post!;

      _titleController.text = post.title!;
      _contentController.text = post.content!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 2,
          sigmaY: 2,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: isEditing ? const Text("Edit Post") : const Text("Add Post"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  chooseImageField(),
                  const SizedBox(height: 8),
                  titleField(),
                  const SizedBox(height: 8),
                  contentField(),
                ],
              ),
            ),
          ),
          actions: [
            cancelButton(context),
            addSaveButton(context, isEditing),
          ],
        ),
      ),
    );
  }

  Widget chooseImageField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _image != null || _video != null
          ? [
              Row(
                children: [
                  const SizedBox(width: 40),
                  Container(
                    height: 62,
                    width: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        isUploading
                            ? const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  IconButton(
                    splashRadius: 16,
                    onPressed: () {
                      setState(() {
                        _image = null;
                        _video = null;
                      });
                    },
                    icon: const Icon(CupertinoIcons.clear_circled),
                  ),
                ],
              )
            ]
          : [
              imageField(
                  source: ImageSource.camera,
                  image: "assets/icons/ic_camera.png"),
              imageField(
                  source: ImageSource.gallery,
                  image: "assets/icons/ic_image.png"),
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.grey.shade600,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: () => pickVideo(),
                    child: const SizedBox(
                      height: 60,
                      width: 60,
                      child: Icon(Icons.play_arrow),
                    ),
                  ),
                ),
              ),
            ],
    );
  }

  Container imageField({required ImageSource source, required String image}) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade600, width: 1.5)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: () => pickImage(source),
          child: SizedBox(
            height: 60,
            width: 60,
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  TextFormField titleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(21)),
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(21)),
        ),
        hintText: 'Enter Title',
      ),
      validator: (name) => name != null && name.isEmpty ? 'Enter Title' : null,
    );
  }

  TextFormField contentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(21)),
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(21)),
        ),
        hintText: 'Enter Content',
      ),
      validator: (country) =>
          country != null && country.isEmpty ? 'Enter Content' : null,
    );
  }

  TextButton cancelButton(BuildContext context) {
    return TextButton(
      onPressed: cancelFunction,
      child: const Text("Cancel"),
    );
  }

  TextButton addSaveButton(BuildContext context, bool isEditing) {
    return TextButton(
      onPressed: addFunction,
      child: isEditing ? const Text("Save") : const Text("Add"),
    );
  }
}
