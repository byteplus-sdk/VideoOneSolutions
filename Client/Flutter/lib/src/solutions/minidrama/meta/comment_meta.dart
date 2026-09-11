class Comment {
  String? content;
  String? name;
  int? uid;
  String? createTime;
  int? like;
  bool liked = false;

  Comment({this.content, this.name, this.uid, this.createTime, this.like});

  @override
  String toString() {
    return 'Comment(content: $content, name: $name, uid: $uid, createTime: $createTime, like: $like)';
  }

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        content: json['content'] as String?,
        name: json['name'] as String?,
        uid: json['uid'] as int?,
        createTime: json['createTime'] as String?,
        like: json['like'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'content': content,
        'name': name,
        'uid': uid,
        'createTime': createTime,
        'like': like,
      };
}
