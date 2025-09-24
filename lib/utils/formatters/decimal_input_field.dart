import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DecimalInputField extends StatefulWidget {
  @override
  _DecimalInputFieldState createState() => _DecimalInputFieldState();
}

class _DecimalInputFieldState extends State<DecimalInputField> {
  final TextEditingController _controller = TextEditingController();
  final NumberFormat formatter = NumberFormat("#,##0.00", "en_US"); // Format with decimal

  void _formatInput(String value) {
    if (value.isNotEmpty) {
      double? number = double.tryParse(value.replaceAll(',', ''));
      if (number != null) {
        _controller.value = TextEditingValue(
          text: formatter.format(number),
          selection: TextSelection.collapsed(offset: formatter.format(number).length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: "Enter a number"),
      onChanged: _formatInput, // Format number while typing
      onSaved: (value) {
        double savedValue = double.tryParse(value!.replaceAll(',', '')) ?? 0.0;
        print("Saved as double: $savedValue"); // Convert back to double
      },
    );
  }
}
