import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/empty_cart.dart';
import 'package:istoreto/featured/cart/view/vendor_cart_block.dart';
import 'package:istoreto/featured/cart/view/widgets/address_order.dart';
import 'package:istoreto/featured/cart/view/widgets/cart__static_menu_item.dart';
import 'package:istoreto/featured/cart/view/widgets/order_success.dart';
import 'package:istoreto/featured/cart/view/widgets/payment_method_selector.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/data/order.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/featured/shop/view/widgets/vendor_profile.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/loader/loaders.dart';

/// صفحة إكمال الطلب مع Stepper أفقي - نسخة مبسطة
class CheckoutStepperScreenSimple extends StatefulWidget {
  const CheckoutStepperScreenSimple({super.key});

  @override
  State<CheckoutStepperScreenSimple> createState() =>
      _CheckoutStepperScreenSimpleState();
}

class _CheckoutStepperScreenSimpleState
    extends State<CheckoutStepperScreenSimple> {
  int _currentStep = 0;
  final CartController cartController = Get.put(CartController());
  String selectedPaymentMethod = 'cod';
  Map<String, VendorModel?> vendorProfiles = {};

  @override
  void initState() {
    super.initState();

    // تهيئة Controllers
    if (!Get.isRegistered<VendorRepository>()) {
      Get.lazyPut(() => VendorRepository());
    }
    if (!Get.isRegistered<AddressService>()) {
      Get.put(AddressService());
    }

    // تحميل بيانات التجار
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        cartController.toggleSelectAll(true);
        _loadVendorProfiles();
      }
    });
  }

  /// تحميل بيانات التجار
  Future<void> _loadVendorProfiles() async {
    if (!mounted) return;

    try {
      final groupedItems = cartController.groupedByVendor;
      for (var vendorId in groupedItems.keys) {
        try {
          final profile = await VendorController.instance
              .fetchVendorreturnedData(vendorId);
          vendorProfiles[vendorId] = profile;

          if (vendorProfiles.length == 1) {
            if (profile.enableCod == true) {
              selectedPaymentMethod = 'cod';
            } else if (profile.enableIwintoPayment == true) {
              selectedPaymentMethod = 'iwinto_wallet';
            }
          }
        } catch (e) {
          print('Error loading vendor $vendorId: $e');
        }
      }
    } catch (e) {
      print('Error loading profiles: $e');
    }
  }

  /// الانتقال للخطوة التالية
  void _nextStep() {
    if (_currentStep < 2) {
      if (_currentStep == 0 && cartController.selectedItemsCount == 0) {
        TLoader.warningSnackBar(
          title: 'تنبيه',
          message: 'الرجاء اختيار منتج واحد على الأقل',
        );
        return;
      }

      if (_currentStep == 1) {
        final addressService = Get.find<AddressService>();
        final selectedAddress = addressService.selectedAddress.value;
        if (selectedAddress == null) {
          TLoader.warningSnackBar(
            title: 'تنبيه',
            message: 'الرجاء اختيار عنوان التوصيل',
          );
          return;
        }
      }

      setState(() {
        _currentStep++;
      });
    }
  }

  /// الرجوع للخطوة السابقة
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  /// إتمام الطلب
  Future<void> _completeOrder() async {
    final controller = OrderController.instance;
    controller.isSubmitting.value = true;

    try {
      final profile = VendorController.instance.profileData.value;
      final addressService = Get.find<AddressService>();
      final selectedAddress = addressService.selectedAddress.value;

      if (selectedAddress == null) {
        TLoader.warningSnackBar(
          message: 'الرجاء اختيار عنوان التوصيل',
          title: 'تنبيه',
        );
        return;
      }

      final groupedItems = cartController.groupedByVendor;
      final selectedItems = cartController.selectedItems;

      for (var entry in groupedItems.entries) {
        final vendorId = entry.key;
        final vendorItems =
            entry.value
                .where((item) => selectedItems[item.product.id] == true)
                .toList();

        if (vendorItems.isEmpty) continue;

        final total = vendorItems.fold<double>(
          0,
          (sum, item) => sum + item.totalPrice,
        );

        final order = OrderModel(
          docId: "",
          id: UniqueKey().toString(),
          buyerId: profile.userId ?? '',
          vendorId: vendorId,
          totalPrice: total,
          state: selectedPaymentMethod == 'cod' ? '4' : '1',
          orderDate: DateTime.now(),
          productList: vendorItems,
          phoneNumber: selectedAddress.phoneNumber,
          fullAddress: selectedAddress.fullAddress,
          buildingNumber: selectedAddress.buildingNumber,
          paymentMethod: selectedPaymentMethod,
          locationLat: selectedAddress.latitude,
          locationLng: selectedAddress.longitude,
          buyerDetails: AuthController.instance.currentUser.value!,
        );

        await OrderController.instance.submitOrder(order);

        for (var item in vendorItems) {
          cartController.removeFromCart(item.product);
        }
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) => OrderSuccessScreen(
                order: OrderModel(
                  docId: "",
                  id: "multiple_orders",
                  buyerId: profile.userId ?? '',
                  vendorId: "multiple",
                  totalPrice: cartController.selectedTotalPrice,
                  state: selectedPaymentMethod == 'cod' ? '4' : '1',
                  orderDate: DateTime.now(),
                  productList:
                      cartController.cartItems
                          .where(
                            (item) => selectedItems[item.product.id] == true,
                          )
                          .toList(),
                  phoneNumber: selectedAddress.phoneNumber,
                  fullAddress: selectedAddress.fullAddress,
                  buildingNumber: selectedAddress.buildingNumber,
                  paymentMethod: selectedPaymentMethod,
                  locationLat: selectedAddress.latitude,
                  locationLng: selectedAddress.longitude,
                  buyerDetails: AuthController.instance.currentUser.value!,
                ),
              ),
        ),
        (route) => false,
      );
    } catch (e) {
      TLoader.erroreSnackBar(message: 'حدث خطأ أثناء إرسال الطلب');
    } finally {
      controller.isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // AppBar
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: _previousStep,
                    ),
                  Expanded(
                    child: Text(
                      _getStepTitle(_currentStep),
                      style: titilliumBold.copyWith(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Stepper
          _buildStepper(),

          const Divider(height: 1),

          // المحتوى
          Expanded(child: _buildContent()),

          // الأزرار السفلية
          _buildBottomBar(),
        ],
      ),
    );
  }

  /// Stepper
  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _buildStepIndicator(0, Icons.shopping_cart, 'السلة'),
          _buildStepLine(0),
          _buildStepIndicator(1, Icons.location_on, 'العنوان'),
          _buildStepLine(1),
          _buildStepIndicator(2, Icons.receipt_long, 'الملخص'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, IconData icon, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey.shade400,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: titilliumRegular.copyWith(
              fontSize: 10,
              color: isActive ? Colors.black : Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 40),
        color: isActive ? Colors.black : Colors.grey.shade300,
      ),
    );
  }

  /// المحتوى
  Widget _buildContent() {
    if (_currentStep == 0) {
      return _buildCartStep();
    } else if (_currentStep == 1) {
      return _buildAddressStep();
    } else {
      return _buildSummaryStep();
    }
  }

  /// الخطوة 1: السلة
  Widget _buildCartStep() {
    return GetBuilder<CartController>(
      builder: (controller) {
        final groupedItems = controller.groupedByVendor;

        if (groupedItems.isEmpty) {
          return const Center(child: EmptyCartView());
        }

        final widgets = <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'منتجات حسب المتاجر',
              style: titilliumBold.copyWith(fontSize: 18, color: Colors.black),
            ),
          ),
          ...groupedItems.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: VendorCartBlock(vendorId: entry.key, items: entry.value),
            );
          }),
          const SizedBox(height: 100), // مساحة للزر السفلي
        ];

        return ListView(children: widgets);
      },
    );
  }

  /// الخطوة 2: العنوان
  Widget _buildAddressStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AddressScreen(),
        const SizedBox(height: 24),
        if (vendorProfiles.isNotEmpty && vendorProfiles.values.first != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('وسيلة الدفع', style: titilliumBold.copyWith(fontSize: 16)),
              const SizedBox(height: 16),
              PaymentMethodSelector(
                vendorProfile: vendorProfiles.values.first!,
                selectedPaymentMethod: selectedPaymentMethod,
                onPaymentMethodChanged: (method) {
                  setState(() {
                    selectedPaymentMethod = method;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }

  /// الخطوة 3: الملخص
  Widget _buildSummaryStep() {
    final selectedItems = cartController.selectedItems;
    final groupedItems = cartController.groupedByVendor;
    final addressService = Get.find<AddressService>();
    final selectedAddress = addressService.selectedAddress.value;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...groupedItems.entries.map((entry) {
          final vendorItems =
              entry.value
                  .where((item) => selectedItems[item.product.id] == true)
                  .toList();

          if (vendorItems.isEmpty) return const SizedBox.shrink();

          final total = vendorItems.fold<double>(
            0,
            (sum, item) => sum + item.totalPrice,
          );

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VendorProfilePreview(
                    vendorId: entry.key,
                    color: Colors.black,
                    withunderLink: false,
                    withPadding: false,
                  ),
                  const SizedBox(height: 16),
                  ...vendorItems.map(
                    (item) => Column(
                      children: [
                        CartStaticMenuItem(item: item),
                        const Divider(),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المجموع', style: titilliumBold),
                      TCustomWidgets.formattedPrice(total, 18, TColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        if (selectedAddress != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.black),
                      const SizedBox(width: 8),
                      Text('عنوان التوصيل', style: titilliumBold),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(selectedAddress.fullAddress),
                  const SizedBox(height: 8),
                  Text(selectedAddress.phoneNumber ?? ''),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        TRoundedContainer(
          showBorder: true,
          borderColor: TColors.primary,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المجموع الكلي', style: titilliumBold),
                TCustomWidgets.formattedPrice(
                  cartController.selectedTotalPrice,
                  20,
                  TColors.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// الأزرار السفلية
  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child:
            _currentStep == 0
                ? _buildStep0Buttons()
                : _buildOtherStepsButtons(),
      ),
    );
  }

  /// أزرار الخطوة 0 (السلة)
  Widget _buildStep0Buttons() {
    return GetBuilder<CartController>(
      builder: (controller) {
        final selectedCount = controller.selectedItemsCount;
        final total = controller.selectedTotalPrice;

        return Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المجموع الكلي',
                    style: titilliumRegular.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TCustomWidgets.formattedPrice(total, 20, TColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '($selectedCount منتج)',
                        style: titilliumRegular.copyWith(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: selectedCount > 0 ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_forward, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'إكمال الطلب',
                    style: titilliumBold.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// أزرار الخطوات الأخرى
  Widget _buildOtherStepsButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'رجوع',
                style: titilliumBold.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _currentStep == 2 ? _completeOrder : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentStep == 2 ? 'إتمام الطلب' : 'التالي',
              style: titilliumBold.copyWith(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'السلة';
      case 1:
        return 'العنوان والدفع';
      case 2:
        return 'ملخص الطلب';
      default:
        return '';
    }
  }
}
