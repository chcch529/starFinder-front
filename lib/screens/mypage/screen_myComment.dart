import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/model_board.dart';
import '../../models/model_userDetail.dart';
import '../../widget/post/post_bubble.dart';

class MyComment extends StatelessWidget {
  const MyComment({super.key});

  Stream<List<Map<String, dynamic>>> getMyCommentDataStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('comments')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> boardsWithDetails = [];
      for (var doc in snapshot.docs) {

        var boardId = doc.get('boardId');
        DocumentSnapshot boardSnapshot = await FirebaseFirestore.instance
            .collection('board').doc(boardId).get();
        Board board = Board.fromJson(boardSnapshot.data() as Map<String, dynamic>);

        var postedId = board.userId;
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('userDetail')
            .doc(postedId)
            .get();
        UserDetail userDetail = userSnapshot.exists
            ? UserDetail.fromJson(userSnapshot.data() as Map<String, dynamic>)
            : UserDetail(nickname: 'starfinder', photoUrl: '');

        boardsWithDetails.add({
          'board': board,
          'userDetail': userDetail,
          'boardId': boardId,
        });
      }
      return boardsWithDetails;
    });
  }


  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('댓글 단 글',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getMyCommentDataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return ListView.builder(
                reverse: false,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = snapshot.data![index];
                  Board board = data['board'];
                  UserDetail userDetail = data['userDetail'];
                  String boardId = data['boardId'];
                  return PostBubble(
                    userDetail.photoUrl,
                    userDetail.nickname,
                    boardId as int,
                    board.userId as int,
                    board.body,
                    board.likeCnt,
                    board.commentCnt,
                    board.createdAt,
                    board.uploadImageUrls,
                  );
                }
            );
          } else {
            return Text('댓글 단 글이 없습니다.');
          }
        },
      ),
    );
  }
}