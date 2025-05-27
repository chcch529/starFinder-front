import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../screens/chat/screen_chatlist.dart';
import '../../screens/chat/screen_chatroom.dart';
import '../../screens/community/screen_post.dart';
import '../../screens/mypage/screen_myPage.dart';
import '../../screens/mypage/set_info.dart';
import '../../screens/screen_map.dart';


class BottomBar extends StatefulWidget {
  final bool isMap;
  final bool isBoard;
  final bool isChat;
  final bool isMy;

  final bool isComment;

  BottomBar({Key? key,this.isMap = true, this.isBoard = false, this.isComment = false, this.isChat = false, this.isMy = false,}) : super(key: key);

  @override
  _BottomBar createState() => _BottomBar();
}

class _BottomBar extends State<BottomBar>{

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isMap) _selectedIndex = 0;
    else if (widget.isBoard) _selectedIndex = 1;
    else if (widget.isChat) _selectedIndex = 2;
    else if (widget.isMy) _selectedIndex = 3;
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 인덱스를 업데이트하고 상태 변경을 알립니다.
    });
    switch(index){
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(),
          ),
        );
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostScreen(),
          ),
        );
      case 2:
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
            )
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatListScreen(),
            ),
          );

        }

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MypageScreen(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,

      child: Container(
          margin: EdgeInsets.fromLTRB(18, 0, 18, 20),
          width: 343, height: 82,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 2.5,
                spreadRadius: 1.0,
                offset: Offset(
                    0,5
                ),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed, // Fixed type when having more than 3 items
              backgroundColor: widget.isComment ? Color(0xffffe8a4) : Color(0xffcfe6fb),
              selectedItemColor: widget.isComment ? Color(0xffffe8a4) : Color(0xffcfe6fb), // 선택된 아이템 색상
              unselectedItemColor: Colors.white, // 선택되지 않은 아이템 색상
              currentIndex: _selectedIndex, // 현재 선택된 탭 인덱스

              onTap: _onItemTapped,

              items: [
                for (int i = 0; i < 4; i++) // 4개의 아이템을 만듭니다.
                  BottomNavigationBarItem(
                    icon: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedIndex == i ? Colors.white : Colors.transparent, // 현재 인덱스가 선택된 경우 흰색으로 설정합니다.
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _selectedIndex == i ? Colors.grey : Colors.transparent, // 현재 인덱스가 선택된 경우 흰색으로 설정합니다.
                            blurRadius: 2.5,
                            spreadRadius: 1.0,
                            offset: Offset(
                                0,5
                            ),
                          )
                        ],
                      ),
                      child: Image.asset(
                        i == 0 ? 'assets/images/home.png' :
                        i == 1 ? 'assets/images/post.png' :
                        i == 2 ? 'assets/images/chat.png' :
                        'assets/images/user.png',
                        width: 35, height: 35,
                        color: _selectedIndex == i ? widget.isComment ? Color(0xffffe8a4) : Color(0xffcfe6fb) : Colors.white, // 선택된 아이콘이면 primaryColor, 아니면 grey
                      ),
                    ),
                    label: '',
                  ),
              ],
              showSelectedLabels: false, // 선택된 레이블을 숨깁니다.
              showUnselectedLabels: false, // 선택되지 않은 레이블을 숨깁니다.
            ),
          )
      ),
    );
  }
}