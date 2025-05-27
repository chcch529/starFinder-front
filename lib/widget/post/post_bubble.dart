import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/model_board.dart';
import '../../models/model_like.dart';
import '../../screens/chat/screen_chatroom.dart';
import '../../screens/community/screen_comment.dart';
import '../profile/profile_avatar.dart';
import 'package:timeago/timeago.dart' as timeago ;

class PostBubble extends StatelessWidget {
  const PostBubble(
      this.photoUrl,
      this.nickname,
      this.boardId,
      this.userId,
      this.body,
      this.likeCnt,
      this.commentCnt,
      this.createdAt,
      this.uploadImageUrls,
      {super.key});

  final String photoUrl;
  final String nickname;
  final String boardId;
  final String userId;
  final String body;
  final int likeCnt;
  final int commentCnt;
  final DateTime? createdAt;
  final List<String>? uploadImageUrls;

  //
  // Like infoLike(){
  //   return Like(
  //     userId: userId,
  //     boardId: boardId!,
  //   );
  // }

  String getChatRoomId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) > 0) {
      return '${userId2}_$userId1';
    } else {
      return '${userId1}_$userId2';
    }
  }

  void startChat(BuildContext context, String postedId) async {
    if (FirebaseAuth.instance.currentUser?.isAnonymous ?? true) {
      // 익명 사용자인 경우 경고 메시지 표시
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Container(
                  alignment: Alignment.center,
                  child: Text(
                    '로그인한 사용자만 채팅을 할 수 있습니다.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                backgroundColor: Color(0xffcfe6fb),
                actions: <Widget>[
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white, // Button background color
                      side: BorderSide(color: Colors.white), // Border color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ));
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // 사용자가 로그인되지 않은 경우 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("로그인이 필요합니다."),
      ));
      return;
    }

    final currentUserId = currentUser.uid;

    String chatRoomId = getChatRoomId(currentUserId!, postedId);

    DocumentReference chatRoomRef =
        FirebaseFirestore.instance.collection('chat')
            .doc(chatRoomId);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatRoomScreen(chatRoomId: chatRoomRef.id, receiverId: postedId),
        ));
  }


  Widget buildImageGrid(List<String>? uploadImageUrls) {
    if (uploadImageUrls != null && uploadImageUrls.isNotEmpty) {
      List<String> validImageUrls = uploadImageUrls.where((url) => url.isNotEmpty && url != 'null').toList();
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 4/5,
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 4,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: validImageUrls.length,
          itemBuilder: (context, index) {
            String imageUrl = validImageUrls[index];
            return Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: NetworkImage(imageUrl),
                ),
              ),
            );
          });
    } else {
      return Container(height: 20,);
    }
  }

  void incrementLikeCount(String boardId) {
    final docRef = FirebaseFirestore.instance.collection('board').doc(boardId);

    FirebaseFirestore.instance
        .runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(docRef);

          if (!snapshot.exists) {
            throw Exception("Post does not exist!");
          }

          Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
          int currentLikes = data['likeCnt'] as int? ?? 0;
          transaction.update(docRef, {'likeCnt': currentLikes + 1});
        })
        .then((value) => print("Like count updated"))
        .catchError((error) => print("Failed to update like count: $error"));
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      decoration: BoxDecoration(
        color: Color(0xffcfe6fb),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      width: 344,
      padding: EdgeInsets.fromLTRB(15, 15, 15, 8),
      margin: EdgeInsets.fromLTRB(15, 0, 15, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              buildUserProfileAvatar(photoUrl, 25), // 프사
              SizedBox(
                width: 10,
              ),
              Text(nickname,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
              ),
              Spacer(),
              Text(
                  '${timeago.format(createdAt!, locale: 'kr')}   ',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0,20,0,0),
            child: Text(
              textAlign: TextAlign.left,
              body,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          buildImageGrid(uploadImageUrls),
          Text.rich(
              textAlign: TextAlign.left,
              TextSpan(
                  text: '좋아요 ',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${likeCnt}',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '  댓글 ',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '${commentCnt}',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                      ),
                    ),
                  ])),
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            color: Colors.white,
            width: 313,
            height: 1,
          ),
          Row(
            children: [
              TextButton(
                  onPressed: () async {
                    if (FirebaseAuth.instance.currentUser?.isAnonymous ??
                        true) {
                      // 익명 사용자인 경우 경고 메시지 표시
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '로그인한 사용자만 좋아요 할 수 있습니다.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                backgroundColor: Color(0xffcfe6fb),
                                actions: <Widget>[
                                  OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      // Button background color
                                      side: BorderSide(color: Colors.white),
                                      // Border color
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    child: const Text(
                                      '확인',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                    } else {
                      incrementLikeCount(boardId);
                    }
                  },
                  child: Text(
                    '좋아요',
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )),
              SizedBox(
                width: 8,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentScreen(
                        boardId: boardId,
                        postedUid: userId,
                      ),
                    ),
                  );
                },
                child: Text(
                  '댓글',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              userId == currentUserId
                  ? TextButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('board')
                            .doc(boardId)
                            .delete();
                      },
                      child: Text(
                        '삭제하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        startChat(context, userId);
                      },
                      child: Text(
                        '채팅하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ), //채팅하기
            ],
          ),
        ],
      ),
    );
  }
}
