import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/album/controller/album_controller.dart';
import 'package:istoreto/featured/album/controller/photo_controller.dart';
import 'package:istoreto/featured/album/screens/fullscreen_image_viewer.dart';
import 'package:istoreto/featured/product/cashed_network_image_free.dart';
import 'package:istoreto/featured/album/model/album_model.dart';
import 'package:istoreto/featured/album/model/photo_model.dart';
import 'package:istoreto/featured/album/screens/album_details.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/sizes.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AlbumSearchPage extends StatefulWidget {
  final String userId;
  const AlbumSearchPage({super.key, required this.userId});

  @override
  State<AlbumSearchPage> createState() => _AlbumSearchPageState();
}

class _AlbumSearchPageState extends State<AlbumSearchPage> {
  final AlbumController albumController = AlbumController.instance;
  final PhotoController photoController = PhotoController.instance;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs;
  final RxList<AlbumModel> searchResults = <AlbumModel>[].obs;
  final RxList<PhotoModel> photoResults = <PhotoModel>[].obs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await albumController.loadAlbumsAndCovers(widget.userId);
    await photoController.loadAllPhotos(widget.userId);
  }

  void _performSearch(String query) {
    searchQuery.value = query.toLowerCase();

    if (query.isEmpty) {
      searchResults.clear();
      photoResults.clear();
      return;
    }

    // البحث في الألبومات
    final albums =
        albumController.albums
            .where(
              (album) => album.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    searchResults.assignAll(albums);

    // البحث في الصور (tags و URLs)
    final photos =
        photoController.photos
            .where(
              (photo) =>
                  photo.tags.any(
                    (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                  ) ||
                  photo.url.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    photoResults.assignAll(photos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 80,
        elevation: 0.1,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        automaticallyImplyLeading: true,
        title: Container(
          margin: const EdgeInsets.only(top: 10.0, right: 8, left: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: searchController,
            onChanged: _performSearch,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "search.search".tr,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontFamily:
                    Get.locale?.languageCode == 'ar'
                        ? arabicFonts
                        : englishFonts,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            ),
            style: titilliumBold.copyWith(
              fontSize: TSizes.paddingSizeLarge,
              fontFamily:
                  Get.locale?.languageCode == 'ar' ? arabicFonts : englishFonts,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (searchQuery.value.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "album_search.start_typing".tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily:
                          Get.locale?.languageCode == 'ar'
                              ? arabicFonts
                              : englishFonts,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (searchResults.isEmpty && photoResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "album_search.no_results".tr.replaceAll(
                      "{query}",
                      searchQuery.value,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily:
                          Get.locale?.languageCode == 'ar'
                              ? arabicFonts
                              : englishFonts,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchResults.isNotEmpty) ...[
                  Text(
                    "album_search.albums_count".tr.replaceAll(
                      "{count}",
                      searchResults.length.toString(),
                    ),
                    style: titilliumBold.copyWith(
                      fontSize: 18,
                      fontFamily:
                          Get.locale?.languageCode == 'ar'
                              ? arabicFonts
                              : englishFonts,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final album = searchResults[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AlbumDetailsPage(
                                    album: album,
                                    userId: widget.userId,
                                  ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            FreeCaChedNetworkImage(
                              url: album.coverUrl ?? "",
                              raduis: BorderRadius.circular(12),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black38,
                              ),
                            ),
                            Center(
                              child: Text(
                                album.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                if (photoResults.isNotEmpty) ...[
                  Text(
                    "album_search.photos_count".tr.replaceAll(
                      "{count}",
                      photoResults.length.toString(),
                    ),
                    style: titilliumBold.copyWith(
                      fontSize: 18,
                      fontFamily:
                          Get.locale?.languageCode == 'ar'
                              ? arabicFonts
                              : englishFonts,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MasonryGridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: photoResults.length,
                    itemBuilder: (context, index) {
                      final photo = photoResults[index];
                      return GestureDetector(
                        onTap: () {
                          // فتح معاينة الصور بحجم الشاشة كاملة
                          showFullscreenImage(
                            context: context,
                            images: photoResults,
                            initialIndex: index,
                            showEditButton: true,
                            onSave: (File processedFile, int index) async {
                              // هنا يمكن إضافة منطق حفظ الصورة المعدلة
                              // يمكن رفع الصورة المعدلة إلى الخادم
                              print(
                                "album_search.image_saved".tr.replaceAll(
                                  "{path}",
                                  processedFile.path,
                                ),
                              );
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            photo.url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: TColors.primary,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                ),
                              );
                            },
                            headers: {
                              'User-Agent':
                                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}
