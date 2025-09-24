// class PaymentController extends GetxController {
//   static PaymentController get instance => Get.find();

//   //Variables

//   checkout(
//     String winiUserId,
//     Map<String, double> list,
//     double totalAmount,
//     BuildContext context,
//   ) async {
//     TLoggerHelper.info('total Amount  in dollar $totalAmount');
//     var totalAmountInCoins = totalAmount / 12;
//     TLoggerHelper.info('total Amount in winis $totalAmountInCoins');
//     //check if the user has enough coins
//     if (globalRef!.read(winicoinsProvider.notifier).state <
//         totalAmountInCoins) {
//       TLoggerHelper.info('Not enough coins to buy product');

//       if (globalRef!.read(payWithStripeProvider)) {
//         //Stripe -----------------
//         try {
//           bool isSuccess = await initPaymentSheet(
//             context,
//             email: globalRef!.read(userMapProvider)!['email'],
//             amount:
//                 (((totalAmountInCoins *
//                                 globalRef!.read(winicoinsUsdRateProvider)) *
//                             globalRef!
//                                 .read(defaultCurrencyProvider.notifier)
//                                 .state['USDToCoinExchangeRate']) *
//                         globalRef!
//                             .read(defaultCurrencyProvider.notifier)
//                             .state['amountInSmallestUnit'])
//                     .toInt(),
//             currency:
//                 globalRef!.read(defaultCurrencyProvider.notifier).state['name'],
//           );

//           if (isSuccess) {
//             await buyWinicoins(
//               userId_,
//               'winicoins',
//               totalAmountInCoins,
//               (((totalAmountInCoins *
//                           globalRef!.read(winicoinsUsdRateProvider)) *
//                       globalRef!
//                           .read(defaultCurrencyProvider.notifier)
//                           .state['USDToCoinExchangeRate']))
//                   .toDouble(),
//               globalRef!.read(defaultCurrencyProvider.notifier).state['name'],
//             );

//             //after fill wallet ..send the mony to vendors stored in fatora map
//             //, the amount in fatora map is dollar so we convert to winicoins by mull with 12
//             list.forEach((vendorId, amount) {
//               paymentMethode(winiUserId, vendorId, amount / 12);
//             });

//             navigatorKey.currentState?.pop();
//           }
//         } catch (e) {
//           TLoggerHelper.error('Error in Stripe payment: ${e.toString()}');
//         }
//       } else {
//         //myfatoorah --------------------------------

//         double sarConversionRate =
//             globalRef!
//                 .read(availableCurrenciesProvider.notifier)
//                 .state
//                 .firstWhere(
//                   (element) => element['iso'] == 'SA',
//                 )['USDToCoinExchangeRate'];

//         log('SAR Conversion Rate: $sarConversionRate');

//         double amount = totalAmount * sarConversionRate.toDouble();

//         var userData = VendorController.instance.profileData.value;

//         await executeMyFatoorahPayment(
//           amount: amount,
//           context: context,
//           customerName: userData.name,
//           onSuccess: () {
//             //after fill wallet ..send the mony to vendors stored in fatora map
//             //, the amount in fatora map is dollar so we convert to winicoins by mull with 12
//             list.forEach((vendorId, amount) {
//               paymentMethode(winiUserId, vendorId, amount / 12);
//             });
//           },
//           onError: (e) => TLoader.erroreSnackBar(message: "payment Error $e"),
//           customerEmail: userData.email,
//         );
//       }
//     } else // the wallet has totalmount
//     {
//       list.forEach((vendorId, amount) {
//         paymentMethode(winiUserId, vendorId, amount / 12);
//       });
//     }
//   }
// }

// paymentMethode(String senderId, String receiverId, double winiPrice) async {
//   try {
//     Map<String, dynamic> s = await sendWinicoins(
//       senderId,
//       receiverId,
//       'winicoins',
//       winiPrice,
//       false,
//     );
//     // Get.closeCurrentSnackbar();
//     if (s['success'].toString() == 'true') {
//       // Get.closeCurrentSnackbar();
//       TLoader.successSnackBar(
//         title: "",
//         message:     "payment_successfully".tr,
//       );
//     } else {
//       TLoader.erroreSnackBar(
//         message: "payment_faild".tr,
//       );
//     }
//   } on Exception catch (e) {
//     TLoggerHelper.info(e.toString());
//     TLoader.warningSnackBar(title: '', message: e.toString());
//   }
// }

