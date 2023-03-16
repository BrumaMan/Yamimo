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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
          color: getColor(), borderRadius: BorderRadius.circular(8.0)),
      child: Text(sourceTitle[0].toUpperCase(),
          style: TextStyle(color: Colors.white)),
    );
  }
}
