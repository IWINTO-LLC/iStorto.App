import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/album/controller/photo_controller.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:istoreto/featured/album/model/album_model.dart';
import 'package:istoreto/featured/album/model/photo_model.dart';
import 'package:istoreto/featured/album/screens/fullscreen_image_viewer.dart';

import 'package:istoreto/utils/common/styles/styles.dart';

class AlbumDetailsPage extends StatefulWidget {
  final String userId;
  final AlbumModel album;
  const AlbumDetailsPage({
    super.key,
    required this.album,
    required this.userId,
  });

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  final PhotoController controller = PhotoController.instance;
  bool isLoading = true;
  List<File> tempImages = [];
  double uploadProgress = 0.0;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => isLoading = true);
    await controller.loadPhotos(widget.userId, widget.album.id ?? '');
    setState(() => isLoading = false);
  }

  // حذف صورة مؤقتة
  void _removeTempImage(int index) {
    setState(() {
      tempImages.removeAt(index);
    });
  }

  // معاينة الصور بحجم الشاشة كاملة
  void _showFullscreenImages(List<dynamic> allImages, int initialIndex) {
    showFullscreenImage(
      context: context,
      images: allImages,
      initialIndex: initialIndex,
      showDeleteButton: true,
      showEditButton: true,
      onDelete: (index) {
        // حذف الصورة المؤقتة إذا كانت في النطاق
        if (index < tempImages.length) {
          _removeTempImage(index);
        }
      },
      onSave: (File processedFile, int index) async {
        // استبدال الصورة المؤقتة بالصورة المعدلة
        if (index < tempImages.length) {
          setState(() {
            tempImages[index] = processedFile;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        elevation: 0.1,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        automaticallyImplyLeading: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            widget.album.name,
            style: titilliumBold,
            maxLines: 1,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        bottom:
            isUploading
                ? PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: LinearProgressIndicator(value: uploadProgress),
                )
                : null,
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Obx(() {
                  final List<PhotoModel> photos =
                      controller.photos
                          .where(
                            (photo) => !photo.isDeleted,
                          ) // استبعاد الصور المحذوفة
                          .toList();
                  final allImages = [...tempImages, ...photos];

                  if (allImages.isEmpty) {
                    return Center(child: Text("album_details.no_photos".tr));
                  }

                  return MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: const EdgeInsets.all(12),
                    itemCount: allImages.length,
                    itemBuilder: (context, index) {
                      final image = allImages[index];
                      final isTemp = index < tempImages.length;

                      return GestureDetector(
                        onTap: () => _showFullscreenImages(allImages, index),
                        onLongPress:
                            () => _showImageOptions(
                              context,
                              image,
                              index,
                              isTemp,
                            ),
                        child: Stack(
                          children: [
                            // الصورة
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  isTemp
                                      ? Image.file(
                                        image as File,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      )
                                      : Image.network(
                                        (image as PhotoModel).url,
                                        fit: BoxFit.contain,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        },
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return SizedBox(
                                            height: 300,
                                            width: 200,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value:
                                                      loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                ),
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

                            // أيقونة الحذف للصور المؤقتة
                            if (isTemp)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removeTempImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),

                            // أيقونة مؤقتة للصور المؤقتة
                            if (isTemp)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }),
      ),
      floatingActionButton:
          tempImages.isNotEmpty
              ? FloatingActionButton.extended(
                heroTag: "album_details_save_button",
                onPressed: isUploading ? null : _uploadTempImages,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                icon:
                    isUploading
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
                        : const Icon(Icons.cloud_upload, color: Colors.white),
                label: Text(
                  isUploading
                      ? "album_details.saving".tr
                      : "album_details.save_photos".tr,
                  style: titilliumBold.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              )
              : FloatingActionButton(
                heroTag: "album_details_add_button",
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                onPressed: () => _showAddPhotoOptions(context),
                child: const Icon(Icons.add, color: Colors.white),
              ),
    );
  }

  void _showAddPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text("album_details.choose_from_gallery".tr),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImagesFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text("album_details.take_photo".tr),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImagesFromCamera();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        tempImages.addAll(pickedFiles.map((f) => File(f.path)));
      });
    }
  }

  Future<void> _pickImagesFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> capturedPhotos = [];

    while (true) {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        capturedPhotos.add(photo);
      } else {
        // المستخدم ضغط على زر الرجوع أو إلغاء
        break;
      }
    }

    // إضافة جميع الصور الملتقطة للقائمة المؤقتة
    if (capturedPhotos.isNotEmpty) {
      setState(() {
        tempImages.addAll(capturedPhotos.map((f) => File(f.path)));
      });
    }
  }

  // عرض خيارات الصورة عند الضغط الطويل
  void _showImageOptions(
    BuildContext context,
    dynamic image,
    int index,
    bool isTemp,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // عنوان
                Text(
                  "album_details.image_options".tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),

                // خيارات للصور المؤقتة
                if (isTemp) ...[
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text("album_details.delete_image".tr),
                    onTap: () {
                      Navigator.pop(context);
                      _removeTempImage(index);
                    },
                  ),
                ] else ...[
                  // خيارات للصور المحفوظة
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: Text("album_details.image_details".tr),
                    onTap: () {
                      Navigator.pop(context);
                      _showPhotoDetails(image as PhotoModel);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download, color: Colors.green),
                    title: Text("album_details.download_to_studio".tr),
                    onTap: () {
                      Navigator.pop(context);
                      _downloadToStudio(image as PhotoModel);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text("album_details.delete_image".tr),
                    onTap: () {
                      Navigator.pop(context);
                      _deletePhoto(image as PhotoModel);
                    },
                  ),
                ],

                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("album_details.cancel".tr),
                ),
              ],
            ),
          ),
    );
  }

  // عرض تفاصيل الصورة
  void _showPhotoDetails(PhotoModel photo) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("album_details.image_details".tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${"album_details.url".tr}: ${photo.url}"),
                const SizedBox(height: 8),
                Text(
                  "${"album_details.size".tr}: ${(photo.size / 1024 / 1024).toStringAsFixed(2)} MB",
                ),
                const SizedBox(height: 8),
                Text("${"album_details.album_id".tr}: ${photo.albumId}"),
                const SizedBox(height: 8),
                Text("${"album_details.tags".tr}: ${photo.tags.join(', ')}"),
                const SizedBox(height: 8),
                Text(
                  "${"album_details.delete_status".tr}: ${photo.isDeleted ? "album_details.deleted".tr : "album_details.exists".tr}",
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("album_details.close".tr),
              ),
            ],
          ),
    );
  }

  // تحميل الصورة في الأستديو
  Future<void> _downloadToStudio(PhotoModel photo) async {
    try {
      // هنا يمكن إضافة منطق تحميل الصورة في الأستديو
      // يمكن أن يكون حفظ في مجلد معين أو إرسال إلى خدمة معينة

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("album_details.download_success".tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${"album_details.download_error".tr}: $e")),
        );
      }
    }
  }

  // حذف الصورة
  Future<void> _deletePhoto(PhotoModel photo) async {
    try {
      await controller.deletePhoto(
        userId: widget.userId,
        photoId: photo.id ?? '',
        albumId: photo.albumId ?? '',
        size: photo.size,
      );
      await _loadPhotos(); // إعادة تحميل الصور
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("album_details.delete_success".tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${"album_details.delete_error".tr}: $e")),
        );
      }
    }
  }

  Future<void> _uploadTempImages() async {
    setState(() {
      isUploading = true;
      uploadProgress = 0.0;
    });

    final total = tempImages.length;
    for (int i = 0; i < total; i++) {
      final file = tempImages[i];

      try {
        await controller.uploadImage(
          file: file,
          albumId: widget.album.id ?? '',
          userId: widget.userId,
        );

        setState(() {
          uploadProgress = (i + 1) / total;
        });
      } catch (e) {
        print('Error uploading image: $e');
        // الاستمرار مع الصورة التالية حتى لو فشلت واحدة
      }
    }

    setState(() {
      tempImages.clear();
      isUploading = false;
      uploadProgress = 0.0;
    });
    await _loadPhotos();
  }
}
