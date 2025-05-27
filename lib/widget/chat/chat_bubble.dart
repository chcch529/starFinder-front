import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../profile/profile_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatBubble extends StatelessWidget {
  const ChatBubble(this.photoUrl, this.nickname, this.receiverphotoUrl,
      this.receivernickname, this.text, this.createdAt, this.isMe,
      {super.key});

  final String photoUrl;
  final String nickname;
  final String receiverphotoUrl;
  final String receivernickname;

  final String text;
  final DateTime? createdAt;
  final bool isMe;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            buildUserProfileAvatar(receiverphotoUrl, 23),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              if (!isMe) ...[
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    receivernickname,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if(isMe) ...[
                    Text(
                      '${timeago.format(createdAt!, locale: 'kr')}',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMe ? Color(0xff61abf1) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                          bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        softWrap: true,
                      ),
                    ),
                  ),
                  if(!isMe) ...[
                    Text(
                      '${timeago.format(createdAt!, locale: 'kr')}',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}
