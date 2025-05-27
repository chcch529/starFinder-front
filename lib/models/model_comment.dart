class Comment {
  final String userId;
  final String boardId;
  final String body;
  final DateTime? createdAt;

  Comment({
    required this.userId,
    required this.boardId,
    required this.body,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userId'] as String? ?? 'null',
      boardId: json['boardId'] as String? ?? 'null',
      body: json['body'] as String? ?? 'null',
      createdAt: json['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'boardId': boardId,
    'body': body,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
