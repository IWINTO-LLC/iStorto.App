// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:istoreto/core/constants/text_styles.dart';

// class PupupMenu extends StatelessWidget {
//   const PupupMenu({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return PopupMenuButton<int>(
//       icon: const Icon(Icons.more_vert, color: Colors.black),
//       color: Colors.white,
//       itemBuilder: (context) {
//         final items = getVendorMenuItems(context, vendorId);
//         return List<PopupMenuEntry<int>>.generate(items.length, (index) {
//           final item = items[index];
//           return PopupMenuItem<int>(
//             value: index,
//             child: Row(
//               children: [
//                 Icon(item.icon, color: Colors.black, size: 20),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     item.title,
//                     style: bodyText1.copyWith(color: Colors.black),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         });
//       },
//       onSelected: (index) {
//         final selectedItem = getVendorMenuItems(context, vendorId)[index];
//         HapticFeedback.lightImpact();
//         selectedItem.onTap();
//       },
//     );
//   }
// }
