import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoul/screens/chat/screen_chatroom.dart';
import 'package:seoul/screens/community/screen_newPost.dart';
import 'package:seoul/screens/community/screen_post.dart';
import 'package:seoul/screens/login/screen_findIdPw.dart';
import 'package:seoul/screens/mypage/set_info.dart';
import 'package:seoul/screens/screen_loading.dart';
import 'package:seoul/screens/login/screen_login.dart';
import 'package:seoul/screens/screen_map.dart';
import 'package:seoul/screens/signup/screen_welcome.dart';
import 'package:seoul/screens/signup/screen_signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seoul/weather/provideWeather.dart';
import 'package:seoul/weather/showWeather.dart';
import 'package:seoul/widget/timeago.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  timeago.setLocaleMessages("kr", KrCustomMessages());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Pretendard"
      ),
      routes: routes,
      home: LoginScreen(),
    );

    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: (context) {
    //       var weatherProvider = WeatherProvider();
    //       weatherProvider.loadWeather(); // 앱 시작 시 날씨 데이터 로드
    //       return weatherProvider;
    //     }),
    //   ],
    //   child: MaterialApp(
    //     theme: ThemeData(
    //     fontFamily: "Pretendard"
    //   ),
    //   routes: routes,
    //   home: Scaffold(
    //     backgroundColor: Color(0xfff5d6b3),
    //     body: WeatherWidget(),
    //     ),
    //   ),
    // );


  }
}

final routes = {
  // ChatRoomScreen.routeName: (context) => ChatRoomScreen(),
  PostScreen.routeName: (context) => PostScreen(),
  MapScreen.routeName: (context) => MapScreen(),
  FindCredentialsScreen.routeName: (context) => FindCredentialsScreen(),

};

// LoadingScreen
// LoginScreen
// MapScreen
// SignupScreen
// WelcomeScreen
// ChatScreen
