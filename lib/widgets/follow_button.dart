import 'package:flutter/material.dart';
class FollowButton extends StatelessWidget {
  final Function() ? function;
  final Color backgroundcolor;
  final Color bordercolor;
  final String text;
  final Color textcolor;
  const FollowButton({super.key,
    required this.text,
    required this.bordercolor,
    required this.backgroundcolor,
    required this.textcolor,
    this.function});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed:function,
        child: Container(
          decoration: BoxDecoration(
              color: backgroundcolor,
              border: Border.all(color: bordercolor,)
              ,borderRadius: BorderRadius.circular(5)
          ),
          alignment: Alignment.center,
          child: Text(text,
            style: TextStyle(
                color: textcolor,
                fontWeight: FontWeight.bold),),
          width: MediaQuery.of(context).size.width/1.8,
          height: 27,

        ),

      ),
    );
  }
}
