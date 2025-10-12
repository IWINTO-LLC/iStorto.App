import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/category_controller.dart';
import 'package:istoreto/controllers/edit_category_controller.dart';
import 'package:istoreto/controllers/translate_controller.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/data/repositories/category_repository.dart';
import 'package:istoreto/featured/album/controller/album_controller.dart';
import 'package:istoreto/featured/album/controller/photo_controller.dart';
import 'package:istoreto/featured/album/data/album_repository.dart';
import 'package:istoreto/featured/album/data/photo_repository.dart';
import 'package:istoreto/featured/banner/controller/banner_controller.dart';
import 'package:istoreto/featured/cart/controller/cart_controller.dart';
import 'package:istoreto/featured/cart/controller/save_for_later.dart';
import 'package:istoreto/featured/cart/controller/saved_controller.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/home-page/views/widgets/banner_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/home_search_widget.dart';
import 'package:istoreto/featured/home-page/views/widgets/major_category_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/most_popular_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/populer_product.dart';
import 'package:istoreto/featured/home-page/views/widgets/the_last_vendor_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/topseller_section.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/views/product_images_gallery_page.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/product/controllers/edit_product_controller.dart';
import 'package:istoreto/featured/product/controllers/favorite_product_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/product/services/product_currency_service.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/featured/shop/follow/controller/follow_controller.dart';
import 'package:istoreto/services/image_upload_service.dart';
import 'package:istoreto/utils/bindings/general_binding.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/http/network.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("this user is ${Supabase.instance.client.auth.currentUser?.email}");
      print("this user id is ${Supabase.instance.client.auth.currentUser?.id}");
    }
    // Get translation controller to trigger rebuild on language change
    Get.find<TranslationController>();
    // Initialize General Bindings only once
    if (!Get.isRegistered<VendorRepository>()) {
      final generalBindings = GeneralBindings();
      generalBindings.dependencies();
      Get.put(VendorRepository());
    }

    // تهيئة Controllers بشكل آمن - استخدام Get.find مع fallback
    if (!Get.isRegistered<CategoryController>()) Get.put(CategoryController());
    if (!Get.isRegistered<NetworkManager>()) Get.put(NetworkManager());
    if (!Get.isRegistered<CategoryRepository>()) Get.put(CategoryRepository());
    if (!Get.isRegistered<SavedController>()) Get.put(SavedController());
    if (!Get.isRegistered<BannerController>()) Get.put(BannerController());
    if (!Get.isRegistered<SaveForLaterController>())
      Get.put(SaveForLaterController());
    if (!Get.isRegistered<FavoriteProductsController>())
      Get.put(FavoriteProductsController());
    if (!Get.isRegistered<ProductController>()) Get.put(ProductController());
    if (!Get.isRegistered<OrderController>()) Get.put(OrderController());
    if (!Get.isRegistered<EditProductController>())
      Get.put(EditProductController());
    if (!Get.isRegistered<AlbumRepository>()) Get.put(AlbumRepository());
    if (!Get.isRegistered<PhotoRepository>()) Get.put(PhotoRepository());
    if (!Get.isRegistered<PhotoController>()) Get.put(PhotoController());
    if (!Get.isRegistered<FollowController>()) Get.put(FollowController());
    if (!Get.isRegistered<AlbumController>()) Get.put(AlbumController());
    if (!Get.isRegistered<CartController>()) Get.put(CartController());
    if (!Get.isRegistered<AddressService>()) Get.put(AddressService());
    if (!Get.isRegistered<EditCategoryController>())
      Get.put(EditCategoryController());
    if (!Get.isRegistered<ImageUploadService>()) Get.put(ImageUploadService());
    if (!Get.isRegistered<TranslateController>())
      Get.put(TranslateController());
    if (!Get.isRegistered<CurrencyController>()) Get.put(CurrencyController());
    if (!Get.isRegistered<ProductCurrencyService>())
      Get.put(ProductCurrencyService());

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: TSizes.paddingSizeDefault),
          // شريط البحث
          Padding(
            padding: const EdgeInsets.only(
              left: TSizes.defaultSpace,
              right: TSizes.defaultSpace,
              top: TSizes.defaultSpace,
              bottom: TSizes.defaultSpace / 2,
            ),
            child: const HomeSearchWidget(),
          ),
          BannerSection(),

          const SizedBox(height: TSizes.spaceBtWsections),

          // Categories Section
          const MajorCategorySection(),

          const SizedBox(height: TSizes.spaceBtWsections),

          // Popular Products Section
          PopularProduct(context: context),
          const SizedBox(height: TSizes.spaceBtWsections),
          _buildDiscoverGalleryButton(context),

          const SizedBox(height: TSizes.spaceBtWsections),

          // MostPopularSection(),
          // const SizedBox(height: TSizes.spaceBtWsections),
          const TheLastVendorSection(),
          const SizedBox(height: TSizes.spaceBtWsections),

          // زر اكتشف معرض الصور

          // const SizedBox(height: TSizes.spaceBtWsections),

          // Top Sellers Section
          TopSellerSections(),

          const SizedBox(height: TSizes.spaceBtWsections),

          // Most Popular Section
          // const MostPopularSection(),

          // const SizedBox(height: TSizes.spaceBtWsections),

          // Just For You Section
          const SizedBox(height: 200), // Space for bottom navigation
        ],
      ),
    );
  }

  /// زر اكتشف معرض الصور
  static Widget _buildDiscoverGalleryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, TColors.black.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Get.to(
                () => const ProductImagesGalleryPage(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // أيقونة
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // النص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'gallery.discover_latest_products'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'gallery.browse_thousands_of_photos'.tr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // سهم
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewItemSection extends StatelessWidget {
  const NewItemSection({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'new_items'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'see_all'.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              final items = [
                {'price': '\$17,00', 'color': Colors.blue},
                {'price': '\$32,00', 'color': Colors.grey},
                {'price': '\$21,00', 'color': Colors.white},
              ];

              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: items[index]['color'] as Color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lorem ipsum dolor sit amet consectetur.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['price'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
