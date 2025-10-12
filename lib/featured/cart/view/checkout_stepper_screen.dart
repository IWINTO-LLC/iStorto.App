import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/view/empty_cart.dart';
import 'package:istoreto/featured/cart/view/vendor_cart_block.dart';
import 'package:istoreto/featured/cart/view/widgets/address_order.dart';
import 'package:istoreto/featured/cart/view/widgets/cart__static_menu_item.dart';
import 'package:istoreto/featured/cart/view/widgets/cart_shimmer.dart';
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
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/loader/loaders.dart';

/// صفحة إكمال الطلب مع Stepper أفقي
class CheckoutStepperScreen extends StatefulWidget {
  const CheckoutStepperScreen({super.key});

  @override
  State<CheckoutStepperScreen> createState() => _CheckoutStepperScreenState();
}

class _CheckoutStepperScreenState extends State<CheckoutStepperScreen> {
  int _currentStep = 0;
  late ScrollController _scrollController;
  late CartController cartController;
  String selectedPaymentMethod = 'cod';
  Map<String, VendorModel?> vendorProfiles = {};
  bool isLoadingVendors = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // تهيئة Controllers بشكل آمن
    try {
      if (!Get.isRegistered<VendorRepository>()) {
        Get.lazyPut(() => VendorRepository());
      }

      cartController =
          Get.isRegistered<CartController>()
              ? Get.find<CartController>()
              : Get.put(CartController());

      // تهيئة AddressService
      if (!Get.isRegistered<AddressService>()) {
        Get.put(AddressService());
      }

      // إضافة listener للتحكم في Visibility
      _scrollController.addListener(() {
        if (_scrollController.hasClients) {
          final direction = _scrollController.position.userScrollDirection;
          if (direction == ScrollDirection.forward) {
            cartController.setCheckoutVisibility(true);
          } else {
            cartController.setCheckoutVisibility(false);
          }
        }
      });

      // تحديد الكل بعد تحميل البيانات
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          cartController.toggleSelectAll(true);
          _loadVendorProfiles();
        }
      });
    } catch (e) {
      print('❌ Error in initState: $e');
    }
  }

  /// تحميل بيانات جميع التجار
  Future<void> _loadVendorProfiles() async {
    if (!mounted) return;

    setState(() {
      isLoadingVendors = true;
    });

    try {
      final groupedItems = cartController.groupedByVendor;
      print('📦 Loading profiles for ${groupedItems.length} vendors');

      for (var vendorId in groupedItems.keys) {
        try {
          print('🔄 Loading vendor: $vendorId');
          final profile = await VendorController.instance
              .fetchVendorreturnedData(vendorId);
          vendorProfiles[vendorId] = profile;
          print('✅ Loaded vendor: $vendorId');

          // تحديد وسيلة الدفع الافتراضية من أول تاجر
          if (vendorProfiles.length == 1) {
            if (profile.enableCod == true) {
              selectedPaymentMethod = 'cod';
            } else if (profile.enableIwintoPayment == true) {
              selectedPaymentMethod = 'iwinto_wallet';
            }
          }
        } catch (e) {
          print('❌ Error loading vendor $vendorId: $e');
          vendorProfiles[vendorId] = null;
        }
      }

      print('✅ Finished loading vendor profiles');
    } catch (e) {
      print('❌ Error loading vendor profiles: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingVendors = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// الانتقال للخطوة التالية
  void _nextStep() {
    if (_currentStep < 2) {
      // التحقق من الشروط قبل الانتقال
      if (_currentStep == 0) {
        // التحقق من اختيار منتجات
        if (cartController.selectedItemsCount == 0) {
          TLoader.warningSnackBar(
            title: 'تنبيه',
            message: 'الرجاء اختيار منتج واحد على الأقل',
          );
          return;
        }
      } else if (_currentStep == 1) {
        // التحقق من اختيار عنوان
        if (!Get.isRegistered<AddressService>()) {
          Get.put(AddressService());
        }
        final addressService = Get.find<AddressService>();
        final selectedAddress = addressService.selectedAddress.value;
        if (selectedAddress == null) {
          TLoader.warningSnackBar(
            title: 'تنبيه',
            message: 'الرجاء اختيار عنوان التوصيل',
          );
          return;
        }
        if (selectedAddress.phoneNumber?.isEmpty ?? true) {
          TLoader.warningSnackBar(
            title: 'تنبيه',
            message: 'الرجاء اختيار عنوان يحتوي على رقم هاتف',
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
      if (!Get.isRegistered<AddressService>()) {
        Get.put(AddressService());
      }
      final addressService = Get.find<AddressService>();
      final selectedAddress = addressService.selectedAddress.value;

      if (selectedAddress == null) {
        TLoader.warningSnackBar(
          message: 'الرجاء اختيار عنوان التوصيل',
          title: 'تنبيه',
        );
        return;
      }

      // إنشاء طلبات منفصلة لكل تاجر
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

        // حذف المنتجات من السلة
        for (var item in vendorItems) {
          cartController.removeFromCart(item.product);
        }
      }

      // الانتقال لصفحة النجاح
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
    print('🎨 Building CheckoutStepperScreen');
    print('📊 Current step: $_currentStep');
    print('🛒 Cart items: ${cartController.cartItems.length}');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // AppBar
          SafeArea(bottom: false, child: _buildAppBar()),

          // Stepper الأفقي
          _buildHorizontalStepper(),

          const Divider(height: 1),

          // محتوى الخطوة
          Expanded(
            child: Obx(() {
              print(
                '📦 Obx rebuilding - Loading: ${cartController.isLoading.value}, Items: ${cartController.cartItems.length}',
              );

              if (cartController.isLoading.value) {
                return const CartShimmer();
              }

              if (cartController.cartItems.isEmpty) {
                return const EmptyCartView();
              }

              return _buildStepContent();
            }),
          ),

          // أزرار التنقل
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// AppBar
  Widget _buildAppBar() {
    return Container(
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
              style: titilliumBold.copyWith(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // للموازنة مع زر الرجوع
        ],
      ),
    );
  }

  /// Stepper الأفقي
  Widget _buildHorizontalStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _buildStepIndicator(0, Icons.shopping_cart, 'cart.shopList'.tr),
          _buildStepLine(0),
          _buildStepIndicator(1, Icons.location_on, 'order.address_section'.tr),
          _buildStepLine(1),
          _buildStepIndicator(2, Icons.receipt_long, 'order.details'.tr),
        ],
      ),
    );
  }

  /// مؤشر الخطوة
  Widget _buildStepIndicator(int step, IconData icon, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Expanded(
      child: Column(
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
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  /// خط الربط بين الخطوات
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

  /// محتوى الخطوة
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCartStep();
      case 1:
        return _buildAddressStep();
      case 2:
        return _buildSummaryStep();
      default:
        return const SizedBox.shrink();
    }
  }

  /// الخطوة 1: السلة
  Widget _buildCartStep() {
    print('🛒 Building Cart Step');

    return GetBuilder<CartController>(
      builder: (controller) {
        final groupedItems = controller.groupedByVendor;
        print('📦 Grouped items: ${groupedItems.length}');

        if (groupedItems.isEmpty) {
          print('⚠️ No grouped items found');
          return const Center(
            child: Padding(padding: EdgeInsets.all(24), child: EmptyCartView()),
          );
        }

        // فلترة التجار الذين لديهم منتجات صالحة
        final validVendors = groupedItems.entries.toList();

        print('✅ Total vendors before filter: ${groupedItems.length}');
        print('✅ Valid vendors: ${validVendors.length}');

        // طباعة تفاصيل كل تاجر
        for (var entry in validVendors) {
          final vendorId = entry.key;
          final items = entry.value;
          print('🏪 Vendor: $vendorId has ${items.length} items');
          for (var item in items) {
            final qty =
                controller.productQuantities[item.product.id]?.value ?? 0;
            print('   📦 Product: ${item.product.title} - Qty: $qty');
          }
        }

        if (validVendors.isEmpty) {
          print('⚠️ No valid vendors found');
          return const Center(
            child: Padding(padding: EdgeInsets.all(24), child: EmptyCartView()),
          );
        }

        // بناء قائمة الـ widgets
        final widgets = <Widget>[
          // العنوان
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              Get.locale?.languageCode == 'ar'
                  ? 'منتجات حسب المتاجر'
                  : 'Products by Vendors',
              style: titilliumBold.copyWith(fontSize: 18, color: Colors.black),
            ),
          ),

          // المنتجات لكل تاجر
          ...validVendors.map((entry) {
            final vendorId = entry.key;
            final items = entry.value;

            print(
              '🏪 Building vendor block: $vendorId with ${items.length} items',
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: VendorCartBlock(vendorId: vendorId, items: items),
            );
          }),
        ];

        print('📋 Total widgets to display: ${widgets.length}');

        return ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: widgets,
        );
      },
    );
  }

  /// الخطوة 2: العنوان ووسيلة الدفع
  Widget _buildAddressStep() {
    // تهيئة AddressService إذا لم يكن موجوداً
    if (!Get.isRegistered<AddressService>()) {
      Get.put(AddressService());
    }

    print('📍 Building Address Step');
    print('🏪 Vendor profiles loaded: ${vendorProfiles.length}');

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // اختيار العنوان
        const AddressScreen(),

        const SizedBox(height: 24),

        // اختيار وسيلة الدفع
        if (vendorProfiles.isNotEmpty && vendorProfiles.values.first != null)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'order.payment_method'.tr,
                style: titilliumBold.copyWith(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
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
    if (!Get.isRegistered<AddressService>()) {
      Get.put(AddressService());
    }
    final addressService = Get.find<AddressService>();
    final selectedAddress = addressService.selectedAddress.value;

    print('📋 Building Summary Step');
    print('✅ Selected address: ${selectedAddress?.fullAddress ?? "None"}');

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // ملخص المنتجات حسب التاجر
        ...groupedItems.entries.map((entry) {
          final vendorId = entry.key;
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
                    vendorId: vendorId,
                    color: Colors.black,
                    withunderLink: false,
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
                      Text(
                        'المجموع',
                        style: titilliumBold.copyWith(fontSize: 16),
                      ),
                      TCustomWidgets.formattedPrice(total, 18, TColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 16),

        // ملخص العنوان
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
                      Text(
                        'عنوان التوصيل',
                        style: titilliumBold.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedAddress.fullAddress,
                    style: titilliumRegular.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedAddress.phoneNumber ?? '',
                    style: titilliumRegular.copyWith(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: numberFonts,
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // ملخص وسيلة الدفع
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  selectedPaymentMethod == 'cod'
                      ? Icons.money
                      : Icons.account_balance_wallet,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'وسيلة الدفع',
                        style: titilliumBold.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedPaymentMethod == 'cod'
                            ? 'الدفع عند الاستلام'
                            : 'محفظة iStoreto',
                        style: titilliumRegular.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // المجموع الكلي
        TRoundedContainer(
          showBorder: true,
          borderColor: TColors.primary,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المجموع الكلي',
                  style: titilliumBold.copyWith(fontSize: 18),
                ),
                Obx(
                  () => TCustomWidgets.formattedPrice(
                    cartController.selectedTotalPrice,
                    20,
                    TColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// زر Checkout للسلة الكاملة
  Widget _buildCheckoutButton() {
    final selectedCount = cartController.selectedItemsCount;
    final total = cartController.selectedTotalPrice;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // المجموع الكلي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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

          // زر Checkout الكامل
          ElevatedButton.icon(
            onPressed: selectedCount > 0 ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            icon: const Icon(Icons.shopping_cart_checkout, size: 20),
            label: Text(
              'إكمال الطلب',
              style: titilliumBold.copyWith(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// أزرار التنقل
  Widget _buildNavigationButtons() {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر Checkout للسلة الكاملة (فقط في الخطوة الأولى)

            // أزرار التنقل العادية
            Row(
              children: [
                // زر الرجوع
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

                // زر التالي/إتمام (فقط في الخطوة 2 و 3)
                if (_currentStep > 0)
                  Expanded(
                    child: Obx(() {
                      final isLastStep = _currentStep == 2;
                      final isLoading =
                          OrderController.instance.isSubmitting.value;

                      return ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : (isLastStep ? _completeOrder : _nextStep),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isLastStep ? 'إتمام الطلب' : 'التالي',
                                      style: titilliumBold.copyWith(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      isLastStep
                                          ? Icons.check
                                          : Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ),
                      );
                    }),
                  ),
              ],
            ),
            // if (_currentStep == 0) _buildCheckoutButton(),
            // const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// عنوان الخطوة
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'cart.shopList'.tr;
      case 1:
        return 'order.address_payment'.tr;
      case 2:
        return 'order.order_summary'.tr;
      default:
        return '';
    }
  }
}
