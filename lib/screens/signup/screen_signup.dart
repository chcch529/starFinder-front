import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seoul/screens/login/screen_login.dart';
import 'package:seoul/screens/signup/screen_star.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seoul/screens/signup/screen_welcome.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _authentication = FirebaseAuth.instance;

  bool showSpinner = false;
  final formKey = GlobalKey<FormState>();
  late ScrollController _controller;
  final RestorableDouble _scrollOffset = RestorableDouble(0);

  String useremail = '';
  String userpassword = '';
  String username = '';
  String userphone = '';
  String usercerti = '';
  String userbirth = '';
  late String verificationId;

  void _tryValidation(){
    // 현재 상태가 null인지 확인합니다.
    if (formKey.currentState != null) {
      final isValid = formKey.currentState!.validate();
      if (isValid) {
        formKey.currentState!.save();
      }
    }
  }

  void verifyPhone(String phone) async {
    // '+'와 국가 코드를 포함한 전체 전화번호 포맷 생성

    var formattedPhone = '+82' + phone.substring(0);

    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      _authentication.signInWithCredential(authResult);
    };

    final PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
      print('${authException.message}');
      _showSnackBar("전화번호를 확인해주세요.");
    };

    final PhoneCodeSent smsSent = (String verId, [int? forceResend]) {
      this.verificationId = verId;
      _showSnackBar("인증번호가 전송되었습니다.");
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await _authentication.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      timeout: const Duration(seconds: 120),
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

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 3), // 스낵바가 보여질 시간 설정
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


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



  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
              centerTitle: true,
              title: Text('가입하기',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            body: Container(
                alignment: Alignment.topCenter,
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Container(
                    height: 800,
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 0),
                    child: SingleChildScrollView(
                      controller: _controller,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('아이디(이메일)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),), //아이디
                          SizedBox(
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
                                hintText: ('이메일 확인'),
                                hintStyle: TextStyle(
                                  color: Color(0xff767676),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                isDense: true,

                              ),
                            ),
                          ),

                          SizedBox(height: 20,),

                          Text('비밀번호',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),), //비밀번호
                          SizedBox(
                            height: 45,
                            child: TextFormField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              obscureText: true,
                              validator: (value) {
                                if (value!.length < 6 ) {
                                  return '6자리 이상 입력해주세요.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                userpassword = value!;

                              },
                              onChanged: (value) {
                                formKey.currentState?.validate();
                                userpassword = value;
                              },
                              decoration: InputDecoration(
                                hintText: ('비밀번호 확인'),
                                hintStyle: TextStyle(
                                  color: Color(0xff767676),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                isDense: true,

                              ),
                            ),
                          ),

                          SizedBox(height: 20,),

                          Text('비밀번호 재확인',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),), //비밀번호 재확인
                          SizedBox(
                            height: 45,
                            child: TextFormField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              obscureText: true,
                              validator: (value) {
                                if (value! != userpassword ) {
                                  return '비밀번호가 일치하지 않습니다';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: ('비밀번호 확인'),
                                hintStyle: TextStyle(
                                  color: Color(0xff767676),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                isDense: true,

                              ),
                            ),
                          ),

                          SizedBox(height: 20,),

                          Text('이름',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),), //이름
                          SizedBox(
                            height: 45,
                            child: TextFormField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value!.isEmpty){
                                  return '이름을 입력해주세요';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                username = value!;

                              },
                              onChanged: (value) {
                                formKey.currentState?.validate();
                                username = value;
                              },
                              decoration: InputDecoration(
                                hintText: ('실명을 입력하시오'),
                                hintStyle: TextStyle(
                                  color: Color(0xff767676),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                isDense: true,

                              ),
                            ),
                          ),

                          SizedBox(height: 20,),

                          Text('휴대폰 번호',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),), //전번
                          SizedBox(
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
                                    verifyPhone(userphone);
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

                          SizedBox(height: 20,),

                          Text('인증번호',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),), //인증번호
                          SizedBox(
                            height: 45,
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

                          SizedBox(height: 20,),

                          Text('생년월일',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),), //생년월일
                          SizedBox(
                            height: 45,
                            child: TextFormField(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value!.length != 8 ) {
                                  return '올바른 생년월일을 입력해주세요';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                userbirth = value!;

                              },
                              onChanged: (value) {
                                formKey.currentState?.validate();
                                userbirth = value;
                              },

                              decoration: InputDecoration(
                                hintText: ('8자리 입력'),
                                hintStyle: TextStyle(
                                  color: Color(0xff767676),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                isDense: true,

                              ),
                            ),
                          ),

                          SizedBox(height: 20,),

                          Container(
                            alignment: Alignment.center,
                            child: OutlinedButton(
                              onPressed: () async{
                                setState(() {
                                  showSpinner = true;
                                });
                                _tryValidation();

                                try {
                                  final newUser = await _authentication
                                      .createUserWithEmailAndPassword(
                                      email: useremail,
                                      password: userpassword

                                  );

                                  if (newUser.user != null) {
                                    // 사용자가 성공적으로 생성되면, Firestore에 사용자 정보 저장
                                    await FirebaseFirestore.instance.collection('users').doc(newUser.user!.uid).set({
                                      'email': useremail,
                                      'phone': userphone,
                                      'username': username,
                                      'birthDate': userbirth
                                    });

                                    // 다음 화면으로 이동
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()),
                                    );
                                  }
                                } catch (e) {
                                  print(e);
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }

                              },
                              child: Text('회원가입',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff767676),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.only(
                                      top: 2, bottom: 2,
                                      right: 2, left: 2
                                  ),
                                  fixedSize: Size(106, 41),
                                  backgroundColor: Color(0xffcfe6fb),
                                  side: BorderSide(
                                      color: Color(0xffcfe6fb),
                                      width: 2
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),)
                              ),
                            ),
                          ), //다음

                          SizedBox(height: 200,),

                        ],
                      ),
                    ),
                  ),
                ),
            ),

        ),
      ),
    );
  }


}