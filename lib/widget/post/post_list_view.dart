import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seoul/providers/post_provider.dart';
import 'package:seoul/widget/post/post_bubble.dart';

class PostListView extends ConsumerStatefulWidget {
  const PostListView( {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _postListView();
  }

  class _postListView extends ConsumerState<PostListView> {
    final ScrollController _scrollController = ScrollController();

    @override
    void initState() {
      super.initState();
      _scrollController.addListener(() {
        _onScroll();
      });
    }

    void _onScroll() {
        final notifier = ref.read(postListProvider.notifier);
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
          notifier.fetchNext();
        }
    }

    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context){
      final postList = ref.watch(postListProvider);

      if (postList.isEmpty){
        return const Center(child: CircularProgressIndicator(),);
      }

      return ListView.builder(
        controller: _scrollController,
        itemCount: postList.length,
        itemBuilder: (context, index) {
          final post = postList[index];
          return PostBubble(
              post.profileUrl,
              post.nickname,
              post.id,
              post.userId,
              post.content,
              post.likeCnt,
              post.commentCnt,
              post.createdAt,
              null);
        },
      );
    }


  // Stream<List<Map<String, dynamic>>> getBoardsWithUserDataStream() {
  //   return FirebaseFirestore.instance.collection('board')
  //       .orderBy('createdAt', descending: true)
  //       .snapshots().asyncMap((snapshot) async {
  //     List<Map<String, dynamic>> boardsWithDetails = [];
  //     for (var doc in snapshot.docs) {
  //       Board board = Board.fromJson(doc.data() as Map<String, dynamic>);
  //       DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('userDetail').doc(board.userId).get();
  //       UserDetail userDetail = userSnapshot.exists
  //           ? UserDetail.fromJson(userSnapshot.data() as Map<String, dynamic>)
  //           : UserDetail(nickname: 'starfinder', photoUrl: '');
  //
  //       boardsWithDetails.add({
  //         'board': board,
  //         'userDetail': userDetail,
  //         'boardId': doc.id,
  //       });
  //     }
  //     return boardsWithDetails;
  //   });
  // }
  //
  //
  //
  //
  // @override
  // Widget build(BuildContext context) {
  //   final uid = FirebaseAuth.instance.currentUser!.uid;
  //
  //   return StreamBuilder<List<Map<String, dynamic>>>(
  //     stream: getBoardsWithUserDataStream(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         return Text("Error: ${snapshot.error}");
  //       } else if (snapshot.hasData) {
  //         return ListView.builder(
  //           reverse: false,
  //           itemCount: snapshot.data!.length,
  //           itemBuilder: (context, index) {
  //             Map<String, dynamic> data = snapshot.data![index];
  //             Board board = data['board'];
  //             UserDetail userDetail = data['userDetail'];
  //             String boardId = data['boardId'];
  //             return PostBubble(
  //               userDetail.photoUrl,
  //               userDetail.nickname,
  //               boardId,
  //               board.userId,
  //               board.body,
  //               board.likeCnt,
  //               board.commentCnt,
  //               board.createdAt,
  //               board.uploadImageUrls,
  //             );
  //           },
  //         );
  //       } else {
  //         return Text("No data found");
  //       }
  //     },
  //   );
  // }


}
