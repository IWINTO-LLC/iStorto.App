import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/constants/color.dart';

class CommercialAccountCongratulationsPage extends StatefulWidget {
  final String vendorId;
  final String organizationName;

  const CommercialAccountCongratulationsPage({
    super.key,
    required this.vendorId,
    required this.organizationName,
  });

  @override
  State<CommercialAccountCongratulationsPage> createState() =>
      _CommercialAccountCongratulationsPageState();
}

class _CommercialAccountCongratulationsPageState
    extends State<CommercialAccountCongratulationsPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  String _loadingStatus = 'congratulations.preparing_store'.tr;
  int _currentStep = 0;

  final List<String> _loadingSteps = [
    'congratulations.loading_vendor_data'.tr,
    'congratulations.loading_banners'.tr,
    'congratulations.loading_categories'.tr,
    'congratulations.loading_products'.tr,
    'congratulations.finalizing'.tr,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingProcess();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  Future<void> _startLoadingProcess() async {
    try {
      // Step 1: Load vendor data
      await _updateLoadingStep(0);
      await VendorController.instance.fetchVendorData(widget.vendorId);
      await Future.delayed(const Duration(milliseconds: 800));

      // Step 2: Load banners (if any)
      await _updateLoadingStep(1);
      // TODO: Load banners when banner system is implemented
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 3: Load categories
      await _updateLoadingStep(2);
      // Categories will be loaded by the marketplace view
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 4: Load products
      await _updateLoadingStep(3);
      // Products will be loaded by the marketplace view
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 5: Finalizing
      await _updateLoadingStep(4);
      await Future.delayed(const Duration(milliseconds: 800));

      // Complete loading
      setState(() {
        _isLoading = false;
      });

      // Navigate to marketplace after a short delay
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Get.to(
          () => MarketPlaceView(vendorId: widget.vendorId, editMode: true),
        );
      }
    } catch (e) {
      print('Error loading vendor data: $e');
      // Still navigate even if there's an error
      if (mounted) {
        Get.offAll(
          () => MarketPlaceView(vendorId: widget.vendorId, editMode: true),
        );
      }
    }
  }

  Future<void> _updateLoadingStep(int step) async {
    if (mounted) {
      setState(() {
        _currentStep = step;
        _loadingStatus = _loadingSteps[step];
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Congratulations Icon
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.celebration,
                    size: 60,
                    color: TColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Congratulations Text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'congratulations.title'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Organization Name
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  widget.organizationName,
                  style: titilliumBold.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // Loading Section
              if (_isLoading) ...[
                // Loading Animation
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * 3.14159,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.settings,
                          size: 30,
                          color: TColors.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Loading Status
                Text(
                  _loadingStatus,
                  style: titilliumBold.copyWith(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Progress Indicator
                TRoundedContainer(
                  width: 200,
                  height: 4,
                  backgroundColor: Colors.grey[200] ?? Colors.grey,
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _loadingSteps.length,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                  ),
                ),
              ] else ...[
                // Success State
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 30,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'congratulations.ready'.tr,
                  style: titilliumBold.copyWith(
                    fontSize: 16,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 48),

              // Additional Info
              FadeTransition(
                opacity: _fadeAnimation,
                child: TRoundedContainer(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue.withOpacity(0.05),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600] ?? Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'congratulations.info'.tr,
                        style: titilliumBold.copyWith(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
