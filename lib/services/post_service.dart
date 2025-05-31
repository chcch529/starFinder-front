import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cursor_response.dart';
import '../models/post_request.dart';

class PostService {
  final String baseUrl = 'http://localhost:8080/api/posts';

  Future<CursorResponse> fetchPosts({int? cursor, int size = 10}) async {
    final url = Uri.parse(baseUrl).replace(
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

  Future<void> createPost(PostRequest postRequest) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(postRequest)
    );

    if (response.statusCode == 200) {
      print('게시글 생성 성공: ${response.body}');
    } else {
      throw Exception('게시글을 생성하는 데 실패했습니다');
    }
  }

  Future<void> updatePost(PostRequest postRequest, int postId) async {
    final url = Uri.parse('$baseUrl/$postId');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode(postRequest)
    );

    if (response.statusCode == 200) {
      print('게시글 수정 성공: ${response.body}');
    } else {
      throw Exception('게시글을 수정하는 데 실패했습니다');
    }
  }

  Future<void> deletePost(int postId) async {
    final url = Uri.parse('$baseUrl/$postId');

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      print('게시글 삭제 성공: ${response.body}');
    } else {
      throw Exception('게시글을 삭제하는 데 실패했습니다');
    }
  }
}
