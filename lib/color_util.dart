import 'dart:math';
import 'package:flutter/material.dart';

class ColorUtil {

  // TODO: How to define these in the theme? Also, how to change field underline?
  static final primaryTextColor = Colors.grey;
  static final hintTextColor = Colors.grey[700];
  static final inactiveColor = Colors.grey[800];
  static final backgroundColor = Color(0xFF303030);

  static Color colorFromScore(int score, Color middleColor) {

    final colors = [
      Colors.red[700], Colors.red[500],
      Colors.orange[700], Colors.orange[400],
      Colors.yellow[300], middleColor,
      Colors.indigo[400], Colors.blue[500],
      Colors.teal[600], Colors.green[400]
    ];

    return colors[min(score ~/ 10, 9)]!;
  }
}