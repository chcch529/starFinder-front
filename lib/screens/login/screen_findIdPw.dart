import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seoul/screens/login/screen_login.dart';

class FindCredentialsScreen extends StatefulWidget {

  static String routeName = "/screen_findIdPw";

  @override
  _FindCredentialsScreenState createState() => _FindCredentialsScreenState();
}

class _FindCredentialsScreenState extends State<FindCredentialsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '아이디 / 비밀번호 찾기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              tabBarTheme: TabBarTheme(
                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.transparent; // 눌린 상태에서는 투명색을 사용
                  }
                  return null; // 기본값은 사용하지 않음
                  },
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Color(0xffcfe6fb),
              unselectedLabelColor: Color(0xffc4c4c4),
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              indicatorColor: Color(0xffcfe6fb),
              indicatorSize: TabBarIndicatorSize.tab,



              tabs: [
                Tab(text: "아이디 찾기"),
                Tab(text: "비밀번호 찾기"),
              ],

            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FindIDScreen(),
          FindPasswordScreen(),
        ],
      ),
    );
  }
}

class FindIDScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final formKey = GlobalKey<FormState>();
    final _authentication = FirebaseAuth.instance;
    String formatUserPhone = '';
    late String verificationId;

    void _showSnackBar(String message) {
      final snackBar = SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3), // 스낵바가 보여질 시간 설정
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }


    void verifyPhone(String phone) async{
      final PhoneVerificationCompleted verified = (AuthCredential authResult) {
        _authentication.signInWithCredential(authResult);
      };

      final PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
        print('${authException.message}');
        _showSnackBar("전화번호를 확인해주세요.");
      };

      final PhoneCodeSent smsSent = (String verId, [int? forceResend]) {
        verificationId = verId;
        _showSnackBar("인증번호가 전송되었습니다.");
      };

      final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
        verificationId = verId;
      };

      await _authentication.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 300),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout,
      );
    }

    void confirmCode(String code) async {
      AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
      try {
        UserCredential result = await _authentication.signInWithCredential(credential);
        User? user = result.user;

        if (user != null) {
          _showSnackBar("전화번호 인증이 완료되었습니다.");
        } else {
          _showSnackBar("인증에 실패했습니다.");
        }
      } on FirebaseAuthException catch (e) {
        _showSnackBar("인증 오류: ${e.message}");
      }
    }

    void findEmailByPhone(String phone) async {
      if (phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a phone number.')));
        return;
      }

      // Firestore에서 전화번호로 사용자 검색
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 일치하는 문서가 있으면 이메일을 표시
        var data = querySnapshot.docs.first.data();
        // 데이터가 null이 아닐 때만 이메일 접근
        if (data != null) {
          Map<String, dynamic> userData = data as Map<String, dynamic>;
          String email = userData['email'] as String; // Safe cast, assuming 'email' is always a string if exists
          showDialog(
            context: context,
            builder: (context) => GetIdScreen(email)
          );
        } else {
        // 데이터가 null인 경우 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No data found for this phone number.')));
        }
      } else {
        // 일치하는 문서가 없을 경우
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('입력하신 정보와 일치하는 계정이 없습니다.')));
      }
    }


    String userphone = '';
    String usercerti = '';

    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 80, bottom: 15, left: 30, right: 30,),
            height: 45,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      userphone = value!;
                      formatUserPhone = '+82' + userphone.substring(1);


                    },
                    onChanged: (value) {
                      formKey.currentState?.validate();
                      userphone = value;
                    },

                    decoration: InputDecoration(
                      hintText: ("'-' 구분 없이 입력"),
                      isDense: true,
                      hintStyle: TextStyle(
                        color: Color(0xff767676),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: (){
                    verifyPhone(formatUserPhone);
                  },
                  child: Text('인증번호 전송',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff61abf1),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.only(
                          top: 2, bottom: 2,
                          right: 2, left: 2
                      ),
                      fixedSize: Size(110, 40),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: Color(0xff61abf1),
                          width: 1
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),)
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 45,
            margin: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      return null;
                    },
                    onSaved: (value) {
                      usercerti = value!;

                    },
                    onChanged: (value) {
                      formKey.currentState?.validate();
                      usercerti= value;
                    },

                    decoration: InputDecoration(
                      hintText: ("인증번호 입력"),
                      isDense: true,
                      hintStyle: TextStyle(
                        color: Color(0xff767676),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: (){
                    confirmCode(usercerti);
                  },
                  child: Text('인증번호 확인',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff61abf1),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.only(
                          top: 2, bottom: 2,
                          right: 2, left: 2
                      ),
                      fixedSize: Size(110, 40),
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: Color(0xff61abf1),
                          width: 1
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),)
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            width: 300,
            child: OutlinedButton(
              onPressed: (){
                findEmailByPhone(formatUserPhone);
              },
              child: Text(
                '아이디 찾기',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.fromLTRB(100, 15, 100, 15),
                minimumSize: Size.zero,
                backgroundColor: Color(0xffcfe6fb),
                side: BorderSide(
                    color: Color(0xffcfe6fb),
                    width: 1
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),)
              ),
            ),
          )
        ],
      ),
    );
  }
}

