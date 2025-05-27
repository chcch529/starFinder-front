import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class StarScreen extends StatefulWidget {
  const StarScreen({super.key});

  @override
  State<StarScreen> createState() => _StarScreenState();
}

class _StarScreenState extends State<StarScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  String starName = '';

  List<String> selectStars = [];

  // firebase에서 star 검색 후 추가
  Future<void> addStarsToUserDetail(String userId, String starName) async {
    await FirebaseFirestore.instance.collection('userDetail')
        .doc(userId).set({
      'stars': FieldValue.arrayUnion(selectStars)
    }, SetOptions(merge: true));


    final starDoc = await FirebaseFirestore.instance
        .collection('star').where('name', isEqualTo: starName)
        .limit(1)
        .get();

    if (starDoc.docs.isNotEmpty) {
      final starId = starDoc.docs.first.id;
      await FirebaseFirestore.instance.collection('star').doc(starId)
          .update({
        'count': FieldValue.increment(1),
      });
    } else {
      await FirebaseFirestore.instance.collection('star').add({
        'name': starName,
        'count': 1,
      });

    }


  }

  Stream<List<Map<String, dynamic>>> getStarsData(String starName) {
    return FirebaseFirestore.instance
          .collection('star')
          .where('name', isEqualTo: starName)
          .snapshots()
          .asyncMap((snapshot) async{
      List<Map<String, dynamic>> starData = [];
      for (var doc in snapshot.docs) {
        starData.add({
          'name': doc.get('name'),
          'count': doc.get('count')
        });
      }
      return starData;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('스타 정보',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Back button action
          },
        ),
      ),
      body: Container(
        child: Row(
          children: [
            Expanded(
                child: SizedBox(
                  width: 336, height: 42,
                  child: IdolSearchBar(
                    onSearch: (value){
                      starName = value;
                    },
                  ),
                )
            ),
            Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: getStarsData(starName),
                  builder: (context, snapshot){
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container(
                        child: ElevatedButton(
                          child: Text('스타 추가하기'),
                          onPressed: (){
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                      title: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'star를 추가하시겠습니까?',
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
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('취소')
                                              ),
                                              OutlinedButton(
                                                  onPressed: () {
                                                    addStarsToUserDetail(userId, starName);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('추가')
                                              ),
                                            ]
                                        )
                                      ]
                                  );
                                }
                            );
                          },
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index){
                        var starData = snapshot.data![index];
                        String name = starData['name'];
                        int count = starData['count'];

                        return ListTile(
                          title: Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16
                                ),
                              ),
                              Spacer(),
                              Text(
                                '${count}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 16
                                ),
                              )
                            ],
                          ),
                          onTap: (){
                            addStarsToUserDetail(userId, name);
                          },
                        );
                      },
                    );
                  },
                )
            )

          ],
        ),
      ),
    );
  }
}

class IdolSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const IdolSearchBar({
    Key? key,
    required this.onSearch,
  }) : super(key: key);

  @override
  _IdolSearchBarState createState() => _IdolSearchBarState();
}

class _IdolSearchBarState extends State<IdolSearchBar> {

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      onChanged: (value) {
        print("Input changed: $value");  // 입력된 값이 바뀔 때마다 프린트
        widget.onSearch(value);
      },
      onSubmitted: (value) {
        print("Input submitted: $value");  // 검색 제출 시 프린트
        widget.onSearch(value);
      },
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      backgroundColor: MaterialStatePropertyAll(Color(0xffcfe6fb)),
      leading: Icon(Icons.search, size: 18,),
      hintText: "나의 스타를 입력해주세요",
      textStyle: MaterialStateProperty.all(TextStyle(
        fontSize: 14,
        color: Color(0xff767676),
      )),
    );
  }
}