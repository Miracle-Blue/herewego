import 'package:firebase_database/firebase_database.dart';
import 'package:herewego/models/post_model.dart';
import 'package:herewego/services/log_service.dart';


class RTDBService {
  static const posts = "posts";
  static final _database = FirebaseDatabase.instance.ref();

  static Future<Stream<DatabaseEvent>> storePost(Post post) async {
    _database.child(posts).push().set(post.toJson());
    Log.d("post stored");
    return _database.onChildAdded;
  }

  static Future<List<Post>> loadPost(String id) async {
    Query _query = _database.child(posts).orderByChild("user_id").equalTo(id);
    DatabaseEvent event = await _query.once();
    Log.d("post loaded");
    return event.snapshot.children.map((e) => Post.fromJson(Map<String, dynamic>.from(e.value as Map))).toList();
  }

  static Future editPost({required String postKey, required Post post}) async {
    await _database.child(posts).child(postKey).update(post.toJson());
    Log.d("post edited");
  }

  static Future deletePost({required String postKey}) async {
    await _database.child(posts).child(postKey).remove();
    Log.d("post deleted");
  }
}