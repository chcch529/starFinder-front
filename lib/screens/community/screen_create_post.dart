import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:seoul/models/post_request.dart';
import 'package:seoul/screens/community/screen_comment.dart';
import 'package:seoul/screens/community/screen_post.dart';

import '../../models/model_board.dart';
import '../../providers/post_provider.dart';
import '../../services/post_service.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});
  @override
  ConsumerState<CreatePostScreen> createState() => _createPostScreen();
}

class _createPostScreen extends ConsumerState<CreatePostScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  bool showSpinner = false;

  final _bodyController = TextEditingController();

  List<XFile?> _selectedImages = []; // 선택된 이미지 파일들
  final ImagePicker _picker = ImagePicker();

  void _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _selectedImages.addAll(selectedImages);
      });
    }
  }

  Future<List<String>> uploadImages() async {
    List<String> imageUrls = [];
    for (var imageFile in _selectedImages!) {
      if (imageFile != null) {
        String uid = FirebaseAuth.instance.currentUser!.uid;

        final storageRef = FirebaseStorage.instance.ref().child(
            'posts/${uid}_${DateTime
                .now()
                .millisecondsSinceEpoch}_${imageFile!.name}');
        final uploadTask = storageRef.putFile(File(imageFile.path));


        try {
          final snapshot = await uploadTask.whenComplete(() {});
          String downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        } catch (e) {
          throw Exception("Failed to upload image: $e");
        }
      }
  }
    return imageUrls;
  }

  // void _sendPost() async {
  //   setState(() {
  //     showSpinner = true;
  //   });
  //   try {
  //     List<String> imageUrls = await uploadImages();
  //     FirebaseFirestore.instance.collection('board').add({
  //       'userId': uid,
  //       'body': _bodyController.text,
  //       'uploadImageUrls': imageUrls,
  //       'createdAt': DateTime.now(),
  //       'likeCnt': 0,
  //       'commentCnt': 0,
  //     });
  //   } catch (e) {
  //     print("Error posting data: $e");
  //   } finally {
  //     setState(() {
  //       showSpinner = false;
  //     });
  //   }
  // }
  void _sendPost() async {
    setState(() {
      showSpinner = true;
    });
    try {
      List<String> imageUrls = await uploadImages();

      final postService = ref.read(postServiceProvider);

      final postRequest = PostRequest(
        content: _bodyController.text,
      );

      await postService.createPost(postRequest);

      ref.invalidate(postListProvider);



    } catch (e) {
      print("Error posting data: $e");
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(File(_selectedImages[index]!.path))
                )
              ),
            ),
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 15,
                ),
                onPressed: (){
                  setState(() {
                    _selectedImages.remove(_selectedImages[index]);
                  });
                },
              ),
            )
          ],
        );
      },
    );
  }

  late ScrollController _controller;
  final RestorableDouble _scrollOffset = RestorableDouble(0);

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(() {

      _scrollOffset.value = _controller.offset;

      // 컨트롤러가 SingleChildScrollView에 연결이 됐는지 안돼는지
      _controller.hasClients;
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  Future<void> _dialogBuilder(BuildContext context){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(

            title: Container(
              alignment: Alignment.center,
              child: Text(
                '게시물을 업로드 하시겠습니까?',
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
                    onPressed: () async{
                      _sendPost();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PostScreen();
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
                    onPressed: (){
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
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            centerTitle: true,
            title: Text('게시글 작성',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            leading: TextButton(
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,

              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 350, height: 200,
                      padding: EdgeInsets.fromLTRB(15, 10, 15, 20),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Color(0xffcfe6fb),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: TextField(
                        controller: _bodyController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '지금 무슨 생각을 하시는 중인가요?',
                          hintStyle: TextStyle(
                            color: Color(0xffabb0bc),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 350, height: 1, color: Color(0xffd9d9d9),
                      margin: EdgeInsets.only(bottom: 20),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text('사진 업로드',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      width: 130, height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xffc4c4c4), width: 1),
                      ),
                      child: IconButton(
                        onPressed: _pickImages,
                        icon: Image.asset(
                          'assets/images/uploadImage.png',
                        ),
                        iconSize: 50,
                      ),
                    ), //사진 추가하기 버튼
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        '사진 추가하기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ), //사진 추가하기 text
                    _selectedImages.isNotEmpty ? _buildImageGrid() : Container(width:0,height:0,),

                    // Container(
                    //   width: 350, height: 1, color: Color(0xffd9d9d9),
                    //   margin: EdgeInsets.only(bottom: 20),
                    // ), //실선
                    // Container(
                    //     alignment: Alignment.centerLeft,
                    //     margin: EdgeInsets.only(bottom: 20),
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(left: 20),
                    //       child: Text('자주 쓰는 태그 추가',
                    //         style: TextStyle(
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w300,
                    //           fontSize: 14,
                    //         ),
                    //       ),
                    //     )
                    // ), //자주쓰느태그추가
                    // Container(
                    //   width: 350, height: 1, color: Color(0xffd9d9d9),
                    //   margin: EdgeInsets.only(bottom: 20),
                    // ), //실선
                    // Container(
                    //     alignment: Alignment.centerLeft,
                    //     margin: EdgeInsets.only(bottom: 20),
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(left: 20),
                    //       child: Text('장소 공유 하기',
                    //         style: TextStyle(
                    //           color: Colors.black,
                    //           fontWeight: FontWeight.w300,
                    //           fontSize: 14,
                    //         ),
                    //       ),
                    //     )
                    // ), //장소공유하기
                     Container(
                            margin: EdgeInsets.only(top: 100, bottom: 20),
                            width: 202, height: 50,
                            child: OutlinedButton(
                              onPressed: (){
                                _dialogBuilder(context);
                              },
                              child: Text('업로드',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black
                                  ),
                                ),
                              style: OutlinedButton.styleFrom(

                                backgroundColor: Color(0xffcfe6fb), // Button background color
                                side: BorderSide(color: Color(0xffcfe6fb)), // Border color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ),



                  ],
                ),
            ),
            ),
          ),
        ),

    );
  }
}


