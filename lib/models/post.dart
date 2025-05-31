class Post {
  final int id;
  final String? content;
  final String nickname;
  final String? profileUrl;
  final DateTime createdAt;
  final int likeCnt;
  final int commentCnt;
  final int userId;

  Post({
    required this.id,
    required this.content,
    required this.nickname,
    required this.profileUrl,
    required this.createdAt,
    required this.likeCnt,
    required this.commentCnt,
    required this.userId

  });

  factory Post.fromJson(Map<String, dynamic> json){
    return Post(
      id: json['id'],
      content: json['content'] as String?,
      nickname: json['nickname'] as String,
      profileUrl: json['profileUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      likeCnt: json['lickCnt'],
      commentCnt: json['commentCnt'],
      userId: json['userId'],
    );
  }
}
