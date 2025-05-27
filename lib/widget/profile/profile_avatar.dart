import 'package:flutter/material.dart';

class buildUserProfileAvatar extends StatelessWidget {
  const buildUserProfileAvatar(this.photoUrl, this.radius, {super.key});

  final String photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffffe8a4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 2.5,
            spreadRadius: 1.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
        child: photoUrl.isEmpty
            ? Icon(Icons.account_circle, size: radius * 2 )
            : null,
        backgroundColor: photoUrl.isEmpty ? Colors.grey[200] : Colors.transparent,
      ),
    );
  }
}
