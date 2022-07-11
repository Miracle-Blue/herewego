import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:herewego/services/hive_service.dart';
import 'package:herewego/services/log_service.dart';
import 'package:image_picker/image_picker.dart';

class StoreService {
  static final _storage = FirebaseStorage.instance.ref();
  static const folderImage = "image";
  static const folderVideo = "video";

  static Future<String?> getImageUrl(ImageSource source) async {
    final DateTime now = DateTime.now();
    final String storageId = "${now.millisecondsSinceEpoch.toString()}"
        "${HiveDB.loadUserId()}";
    final String today = '${now.month.toString()}-${now.day.toString()}';

    try {
      final file = await ImagePicker().pickImage(source: source);

      Reference ref = _storage.child(folderImage).child(today).child(storageId);
      UploadTask uploadTask = ref.putFile(
        File(file!.path),
        SettableMetadata(contentType: 'image'),
      );

      String? downloadUrl;
      await uploadTask.then((p0) async {
        downloadUrl = await p0.ref.getDownloadURL();
      });

      downloadUrl!.d;

      return downloadUrl;
    } catch (e) {
      e.toString().e;
    }

    return null;
  }

  static Future<String?> uploadToStorage(ImageSource source) async {
    final now = DateTime.now();
    final storageId = "${now.millisecondsSinceEpoch.toString()}"
        "${HiveDB.loadUserId()}";
    final today = '${now.month.toString()}-${now.day.toString()}';

    try {
      final file = await ImagePicker().pickVideo(source: source);

      Reference ref = _storage.child(folderVideo).child(today).child(storageId);
      UploadTask uploadTask = ref.putFile(
        File(file!.path),
        SettableMetadata(contentType: 'video/mp4'),
      );

      String? downloadUrl;
      await uploadTask.then((p0) async {
        downloadUrl = await p0.ref.getDownloadURL();
      });

      downloadUrl!.d;

      return downloadUrl;
    } catch (error) {
      error.toString().e;
    }

    return null;
  }
}
