import 'package:flutter/material.dart';

class HeartCounter extends StatelessWidget {
  final int lives;
  final int maxLives;

  const HeartCounter({Key? key, required this.lives, required this.maxLives}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        return Icon(
          index < lives ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
          size: 32,
        );
      }),
    );
  }
}
