import 'package:flutter/material.dart';

class TextStroke extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Color strokeColor;
  final double strokeWidth;

  const TextStroke({
    Key? key,
    required this.text,
    required this.textStyle,
    this.strokeColor = Colors.black,
    this.strokeWidth = 1.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroked text as a border
        Text(
          text,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        // Solid text as a fill
        Text(text, style: textStyle),
      ],
    );
  }
}