class GetIdScreen extends StatelessWidget {
  const GetIdScreen(this.useremail, {super.key});
  final String useremail;

  void resetPassword(BuildContext context, String useremail) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: useremail);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("비밀번호 재설정 링크가 이메일로 발송되었습니다.")),
      );
    } catch (e) {
      print(e); // 에러 로그 출력
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("비밀번호 재설정 링크 발송에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("계정 찾기 결과"),
      content: SingleChildScrollView(
        child: Container(
        child: Column(
          children: [
            Text(
              '입력하는 정보와 일치하는 게정을 찾았습니다',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('아이디: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black,
                    ),),
                  Text(useremail,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black,
                    ),)
                ],
              ),
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffc4c4c4), width: 1)
              ),
            ),
          ],
        ),
      ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              onPressed: () async{
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Color(0xffcfe6fb), // Button background color
                side: BorderSide(color: Color(0xffcfe6fb)), // Border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),

              ),
            ),
            OutlinedButton(
              onPressed: () async{
                resetPassword(context, useremail);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Color(0xffc4c4c4), // Button background color
                side: BorderSide(color: Color(0xffc4c4c4)), // Border color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                '비밀번호 재설정',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}


class FindPasswordScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    late final useremail;
    final formKey = GlobalKey<FormState>();

    void resetPassword(BuildContext context, String useremail) async {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: useremail);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("비밀번호 재설정 링크가 이메일로 발송되었습니다.")),
        );
      } catch (e) {
        print(e); // 에러 로그 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("비밀번호 재설정 링크 발송에 실패했습니다.")),
        );
      }
    }

    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 80, bottom: 15, left: 30, right: 30,),
            height: 45,
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value!.isEmpty || !value.contains('@')) {
                  return '유효한 이메일 주소를 입력해주세요.';
                }
                return null;
              },
              onSaved: (value) {
                useremail = value!;
              },
              onChanged: (value) {
                formKey.currentState?.validate();
                useremail = value;
              },
              decoration: InputDecoration(
                hintText: ('아이디 입력'),
                hintStyle: TextStyle(
                  color: Color(0xff767676),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
                isDense: true,

              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            width: 300,
            child: OutlinedButton(
              onPressed: () async {
                resetPassword(context, useremail);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen();
                    },
                  ),
                );
              },
              child: Text(
                '비밀번호 재설정',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(50, 15, 50, 15),
                  minimumSize: Size.zero,
                  backgroundColor: Color(0xffcfe6fb),
                  side: BorderSide(
                      color: Color(0xffcfe6fb),
                      width: 1
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),)
              ),
            ),
          )
        ],
      ),
    );
  }
}

