class Post {
  final int id;
  final String? content;
  final String nickname;
  final String? profileUrl;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.content,
    required this.nickname,
    required this.profileUrl,
    required this.createdAt

  });

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      id: json['id'],
      content: json['content'] as String?,
      nickname: json['nickname'] as String,
      profileUrl: json['profileUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
