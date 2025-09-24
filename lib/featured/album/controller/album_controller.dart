import 'dart:io';

import 'package:get/get.dart';
import '../data/album_repository.dart';
import '../data/photo_repository.dart';
import '../model/album_model.dart';
import '../model/photo_model.dart';

class AlbumController extends GetxController {
  static AlbumController get instance => Get.find();
  final AlbumRepository _albumRepository = Get.find<AlbumRepository>();
  final PhotoRepository _photoRepository = Get.find<PhotoRepository>();

  // الحالة
  final RxList<AlbumModel> albums = <AlbumModel>[].obs;
  final RxList<PhotoModel> photos = <PhotoModel>[].obs;
  final RxList<File> imagesToUpload = <File>[].obs;

  final RxBool isLoadingAlbums = false.obs;
  final RxBool photosLoaded = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxDouble totalSize = 0.0.obs;

  // ✅ جلب الألبومات مع الغلاف والحجم
  Future<void> loadAlbumsAndCovers(String userId) async {
    try {
      isLoadingAlbums.value = true;
      await _fetchAlbums(userId);
      await _fetchAlbumCovers(userId);
      await _updateStudioSize(userId);
    } catch (e) {
      print('Error loading albums: $e');
    } finally {
      isLoadingAlbums.value = false;
    }
  }

  Future<void> _fetchAlbums(String userId) async {
    try {
      final fetchedAlbums = await _albumRepository.getAlbumsByUser(userId);
      albums.assignAll(fetchedAlbums);
    } catch (e) {
      print('Error fetching albums: $e');
      rethrow;
    }
  }

  Future<void> _fetchAlbumCovers(String userId) async {
    try {
      for (var album in albums) {
        if (album.id != null) {
          final albumPhotos = await _photoRepository.getPhotosByAlbum(
            album.id!,
          );
          if (albumPhotos.isNotEmpty) {
            final coverUrl = albumPhotos.first.url;
            final updated = album.copyWith(coverUrl: coverUrl);
            final index = albums.indexWhere((a) => a.id == album.id);
            if (index != -1) albums[index] = updated;
          }
        }
      }
      albums.refresh();
    } catch (e) {
      print('Error fetching album covers: $e');
    }
  }

  // 📐 تحديث الحجم الإجمالي
  Future<void> _updateStudioSize(String userId) async {
    try {
      final total = await _albumRepository.getTotalSizeForUser(userId);
      totalSize.value = total;
    } catch (e) {
      print('Error updating studio size: $e');
    }
  }

  // ➕ إضافة ألبوم جديد
  Future<void> addAlbum(String userId, String name) async {
    try {
      final album = AlbumModel(
        name: name,
        userId: userId,
        photoCount: 0,
        totalSize: 0.0,
      );
      final createdAlbum = await _albumRepository.createAlbum(album);
      albums.add(createdAlbum);
    } catch (e) {
      print('Error adding album: $e');
      rethrow;
    }
  }

  // ✏️ تعديل اسم الألبوم
  Future<void> renameAlbum(
    String userId,
    String albumId,
    String newName,
  ) async {
    try {
      await _albumRepository.renameAlbum(albumId, newName);
      final index = albums.indexWhere((a) => a.id == albumId);
      if (index != -1) {
        albums[index] = albums[index].copyWith(name: newName);
        albums.refresh();
      }
    } catch (e) {
      print('Error renaming album: $e');
      rethrow;
    }
  }

  // 🗑️ حذف ألبوم
  Future<void> deleteAlbum(String userId, String albumId) async {
    try {
      await _albumRepository.deleteAlbum(albumId);
      albums.removeWhere((a) => a.id == albumId);
    } catch (e) {
      print('Error deleting album: $e');
      rethrow;
    }
  }

  // 🔍 فلترة وفرز الألبومات
  List<AlbumModel> getFilteredAlbums({
    required String query,
    required String sortBy,
  }) {
    List<AlbumModel> result =
        albums
            .where((a) => a.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    switch (sortBy) {
      case "name":
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "size":
        result.sort((a, b) => b.totalSize.compareTo(a.totalSize));
        break;
      case "count":
        result.sort((a, b) => b.photoCount.compareTo(a.photoCount));
        break;
    }

    return result;
  }

  // 🔢 حساب عدد الصور في ألبوم معين ديناميكيًا
  Future<int> getPhotoCountForAlbum(String userId, String albumId) async {
    try {
      return await _photoRepository.getPhotosCountForAlbum(albumId);
    } catch (e) {
      print('Error getting photo count: $e');
      return 0;
    }
  }

  // مثال: تحديث عدد الصور في كل الألبومات بعد تحميلها
  Future<void> updateAlbumsPhotoCounts(String userId) async {
    try {
      for (var album in albums) {
        if (album.id != null) {
          final count = await getPhotoCountForAlbum(userId, album.id!);
          final index = albums.indexWhere((a) => a.id == album.id);
          if (index != -1) {
            albums[index] = albums[index].copyWith(photoCount: count);
          }
        }
      }
      albums.refresh();
    } catch (e) {
      print('Error updating album photo counts: $e');
    }
  }

  // جلب الصور لألبوم معين
  Future<void> loadPhotosForAlbum(String albumId) async {
    try {
      photosLoaded.value = false;
      final fetchedPhotos = await _photoRepository.getPhotosByAlbum(albumId);
      photos.assignAll(fetchedPhotos);
      photosLoaded.value = true;
    } catch (e) {
      print('Error loading photos: $e');
      photosLoaded.value = false;
    }
  }

  // جلب جميع الصور للمستخدم
  Future<void> loadAllPhotos(String userId) async {
    try {
      photosLoaded.value = false;
      final fetchedPhotos = await _photoRepository.getPhotosByUser(userId);
      photos.assignAll(fetchedPhotos);
      photosLoaded.value = true;
    } catch (e) {
      print('Error loading all photos: $e');
      photosLoaded.value = false;
    }
  }

  // البحث في الألبومات
  Future<List<AlbumModel>> searchAlbums(String query, {String? userId}) async {
    try {
      return await _albumRepository.searchAlbums(query, userId: userId);
    } catch (e) {
      print('Error searching albums: $e');
      return [];
    }
  }

  // تحديث غلاف الألبوم
  Future<void> updateAlbumCover(String albumId, String coverUrl) async {
    try {
      await _albumRepository.updateAlbumCover(albumId, coverUrl);
      final index = albums.indexWhere((a) => a.id == albumId);
      if (index != -1) {
        albums[index] = albums[index].copyWith(coverUrl: coverUrl);
        albums.refresh();
      }
    } catch (e) {
      print('Error updating album cover: $e');
    }
  }
}
