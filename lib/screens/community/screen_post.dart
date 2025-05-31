import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seoul/screens/community/screen_create_post.dart';
import 'package:seoul/widget/bottombar/bottom_bar.dart';
import 'package:seoul/widget/post/post_list_view.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  static String routeName = "/screen_post";

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    super.initState();
    // 카테고리를 예시로 'general'로 설정
    getCurrentUser();
  }

  void getCurrentUser(){
    final user = _authentication.currentUser;
    try {
      if (user != null) {
        loggedUser = user;
      }
    } catch(e){
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('커뮤니티',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 100, left: 0, right: 0, top: 0,
            child: PostListView()
          ),
          Positioned(
            bottom: 120, right: 25,
            child: Container(
              width: 65, height: 65,
              child: IconButton(
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser?.isAnonymous ?? true) {
                    // 익명 사용자인 경우 경고 메시지 표시
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Container(
                          alignment: Alignment.center,
                          child: Text(
                            '로그인한 사용자만 게시물을 작성할 수 있습니다.',
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
                      )
                    );
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreatePostScreen())
                    );
                  }
                },
                icon: Icon(
                  Icons.mode_edit_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffffe8a4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2.5,
                    spreadRadius: 1.0,
                    offset: Offset(
                        0,3
                    ),
                  ),
                ],
              ),
            ),
          ),//글쓰기 버튼
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: BottomBar(
              isMap: false,
              isBoard: true,
              isChat: false,
              isMy: false,
              isComment: false,
            ),
          )
        ],
      ),
    );
  }
}
