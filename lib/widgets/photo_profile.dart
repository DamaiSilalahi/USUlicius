import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  final double iconSize;

  const ProfileAvatar({
    super.key,
    this.radius = 40,
    this.iconSize = 50,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE6E0F8),
      child: Icon(
        Icons.person,
        size: iconSize,
        color: const Color(0xFF673AB7),
      ),
    );
  }
}
