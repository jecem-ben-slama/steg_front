import 'package:flutter/material.dart';
import 'package:pfa/Utils/Consts/style.dart';

class TextBtn extends StatelessWidget {
  final String text;
  final double size;
  final VoidCallback onpress;

  const TextBtn({
    super.key,
    required this.text,
    required this.size,
    required this.onpress,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onpress();
      },
      child: Text(
        text,
        style: TextStyle(color: MyColors.lightBlue, fontSize: size),
      ),
    );
  }
}
