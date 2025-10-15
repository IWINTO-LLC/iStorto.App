import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';

class MovableButton extends StatefulWidget {
  final String vendorId;
  const MovableButton({super.key, required this.vendorId});

  @override
  _MovableButtonState createState() => _MovableButtonState();
}

class _MovableButtonState extends State<MovableButton> {
  double top = 47.h;
  double right = 16;

  @override
  void initState() {
    super.initState();
    loadPosition(); // ← استرجاع الموقع
  }

  void loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      top = prefs.getDouble('buttonTop') ?? 100;
      right = prefs.getDouble('buttonRight') ?? 20;
    });
  }

  void savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('buttonTop', top);
    await prefs.setDouble('buttonRight', right);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            top += details.delta.dy;
            right -= details.delta.dx;
          });
        },
        onPanEnd: (_) => savePosition(), // ← حفظ عند انتهاء السحب
        child: backAction(widget.vendorId, context), // ← عنصر التفاعل الخاص بك
      ),
    );
  }
}
