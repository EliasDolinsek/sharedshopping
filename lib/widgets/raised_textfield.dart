import 'package:flutter/material.dart';

class RaisedTextField extends StatelessWidget {
  final Function(String value) onChange;
  final String hintText;
  final String text;
  final Widget suffix;
  final int maxLength;

  const RaisedTextField(
      {this.onChange(String value),
      this.hintText,
      this.text = "",
      this.suffix,
      this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: TextField(
                maxLength: maxLength ?? null,
                controller: TextEditingController(text: text),
                decoration: InputDecoration(
                  hintText: hintText,
                  counter: SizedBox(height: 0,),
                  border: InputBorder.none,
                ),
                onChanged: onChange,
              ),
            ),
            Padding(child: suffix, padding: EdgeInsets.only(bottom: 6),) ?? Container(width: 0, height: 0)
          ],
        ),
      ),
    );
  }
}
