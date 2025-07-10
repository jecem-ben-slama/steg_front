import 'package:flutter/material.dart';

class Btn extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final double width;
  final double height;
  final VoidCallback onpress;
  const Btn({
    super.key,
    required this.color,
    required this.height,
    required this.text,
    required this.size,
    required this.width,
    required this.onpress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          ),
          backgroundColor: WidgetStateProperty.all(color),
        ),
        onPressed: () {
          onpress();
        },
        child: Text(text, style: TextStyle(fontSize: size)),
      ),
    );
  }
}
