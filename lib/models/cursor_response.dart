class CursorResponse {
  final List<Post> content;
  final bool hasNext;

  CursorResponse({
    required this.content,
    required this.hasNext,
  });

  factory CursorResponse.fromJson(Map<String, dynamic> json){
    return CursorResponse(
      content: (json['content'] as List)
          .map((e) => Post.fromJson(e))
          .toList(),
      hasNext: json['hasNext']
    ;
  }
}