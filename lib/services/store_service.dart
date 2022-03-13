import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:herewego/services/hive_service.dart';
import 'package:herewego/services/log_service.dart';
import 'package:image_picker/image_picker.dart';

class StoreService {
  static final DateTime now = DateTime.now();
  static final String storageId =
      "${now.millisecondsSinceEpoch.toString()}${HiveDB.loadUserId()}";
  static final String today = ('${now.month.toString()}-${now.day.toString()}');

  static final _storage = FirebaseStorage.instance.ref();
  static const folderImage = "image";
  static const folderVideo = "video";

  static Future<String?> getImageUrl(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source);

      Reference ref = _storage.child(folderImage).child(today).child(storageId);
      UploadTask uploadTask =
          ref.putFile(File(file!.path), SettableMetadata(contentType: 'image'));

      String? downloadUrl;
      await uploadTask.then((p0) async {
        downloadUrl = await p0.ref.getDownloadURL();
      });
      Log.d(downloadUrl!);

      return downloadUrl;
    } catch (e) {
      Log.d(e.toString());
      return null;
    }
  }

  static Future<String?> uploadToStorage(ImageSource source) async {
    try {
      final file = await ImagePicker().pickVideo(source: source);

      Reference ref = _storage.child(folderVideo).child(today).child(storageId);
      UploadTask uploadTask = ref.putFile(
          File(file!.path), SettableMetadata(contentType: 'video/mp4'));

      String? downloadUrl;
      await uploadTask.then((p0) async {
        downloadUrl = await p0.ref.getDownloadURL();
      });
      Log.d(downloadUrl!);

      return downloadUrl;
    } catch (error) {
      Log.d(error.toString());
      return null;
    }
  }
}
