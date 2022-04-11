import 'package:flutter/material.dart';

class MenuBox extends StatefulWidget {
  String title;
  String detail;
  Color color;
  double size;

  MenuBox(this.title, this.detail, this.color, this.size, {Key? key})
      : super(key: key);

  @override
  State<MenuBox> createState() => _MenuBoxState();
}

class _MenuBoxState extends State<MenuBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: widget.color, borderRadius: BorderRadius.circular(10)),
      height: widget.size,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 28, color: Colors.black),
          ),
          Expanded(
            child: Text(
              widget.detail,
              style: const TextStyle(
                fontSize: 28,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          )
        ],
      ),
    );
  }
}