// Future<bool> executeMyFatoorahPayment({
//   required BuildContext context,
//   required double amount,
//   required String customerEmail,
//   required String customerName,
//   required Function() onSuccess,
//   required Function(String) onError,
// }) async {
//   try {
//     // Get available payment methods
//     final initRequest = MFInitiatePaymentRequest(
//       invoiceAmount: amount.roundToDouble(),
//       currencyIso: "SAR",
//     );
//     final initResult = await MFSDK.initiatePayment(
//       initRequest,
//       MFLanguage.ENGLISH,
//     );

//     // Filter payment methods for card, Apple Pay, and Google Pay
//     final availableMethods =
//         initResult.paymentMethods?.where((method) {
//           final name = method.paymentMethodEn?.toLowerCase() ?? '';
//           return name.contains('card') ||
//               name.contains('apple') ||
//               name.contains('google');
//         }).toList() ??
//         [];

//     // Add default card payment if not present
//     final hasCardPayment = availableMethods.any(
//       (method) =>
//           (method.paymentMethodEn?.toLowerCase() ?? '').contains('card'),
//     );

//     final allMethods =
//         hasCardPayment
//             ? availableMethods
//             : [
//               ...availableMethods,
//               MFPaymentMethod()
//                 ..paymentMethodEn = 'Credit/Debit Card'
//                 ..paymentMethodId = 2,
//             ];

//     // Show payment method selection
//     final selectedMethod = await showModalBottomSheet<dynamic>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Directionality(
//           textDirection: TextDirection.ltr,
//           child: Container(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.8,
//               minHeight: MediaQuery.of(context).size.height * 0.5,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
//                   child: Text(
//                     'Select Payment Method',
//                     style: headline3.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const Divider(height: 1),
//                 Expanded(
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     padding: const EdgeInsets.only(top: 8),
//                     itemCount: allMethods.length,
//                     physics: const BouncingScrollPhysics(),
//                     itemBuilder: (context, index) {
//                       final method = allMethods[index];
//                       final name = method.paymentMethodEn?.toLowerCase() ?? '';

//                       Widget icon;
//                       if (name.contains('apple')) {
//                         icon = SvgPicture.asset(
//                           'assets/svg/apple.svg',
//                           width: 32,
//                           height: 32,
//                         );
//                       } else if (name.contains('google')) {
//                         icon = SvgPicture.asset(
//                           'assets/svg/google.svg',
//                           width: 32,
//                           height: 32,
//                         );
//                       } else {
//                         icon = const Icon(Icons.credit_card, size: 32);
//                       }

//                       return ListTile(
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 8,
//                         ),
//                         leading: icon,
//                         title: Text(
//                           method.paymentMethodEn ?? 'Credit/Debit Card',
//                           style: headline3,
//                         ),
//                         onTap: () => Navigator.pop(context, method),
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 16), // Reduced bottom padding
//               ],
//             ),
//           ),
//         );
//       },
//     );

//     if (selectedMethod != null) {
//       MFExecutePaymentRequest request = MFExecutePaymentRequest(
//         invoiceValue: amount,
//         customerEmail: customerEmail,
//         customerName: customerName,
//       );
//       request.paymentMethodId = selectedMethod.paymentMethodId ?? 2;

//       final response = await MFSDK.executePayment(
//         request,
//         MFLanguage.ENGLISH,
//         (invoiceId) => log('Invoice ID: $invoiceId'),
//       );

//       log('MyFatoorah Status: ${response.invoiceStatus}');
//       if (response.invoiceStatus?.toLowerCase() == 'paid') {
//         onSuccess();
//         return true;
//       } else {
//         onError('Payment not completed');
//         return false;
//       }
//     }
//     return false;
//   } catch (error) {
//     log('MyFatoorah Error: $error');
//     onError(error.toString());
//     return false;
//   }
// }
