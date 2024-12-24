import 'package:flutter/material.dart';
class TextFeildInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool ispass;
  final String hinttext;
  final TextInputType textInputType;
  const TextFeildInput({super.key,required this.textInputType, this.
  ispass =false ,required this.textEditingController,required this.hinttext
  });

  @override
  Widget build(BuildContext context) {
    final InputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context)
    );
    return TextField(
      controller:textEditingController ,
      decoration: InputDecoration(
        hintText: hinttext,
        border:InputBorder,
          focusedBorder:InputBorder,
          enabledBorder: InputBorder,
          filled: true,
        contentPadding: EdgeInsets.all(8.0),
      ),
      keyboardType: textInputType,
      obscureText: ispass,
    );
  }
}
