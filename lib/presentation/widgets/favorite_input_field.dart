import 'package:flutter/material.dart';

class FavoriteInputField extends StatelessWidget {
  final TextEditingController controller;

  const FavoriteInputField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Digite o nome do item...',
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Color(0xFFE65100),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}
