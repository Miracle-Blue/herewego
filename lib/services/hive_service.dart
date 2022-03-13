import 'package:hive/hive.dart';

class HiveDB {
  static String DB_NAME = "flutter_b14";
  static var box = Hive.box(DB_NAME);

  static void storeUserId(String id) async {
    box.put("userId", id);
  }

  static String loadUserId() {
    String id = box.get("userId") ?? "";
    return id;
  }

  static void removeUserId() async {
    box.delete("userId");
  }
}