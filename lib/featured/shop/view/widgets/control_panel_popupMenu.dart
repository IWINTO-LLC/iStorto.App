// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:istoreto/core/constants/text_styles.dart';
// import 'package:istoreto/featured/controls/presentation/control_center.dart';
// import 'package:istoreto/featured/album/screens/gallery_tab.dart';
// import 'package:istoreto/featured/banner/view/all/all_banners.dart';
// import 'package:istoreto/featured/category/view/all_category/all_categories.dart';
// import 'package:istoreto/featured/excel/view/excel_terms.dart';
// import 'package:istoreto/featured/payment/screen/vendor_sales.dart';
// import 'package:istoreto/featured/product/add_product/product_add_page.dart';
// import 'package:istoreto/featured/product/views/all_products_list.dart';
// import 'package:istoreto/featured/shop/data/menu_model.dart';
// import 'package:istoreto/featured/shop/view/policy_page.dart';
// import 'package:istoreto/featured/shop/view/store_settings.dart';

// class ControlPanelPopMenu extends StatelessWidget {
//   const ControlPanelPopMenu({super.key, required this.vendorId});
//   final String vendorId;

//   @override
//   Widget build(BuildContext context) {
//     final localizations = AppLocalizations.of(context);
//     final items = getVendorMenuItems(context, vendorId);

//     return Theme(
//       data: Theme.of(context).copyWith(
//         popupMenuTheme: PopupMenuThemeData(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15), // شكل الحواف الدائرية
//           ),
//         ),
//       ),
//       child: PopupMenuButton<int>(
//         icon: const Icon(Icons.more_vert, color: Colors.black),
//         iconSize: 25,
//         borderRadius: BorderRadius.circular(15),
//         padding: const EdgeInsetsDirectional.all(2),
//         itemBuilder:
//             (context) => List.generate(items.length, (index) {
//               final item = items[index];
//               return PopupMenuItem<int>(
//                 value: index,
//                 child: Row(
//                   children: [
//                     Icon(item.icon, color: Colors.black),
//                     const SizedBox(width: 10),
//                     Text(
//                       item.title,
//                       style: bodyText1.copyWith(color: Colors.black),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//         onSelected: (index) {
//           HapticFeedback.lightImpact();
//           items[index].onTap();
//         },
//       ),
//     );
//   }

//   List<MenuItemData> getVendorMenuItems(BuildContext context, String vendorId) {
//     final localizations = AppLocalizations.of(context);

//     return [
//       // MenuItemData(
//       //   icon: CupertinoIcons.eye,
//       //   title: isArabicLocale() ? 'مشاهدة متجري' : 'View my Shop',
//       //   onTap: () => Navigator.push(
//       //     context,
//       //     PageRouteBuilder(
//       //       pageBuilder: (context, animation, secondaryAnimation) => SaveForLaterScreen(),
//       //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       //         return SlideTransition(
//       //           position: Tween<Offset>(
//       //             begin: const Offset(1.0, 0.0),
//       //             end: Offset.zero,
//       //           ).animate(CurvedAnimation(
//       //             parent: animation,
//       //             curve: Curves.easeInOut,
//       //           )),
//       //           child: child,
//       //         );
//       //       },
//       //       transitionDuration: const Duration(milliseconds: 900),
//       //     ),
//       //   ),
//       // ),
//       MenuItemData(
//         icon: CupertinoIcons.settings,
//         title:   'settings.title'),
//         onTap:
//             () => Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder:
//                     (context, animation, secondaryAnimation) =>
//                         VendorSettingsPage(
//                           fromBage: 'controll',
//                           vendorId: vendorId,
//                         ),
//                 transitionsBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                   child,
//                 ) {
//                   return ScaleTransition(
//                     scale: Tween<double>(begin: 0.0, end: 1.0).animate(
//                       CurvedAnimation(
//                         parent: animation,
//                         curve: Curves.elasticOut,
//                       ),
//                     ),
//                     child: child,
//                   );
//                 },
//                 transitionDuration: const Duration(milliseconds: 900),
//               ),
//             ),
//       ),

