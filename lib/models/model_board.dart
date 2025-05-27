class Board {
  final String? boardId;
  final String userId;
  final String body;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int likeCnt;
  final int commentCnt;
  final List<String>? uploadImageUrls;

  Board({
    this.boardId,
    required this.userId,
    required this.body,
    this.createdAt,
    this.updatedAt,
    required this.likeCnt,
    required this.commentCnt,
    this.uploadImageUrls = const [],
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      boardId: json['boardId']as String? ?? 'null',
      userId: json['userId'] as String? ?? 'null',
      body: json['body'] as String? ?? 'null',
      createdAt: json['createdAt']?.toDate(),
      updatedAt: json['updatedAt']?.toDate(),
      likeCnt: json['likeCnt'] as int? ?? 0,
      commentCnt: json['commentCnt'] as int? ?? 0,
      uploadImageUrls: json['uploadImageUrls'] != null ? List<String>.from(json['uploadImageUrls']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'boardId': boardId,
    'userId': userId,
    'body': body,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    'likeCnt': likeCnt,
    'commentCnt': commentCnt,
    'uploadImageUrls': uploadImageUrls,
  };
}


