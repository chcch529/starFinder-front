import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          fontFamily: "Pretendard"
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                  'assets/images/welcome.png',
                  width: 100, // 이미지의 너비
                  height: 100, // 이미지의 높이
                  fit: BoxFit.contain
              ),
              SizedBox(height: 20), // 이미지와 하단 텍스트 사이의 공간
              Text(
                '환영합니다',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 50,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
