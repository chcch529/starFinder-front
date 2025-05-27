import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 0.5,
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
                },
              icon: Icon(Icons.notifications_none),
              iconSize: 30.0,
            ),

            SizedBox(width: 20,),

            Container(
              width: 149,
              height: 32,
              alignment: Alignment.center,
              child: Image.asset(
                  'assets/images/appbar_starfinder.png',
                  // width: 150, // 이미지의 너비
                  // height: 35, // 이미지의 높이
                  fit: BoxFit.contain
              ),
            ),

            SizedBox(width: 20,),

            IconButton(
              onPressed: () {
                Navigator.pop(context);
                },
              icon: Icon(Icons.favorite_border),
              iconSize: 30.0,
            ),
            SizedBox(
              width: 0.5,
            ),
          ],
        )
      ),
    );
  }
}

PreferredSizeWidget BackAppBar(BuildContext context) {
  return AppBar(
    centerTitle: true,
    title: Image.asset(
        'assets/images/appbar_starfinder.png',
        width: 150, // 이미지의 너비
        height: 35, // 이미지의 높이
        fit: BoxFit.contain
    ),
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  );
}