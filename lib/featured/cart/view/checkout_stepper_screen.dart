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
  String? selectedSingleVendorId; // معرف التاجر المحدد للطلب الفردي
  bool isSingleVendorCheckout = false; // هل هو checkout لتاجر واحد فقط

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
          _loadUserAddresses();
        }
      });
    } catch (e) {
      print('❌ Error in initState: $e');
    }
  }

  /// تحميل عناوين المستخدم
  Future<void> _loadUserAddresses() async {
    if (!mounted) return;

    try {
      final authController = AuthController.instance;
      final userId = authController.currentUser.value?.id;

      if (userId != null) {
        print('📍 Loading user addresses for userId: $userId');
        final addressService = AddressService.instance;

        // تحميل العناوين
        await addressService.getUserAddresses(userId);

        // اختيار العنوان الافتراضي تلقائياً
        if (addressService.addresses.isNotEmpty) {
          final defaultAddress = addressService.getDefaultAddress();
          if (defaultAddress != null) {
            addressService.selectAddress(defaultAddress);
            print('✅ Default address selected: ${defaultAddress.fullAddress}');
          } else {
            // اختيار أول عنوان إذا لم يكن هناك عنوان افتراضي
            addressService.selectAddress(addressService.addresses.first);
            print(
              '✅ First address selected: ${addressService.addresses.first.fullAddress}',
            );
          }
        }
      }
    } catch (e) {
      print('❌ Error loading user addresses: $e');
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

  /// إتمام الطلب لتاجر واحد فقط
  void checkoutSingleVendor(String vendorId, List<dynamic> items) {
    final selectedVendorItems =
        items
            .where(
              (item) => cartController.selectedItems[item.product?.id] == true,
            )
            .toList();

    if (selectedVendorItems.isEmpty) {
      TLoader.warningSnackBar(
        title: 'alert'.tr,
        message: 'please_select_product_from_store'.tr,
      );
      return;
    }

    // تعيين وضع الطلب الفردي
    setState(() {
      selectedSingleVendorId = vendorId;
      isSingleVendorCheckout = true;
    });

    // الانتقال للخطوة التالية
    _nextStep();
  }

  /// الانتقال للخطوة التالية
  void _nextStep() {
    if (_currentStep < 2) {
      // التحقق من الشروط قبل الانتقال
      if (_currentStep == 0) {
        // التحقق من اختيار منتجات
        if (cartController.selectedItemsCount == 0) {
          TLoader.warningSnackBar(
            title: 'alert'.tr,
            message: 'please_select_product'.tr,
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
            title: 'alert'.tr,
            message: 'please_select_delivery_address'.tr,
          );
          return;
        }
        if (selectedAddress.phoneNumber?.isEmpty ?? true) {
          TLoader.warningSnackBar(
            title: 'alert'.tr,
            message: 'please_select_address_with_phone'.tr,
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
          message: 'please_select_delivery_address'.tr,
          title: 'alert'.tr,
        );
        return;
      }

      final groupedItems = cartController.groupedByVendor;
      final selectedItems = cartController.selectedItems;

      // إذا كان checkout لتاجر واحد فقط
      if (isSingleVendorCheckout && selectedSingleVendorId != null) {
        // معالجة طلب تاجر واحد فقط
        final vendorId = selectedSingleVendorId!;
        final vendorItems =
            groupedItems[vendorId]
                ?.where((item) => selectedItems[item.product.id] == true)
                .toList() ??
            [];

        if (vendorItems.isEmpty) {
          TLoader.warningSnackBar(
            title: 'alert'.tr,
            message: 'please_select_product_from_store'.tr,
          );
          return;
        }

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

        // الانتقال لصفحة النجاح
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(order: order),
          ),
          (route) => false,
        );
      } else {
        // معالجة طلبات لجميع التجار (الوضع القديم)
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
      }
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

          // أزرار التنقل في الأسفل
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
              'products_by_vendors'.tr,
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
              child: VendorCartBlock(
                vendorId: vendorId,
                items: items,
                onCheckout: () => checkoutSingleVendor(vendorId, items),
              ),
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
                'payment_method_title'.tr,
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
    print('🏪 Single vendor checkout: $isSingleVendorCheckout');
    print('🏪 Selected vendor ID: $selectedSingleVendorId');

    // تصفية التجار بناءً على وضع الطلب
    final vendorsToShow =
        isSingleVendorCheckout && selectedSingleVendorId != null
            ? {selectedSingleVendorId!: groupedItems[selectedSingleVendorId]!}
            : groupedItems;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // ملخص المنتجات حسب التاجر
        ...vendorsToShow.entries.map((entry) {
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
                        'total_label'.tr,
                        style: titilliumBold.copyWith(fontSize: 16),
                      ),
                      TCustomWidgets.formattedPrice(total, 18, TColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

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
                        'delivery_address'.tr,
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
                        'payment_method_title'.tr,
                        style: titilliumBold.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedPaymentMethod == 'cod'
                            ? 'cash_on_delivery'.tr
                            : 'istoreto_wallet'.tr,
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
                  'grand_total'.tr,
                  style: titilliumBold.copyWith(fontSize: 18),
                ),
                Obx(() {
                  // حساب المجموع بناءً على وضع الطلب
                  double totalPrice;
                  if (isSingleVendorCheckout &&
                      selectedSingleVendorId != null) {
                    // مجموع التاجر المحدد فقط
                    final vendorItems =
                        groupedItems[selectedSingleVendorId]
                            ?.where(
                              (item) => selectedItems[item.product.id] == true,
                            )
                            .toList() ??
                        [];
                    totalPrice = vendorItems.fold<double>(
                      0,
                      (sum, item) => sum + item.totalPrice,
                    );
                  } else {
                    // مجموع جميع التجار
                    totalPrice = cartController.selectedTotalPrice;
                  }

                  return TCustomWidgets.formattedPrice(
                    totalPrice,
                    20,
                    TColors.primary,
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 100), // مساحة للأزرار السفلية
      ],
    );
  }

  /// أزرار التنقل في الأسفل
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر الرجوع (يظهر فقط إذا لم نكن في الخطوة الأولى)
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  label: Text(
                    'back'.tr,
                    style: titilliumBold.copyWith(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

            if (_currentStep > 0) const SizedBox(width: 12),

            // زر التالي أو إتمام الطلب
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: Obx(() {
                final isSubmitting =
                    _currentStep == 2
                        ? OrderController.instance.isSubmitting.value
                        : false;
                final selectedCount = cartController.selectedItemsCount;

                return ElevatedButton.icon(
                  onPressed:
                      isSubmitting || selectedCount == 0
                          ? null
                          : (_currentStep == 2 ? _completeOrder : _nextStep),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon:
                      isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Icon(
                            _currentStep == 2
                                ? Icons.check_circle_outline
                                : Icons.arrow_forward,
                            size: 20,
                          ),
                  label: Text(
                    isSubmitting
                        ? 'processing'.tr
                        : (_currentStep == 2 ? 'complete_order'.tr : 'next'.tr),
                    style: titilliumBold.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
            ),
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
