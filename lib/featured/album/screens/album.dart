import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/album/controller/album_controller.dart';
import 'package:istoreto/featured/album/model/album_model.dart';
import 'package:istoreto/featured/album/screens/album_details.dart';
import 'package:istoreto/featured/album/screens/fullscreen_image_viewer.dart';
import 'package:istoreto/featured/product/cashed_network_image_free.dart';
import 'package:istoreto/utils/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class AlbumGridView extends StatefulWidget {
  final String userId;
  final bool showSearchAndSort;
  const AlbumGridView({
    super.key,
    required this.userId,
    this.showSearchAndSort = false,
  });

  @override
  State<AlbumGridView> createState() => _AlbumGridViewState();
}

class _AlbumGridViewState extends State<AlbumGridView> {
  final AlbumController controller = AlbumController.instance;
  final RxString searchQuery = "".obs;
  final RxString sortBy = "default".obs;

  @override
  void initState() {
    super.initState();
    controller.loadAlbumsAndCovers(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // const SizedBox(height: 8),
            // if (widget.showSearchAndSort)
            //   _SearchAndSort(searchQuery: searchQuery, sortBy: sortBy),
            Expanded(
              child: _AlbumGrid(
                userId: widget.userId,
                controller: controller,
                searchQuery: searchQuery,
                sortBy: sortBy,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          widget.showSearchAndSort
              ? null
              : _FloatingActions(
                controller: controller,
                userId: widget.userId,
                onAddAlbum:
                    (context) => _showAddAlbumDialog(context, widget.userId),
              ),
    );
  }

  void _showAddAlbumDialog(BuildContext context, String userId) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("album.new_album".tr),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: "album.album_name".tr),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("common.cancel".tr),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    controller.addAlbum(userId, name);
                    Navigator.pop(context);
                  }
                },
                child: Text("album.create".tr),
              ),
            ],
          ),
    );
  }
}

class SearchAndSort extends StatelessWidget {
  final RxString searchQuery;
  final RxString sortBy;

  const SearchAndSort({
    super.key,
    required this.searchQuery,
    required this.sortBy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 🔍 البحث
            Expanded(
              flex: 3,
              child: TextField(
                onChanged: (value) => searchQuery.value = value.toLowerCase(),
                onSubmitted: (value) => searchQuery.value = value.toLowerCase(),
                decoration: InputDecoration(
                  hintText: "search.search".tr + " ...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            //  const SizedBox(width: 12),

            // ⏬ الفرز
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Obx(
                  () => DropdownButton<String>(
                    value: sortBy.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.sort, color: Colors.grey),
                    style: const TextStyle(color: Colors.black),
                    items: [
                      DropdownMenuItem(
                        value: "default",
                        child: Text("album.default_sort".tr),
                      ),
                      DropdownMenuItem(
                        value: "name",
                        child: Text("album.sort_by_name".tr),
                      ),
                      DropdownMenuItem(
                        value: "size",
                        child: Text("album.sort_by_size".tr),
                      ),
                      DropdownMenuItem(
                        value: "count",
                        child: Text("album.sort_by_count".tr),
                      ),
                    ],
                    onChanged: (val) => sortBy.value = val ?? "default",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumGrid extends StatelessWidget {
  final String userId;
  final AlbumController controller;
  final RxString searchQuery;
  final RxString sortBy;

  const _AlbumGrid({
    required this.userId,
    required this.controller,
    required this.searchQuery,
    required this.sortBy,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingAlbums.value) {
        return const Center(child: TLoaderWidget());
      }

      final allAlbums = controller.albums;

      // تطبيق البحث
      List<AlbumModel> filteredAlbums =
          allAlbums
              .where(
                (album) => album.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
              )
              .toList();

      // تطبيق الفرز
      switch (sortBy.value) {
        case "name":
          filteredAlbums.sort((a, b) => a.name.compareTo(b.name));
          break;
        case "size":
          filteredAlbums.sort((a, b) => b.totalSize.compareTo(a.totalSize));
          break;
        case "count":
          filteredAlbums.sort((a, b) => b.photoCount.compareTo(a.photoCount));
          break;
      }

      if (filteredAlbums.isEmpty) {
        return Center(child: Text("album.no_albums".tr));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemCount: filteredAlbums.length,
        itemBuilder: (context, index) {
          final album = filteredAlbums[index];
          final coverUrl = album.coverUrl ?? "";

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          AlbumDetailsPage(album: album, userId: userId),
                ),
              );
            },
            onLongPress: () {
              // معاينة صورة الغلاف بحجم الشاشة كاملة عند الضغط المطول
              if (coverUrl.isNotEmpty) {
                showFullscreenImage(
                  context: context,
                  images: [coverUrl],
                  initialIndex: 0,
                  showEditButton: true,
                  onSave: (File processedFile, int index) async {
                    // هنا يمكن إضافة منطق حفظ صورة الغلاف المعدلة
                    print('تم حفظ صورة الغلاف المعدلة: ${processedFile.path}');
                  },
                );
              }
            },
            child: Stack(
              children: [
                FreeCaChedNetworkImage(
                  url: coverUrl,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Visibility(
                  visible: false,
                  child: Positioned(
                    bottom: 6,
                    right: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.image,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${album.photoCount}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _FloatingActions extends StatelessWidget {
  final AlbumController controller;
  final String userId;
  final void Function(BuildContext) onAddAlbum;

  const _FloatingActions({
    required this.controller,
    required this.userId,
    required this.onAddAlbum,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "album_refresh_button",
          backgroundColor: Colors.black,
          elevation: 0,
          foregroundColor: Colors.white,
          onPressed: () => controller.loadAlbumsAndCovers(userId),
          child: Center(
            child: TRoundedContainer(
              enableShadow: true,
              width: 35,
              height: 35,
              showBorder: true,
              borderWidth: .5,
              borderColor: Colors.black,
              radius: BorderRadius.circular(300),
              child: Icon(Icons.refresh, size: 20, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "album_add_button",
          backgroundColor: Colors.black,
          elevation: 0,
          foregroundColor: Colors.white,
          onPressed: () => onAddAlbum(context),
          child: Center(
            child: TRoundedContainer(
              enableShadow: true,
              width: 35,
              height: 35,
              showBorder: true,
              borderWidth: .5,
              borderColor: Colors.black,
              radius: BorderRadius.circular(300),
              child: Icon(Icons.add, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

void showAddAlbumDialog(BuildContext context, String userId) {
  final nameController = TextEditingController();

  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: Text("album.new_album".tr),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "album.album_name".tr),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("common.cancel".tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  AlbumController.instance.addAlbum(userId, name);
                  Navigator.pop(context);
                }
              },
              child: Text("album.create".tr),
            ),
          ],
        ),
  );
}
