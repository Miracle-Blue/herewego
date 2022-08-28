import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/ui/provider.dart';
import 'package:herewego/ui/providers/post_provider.dart';
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

  static Widget init(
      {Post? post,
      required Function(
        String title,
        String content,
        String? imageUrl,
        String? videoUrl,
      )
          onDone}) {
    return ChangeNotifierProvider(
      model: PostVM(post, onDone),
      child: PostDialog(
        post: post,
        onDone: onDone,
      ),
    );
  }

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  final formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late PostVM model;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    model = context.read<PostVM>()!
      ..init(
        _titleController,
        _contentController,
      );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<PostVM>();
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
          title: (model.isEditing != null && model.isEditing!)
              ? const Text("Edit Post")
              : const Text("Add Post"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  model.isUploading
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
            addSaveButton(context, model.isEditing),
          ],
        ),
      ),
    );
  }

  Widget chooseImageField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: (model.imageUrl != null || model.videoUrl != null)
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
                            child: (model.imageUrl != null)
                                ? Image.network(
                                    model.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.play_arrow),
                          ),
                        ),
                        model.isUploading
                            ? const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  IconButton(
                    splashRadius: 16,
                    onPressed: () => model.clearMedia(),
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
      onTap: () => model.pickVideo(ImageSource.gallery),
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
      onTap: () => model.pickImage(source),
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
      onPressed: () => model.cancelFunction(context),
      child: const Text("Cancel"),
    );
  }

  TextButton addSaveButton(BuildContext context, bool? isEditing) {
    return TextButton(
      onPressed: () => model.addFunction(
        context,
        formKey,
        _titleController,
        _contentController,
      ),
      child: (isEditing != null && isEditing)
          ? const Text("Save")
          : const Text("Add"),
    );
  }
}
