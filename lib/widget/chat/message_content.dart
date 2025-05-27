import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seoul/widget/chat/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/model_chat.dart';
import '../../models/model_userDetail.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key, required this.chatRoomId, required this.receiverId}) : super(key: key);

  final String chatRoomId;
  final String receiverId;


  Stream<List<Map<String, dynamic>>> getChatsWithUserDataStream() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }
    return FirebaseFirestore.instance.collection('chat')
        .doc(chatRoomId)
        .collection('message')
        .orderBy('createdAt', descending: true)
        .snapshots().asyncMap((snapshot) async {
      List<Map<String, dynamic>> chatsWithDetails = [];
      for (var doc in snapshot.docs) {
        Chat chat = Chat.fromJson(doc.data() as Map<String, dynamic>);

        if (chat.userId == null || chat.receiverId == null) continue;

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('userDetail').doc(currentUser.uid).get();
        DocumentSnapshot receiverSnapshot = await FirebaseFirestore.instance.collection('userDetail').doc(receiverId).get();

        UserDetail userDetail = userSnapshot.exists
            ? UserDetail.fromJson(userSnapshot.data() as Map<String, dynamic>)
            : UserDetail(nickname: 'starfinder', photoUrl: '');
        UserDetail receiverDetail = receiverSnapshot.exists
            ? UserDetail.fromJson(receiverSnapshot.data() as Map<String, dynamic>)
            : UserDetail(nickname: 'starfinder', photoUrl: '');

        chatsWithDetails.add({
          'chat': chat,
          'userDetail': userDetail,
          'receiverDetail': receiverDetail,
          'chatRoomId': chatRoomId,
        });
      }
      return chatsWithDetails;
    });
  }


  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(child: Text("로그인이 필요합니다."));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: getChatsWithUserDataStream(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            return ListView.builder(
              reverse: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index){
                Map<String, dynamic> data = snapshot.data![index];
                Chat chat = data['chat'];
                UserDetail userDetail = data['userDetail'];
                UserDetail receiverDetail = data['receiverDetail'];
                var isMe = currentUser.uid == chat.userId;

                return ChatBubble(
                  userDetail.photoUrl,
                  userDetail.nickname,
                  receiverDetail.photoUrl,
                  receiverDetail.nickname,
                  chat.text,
                  chat.createdAt,
                  isMe
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
