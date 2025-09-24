import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/widgets/address_order.dart';
import 'package:istoreto/featured/cart/view/widgets/cart__static_menu_item.dart';
import 'package:istoreto/featured/cart/view/widgets/order_success.dart';
import 'package:istoreto/featured/cart/view/widgets/payment_method_selector.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/view/widgets/vendor_profile.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/loader/loaders.dart';

class VendorSummaryScreen extends StatefulWidget {
  final String vendorId;
  const VendorSummaryScreen({super.key, required this.vendorId});

  @override
  State<VendorSummaryScreen> createState() => _VendorSummaryScreenState();
}

class _VendorSummaryScreenState extends State<VendorSummaryScreen> {
  String selectedPaymentMethod = 'cod'; // وسيلة الدفع الافتراضية
  VendorModel? vendorProfile;
  late ScrollController _scrollController; // ← أضف ScrollController
  late CartController cartController; // ← أضف CartController

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(); // ← إنشاء ScrollController
    cartController = CartController.instance; // ← تهيئة CartController

    // إضافة listener للتحكم في Visibility
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.forward) {
        cartController.setCheckoutVisibility(true);
      } else {
        cartController.setCheckoutVisibility(false);
      }
    });

    _loadVendorProfile();
  }

  Future<void> _loadVendorProfile() async {
    try {
      final profile = await VendorController.instance.fetchVendorreturnedData(
        widget.vendorId,
      );
      setState(() {
        vendorProfile = profile;
        // تحديد وسيلة الدفع الافتراضية بناءً على إعدادات التاجر
        if (profile.enableCod == true) {
          selectedPaymentMethod = 'cod';
        } else if (profile.enableIwintoPayment == true) {
          selectedPaymentMethod = 'iwinto_wallet';
        }
      });
    } catch (e) {
      print('Error loading vendor profile: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ← تنظيف ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = cartController.selectedItems;
    var controller = OrderController.instance;
    final items =
        cartController.cartItems
            .where(
              (item) =>
                  selected[item.product.id] == true &&
                  item.product.vendorId == widget.vendorId,
            )
            .toList();

    final total = items.fold<double>(0, (sum, item) => sum + item.totalPrice);

    return Scaffold(
      appBar: CustomAppBar(title: 'order.details'.tr),

      body: SafeArea(
        child:
            items.isEmpty
                ? Center(child: Text('cart_no_products_for_vendor'))
                : vendorProfile == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  controller: _scrollController, // ← استخدم ScrollController
                  padding: const EdgeInsets.all(16),
                  children: [
                    VendorProfilePreview(
                      vendorId: widget.vendorId,
                      color: Colors.black,
                      withunderLink: false,
                    ),
                    const SizedBox(height: 8),
                    ...items.map(
                      (item) => Column(
                        children: [
                          CartStaticMenuItem(item: item),
                          TCustomWidgets.buildDivider(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Row(
                        children: [
                          Text(
                            'cart_all_amount',
                            style: titilliumBold.copyWith(
                              fontFamily: numberFonts,
                            ),
                          ),
                          TRoundedContainer(
                            radius: BorderRadius.circular(15),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 16,
                              ),
                              child: TCustomWidgets.formattedPrice(
                                total,
                                20,
                                TColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AddressScreen(),
                    //  const SizedBox(height: 20),

                    // اختيار وسيلة الدفع
                    PaymentMethodSelector(
                      vendorProfile: vendorProfile!,
                      selectedPaymentMethod: selectedPaymentMethod,
                      onPaymentMethodChanged: (method) {
                        setState(() {
                          selectedPaymentMethod = method;
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                    Obx(
                      () => SizedBox(
                        child: ElevatedButton(
                          // سنستخدم child بدلاً من النص
                          onPressed:
                              controller.isSubmitting.value
                                  ? () {}
                                  : () async {
                                    if (items.isEmpty) {
                                      TLoader.warningSnackBar(
                                        message: 'cart.select_product_first'.tr,

                                        title: "",
                                      );
                                      return;
                                    }

                                    controller.isSubmitting.value = true;

                                    try {
                                      final profile =
                                          VendorController
                                              .instance
                                              .profileData
                                              .value;
                                      final addressService =
                                          Get.find<AddressService>();
                                      final selectedAddress =
                                          addressService.selectedAddress.value;

                                      // التحقق من وجود عنوان مختار
                                      if (selectedAddress == null) {
                                        TLoader.warningSnackBar(
                                          message:
                                              'cart_select_delivery_address'.tr,
                                          title: "",
                                        );
                                        return;
                                      }

                                      // التحقق من وجود رقم هاتف في العنوان المختار
                                      if (selectedAddress
                                          .phoneNumber!
                                          .isEmpty) {
                                        TLoader.warningSnackBar(
                                          message:
                                              'cart.select_address_with_phone'
                                                  .tr,

                                          title: "",
                                        );
                                        return;
                                      }

                                      // التحقق من رصيد المحفظة إذا كانت وسيلة الدفع هي محفظة iWinto
                                      // if (selectedPaymentMethod ==
                                      //     'iwinto_wallet') {
                                      //   await PaymentController.instance
                                      //       .checkout(
                                      //         profile.userId ?? '',
                                      //         {widget.vendorId: total},
                                      //         total,
                                      //         context,
                                      //       );
                                      // }

                                      final order = OrderModel(
                                        docId: "",
                                        id: UniqueKey().toString(),
                                        buyerId: profile.userId ?? '',
                                        vendorId: widget.vendorId,
                                        totalPrice: total,
                                        state:
                                            selectedPaymentMethod == 'cod'
                                                ? '4'
                                                : '1', // 4 للدفع عند الاستلام، 1 للدفع المسبق
                                        orderDate: DateTime.now(),

                                        productList: items,
                                        phoneNumber:
                                            selectedAddress.phoneNumber,
                                        fullAddress:
                                            selectedAddress.fullAddress,
                                        buildingNumber:
                                            selectedAddress.buildingNumber,
                                        paymentMethod: selectedPaymentMethod,
                                        locationLat: selectedAddress.latitude,
                                        locationLng: selectedAddress.longitude,
                                        buyerDetails:
                                            AuthController
                                                .instance
                                                .currentUser
                                                .value!,
                                      );

                                      await OrderController.instance
                                          .submitOrder(order);

                                      for (var i in items) {
                                        cartController.removeFromCart(
                                          i.product,
                                        );
                                      }

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => OrderSuccessScreen(
                                                order: order,
                                              ),
                                        ),
                                        (route) => false,
                                      );
                                    } catch (e) {
                                      TLoader.erroreSnackBar(
                                        message: 'order.submit_error'.tr,
                                      );
                                    } finally {
                                      controller.isSubmitting.value = false;
                                    }
                                  },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child:
                                controller.isSubmitting.value
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      'order.confirm'.tr,
                                      style: titilliumBold.copyWith(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      key: const ValueKey('order_confirm_text'),
                                    ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtWsections),
                  ],
                ),
      ),
    );
  }
}

// تم حذف extension الخاطئ
