class Like {
  final int userId;
  final int boardId;


  Like({
    required this.userId,
    required this.boardId,

  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      userId: json['userId'] as int,
      boardId: json['boardId'] as int,
   );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'boardId': boardId,
  };
}
