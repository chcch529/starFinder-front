import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seoul/screens/login/screen_login.dart';
import 'package:seoul/screens/mypage/pdfView.dart';
import 'package:seoul/screens/mypage/screen_myComment.dart';
import 'package:seoul/screens/mypage/screen_myPosting.dart';
import 'package:seoul/screens/mypage/set_info.dart';

import '../../models/model_userDetail.dart';
import '../../widget/appbar/main_app_bar.dart';
import '../../widget/bottombar/bottom_bar.dart';
import '../../widget/profile/profile_avatar.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    }


  // Future<UserDetail> getUserDetail(String userId) async {
  //   DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //       .collection('userDetail')
  //       .doc(userId)
  //       .get();
  //   if (userDoc.exists) {
  //     return UserDetail.fromJson(userDoc.data() as Map<String, dynamic>);
  //   } else {
  //     return UserDetail(nickname: "starfinder", photoUrl: "");
  //   }
  // }


  Stream<UserDetail> getUserDetail(String userId) {
    return FirebaseFirestore.instance
        .collection('userDetail')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return UserDetail.fromJson(snapshot.data() as Map<String, dynamic>);
      } else {
        return UserDetail(nickname: "starfinder", photoUrl: "");
      }
    });
  }

  Future<void> _logOutDialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Container(
            alignment: Alignment.center,
            child: Text(
              '로그아웃 하시겠습니까?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          backgroundColor: Color(0xffcfe6fb),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen();
                        },
                      ),
                    );
                  },
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
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    side: BorderSide(color: Colors.white), // Border color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _authDeletDialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Container(
            alignment: Alignment.center,
            child: Text(
              '계정 탈퇴 하시겠습니까?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          backgroundColor: Color(0xffcfe6fb),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.currentUser!.delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("아이디 삭제가 완료되었습니다")),
                      );
                      await FirebaseAuth.instance.signOut();
                      // await FacebookAuth.instance.logOut();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginScreen();
                          },
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
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
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white, // Button background color
                    side: BorderSide(color: Colors.white), // Border color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        // AppBar 클래스는 명시적으로 너비와 높이를 설정할 수 있는 PreferredSize 위젯을 상속 받는다.
        preferredSize: Size.fromHeight(60), // 앱바 높이 조절
        child: MainAppBar(), // 앱바 적용
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '내 정보',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              StreamBuilder<UserDetail>(
                  stream: getUserDetail(currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else {
                      // 데이터가 있으면 해당 데이터 사용, 없으면 기본 값 설정
                      UserDetail userDetailData = snapshot.hasData
                          ? snapshot.data!
                          : UserDetail(nickname: "starfinder", photoUrl: "");
                      return Container(
                        margin: EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            buildUserProfileAvatar(snapshot.data!.photoUrl, 40),

                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                snapshot.data!.nickname,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ), //닉네임
                            Spacer(),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  if (FirebaseAuth
                                          .instance.currentUser?.isAnonymous ??
                                      true) {
                                    // 익명 사용자인 경우 경고 메시지 표시
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '로그인한 사용자만 프로필을 수정할 수 있습니다.',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              backgroundColor:
                                                  Color(0xffcfe6fb),
                                              actions: <Widget>[
                                                OutlinedButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    // Button background color
                                                    side: BorderSide(
                                                        color: Colors.white),
                                                    // Border color
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30.0),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    '확인',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ));
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SetInfo(
                                            photoUrl: snapshot.data!.photoUrl,
                                            nickname: snapshot.data!.nickname),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  '프로필 수정',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Color(0xff767676),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  }),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MyPosting(),
                      ));
                },
                child: Text(
                  '내가 쓴 글',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ), // 버전 정보
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MyComment(),
                      ));
                },
                child: Text(
                  '댓글 단 글',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ), // 버전 정보
              SizedBox(
                height: 20,
              ),
              
              TextButton(
                onPressed: () {},
                child: Text(
                  '버전 정보',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ), // 버전 정보
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerPage(
                        assetPath: "assets/tou.pdf", // 이용약관 PDF 파일 경로
                      ),
                    ),
                  );
                },
                child: Text(
                  '스타파인더 이용약관',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ), // 스타파인더 이용약관
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerPage(
                        assetPath: "assets/pipp.pdf", // 이용약관 PDF 파일 경로
                      ),
                    ),
                  );
                },
                child: Text(
                  '개인정보 처리방침',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ), // 앱 설정
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  '앱 설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ), // 공지사항
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  '알림 설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ), // 알림설정
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () async {
                  _logOutDialogBuilder(context);
                },
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ), // 로그아웃
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  _authDeletDialogBuilder(context);
                },
                child: Text(
                  '계정 탈퇴',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ), // 계정 탈퇴
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
        isMap: false,
        isBoard: false,
        isChat: false,
        isMy: true,
        isComment: false,
      ),
    );
  }
}
