import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seoul/models/post_response.dart';
import 'package:seoul/services/post_service.dart';

final postServiceProvider = Provider<PostService>((ref) => PostService());

final postListProvider = StateNotifierProvider<PostListNotifier, List<PostResponse>>((ref) {
  final postService = ref.read(postServiceProvider);
  return PostListNotifier(postService);
});

class PostListNotifier extends StateNotifier<List<PostResponse>> {
  final PostService _postService;
  int? _cursor;
  bool _isFetching = false;
  bool _hasNext = true;

  PostListNotifier(this._postService) : super([]){
    fetchNext();
  }

  Future<void> fetchNext() async{
    if (_isFetching || !_hasNext) return;
    _isFetching = true;

    try {
      final response = await _postService.fetchPosts(cursor: _cursor);
      state = [...state, ...response.content];
      _cursor = response.nextCurosr;
      _hasNext = response.hasNext;
    } catch (e){
      print('오류: $e');
    } finally {
      _isFetching = false;
    }
  }
}