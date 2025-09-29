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
import 'package:istoreto/featured/home-page/views/widgets/banner_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/category_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/just_foryou_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/major_category_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/most_popular_section.dart';
import 'package:istoreto/featured/home-page/views/widgets/topseller_section.dart';
import 'package:istoreto/featured/payment/controller/order_controller.dart';
import 'package:istoreto/featured/payment/services/address_service.dart';
import 'package:istoreto/featured/product/controllers/edit_product_controller.dart';
import 'package:istoreto/featured/product/controllers/favorite_product_controller.dart';
import 'package:istoreto/featured/product/controllers/product_controller.dart';
import 'package:istoreto/featured/sector/controller/sector_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/featured/shop/follow/controller/follow_controller.dart';
import 'package:istoreto/utils/bindings/general_binding.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:istoreto/utils/http/network.dart';
import 'package:istoreto/widgets/language_switcher.dart';
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
    Get.put(GeneralBindings());
    Get.put(VendorRepository());
    Get.put(VendorController());
    Get.put(CategoryController());
    Get.put(NetworkManager());
    Get.put(CategoryRepository());
    Get.put(SavedController());
    Get.put(BannerController());
    Get.put(SaveForLaterController());
    Get.put(FavoriteProductsController());
    Get.put(ProductController());
    Get.put(OrderController());
    Get.put(EditProductController());
    Get.put(AlbumRepository());
    Get.put(PhotoRepository());
    Get.put(PhotoController());
    Get.put(FollowController());
    Get.put(AlbumController());
    Get.put(CartController());
    Get.put(AddressService());
    Get.put(EditCategoryController());
    Get.put(TranslateController());

    Get.put(FollowController());
    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner Carousel
          Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Row(
              children: [
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: TColors.textBlack,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'search'.tr,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const CompactLanguageSwitcher(),
              ],
            ),
          ),
          BannerSection(),

          const SizedBox(height: TSizes.spaceBtWsections),

          // Categories Section
          const MajorCategorySection(),

          const SizedBox(height: TSizes.spaceBtWsections),

          // Popular Products Section
          PopularProduct(context: context),

          const SizedBox(height: TSizes.spaceBtWsections),

          // New Items Section
          NewItemSection(context: context),

          const SizedBox(height: TSizes.spaceBtWsections),

          // Top Sellers Section
          TopSellerSections(),

          const SizedBox(height: TSizes.spaceBtWsections),

          // Most Popular Section
          const MostPopularSection(),

          const SizedBox(height: TSizes.spaceBtWsections),

          // Just For You Section
          const JustForYou(),

          const SizedBox(height: 100), // Space for bottom navigation
        ],
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

class PopularProduct extends StatelessWidget {
  const PopularProduct({super.key, required this.context});

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
                'popular_products'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 2,
            itemBuilder: (context, index) {
              final products = [
                {
                  'name': 'Short jacket in long-pile faux fur',
                  'price': '\$218.00',
                  'image': 'assets/images/product_12.jpg',
                },
                {
                  'name': 'Women\'s walking shoes ten',
                  'price': '\$54.99',
                  'image': 'assets/images/product_2.png',
                },
              ];

              return Container(
                width: MediaQuery.of(context).size.width - 32,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image,
                        color: Colors.grey.shade400,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            products[index]['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            products[index]['price'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
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
