class PostService {

  Future<CursorResponse> fetchPosts({int? cursor, int size = 10}) async {
    final uri = Uri.parse('https://localhost:8080/api/posts').replace(
        queryParameters: {
          if (cursor != null) 'cursor': '$cursor',
          'size': '$size'
        });

    final response = await http.get(url);
    if (response.statusCode == 200){
      return CursorResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('게시글을 불러오는 데 실패했습니다');
    }
  }
}
