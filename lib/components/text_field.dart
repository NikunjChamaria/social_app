import 'package:flutter/material.dart';

class MyTextFiled extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscuretext;
  const MyTextFiled(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscuretext});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscuretext,
      decoration: InputDecoration(
          fillColor: Theme.of(context).colorScheme.primary,
          filled: true,
          hintText: hintText,
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.secondary))),
    );
  }
}
