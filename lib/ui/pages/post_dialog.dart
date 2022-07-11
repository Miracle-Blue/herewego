import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/log_service.dart';
import 'package:herewego/services/store_service.dart';
import 'package:image_picker/image_picker.dart';

class PostDialog extends StatefulWidget {
  final Post? post;
  final Function(
    String title,
    String content,
    String? imageUrl,
    String? videoUrl,
  ) onDone;

  const PostDialog({
    Key? key,
    this.post,
    required this.onDone,
  }) : super(key: key);

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  final formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _videoUrl;
  String? _imageUrl;
  bool isUploading = false;
  late final bool isEditing;

  void load(bool value) {
    isUploading = value;
    setState(() {});
  }

  void pickImage(ImageSource source) async {
    load(true);
    _imageUrl = await StoreService.getImageUrl(source);
    _videoUrl = '';
    load(false);
  }

  void pickVideo(ImageSource source) async {
    load(true);
    _videoUrl = await StoreService.uploadToStorage(source);
    _imageUrl = '';
    load(false);
  }

  void addFunction() {
    final isValid = formKey.currentState!.validate();

    if (isValid) {
      final title = _titleController.text;
      final content = _contentController.text;

      _imageUrl.toString().d;
      _videoUrl.toString().d;

      widget.onDone(title, content, _imageUrl, _videoUrl);
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
                  isUploading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(),
                        )
                      : chooseImageField(),
                  const SizedBox(height: 8),
                  textField(
                    controller: _titleController,
                    hintText: 'Enter Title',
                    validator: (name) =>
                        name != null && name.isEmpty ? 'Enter Title' : null,
                  ),
                  const SizedBox(height: 8),
                  textField(
                    controller: _contentController,
                    hintText: 'Enter Content',
                    validator: (country) => (country != null && country.isEmpty)
                        ? 'Enter Content'
                        : null,
                  )
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
      children: (_imageUrl != null || _videoUrl != null)
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
                            child: (_imageUrl != null)
                                ? Image.network(
                                    _imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.play_arrow),
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
                        _imageUrl = null;
                        _videoUrl = null;
                      });
                    },
                    icon: const Icon(CupertinoIcons.clear_circled),
                  ),
                ],
              )
            ]
          : [
              pickWidget(
                pick: imagePickWidget(
                  source: ImageSource.camera,
                  image: "assets/icons/ic_camera.png",
                ),
              ),
              pickWidget(
                pick: imagePickWidget(
                  source: ImageSource.gallery,
                  image: "assets/icons/ic_image.png",
                ),
              ),
              pickWidget(pick: videoPickWidget()),
            ],
    );
  }

  List<Widget> pickImageWidgets() => [
        pickWidget(
          pick: imagePickWidget(
            source: ImageSource.camera,
            image: "assets/icons/ic_camera.png",
          ),
        ),
        pickWidget(
          pick: imagePickWidget(
            source: ImageSource.gallery,
            image: "assets/icons/ic_image.png",
          ),
        ),
        pickWidget(pick: videoPickWidget()),
      ];

  Container pickWidget({required Widget pick}) {
    return Container(
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
        child: pick,
      ),
    );
  }

  InkWell videoPickWidget() {
    return InkWell(
      onTap: () => pickVideo(ImageSource.gallery),
      child: const SizedBox(
        height: 60,
        width: 60,
        child: Icon(Icons.play_arrow),
      ),
    );
  }

  InkWell imagePickWidget({
    required ImageSource source,
    required String image,
  }) {
    return InkWell(
      onTap: () => pickImage(source),
      child: SizedBox(
        height: 60,
        width: 60,
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget textField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      maxLines: null,
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(21)),
          borderSide: BorderSide(
            color: Colors.black,
          ),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(21)),
        ),
        hintText: hintText,
      ),
      validator: validator,
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
