import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:herewego/services/hive_service.dart';
import 'package:herewego/services/log_service.dart';
import 'package:image_picker/image_picker.dart';

class StoreService {
  static final _storage = FirebaseStorage.instance.ref();
  static const folder = "image_folder";

  static Future<String?> getImageUrl(File _imagePath) async {
    String? _downloadUrl;
    String imageName = "image_${DateTime.now().toIso8601String()}";
    await _storage.child(folder).child(imageName).putFile(_imagePath).then((p0) async {
      if (p0.metadata != null) {
        _downloadUrl = await p0.ref.getDownloadURL();
      } else {
        return null;
      }
    });
    return _downloadUrl;
  }

  static Future<String?> uploadToStorage() async {
    try {
      final DateTime now = DateTime.now();
      final int millSeconds = now.millisecondsSinceEpoch;
      final String month = now.month.toString();
      final String date = now.day.toString();
      final String storageId = (millSeconds.toString() + HiveDB.loadUserId());
      final String today = ('$month-$date');

      final file =  await ImagePicker().pickVideo(source: ImageSource.gallery);

      Reference ref = FirebaseStorage.instance.ref().child("video").child(today).child(storageId);
      UploadTask uploadTask = ref.putFile(File(file!.path), SettableMetadata(contentType: 'video/mp4'));

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