import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:istoreto/utils/loader/loaders.dart';

class CopyableText extends StatelessWidget {
  const CopyableText({super.key, required this.child, required this.text});

  final Widget child;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: child),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
          tooltip: 'نسخ',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
            TLoader.successSnackBar(title: "", message: 'snak.copied'.tr);
          },
        ),
      ],
    );
  }
}
