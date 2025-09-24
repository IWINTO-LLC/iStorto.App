// import 'package:country_flags/country_flags.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sizer/sizer.dart';
// import 'package:istoreto/core/constants/text_styles.dart';
// import 'package:istoreto/featured/wallet/data/firebase/currencies.dart';

// class currentCurrencyWidget extends StatelessWidget {
//   const currentCurrencyWidget({
//     super.key,
//     //required this.cur,
//   });

//   //final Map<String, dynamic> cur;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer(
//       builder: (context, ref, child) {
//         var cur = ref.read(defaultCurrencyProvider.notifier).state;
//         return Container(
//           // width: 40.w,
//           color: Colors.white,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   cur['iso'] != 'wc' &&
//                           ref
//                                   .read(defaultCurrencyProvider.notifier)
//                                   .state['iso'] !=
//                               'USDT'
//                       ? CountryFlag.fromCountryCode(
//                         cur['iso'],
//                         height: 18,
//                         width: 35,
//                         borderRadius: 0,
//                       )
//                       : Container(
//                         width: 28,
//                         height: 28,
//                         margin: const EdgeInsets.only(left: 5, right: 2),
//                         decoration: BoxDecoration(
//                           color: Colors.transparent,
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: Center(
//                           child: Image.asset(
//                             cur['iso'] != 'USDT'
//                                 ? 'assets/images/winicoin.png'
//                                 : 'assets/images/usdt.png',
//                             width: 45,
//                             height: 45,
//                           ),
//                         ),
//                       ),
//                   const SizedBox(width: 16),
//                   Text(
//                     cur['name'],
//                     style: headline3.copyWith(fontFamily: 'Poppins'),
//                   ),
//                 ],
//               ),
//               // const Padding(
//               //   padding: EdgeInsets.only(right: 16.0),
//               //   child: Icon(
//               //     CupertinoIcons.arrow_turn_down_left,
//               //     color: Colors.black,
//               //     size: 18,
//               //   ),
//               // ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
