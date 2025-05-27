import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart';


class KrCustomMessages implements LookupMessages {
  String prefixAgo() => '';
  String prefixFromNow() => '';
  String suffixAgo() => '전';
  String suffixFromNow() => '후';
  String lessThanOneMinute(int seconds) => '방금';
  String aboutAMinute(int minutes) => '방금';
  String minutes(int minutes) => '$minutes분';
  String aboutAnHour(int minutes) => '1시간';
  String hours(int hours) => '$hours시간';
  String aDay(int hours) => '1일';
  String days(int days) => '$days일';
  String aboutAMonth(int days) => '한달';
  String months(int months) => '$months개월';
  String aboutAYear(int year) => '1년';
  String years(int years) => '$years년';
  String wordSeparator() => ' ';
}

// class dd extends StatelessWidget {
//   const dd({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       margin: EdgeInsets.fromLTRB(15, 0, 15, 20),
//       child: Column(
//         mainAxisAlignment:
//         MainAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               buildUserProfileAvatar(userDetail.photoUrl, 20), // 프사
//               SizedBox(
//                 width: 10,
//               ),
//               Text(userDetail.nickname,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16,
//                   )),
//             ],
//           ),
//           Container(
//             margin: EdgeInsets.only(
//                 top: 10, bottom: 10, left: 20),
//             alignment: Alignment.centerLeft,
//             child: Text(
//               comment.body,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.w300,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


