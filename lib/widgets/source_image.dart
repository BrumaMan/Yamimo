import 'dart:math';

import 'package:flutter/material.dart';

class SourceImage extends StatelessWidget {
  const SourceImage({super.key, required this.sourceTitle});

  final String sourceTitle;

  Color? getColor() {
    List<Color?> colors = [
      Colors.blue[400],
      Colors.green[400],
      Colors.red[400],
    ];

    int index = Random().nextInt(3);

    return colors[index];
  }

  Widget getSourceImage() {
    try {
      return Image.asset(
        "assets/${sourceTitle}.png",
        width: 32,
        height: 32,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Text(sourceTitle[0].toUpperCase(),
          style: TextStyle(color: Colors.white));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
        child: getSourceImage());
  }
}
