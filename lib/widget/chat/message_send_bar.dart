import 'package:flutter/material.dart';
import 'package:seoul/widget/chat/message_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key, required this.receiverId, required this.chatRoomId}) : super(key: key);

  final String receiverId;
  final String chatRoomId;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  var _userEnterMessage = '';

  // void _sendMessage(){
  //   // FocusScope.of(context).unfocus();
  //   final user = FirebaseAuth.instance.currentUser;
  //
  //   FirebaseFirestore.instance.collection('chat').doc(widget.chatRoomId)
  //       .collection('message').add({
  //     'text' : _userEnterMessage,
  //     'createdAt' : Timestamp.now(),
  //     'userId' : user!.uid,
  //     'receiverId': widget.receiverId,
  //     'chatRoomId' : widget.chatRoomId,
  //   });
  //   _controller.clear();
  // }

  Future<void> sendMessage(String chatRoomId, String text, String receiverId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance.collection('chat').doc(chatRoomId)
        .collection('message').add({
      'text' : text,
      'createdAt' : DateTime.now(),
      'userId' : userId,
      'receiverId': receiverId,
      'chatRoomId' : chatRoomId,
    });

    FirebaseFirestore.instance.collection('chat').doc(chatRoomId).set({
      'participant' : [userId, receiverId]
    }, SetOptions(merge: true));


    FirebaseFirestore.instance.collection('chat').doc(chatRoomId)
        .collection('header').doc('header').set({
      'lastMessage': text,
      'lastMessageUserId': userId,
      'lastMessageCreatedAt': DateTime.now(),
      'chatRoomId': chatRoomId,
    }, SetOptions(merge: true));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
        width: 343,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          maxLines: null,
          controller: _controller,
          onChanged: (value){
            setState(() {
              _userEnterMessage = value;
            });
          },
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.emoji_emotions_outlined,
            color: Color(0xffcfe6fb), size: 27,
             ),

            hintText: '채팅을 입력하세요',
            // Username input
            hintStyle: TextStyle(
              color: Color(0xff767676),
              fontSize: 15,
              fontWeight: FontWeight.w400,

            ),

          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.attach_file_outlined,
                color: Color(0xffd9d9d9), size: 21,),

              SizedBox(width: 10,),

              IconButton(
                onPressed: _userEnterMessage.trim().isEmpty ? null : () => sendMessage(widget.chatRoomId, _userEnterMessage, widget.receiverId),
                icon: Icon(Icons.send, size: 27,),
                color: Color(0xffcfe6fb),
                ),

            ],
          ),
          contentPadding: EdgeInsets.only(bottom: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
