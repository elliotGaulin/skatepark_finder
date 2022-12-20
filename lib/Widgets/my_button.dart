import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final String text;
  final Function() onPressed;

  const MyButton({required this.text, required this.onPressed, super.key});

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapUp: (details) => setState(() {
        scale = 1;
        widget.onPressed();
      }),
      onTapCancel: () => setState(() => scale = 1),
      onTapDown: (details) => setState(() => scale = 1.5),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(widget.text,
              style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
    );
  }
}
