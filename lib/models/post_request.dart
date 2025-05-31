class PostRequest{
  final String? content;

  PostRequest({
    this.content
  });

  factory PostRequest.fromJson(Map<String, dynamic> json){
    return PostRequest(
      content: json['content'] as String?
    );
  }
}