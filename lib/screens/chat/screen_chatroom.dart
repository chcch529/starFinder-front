import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seoul/widget/chat/message_content.dart';
import 'package:seoul/widget/chat/message_send_bar.dart';
import '../../widget/appbar/main_app_bar.dart';


class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({Key? key, required this.receiverId, required this.chatRoomId}) : super(key: key);
  final String receiverId;
  final String chatRoomId;


  static String routeName = "/screen_chatroom";

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}


class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;
    try {
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  final userId = FirebaseAuth.instance.currentUser!.uid;


  void updateLastSeenMessageId(String chatRoomId, String userId, String lastMessageId){
    FirebaseFirestore.instance.collection('chat').doc(chatRoomId).set({
      'lastSeenMessageIds': {
        userId: lastMessageId
      }
    }, SetOptions(merge: true));
  }

  void onChatRoomExit(String chatRoomId, String userId) async {
    var messagesSnapshot = await FirebaseFirestore.instance
        .collection('chat').doc(chatRoomId)
        .collection('messages')
        .orderBy('createAt', descending: true)
        .limit(1).get();
    if (messagesSnapshot.docs.isNotEmpty){
      String lastMessageId = messagesSnapshot.docs.first.id;

      updateLastSeenMessageId(chatRoomId, userId, lastMessageId);
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
          appBar: PreferredSize( // AppBar 클래스는 명시적으로 너비와 높이를 설정할 수 있는 PreferredSize 위젯을 상속 받는다.
            preferredSize: Size.fromHeight(60), // 앱바 높이 조절
            child: AppBar(
              centerTitle: true,
              title: Image.asset(
                  'assets/images/appbar_starfinder.png',
                  width: 150, // 이미지의 너비
                  height: 35, // 이미지의 높이
                  fit: BoxFit.contain
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  onChatRoomExit(widget.chatRoomId, userId);
                  Navigator.pop(context);
                },
              ),
            ), // 앱바 적용
          ),
          body: Stack(
            children: [
              Positioned(
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 700,
                    color: Color(0xffcfe6fb),
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: Messages(chatRoomId: widget.chatRoomId,
                        receiverId: widget.receiverId),
                  ),
                  NewMessage(chatRoomId: widget.chatRoomId,
                      receiverId: widget.receiverId,
                  ),


                ],
              ),
            ],
          )
      ),
    );
  }
}