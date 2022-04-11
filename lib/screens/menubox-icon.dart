import 'package:flutter/material.dart';

class MenuBoxIcon extends StatefulWidget {
  String title;
  String image;
  Color color;
  double size;

  MenuBoxIcon(this.title, this.image, this.color, this.size, {Key? key})
      : super(key: key);

  @override
  State<MenuBoxIcon> createState() => _MenuBoxIconState();
}

class _MenuBoxIconState extends State<MenuBoxIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: widget.color, borderRadius: BorderRadius.circular(10)),
      height: widget.size,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
                fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Image.asset(widget.image),
          )
        ],
      ),
    );
  }
}
