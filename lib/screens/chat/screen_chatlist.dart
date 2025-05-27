import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:seoul/screens/chat/screen_chatroom.dart';
import 'package:seoul/screens/chat/screen_userSearch.dart';
import 'package:seoul/widget/appbar/main_app_bar.dart';
import 'package:seoul/widget/profile/profile_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/model_chat.dart';
import '../../models/model_userDetail.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
  }

  final userId = FirebaseAuth.instance.currentUser!.uid;



  Stream<List<Map<String, dynamic>>> getChatsWithUserDataStream() {
    return FirebaseFirestore.instance
        .collection('chat')
        .where('participant', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> chatsWithDetails = [];
      for (var doc in snapshot.docs) {
        var headerSnapshot =
            await doc.reference.collection('header').doc('header').get();
        if (headerSnapshot.exists) {
          // header 정보 가져옴 (userid, time, text, chatid)
          var headerData = headerSnapshot.data()!;

          // 참여자 아이디 가져옴
          var participant = doc.data()['participant'] as List<dynamic>;

          String receiverId =
              headerData['lastMessageUserId'] == userId // 마지막으로 보낸 게 나라면
                  ? participant
                      .firstWhere((id) => id != userId) // 참여자 중에서 내가 아닌 다른 id
                  : headerData['lastMessageUserId']; // 마지막 전송이 나 아니면 걍 그 아이디 사용

          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('userDetail')
              .doc(receiverId)
              .get();

          UserDetail userDetail = userSnapshot.exists
              ? UserDetail.fromJson(userSnapshot.data() as Map<String, dynamic>)
              : UserDetail(nickname: 'starfinder', photoUrl: '');

          var lastSeenMessageIds = doc.data()['lastSeenMessageIds'] as Map<String, dynamic>?;
          String? lastSeenMessageId;
          if (lastSeenMessageIds != null && lastSeenMessageIds.containsKey(userId)) {
            lastSeenMessageId = lastSeenMessageIds[userId];
          }
          
          int unreadMessateCount = 0;
          if (lastSeenMessageId != null){
            var messageSnapshot = await doc.reference.collection('messages')
                .where(FieldPath.documentId, isGreaterThan: lastSeenMessageId)
                .get();

            unreadMessateCount = messageSnapshot.size;
          }

          chatsWithDetails.add({
            'chatRoomId': doc.id,
            'lastMessage': headerData['lastMessage'],
            'lastMessageUserId': headerData['lastMessageUserId'],
            'lastMessageCreatedAt': headerData['lastMessageCreatedAt'],
            'reveiverDetail': userDetail,
            'receiverId': receiverId,
            'unreadMessateCount': unreadMessateCount,
          });
        }
      }
      return chatsWithDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(context),
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
                width: MediaQuery.of(context).size.width,
                height: 700,
                color: Color(0xffcfe6fb),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              width: 350,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 30),
                    child: Text(
                      '채팅하기',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserSearch(),
                          ));
                    },
                    icon: Icon(Icons.search),
                    iconSize: 24,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            bottom: 0,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getChatsWithUserDataStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No chats available"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var chatData = snapshot.data![index];
                    String chatRoomId = chatData['chatRoomId'];
                    String lastMessage = chatData['lastMessage'];
                    Timestamp lastMessageCreatedAt =
                        chatData['lastMessageCreatedAt'];
                    UserDetail reveiverDetail = chatData['reveiverDetail'];
                    String receiverId = chatData['receiverId'];
                    int unreadMessateCount = chatData['unreadMessateCount'];

                    return ListTile(
                      leading:
                          buildUserProfileAvatar(reveiverDetail.photoUrl, 30),
                      title: Text(
                        reveiverDetail.nickname,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w300),
                            lastMessage,
                          ),
                          Spacer(),
                          Column(
                            children: [
                              Container(
                                child: Text(
                                    '${unreadMessateCount}',
                                  style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700,
                                    color: Colors.white)
                                  ),
                                decoration: BoxDecoration(
                                  color: Color(0xffeb4335),
                                  borderRadius:BorderRadius.circular(20)
                                ),
                                ),
                              Text(
                                '${timeago.format(lastMessageCreatedAt.toDate(), locale: 'kr')}',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomScreen(
                              receiverId: receiverId,
                              chatRoomId: chatRoomId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Positioned(
          //     top: 0,
          //     left: 0,
          //     right: 0,
          //     bottom: 0,
          //     child: Container(
          //       alignment: Alignment.center,
          //       width: 350,
          //       child: Row(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Container(
          //             margin: EdgeInsets.only(left: 30),
          //             child: Text(
          //               '채팅하기',
          //               style: TextStyle(
          //                 fontWeight: FontWeight.w700,
          //                 fontSize: 20,
          //                 color: Colors.black,
          //               ),
          //             ),
          //           ),
          //           IconButton(
          //             onPressed: () {
          //               Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) => UserSearch(),
          //                   ));
          //             },
          //             icon: Icon(Icons.search),
          //             iconSize: 24,
          //             color: Colors.black,
          //           ),
          //         ],
          //       ),
          //     ),
          // ) //추천
        ],
      ),
    );
  }
}
