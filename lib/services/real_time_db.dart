import 'package:firebase_database/firebase_database.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/log_service.dart';

class RTDBService {
  static const posts = "posts";
  static final database = FirebaseDatabase.instance.ref();

  static Future<Stream<DatabaseEvent>> storePost(Post post) async {
    database.child(posts).push().set(post.toJson());

   "post stored".v;

    return database.onChildAdded;
  }

  static Future<List<Post>> loadPost(String id) async {
    Query _query = database.child(posts).orderByChild("user_id").equalTo(id);
    DatabaseEvent event = await _query.once();

    "post loaded".v;

    return event.snapshot.children
        .map(
          (e) => Post.fromJson(
            Map<String, dynamic>.from(e.value as Map),
          ),
        )
        .toList();
  }

  static Future editPost({required String postKey, required Post post}) async {
    await database.child(posts).child(postKey).update(post.toJson());

    "post edited".v;
  }

  static Future deletePost({required String postKey}) async {
    await database.child(posts).child(postKey).remove();

    "post deleted".v;
  }
}
