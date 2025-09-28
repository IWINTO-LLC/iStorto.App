import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/view/all_tab.dart';
import 'package:istoreto/featured/shop/view/widgets/market_header_organization.dart';
import 'package:istoreto/featured/shop/view/widgets/market_waiting_page.dart';
import 'package:istoreto/utils/bindings/general_binding.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/logging/logger.dart';

class MarketPlaceView extends StatefulWidget {
  const MarketPlaceView({
    super.key,
    required this.editMode,
    required this.vendorId,
  });
  final bool editMode;
  final String vendorId;

  @override
  State<MarketPlaceView> createState() => _MarketPlaceViewState();
}

class _MarketPlaceViewState extends State<MarketPlaceView> {
  late SectorController sectorController;
  bool _isInitialized = false;
  bool _areControllersReady = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// Initialize controllers before building the UI
  Future<void> _initializeControllers() async {
    try {
      // انتظار حتى تكون جميع المتحكمات جاهزة
      await GeneralBindings.waitForControllers();

      // Initialize SectorController with vendorId
      sectorController = Get.put(SectorController(widget.vendorId));

      // Fetch vendor profile data
      await VendorController.instance.fetchVendorData(widget.vendorId);
      ProductController.instance.isExpanded.value = false;

      setState(() {
        _isInitialized = true;
        _areControllersReady = true;
      });

      TLoggerHelper.info(
        "MarketPlaceView controllers initialized successfully",
      );
    } catch (e) {
      TLoggerHelper.error("Error initializing MarketPlaceView controllers: $e");
      // Still set initialized to true to avoid infinite loading
      setState(() {
        _isInitialized = true;
        _areControllersReady = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing
    if (!_isInitialized) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Shimmer for header section
                //_buildHeaderShimmer(),
                // Shimmer for content section
                _buildContentShimmer(),
              ],
            ),
          ),
        ),
      );
    }

    // التحقق من جاهزية المتحكمات
    if (!_areControllersReady) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Shimmer for header section
                _buildHeaderShimmer(),
                // Shimmer for content section
                _buildContentShimmer(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              marketHeaderSection(
                widget.vendorId,
                widget.editMode,
                widget.vendorId ==
                    Get.find<AuthController>().currentUser.value?.id,
              ),
              FutureBuilder(
                future: CategoryController.instance.getCategoryOfUser(
                  widget.vendorId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    ); //MarketWaitingPage(vendorId: widget.vendorId);
                  } else {
                    return _buildBody();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final profileData = VendorController.instance.profileData.value;

      // if (profileData.organizationActivated ?? true == false ) {
      //   return _buildStoreSuspendedCard();
      // }
      // if (profileData.organizationDeleted ?? false  == true) {
      //       return _buildStoreDeletedCard();
      //     }

      return NestedScrollViewForHome(
        vendorId: widget.vendorId,
        editMode: widget.editMode,
      );
    });
  }

  Widget _buildStorueDeletedCard() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: TRoundedContainer(
        radius: BorderRadius.circular(15),
        enableShadow: true,
        showBorder: true,
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 24),
              Text(
                'store_activation.store_deleted_title'.tr,
                style: titilliumBold.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'store_activation.store_deleted_desc'.tr,
                textAlign: TextAlign.center,
                style: titilliumBold.copyWith(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              // الرسالة الاختيارية بتصميم البطاقة
              if ((VendorController.instance.profileData.value.storeMessage)
                  .isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      VendorController.instance.profileData.value.storeMessage!,
                      textAlign: TextAlign.center,
                      style: titilliumBold.copyWith(
                        fontSize: 16,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'store_activation.back'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreSuspendedCard() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: TRoundedContainer(
        radius: BorderRadius.circular(15),
        enableShadow: true,
        showBorder: true,
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pause_circle_outline,
                size: 80,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 24),
              Text(
                'store_activation.store_suspended_title'.tr,
                style: titilliumBold.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'store_activation.store_suspended_desc'.tr,
                textAlign: TextAlign.center,
                style: titilliumBold.copyWith(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              // الرسالة الاختيارية بتصميم البطاقة
              if ((VendorController.instance.profileData.value.storeMessage)
                  .isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      VendorController.instance.profileData.value.storeMessage,
                      textAlign: TextAlign.center,
                      style: titilliumBold.copyWith(
                        fontSize: 16,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'store_activation.back'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build shimmer effect for header section
  Widget _buildHeaderShimmer() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Store logo and name shimmer
          const Row(
            children: [
              // Store logo shimmer
              const TShimmerEffect(
                width: 80,
                height: 80,
                raduis: BorderRadius.all(Radius.circular(40)),
              ),
              const SizedBox(width: 16),
              // Store info shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    TShimmerEffect(width: 150, height: 20),
                    SizedBox(height: 8),
                    TShimmerEffect(width: 100, height: 16),
                    SizedBox(height: 8),
                    TShimmerEffect(width: 120, height: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Action buttons shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (index) => const TShimmerEffect(
                width: 80,
                height: 40,
                raduis: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer effect for content section
  Widget _buildContentShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Category tabs shimmer
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder:
                  (context, index) => Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: const TShimmerEffect(
                      width: 80,
                      height: 40,
                      raduis: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 20),
          // Products grid shimmer
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder:
                (context, index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image shimmer
                      Expanded(
                        flex: 3,
                        child: const TShimmerEffect(
                          width: double.infinity,
                          height: double.infinity,
                          raduis: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                      ),
                      // Product info shimmer
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              TShimmerEffect(
                                width: double.infinity,
                                height: 14,
                              ),
                              SizedBox(height: 4),
                              TShimmerEffect(width: 60, height: 12),
                              SizedBox(height: 4),
                              TShimmerEffect(width: 40, height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}

class NestedScrollViewForHome extends StatelessWidget {
  RxInt selectedIndex = 0.obs;
  final bool editMode;
  final String vendorId;

  NestedScrollViewForHome({
    super.key,
    required this.editMode,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context) {
    var userId = VendorController.instance.profileData.value.id;
    var categoryController = CategoryController.instance;

    // Check if SectorController is already initialized
    if (!Get.isRegistered<SectorController>()) {
      Get.put(SectorController(vendorId));
    }

    // Show products tab
    return Padding(
      padding: const EdgeInsets.only(top: 28.0),
      child: AllTab(vendorId: vendorId, editMode: editMode),
    );
  }
}
