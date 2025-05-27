import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seoul/widget/profile/profile_avatar.dart';

import '../../models/model_userDetail.dart';

class UserSearch extends StatefulWidget {
  const UserSearch({super.key});

  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  String findName = '';

  Stream<List<Map<String, dynamic>>> findUser(String searchName) {
    return FirebaseFirestore.instance
        .collection('userDetail')
        .where('nickname', isEqualTo: searchName)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> findUserDetail = [];
      for (var doc in snapshot.docs) {
        UserDetail userDetail = UserDetail.fromJson(doc.data() as Map<String, dynamic>);

        findUserDetail.add({
          'userId': doc.id,
          'userDetail': userDetail,
        });
        print('검색한 닉네임: ${userDetail.nickname}');
      }
      return findUserDetail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SearchBar(
                onSubmitted: (value) {
                  setState(() {
                    findName = value;
                  });
                },
                textInputAction: TextInputAction.search,
                keyboardType: TextInputType.text,
                backgroundColor: MaterialStatePropertyAll(Colors.white),
                hintText: "닉네임을 검색하시오",
                textStyle: MaterialStateProperty.all(TextStyle(
                  fontSize: 14,
                  color: Color(0xff767676),
                )),
                trailing: [
                  Icon(Icons.search, size: 18,),
                ],
              ),
            ),
            if (findName.isNotEmpty)
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: findUser(findName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("검색 결과가 없습니다."));
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 4/5,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var userData = snapshot.data![index];

                      UserDetail userDetail = userData['userDetail'];
                      String userId = userData['userId'];

                      return Container(

                        decoration: BoxDecoration(
                          color: Color(0xffcfe6fb),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildUserProfileAvatar(userDetail.photoUrl, 30),
                            SizedBox(height: 5,),
                            Text(
                                userDetail.nickname,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
