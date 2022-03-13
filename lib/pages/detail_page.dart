import 'package:flutter/material.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/hive_service.dart';
import 'package:herewego/services/log_service.dart';
import 'package:herewego/services/real_time_db.dart';

import 'home_page.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  static const id = "/detail_page";

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void storeNewPost() async {
    Post post = Post();

    post.userId = HiveDB.loadUserId();
    post.title = _titleController.text.trim().toString();
    post.content = _contentController.text.trim().toString();

    await RTDBService.storePost(post).then((value) {
      Log.d(value.toString());
      Navigator.pushReplacementNamed(context, HomePage.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              textField(controller: _titleController, text: "Title"),
              const SizedBox(height: 10),
              textField(controller: _contentController, text: "Content"),
              const SizedBox(height: 10),
              MaterialButton(
                color: Colors.amber,
                minWidth: MediaQuery.of(context).size.width,
                height: 55,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
                onPressed: storeNewPost,
                child: const Text("Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField textField(
      {required String text, required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: text,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }
}
