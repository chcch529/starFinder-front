import 'package:seoul/models/post.dart';

class CursorResponse {
  final List<Post> content;
  final bool hasNext;
  final int? nextCurosr;

  CursorResponse({
    required this.content,
    required this.hasNext,
    this.nextCurosr
  });

  factory CursorResponse.fromJson(Map<String, dynamic> json){
    return CursorResponse(
      content: (json['content'] as List)
          .map((e) => Post.fromJson(e))
          .toList(),
      hasNext: json['hasNext'],
      nextCurosr: json['nextCursor']
    );
  }
}