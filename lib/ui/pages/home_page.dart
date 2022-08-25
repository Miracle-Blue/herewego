import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/auth_service.dart';
import 'package:herewego/services/hive_service.dart';
import 'package:herewego/services/log_service.dart';
import 'package:herewego/services/real_time_db.dart';
import 'package:intl/intl.dart';

import 'post_dialog.dart';
import 'show_file_page.dart';

class HomePage extends StatelessWidget {
  static const id = "/home_page";

  const HomePage({Key? key}) : super(key: key);

  void addPost(
    String title,
    String content,
    String? imageUrl,
    String? videoUrl,
  ) async {
    String id = HiveDB.loadUserId();

    final post = Post(
      userId: id,
      title: title,
      content: content,
      date: DateFormat('hh:mm aaa,' ' EEE, MMM d, ' 'yyyy')
          .format(DateTime.now()),
      imagePath: imageUrl ?? '',
      videoPath: videoUrl ?? '',
    );

    await RTDBService.storePost(post);
  }

  Future<dynamic> addPostDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => PostDialog(
        onDone: addPost,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: FirebaseAnimatedList(
          query: RTDBService.database
              .child('posts')
              .orderByChild('user_id')
              .equalTo(
                HiveDB.loadUserId(),
              ),
          itemBuilder: (
            BuildContext context,
            DataSnapshot snapshot,
            Animation<double> animation,
            int index,
          ) {
            Post item = Post.fromJson(
              jsonDecode(jsonEncode(snapshot.value)),
            );
            String postKey = snapshot.key!;

            return BuildItemCard(
              postKey: postKey,
              post: item,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  void loginOut(BuildContext context) {
    Navigator.pop(context);
    AuthService.signOutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Firebase App"),
      centerTitle: true,
      actions: [
        PopupMenuButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
          ),
          icon: const Icon(CupertinoIcons.xmark_square),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: () => loginOut(context),
                child: const Text("Log Out"),
              ),
              PopupMenuItem(
                onTap: () async => await AuthService.deleteUser(context),
                child: const Text("Delete Account"),
              ),
            ];
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class BuildItemCard extends StatelessWidget {
  final String postKey;
  final Post post;

  const BuildItemCard({
    Key? key,
    required this.postKey,
    required this.post,
  }) : super(key: key);

  void deletePost({required String postKey}) async {
    await RTDBService.deletePost(postKey: postKey);
  }

  void showFilePage({
    required BuildContext context,
    required String postKey,
    required Post post,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) =>
            ShowFilePage(postKey: postKey, post: post),
      ),
    );
  }

  Future<dynamic> editPostDialog({
    required BuildContext context,
    required String postKey,
    required Post post,
  }) {
    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) => PostDialog(
        post: post,
        onDone: (title, content, imageUrl, videoUrl) => editPost(
          post: post,
          postKey: postKey,
          content: content,
          title: title,
          imageUrl: imageUrl,
          videoUrl: videoUrl,
        ),
      ),
    );
  }

  void editPost({
    required String postKey,
    required Post post,
    required String title,
    required String content,
    String? imageUrl,
    String? videoUrl,
  }) async {
    post.title = title;
    post.content = content;
    post.date =
        DateFormat('hh:mm aaa,' ' EEE, MMM d, ' 'yyyy').format(DateTime.now());
    if (imageUrl != null) {
      post.imagePath = imageUrl;
    }

    if (videoUrl != null) {
      post.videoPath = videoUrl;
    }

    post.toJson().toString().e;

    await RTDBService.editPost(postKey: postKey, post: post);
  }

  void cardTapped(BuildContext context) {
    if (post.videoPath.isNotEmpty || post.imagePath.isNotEmpty) {
      showFilePage(
        context: context,
        postKey: postKey,
        post: post,
      );
    } else {
      editPostDialog(
        context: context,
        postKey: postKey,
        post: post,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(21),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      child: Dismissible(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) => deletePost(
          postKey: postKey,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ! Image
              Container(
                height: 100,
                width: 100,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.amber,
                ),
                child: InkWell(
                  onTap: () => cardTapped(context),
                  child: widgets(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        post.date ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    InkWell(
                      onTap: () => editPostDialog(
                        context: context,
                        postKey: postKey,
                        post: post,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Text(
                              post.title ?? "",
                              maxLines: null,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            post.content ?? "",
                            maxLines: null,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget widgets() {
    if (post.imagePath.isNotEmpty) {
      return const ColoredBox(
        color: Colors.red,
        child: Icon(
          Icons.play_arrow,
          size: 40,
          color: Colors.white,
        ),
      );
    } else if (post.videoPath.isNotEmpty) {
      return CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: post.imagePath,
        placeholder: (context, url) => const ColoredBox(
          color: Colors.amber,
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