//       MenuItemData(
//         icon: Icons.list,
//         title:   'order.orders'),
//         onTap:
//             () => Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder:
//                     (context, animation, secondaryAnimation) =>
//                         VendorSalesScreen(vendorId: vendorId),
//                 transitionsBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                   child,
//                 ) {
//                   return SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(0.0, 1.0),
//                       end: Offset.zero,
//                     ).animate(
//                       CurvedAnimation(
//                         parent: animation,
//                         curve: Curves.easeInOut,
//                       ),
//                     ),
//                     child: child,
//                   );
//                 },
//                 transitionDuration: const Duration(milliseconds: 900),
//               ),
//             ),
//       ),
//       //  MenuItemData(
//       //   icon: Icons.card_travel,
//       //   title:'add product',
//       //   onTap: () => Navigator.push(
//       //         context,
//       //         PageRouteBuilder(
//       //           pageBuilder: (context, animation, secondaryAnimation) => ProductAddPage(),
//       //           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       //             return SlideTransition(
//       //               position: Tween<Offset>(
//       //                 begin: const Offset(0.0, 1.0),
//       //                 end: Offset.zero,
//       //               ).animate(CurvedAnimation(
//       //                 parent: animation,
//       //                 curve: Curves.easeInOut,
//       //               )),
//       //               child: child,
//       //             );
//       //           },
//       //           transitionDuration: const Duration(milliseconds: 900),
//       //         ),
//       //       ),
//       // ),
//       MenuItemData(
//         icon: Icons.terminal,
//         title:   'shop.manage_terms'),
//         onTap:
//             () => Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder:
//                     (context, animation, secondaryAnimation) =>
//                         PolicyPage(vendorId: vendorId),
//                 transitionsBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                   child,
//                 ) {
//                   return ScaleTransition(
//                     scale: Tween<double>(begin: 0.0, end: 1.0).animate(
//                       CurvedAnimation(
//                         parent: animation,
//                         curve: Curves.bounceOut,
//                       ),
//                     ),
//                     child: child,
//                   );
//                 },
//                 transitionDuration: const Duration(milliseconds: 900),
//               ),
//             ),
//       ),
//       MenuItemData(
//         icon: Icons.save,
//         title:   'shop.excel_import'),
//         onTap:
//             () => Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder:
//                     (context, animation, secondaryAnimation) =>
//                         ImportExcelPage(vendorId: vendorId),
//                 transitionsBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                   child,
//                 ) {
//                   return SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(1.0, 0.0),
//                       end: Offset.zero,
//                     ).animate(
//                       CurvedAnimation(
//                         parent: animation,
//                         curve: Curves.easeInOut,
//                       ),
//                     ),
//                     child: child,
//                   );
//                 },
//                 transitionDuration: const Duration(milliseconds: 900),
//               ),
//             ),
//       ),
//       MenuItemData(
//         icon: Icons.category,
//         title: localizations.translate('shop.categories'),
//         onTap:
//             () => Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder:
//                     (context, animation, secondaryAnimation) =>
//                         CategoryMobileScreen(vendorId: vendorId),
//                 transitionsBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                   child,
//                 ) {
//                   return SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(1.0, 0.0),
//                       end: Offset.zero,
//                     ).animate(
//                       CurvedAnimation(
//                         parent: animation,
//                         curve: Curves.easeInOut,
//                       ),
//                     ),
//                     child: child,
//                   );
//                 },
//                 transitionDuration: const Duration(milliseconds: 900),
//               ),
//             ),
//       ),
//       MenuItemData(
//         icon: CupertinoIcons.infinite,
//         title: localizations.translate('shop.products'),
//         onTap:
//             () => Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder:
//                     (context, animation, secondaryAnimation) =>
//                         ProductsList(vendorId: vendorId),
//                 transitionsBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                   child,
//                 ) {
//                   return FadeTransition(
//                     opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
//                       CurvedAnimation(
//                         parent: animation,
//                         curve: Curves.easeInOut,
//                       ),
//                     ),
//                     child: child,
//                   );
//                 },
//                 transitionDuration: const Duration(milliseconds: 900),
//               ),
//             ),
//       ),
//       MenuItemData(
//         icon: CupertinoIcons.photo_on_rectangle,
//         title: localizations.translate('shop.banners'),
//         onTap:
//             () => Navigator.push(
//               context,
//               PageRouteBuilder(
//                 pageBuilder:
//                     (context, animation, secondaryAnimation) =>
//                         BannersMobileScreen(vendorId: vendorId),
//                 transitionsBuilder: (
//                   context,
//                   animation,
//                   secondaryAnimation,
//                   child,
//                 ) {
//                   return SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(1.0, 0.0),
//                       end: Offset.zero,
//                     ).animate(
//                       CurvedAnimation(
//                         parent: animation,
//                         curve: Curves.easeInOut,
//                       ),
//                     ),
//                     child: child,
//                   );
//                 },
//                 transitionDuration: const Duration(milliseconds: 900),
//               ),
//             ),
//       ),

//     ];
//   }
// }
