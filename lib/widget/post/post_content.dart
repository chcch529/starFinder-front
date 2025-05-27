import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seoul/widget/post/post_bubble.dart';

import '../../models/model_board.dart';
import '../../models/model_userDetail.dart';

class Content extends StatelessWidget {
  const Content( {super.key});

  Stream<List<Map<String, dynamic>>> getBoardsWithUserDataStream() {
    return FirebaseFirestore.instance.collection('board')
        .orderBy('createdAt', descending: true)
        .snapshots().asyncMap((snapshot) async {
      List<Map<String, dynamic>> boardsWithDetails = [];
      for (var doc in snapshot.docs) {
        Board board = Board.fromJson(doc.data() as Map<String, dynamic>);
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('userDetail').doc(board.userId).get();
        UserDetail userDetail = userSnapshot.exists
            ? UserDetail.fromJson(userSnapshot.data() as Map<String, dynamic>)
            : UserDetail(nickname: 'starfinder', photoUrl: '');

        boardsWithDetails.add({
          'board': board,
          'userDetail': userDetail,
          'boardId': doc.id,
        });
      }
      return boardsWithDetails;
    });
  }




  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getBoardsWithUserDataStream(),
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
                boardId,
                board.userId,
                board.body,
                board.likeCnt,
                board.commentCnt,
                board.createdAt,
                board.uploadImageUrls,
              );
            },
          );
        } else {
          return Text("No data found");
        }
      },
    );
  }

}
