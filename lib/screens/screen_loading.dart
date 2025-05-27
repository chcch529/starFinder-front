import 'dart:async';

import 'package:flutter/material.dart';
import 'package:seoul/screens/login/screen_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seoul/screens/screen_map.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isInitialTimerComplete = false;

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 1800), () {
      setState(() {
        isInitialTimerComplete = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isInitialTimerComplete ? StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return MapScreen();
            } else {
              return LoginScreen();
            }
          }
          return buildLoading();
        },
      )
      : buildLoading();
  }

  Widget buildLoading() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,

              children: [
                Container(
                  width: 180, height: 30,
                  color: Color(0xffd9d9d9),
                ),
                Positioned(
                  child: Image.asset(
                      'assets/images/starfinder.png',
                      width: 260, // 이미지의 너비
                      height: 120, // 이미지의 높이
                      fit: BoxFit.contain
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 텍스트와 이미지 사이의 공간

            Image.asset(
                'assets/images/logo.png',
                width: 400, // 이미지의 너비
                height: 320, // 이미지의 높이
                fit: BoxFit.contain
            ),
            SizedBox(height: 20), // 이미지와 하단 텍스트 사이의 공간
            Text(
              '카리나를 찾는 중...',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
