import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TableHeader extends StatelessWidget {
  const TableHeader(
      {super.key,
      this.onPressed,
      required this.buttonText,
      this.searchController,
      this.searchOnChanged});

  final Function()? onPressed;
  final String buttonText;
  final TextEditingController? searchController;
  final Function(String)? searchOnChanged;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50.w,
          child: ElevatedButton(onPressed: onPressed, child: Text(buttonText)),
        ),
        // Expanded(
        //   child: TextFormField(
        //     controller: searchController,
        //     onChanged: searchOnChanged,
        //     decoration: const InputDecoration(
        //         hintText: 'Search here ..', prefixIcon: Icon(Icons.search)),
        //   ),
        // )
      ],
    );
  }
}
