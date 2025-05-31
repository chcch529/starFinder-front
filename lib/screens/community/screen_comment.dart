import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seoul/models/model_userDetail.dart';
import '../../models/model_board.dart';
import '../../models/model_comment.dart';
import '../../widget/bottombar/bottom_bar.dart';
import '../../widget/profile/profile_avatar.dart';
import '../chat/screen_chatroom.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentScreen extends StatefulWidget {
  const CommentScreen(
      {Key? key, required this.boardId, required this.postedUid})
      : super(key: key);
  final int boardId;
  final String postedUid;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  late Future<Map<String, dynamic>> _postWithUserDetails;
  late Stream<List<Map<String, dynamic>>> _commentsWithUserDetails;
  ScrollController _scrollController = ScrollController();
  String? currentUserUid;

  @override
  void initState() {
    super.initState();
    getCurrentUserUid();
    _postWithUserDetails = _fetchPostWithUserData(widget.boardId! as String);
    _commentsWithUserDetails = fetchCommentsWithUserDataStream(widget.boardId! as String);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserUid = user.uid; // 현재 로그인한 사용자의 UID 저장
    } else {
      currentUserUid = ''; // 사용자가 로그인하지 않은 경우
    }
  }

  Future<Map<String, dynamic>> _fetchPostWithUserData(String boardId) async {
    DocumentSnapshot boardSnapshot =
        await FirebaseFirestore.instance.collection('board').doc(boardId).get();

    if (!boardSnapshot.exists) {
      throw Exception('게시물을 찾을 수 없습니다.');
    }

    Board board = Board.fromJson(boardSnapshot.data() as Map<String, dynamic>);
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('userDetail')
        .doc(board.userId)
        .get();

    UserDetail userDetail = userSnapshot.exists
        ? UserDetail.fromJson(userSnapshot.data() as Map<String, dynamic>)
        : UserDetail(nickname: 'starfinder', photoUrl: '');

    return {
      'board': board,
      'userDetail': userDetail,
    };
  }


  var _userEnterBody = '';
  final _commentBodyController = TextEditingController();

  Stream<List<Map<String, dynamic>>> fetchCommentsWithUserDataStream(
      String boardId) {
    return FirebaseFirestore.instance
        .collection('comments')
        .where('boardId', isEqualTo: boardId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> commentsWithUserData = [];
      for (var doc in snapshot.docs) {
        Comment comment = Comment.fromJson(doc.data() as Map<String, dynamic>);
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('userDetail')
            .doc(comment.userId)
            .get();
        UserDetail userDetail = userSnapshot.exists
            ? UserDetail.fromJson(userSnapshot.data() as Map<String, dynamic>)
            : UserDetail(nickname: 'starfinder', photoUrl: '');

        commentsWithUserData.add({
          'comment': comment,
          'userDetail': userDetail,
        });
      }
      return commentsWithUserData;
    });
  }

  void _sendComment() async {
    if (FirebaseAuth.instance.currentUser?.isAnonymous ?? true) {
      // 익명 사용자인 경우 경고 메시지 표시
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Container(
                  alignment: Alignment.center,
                  child: Text(
                    '로그인한 사용자만 댓글을 작성할 수 있습니다.',
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
    if (_userEnterBody.trim().isEmpty) return;

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    DocumentReference commentRef = FirebaseFirestore.instance
        .collection('comments')
        .doc('${widget.boardId}_$timestamp');
    DocumentReference boardRef =
        FirebaseFirestore.instance.collection('board').doc(widget.boardId as String?);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      // 게시물 문서를 먼저 읽어옵니다.
      DocumentSnapshot boardSnapshot = await transaction.get(boardRef);
      if (!boardSnapshot.exists) {
        throw Exception("게시물이 존재하지 않습니다.");
      }
      int currentCount = boardSnapshot.get('commentCnt') ?? 0;

      transaction.set(commentRef, {
        'body': _userEnterBody.trim(),
        'boardId': widget.boardId,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(boardRef, {'commentCnt': currentCount + 1});
    }).then((value) {
      _commentBodyController.clear();
      setState(() {
        _userEnterBody = '';
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("댓글이 추가되었습니다.")));
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("댓글 추가에 실패했습니다: $error")));
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  String getChatRoomId(String userId1, String userId2) {
    if (userId1.compareTo(userId2) > 0) {
      return '${userId2}_$userId1';
    } else {
      return '${userId1}_$userId2';
    }
  }

  void startChat() async {
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

    String chatRoomId = getChatRoomId(currentUserId!, widget.postedUid);

    DocumentReference chatRoomRef =
    FirebaseFirestore.instance.collection('chat')
        .doc(chatRoomId);

    // 채팅 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
            receiverId: widget.postedUid, chatRoomId: chatRoomRef.id),
      ),
    );
  }

  Widget buildImageGrid(List<String>? uploadImageUrls) {
    if (uploadImageUrls != null && uploadImageUrls.isNotEmpty) {
      List<String> validImageUrls = uploadImageUrls
          .where((url) => url.isNotEmpty && url != 'null')
          .toList();
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
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
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset('assets/images/appbar_starfinder.png',
              width: 150, // 이미지의 너비
              height: 35, // 이미지의 높이
              fit: BoxFit.contain),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FutureBuilder<Map<String, dynamic>>(
                  future: _postWithUserDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (snapshot.hasData) {
                      Board board = snapshot.data!['board'];
                      UserDetail userDetail = snapshot.data!['userDetail'];
                      return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: <Widget>[
                                buildUserProfileAvatar(userDetail.photoUrl, 25),
                                SizedBox(width: 10,),
                                Text(
                                  userDetail.nickname,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      widget.postedUid == currentUserUid
                                          ? TextButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('board')
                                                    .doc(widget.boardId as String?)
                                                    .delete();
                                              },
                                              child: Text(
                                                '삭제하기',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xff767676),
                                                ),
                                              ),
                                            )
                                          : TextButton(
                                              onPressed: () {
                                                startChat();
                                              },
                                              child: Text(
                                                '채팅하기',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xff767676),
                                                ),
                                              ),
                                            ), //채팅하기
                                      Text('${timeago.format(board.createdAt!, locale: 'kr')}   '),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Colors.black,
                          ),
                          Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 2),
                              child: Text(board.body,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  )
                              )
                          ),
                          buildImageGrid(board.uploadImageUrls),
                          Container(
                            margin: EdgeInsets.only(
                              bottom: 10,
                            ),
                            height: 1,
                            color: Colors.black,
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              bottom: 10,
                            ),
                            width: double.maxFinite,
                            child: Text.rich(
                              TextSpan(
                                  text: '좋아요 ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${board.likeCnt}  ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '댓글 ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${board.commentCnt}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ]),
                            ),
                          ), //좋아요, 댓글 수
                        ],
                      );
                    } else {
                      return Center(
                        child: Text('no data avilable'),
                      );
                    }
                  }),
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: (MediaQuery.of(context).size.height) - 100,
                          color: Color(0xffcfe6fb),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream:
                            fetchCommentsWithUserDataStream(widget.boardId! as String),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.hasData) {
                            return ListView.builder(
                                controller: _scrollController,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var data = snapshot.data![index];
                                  Comment comment = data['comment'];
                                  UserDetail userDetail = data['userDetail'];
                                  return Container(
                                    margin: EdgeInsets.fromLTRB(15, 0, 15, 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        buildUserProfileAvatar(userDetail.photoUrl, 20),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text.rich(
                                              TextSpan(
                                                text: '${userDetail.nickname}',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: '   ${timeago.format(comment.createdAt!, locale: 'kr')}',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w300,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Text(
                                              comment.body,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                  );
                                });
                          } else {
                            return Center(
                              child: Text('no data avilable'),
                            );
                          }
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 120,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 20),
// 왜 중앙이 아니냐고
                        width: 343,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          maxLines: null,
                          controller: _commentBodyController,
                          onChanged: (value) {
                            setState(() {
                              _userEnterBody = value;
                            });
                          },
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.attach_file_outlined,
                              size: 18,
                              color: Color(0xff767676),
                            ),

                            hintText: '댓글을 입력하세요',
// Username input
                            hintStyle: TextStyle(
                              color: Color(0xff767676),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),

                            suffixIcon: IconButton(
                              onPressed: _userEnterBody.trim().isEmpty
                                  ? null
                                  : _sendComment,
                              icon: Icon(
                                Icons.send,
                                size: 27,
                              ),
                              color: Color(0xffcfe6fb),
                            ),
                            contentPadding: EdgeInsets.only(bottom: 10),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: BottomBar(
                        isMap: false,
                        isBoard: true,
                        isChat: false,
                        isMy: false,
                        isComment: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
