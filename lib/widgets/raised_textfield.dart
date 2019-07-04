import 'package:flutter/material.dart';

class RaisedTextField extends StatelessWidget {
  final Function(String value) onChange;
  final String hintText;
  final String text;
  final Widget suffixIcon;
  final int maxLength;

  const RaisedTextField(
      {this.onChange(String value),
      this.hintText,
      this.text = "",
      this.suffixIcon,
      this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
        child: TextField(
          maxLength: maxLength ?? null,
          controller: TextEditingController(text: text)
            ..selection = TextSelection.collapsed(offset: text.length),
          decoration: InputDecoration(
              hintText: hintText,
              counter: SizedBox(
                height: 0,
              ),
              border: InputBorder.none,
              suffixIcon: suffixIcon),
          onChanged: onChange,
        ),
      ),
    );
  }
}
