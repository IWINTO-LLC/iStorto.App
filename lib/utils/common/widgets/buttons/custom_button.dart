import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/styles/styles.dart';

class CustomButtonBlack extends StatelessWidget {
  CustomButtonBlack({
    super.key,
    this.onTap,
    this.width = 150,
    required this.text,
  });

  final VoidCallback? onTap;
  final String text;
  double width;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: width,
          padding: const EdgeInsets.fromLTRB(5, 7, 5, 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.black,
          ),
          child: Center(
            child: Text(
              text,
              style: titilliumSemiBold.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
