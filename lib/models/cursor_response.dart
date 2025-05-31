import 'package:seoul/models/post_response.dart';

class CursorResponse {
  final List<PostResponse> content;
  final bool hasNext;
  final int? nextCursor;

  CursorResponse({
    required this.content,
    required this.hasNext,
    this.nextCursor
  });

  factory CursorResponse.fromJson(Map<String, dynamic> json){
    return CursorResponse(
      content: (json['content'] as List)
          .map((e) => PostResponse.fromJson(e))
          .toList(),
      hasNext: json['hasNext'],
        nextCursor: json['nextCursor']
    );
  }
}