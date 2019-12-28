import 'package:flutter/material.dart';

class ScoreSlider extends StatelessWidget {

  final int score;
  final ValueChanged<double> onChanged;

  ScoreSlider({this.score, this.onChanged});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text("How well you know this ($score)", style: TextStyle(color: Colors.grey))
        ),
        Slider(
          value: score.toDouble(),
          onChanged: onChanged,
          min: 0,
          max: 100,
        )
      ],
    );
  }
}