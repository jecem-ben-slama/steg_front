import 'package:flutter/material.dart';
import 'package:pfa/Utils/Consts/style.dart';

class CustomInputField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final TextEditingController controller;
  final IconData? icon;
  final bool isPassword; // New property to indicate if it's a password field
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.icon,
    this.validator,
    this.isPassword = false, // Default to false
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool obscureText; // Internal state for toggling visibility

  @override
  void initState() {
    super.initState();
    obscureText = widget.isPassword; // Initialize based on isPassword
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white, fontSize: 12),
      controller: widget.controller,
      obscureText: obscureText, // Use internal state
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: MyColors.lightBlue),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(
          widget.icon,
          color: const Color.fromARGB(255, 240, 240, 240),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: const Color.fromARGB(255, 240, 240, 240),
                ),
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText; // Toggle visibility
                  });
                },
              )
            : null, // Only show suffix icon if it's a password field
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 255, 255, 255),
            width: 2,
          ),
        ),
      ),
      validator: widget.validator,
    );
  }
}
