import 'package:flutter/material.dart';
import 'package:istoreto/utils/common/styles/styles.dart';

class AutoResizeTextField extends StatefulWidget {
  final String initialText;
  final Function(String) onChanged;

  AutoResizeTextField({required this.initialText, required this.onChanged});

  @override
  _AutoResizeTextFieldState createState() => _AutoResizeTextFieldState();
}

class _AutoResizeTextFieldState extends State<AutoResizeTextField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, // تحديد عرض ثابت للخلية
      child: TextFormField(
        controller: controller,
        onChanged: widget.onChanged,
        maxLines: 3, // السماح بالتمدد لأسطر جديدة
        style: titilliumRegular.copyWith(fontSize: 11),
      ),
    );
  }
}
