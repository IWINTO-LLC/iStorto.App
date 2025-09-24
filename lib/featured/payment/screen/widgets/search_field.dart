import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchField extends StatefulWidget {
  final Function(String) onChanged;
  const SearchField({required this.onChanged, super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: 'searchHint'.tr,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          // suffixIcon: IconButton(
          //   icon: const Icon(Icons.close, color: Colors.grey, size: 15),
          //   onPressed: () {
          //     controller.clear();
          //     widget.onChanged('');
          //   },
          // ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
