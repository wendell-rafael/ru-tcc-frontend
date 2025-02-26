import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final FocusNode? nextFocus;
  final bool isConfirm;
  final String? Function(String?)? validator;

  const CustomPasswordField({
    Key? key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.nextFocus,
    this.isConfirm = false,
    this.validator,
  }) : super(key: key);

  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: _obscureText,
        textInputAction: widget.nextFocus != null ? TextInputAction.next : widget.textInputAction,
        onFieldSubmitted: (_) {
          if (widget.nextFocus != null) {
            FocusScope.of(context).requestFocus(widget.nextFocus);
          }
        },
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFFE65100), width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
        validator: widget.validator ??
                (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira ${widget.label.toLowerCase()}.';
              }
              if (!widget.isConfirm && value.length < 8) {
                return 'A senha deve ter no mínimo 8 caracteres.';
              }
              return null;
            },
      ),
    );
  }
}
