import 'package:flutter/material.dart';

PopupMenuItem<int> buildMenuItem({
  required int value,
  required IconData icon,
  required String title,
  required TextStyle textStyle,
}) {
  return PopupMenuItem(
    value: value,
    child: Row(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: textStyle,
          ),
        ),
      ],
    ),
  );
}
