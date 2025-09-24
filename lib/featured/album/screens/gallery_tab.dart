import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/translation_controller.dart';
import 'package:istoreto/featured/album/controller/photo_controller.dart';
import 'package:istoreto/featured/album/model/photo_model.dart';
import 'package:istoreto/featured/album/screens/album.dart';
import 'package:istoreto/featured/album/screens/album_search.dart';
import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:istoreto/utils/constants/sizes.dart';

class AlbumsTabPage extends StatelessWidget {
  final String userId;
  const AlbumsTabPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          toolbarHeight: 40,
          elevation: 0.1,

          iconTheme: IconThemeData(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          automaticallyImplyLeading: false,
       
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    labelStyle: titilliumBold.copyWith(
                      fontSize: TSizes.paddingSizeLarge,
                      fontFamily: TranslationController.instance.isRTL ? arabicFonts : englishFonts,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    tabs: [
                      Tab(text: 'shop.album'.tr),
                      Tab(text: 'shop.all_photos'.tr),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                AlbumSearchPage(userId: userId),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              AlbumGridView(userId: userId, showSearchAndSort: true),
              AllPhotosGridView(userId: userId),
            ],
          ),
        ),
      ),
    );
  }
}

class AllPhotosGridView extends StatefulWidget {
  final String userId;
  const AllPhotosGridView({super.key, required this.userId});

  @override
  State<AllPhotosGridView> createState() => _AllPhotosGridViewState();
}

class _AllPhotosGridViewState extends State<AllPhotosGridView> {
  final PhotoController controller = PhotoController.instance;
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initLoad();
    _scrollController.addListener(_onScroll);
  }

  void _initLoad() async {
    controller.resetPagination();
    await controller.loadPhotosPaginated(widget.userId, reset: true);
    setState(() {
      _initialized = true;
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        controller.hasMore == true &&
        controller.isLoading == false) {
      controller.loadPhotosPaginated(widget.userId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    return Obx(() {
      final List<PhotoModel> allPhotos = controller.photos;
      if (!_initialized) {
        return const Center(child: CircularProgressIndicator());
      }
      if (allPhotos.isEmpty) {
        return Center(child: Text('shop.no_photos'.tr));
      }
      // تجميع الصور حسب اليوم
      Map<String, List<PhotoModel>> groupedByDay = {};
      for (var photo in allPhotos) {
        final day = photo.createdAt?.toLocal().toString().substring(
          0,
          10,
        ); // yyyy-MM-dd
        groupedByDay.putIfAbsent(day!, () => []).add(photo);
      }
      final days = groupedByDay.keys.toList()..sort((a, b) => b.compareTo(a));
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: days.length + ((controller.hasMore == true) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == days.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final day = days[index];
          final photos = groupedByDay[day]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: photos.length,
                itemBuilder: (context, i) {
                  final photo = photos[i];
                  return GestureDetector(
                    onLongPress: () {
                      // يمكنك إضافة خيارات الصورة هنا
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(photo.url, fit: BoxFit.contain),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    });
  }
}

