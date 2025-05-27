import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../widget/profile/profile_avatar.dart';

class SetInfo extends StatefulWidget {
  const SetInfo({Key? key, required this.photoUrl, required this.nickname}) : super(key: key);

  final String photoUrl;
  final String nickname;

  static String routeName = "/set_info";

  @override
  State<SetInfo> createState() => _SetInfoState();
}

class _SetInfoState extends State<SetInfo> {
  final _authentication = FirebaseAuth.instance;
  final _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _image;

  Future pickImage() async {
    final XFile? selectedProfile = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedProfile != null) {
      setState(() {
        _image = XFile(selectedProfile.path);
      });
    }

  }

  Future<String> uploadUserProfilePicture() async {
    String imageUrl = '';
    if (_image != null) {
      String uid = _authentication.currentUser!.uid;
      final storageRef = FirebaseStorage.instance.ref().child(
          'profile_images/${uid}');
      final uploadTask = storageRef.putFile(File(_image!.path));

      try {
        // Firebase Storage에 파일 업로드
        final snapshot = await uploadTask.whenComplete(() {});
        // 업로드된 파일의 URL을 반환
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrl =  downloadUrl;
      } catch (e) {
        throw Exception("Failed to upload image: $e");
      }
    }
    return imageUrl;
  }

  Future<void> updateUserProfilePicture() async {
    String imageUrl = await uploadUserProfilePicture();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('userDetail').doc(userId).update({
      'photoUrl': imageUrl,
    });
  }

  Future<void> updateNickname(String nickname) async {
    String newNickname = '';
    _controller.text.isNotEmpty ? newNickname = _controller.text : newNickname = nickname;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // 문서 업데이트 또는 생성
      await FirebaseFirestore.instance.collection('userDetail').doc(userId).set({
        'nickname': newNickname,
      }, SetOptions(merge: true)); // merge 옵션을 사용하여 문서가 없으면 생성
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("프로필이 변경되었습니다.")));
    } catch (e) {
      print("Error updating nickname: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("프로필 변경에 실패했습니다: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '프로필 설정',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),

        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20,left: 20),
              child: Text('프로필 사진',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),),
            ),
            Container(
              width: double.maxFinite,
              height: 150,
              child: IconButton(
                alignment: Alignment.center,
                onPressed: () async {
                  try {
                    await pickImage();
                    if (_image != null) {
                      await updateUserProfilePicture();
                      print("Profile picture updated successfully");
                    }
                  } catch (e) {
                    print("Error updating profile picture: $e");
                  }
                },
                icon: buildUserProfileAvatar(widget.photoUrl, 80),
                iconSize: 150,
              ),
            ),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text('닉네임',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: Color(0xffcfe6fb), width: 2)
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.nickname.isNotEmpty ? widget.nickname : '닉네임을 입력하세요',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 60,
              margin: EdgeInsets.fromLTRB(20, 150, 20, 20),
              child: ElevatedButton(
                onPressed: () => updateNickname(widget.nickname), // 닉네임 업데이트
                child: Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color(0xffffe8a4), // Button background color
                  side: BorderSide(color: Color(0xffffe8a4)), // Border color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
