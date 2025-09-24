import 'dart:ui';

import 'package:flutter/material.dart';

class SearchAndSort extends StatelessWidget {
  final TextEditingController controller;
  final String sortBy;
  final ValueChanged<String> onSortChanged;

  const SearchAndSort({
    required this.controller,
    required this.sortBy,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white30),
          ),
          child: Column(
            children: [
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "${"search.search"} ...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButton<String>(
                  value: sortBy,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: Colors.black.withOpacity(0.85),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                  items: const [
                    DropdownMenuItem(
                      value: "default",
                      child: Text("الافتراضي"),
                    ),
                    DropdownMenuItem(value: "name", child: Text("الاسم")),
                    DropdownMenuItem(value: "size", child: Text("الحجم")),
                    DropdownMenuItem(value: "count", child: Text("عدد الصور")),
                  ],
                  onChanged: (val) => onSortChanged(val ?? "default"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
