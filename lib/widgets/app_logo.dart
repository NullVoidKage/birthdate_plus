import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({
    Key? key,
    this.size = 40,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.cake,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }
} 