import 'dart:io';

import 'package:get/get.dart';
import '../data/photo_repository.dart';
import '../data/album_repository.dart';
import '../model/photo_model.dart';

class PhotoController extends GetxController {
  final RxList<PhotoModel> photos = <PhotoModel>[].obs;
  static PhotoController get instance => Get.find();
  final PhotoRepository _photoRepository = Get.find<PhotoRepository>();
  final AlbumRepository _albumRepository = Get.find<AlbumRepository>();

  final RxList<File> tempImages = <File>[].obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxInt currentOffset = 0.obs;
  final RxInt limit = 20.obs;

  // جلب الصور لألبوم معين
  Future<void> loadPhotos(String userId, String albumId) async {
    try {
      isLoading.value = true;
      final fetchedPhotos = await _photoRepository.getPhotosByAlbum(albumId);
      photos.assignAll(fetchedPhotos);
    } catch (e) {
      print('Error loading photos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // جلب جميع الصور للمستخدم
  Future<void> loadAllPhotos(String userId) async {
    try {
      isLoading.value = true;
      final fetchedPhotos = await _photoRepository.getPhotosByUser(userId);
      photos.assignAll(fetchedPhotos);
    } catch (e) {
      print('Error loading all photos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // جلب الصور مع التصفح التدريجي
  Future<void> loadPhotosPaginated(String userId, {bool reset = false}) async {
    if (isLoading.value || !hasMore.value) return;

    try {
      isLoading.value = true;

      if (reset) {
        currentOffset.value = 0;
        hasMore.value = true;
        photos.clear();
      }

      final fetchedPhotos = await _photoRepository.getPhotosPaginated(
        userId,
        limit: limit.value,
        offset: currentOffset.value,
      );

      if (fetchedPhotos.isNotEmpty) {
        photos.addAll(fetchedPhotos);
        currentOffset.value += limit.value;
        hasMore.value = fetchedPhotos.length == limit.value;
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      print('Error loading paginated photos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // إعادة تعيين التصفح التدريجي
  void resetPagination() {
    currentOffset.value = 0;
    hasMore.value = true;
    isLoading.value = false;
    photos.clear();
  }

  // إضافة صور مؤقتة
  void addTempImages(List<File> files) {
    tempImages.addAll(files);
  }

  // حذف صورة
  Future<void> deletePhoto({
    required String userId,
    required String photoId,
    required String albumId,
    required double size,
  }) async {
    try {
      await _photoRepository.deletePhoto(photoId);
      photos.removeWhere((p) => p.id == photoId);

      // تحديث عدد الصور في الألبوم
      await _updateAlbumStats(albumId);
    } catch (e) {
      print('Error deleting photo: $e');
      rethrow;
    }
  }

  // رفع صورة
  Future<void> uploadImage({
    required File file,
    required String albumId,
    required String userId,
  }) async {
    try {
      // حساب حجم الملف
      final sizeInMb = (await file.length()) / (1024 * 1024);

      // إنشاء كائن الصورة
      final photo = PhotoModel(
        url: "placeholder_url", // استبدل بـ result.fileUrl
        size: sizeInMb,
        albumId: albumId,
        userId: userId,
        tags: [], // استبدل بـ result.tags
        isDeleted: false,
        createdAt: DateTime.now(),
      );

      // حفظ الصورة في قاعدة البيانات
      final createdPhoto = await _photoRepository.createPhoto(photo);
      photos.add(createdPhoto);

      // تحديث إحصائيات الألبوم
      await _updateAlbumStats(albumId);
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  // رفع جميع الصور
  Future<void> uploadAll({
    required String albumId,
    required String userId,
  }) async {
    try {
      for (var file in tempImages) {
        await uploadImage(file: file, albumId: albumId, userId: userId);
      }
      tempImages.clear();
      await loadPhotos(userId, albumId);
    } catch (e) {
      print('Error uploading all images: $e');
    }
  }

  // البحث في الصور
  Future<List<PhotoModel>> searchPhotos(String query, {String? userId}) async {
    try {
      return await _photoRepository.searchPhotosByTags(query, userId: userId);
    } catch (e) {
      print('Error searching photos: $e');
      return [];
    }
  }

  // تحديث تاغات الصورة
  Future<void> updatePhotoTags(String photoId, List<String> tags) async {
    try {
      await _photoRepository.updatePhotoTags(photoId, tags);
      final index = photos.indexWhere((p) => p.id == photoId);
      if (index != -1) {
        photos[index] = photos[index].copyWith(tags: tags);
        photos.refresh();
      }
    } catch (e) {
      print('Error updating photo tags: $e');
    }
  }

  // نقل صورة إلى ألبوم آخر
  Future<void> movePhotoToAlbum(String photoId, String newAlbumId) async {
    try {
      await _photoRepository.movePhotoToAlbum(photoId, newAlbumId);
      photos.removeWhere((p) => p.id == photoId);
    } catch (e) {
      print('Error moving photo: $e');
    }
  }

  // تحديث إحصائيات الألبوم
  Future<void> _updateAlbumStats(String albumId) async {
    try {
      final photoCount = await _photoRepository.getPhotosCountForAlbum(albumId);
      final totalSize = await _photoRepository.getTotalSizeForAlbum(albumId);

      await _albumRepository.updateAlbumPhotoCount(albumId, photoCount);
      await _albumRepository.updateAlbumTotalSize(albumId, totalSize);
    } catch (e) {
      print('Error updating album stats: $e');
    }
  }

  // الحصول على عدد الصور
  Future<int> getPhotosCount(String albumId) async {
    try {
      return await _photoRepository.getPhotosCountForAlbum(albumId);
    } catch (e) {
      print('Error getting photos count: $e');
      return 0;
    }
  }

  // الحصول على الحجم الإجمالي
  Future<double> getTotalSize(String albumId) async {
    try {
      return await _photoRepository.getTotalSizeForAlbum(albumId);
    } catch (e) {
      print('Error getting total size: $e');
      return 0.0;
    }
  }
}
