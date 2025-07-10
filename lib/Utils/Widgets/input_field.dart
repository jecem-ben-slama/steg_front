import 'package:flutter/material.dart';
import 'package:pfa/Utils/Consts/style.dart';

class InputField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool? obscure;
  final String? Function(String?)? validator;

  const InputField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.icon,
    this.validator,
    this.suffixIcon,
    this.obscure,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white, fontSize: 12),

      controller: widget.controller,
      obscureText: widget.obscure ?? false,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: MyColors.lightBlue),
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(widget.icon, color: MyColors.darkBlue),
        suffixIcon: widget.suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: MyColors.lightBlue, width: 2),
        ),
      ),
      validator: widget.validator,
    );
  }
}
