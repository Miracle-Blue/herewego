class Post {
  String? userId;
  String? title;
  String? content;
  String? date;
  String? imagePath;
  String? videoPath;

  Post({this.userId, this.title, this.content, this.date, this.imagePath, this.videoPath});

  Post.fromJson(Map<String, dynamic> json) : userId = json["user_id"], title = json["title"], content = json["content"], date = json["date"], imagePath = json["image_path"], videoPath = json["video_path"];

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'title': title,
    'content': content,
    'date': date,
    'image_path': imagePath,
    'video_path': videoPath,
  };
}