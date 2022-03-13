import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/pages/check_deleting_account_page.dart';
import 'package:herewego/pages/show_file_page.dart';
import 'package:herewego/services/auth_service.dart';
import 'package:herewego/services/hive_service.dart';
import 'package:herewego/services/log_service.dart';
import 'package:herewego/services/real_time_db.dart';

import 'post_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const id = "/home_page";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference reference = FirebaseDatabase.instance.ref().child("posts");

  void loginOut() {
    AuthService.signOutUser(context);
  }

  void deleteAccount() {
    Navigator.pushNamed(context, CheckAccountPage.id);
  }

  void addPost(
      String title, String content, String? imageUrl, String? videoUrl) async {
    String id = HiveDB.loadUserId();

    final post = Post(
        userId: id,
        title: title,
        content: content,
        imagePath: imageUrl,
        videoPath: videoUrl);

    await RTDBService.storePost(post);
  }

  void editPost(
      {required String postKey,
      required Post post,
      required String title,
      required String content,
      String? imageUrl,
      String? videoUrl}) async {
    post.title = title;
    post.content = content;
    if (imageUrl != null) {
      post.imagePath = imageUrl;
    }

    Log.e(post.toJson().toString());

    await RTDBService.editPost(postKey: postKey, post: post);
  }

  void deletePost({required String postKey}) async {
    await RTDBService.deletePost(postKey: postKey);
  }

  Future<dynamic> addPostDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => PostDialog(
        onDone: addPost,
      ),
    );
  }

  Future<dynamic> editPostDialog(
      {required String postKey, required Post post}) {
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

  void showFilePage({required String postKey, required Post post}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            ShowFilePage(postKey: postKey, post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: FirebaseAnimatedList(
          query: reference.orderByChild("user_id").equalTo(HiveDB.loadUserId()),
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Post item = Post.fromJson(jsonDecode(jsonEncode(snapshot.value)));
            String postKey = snapshot.key!;
            return buildItem(postKey: postKey, post: item);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text("Firebase App"),
      centerTitle: true,
      actions: [
        PopupMenuButton(
          icon: const Icon(Icons.exit_to_app),
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                onTap: loginOut,
                child: const Text("Log Out"),
              ),
              PopupMenuItem(
                onTap: deleteAccount,
                child: const Text("Delete Account"),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget buildItem({required String postKey, required Post post}) {
    double height = MediaQuery.of(context).size.height;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(21),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: Colors.white,
      child: Dismissible(
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) => deletePost(postKey: postKey),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: height * 0.13,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ! Image
                  Container(
                    height: MediaQuery.of(context).size.height * 0.09,
                    width: MediaQuery.of(context).size.height * 0.09,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.amber,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        onTap: () =>
                            (post.videoPath != null || post.imagePath != null)
                                ? showFilePage(postKey: postKey, post: post)
                                : editPostDialog(postKey: postKey, post: post),
                        child: Hero(
                          tag: postKey,
                          child: (post.videoPath != null ||
                                  post.imagePath != null)
                              ? ((post.videoPath != null)
                                  ? Container(
                                      color: Colors.red,
                                      child: const Icon(
                                        Icons.play_arrow,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: post.imagePath ?? "",
                                      placeholder: (context, url) => Container(
                                        color: Colors.amber,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ))
                              : Container(
                                  color: Colors.red,
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => editPostDialog(postKey: postKey, post: post),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          post.title ?? "",
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          post.date ?? "",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          post.content ?? "",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
