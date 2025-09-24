import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/photo_model.dart';

class PhotoRepository extends GetxController {
  static PhotoRepository get instance => Get.find();
  final _client = Supabase.instance.client;

  // Get all photos for an album
  Future<List<PhotoModel>> getPhotosByAlbum(String albumId) async {
    try {
      if (albumId.isEmpty) {
        throw 'Album ID is required';
      }

      final response = await _client
          .from('photos')
          .select()
          .eq('album_id', albumId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Photos Data==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => PhotoModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting photos: $e");
      }
      throw 'Failed to get photos: ${e.toString()}';
    }
  }

  // Get all photos for a user
  Future<List<PhotoModel>> getPhotosByUser(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('photos')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      final resultList =
          (response as List).map((data) => PhotoModel.fromJson(data)).toList();

      if (kDebugMode) {
        print("=======User Photos==============");
        print("Count: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting user photos: $e");
      }
      throw 'Failed to get user photos: ${e.toString()}';
    }
  }

  // Get photo by ID
  Future<PhotoModel?> getPhotoById(String photoId) async {
    try {
      if (photoId.isEmpty) {
        throw 'Photo ID is required';
      }

      final response =
          await _client.from('photos').select().eq('id', photoId).maybeSingle();

      if (response == null) {
        return null;
      }

      return PhotoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting photo by ID: $e");
      }
      throw 'Failed to get photo: ${e.toString()}';
    }
  }

  // Create new photo
  Future<PhotoModel> createPhoto(PhotoModel photo) async {
    try {
      if (!photo.isValid) {
        throw 'Photo data is invalid';
      }

      final response =
          await _client.from('photos').insert(photo.toJson()).select().single();

      if (kDebugMode) {
        print("=======Created Photo==============");
        print(response.toString());
      }

      return PhotoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating photo: $e");
      }
      throw 'Failed to create photo: ${e.toString()}';
    }
  }

  // Update photo
  Future<PhotoModel> updatePhoto(PhotoModel photo) async {
    try {
      if (photo.id == null || photo.id!.isEmpty) {
        throw 'Photo ID is required for update';
      }

      final updatedPhoto = photo.updateTimestamp();
      final response =
          await _client
              .from('photos')
              .update(updatedPhoto.toJson())
              .eq('id', photo.id!)
              .select()
              .single();

      if (kDebugMode) {
        print("=======Updated Photo==============");
        print(response.toString());
      }

      return PhotoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating photo: $e");
      }
      throw 'Failed to update photo: ${e.toString()}';
    }
  }

  // Delete photo (soft delete)
  Future<void> deletePhoto(String photoId) async {
    try {
      if (photoId.isEmpty) {
        throw 'Photo ID is required';
      }

      await _client
          .from('photos')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', photoId);

      if (kDebugMode) {
        print("Photo deleted successfully: $photoId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting photo: $e");
      }
      throw 'Failed to delete photo: ${e.toString()}';
    }
  }

  // Permanently delete photo
  Future<void> permanentlyDeletePhoto(String photoId) async {
    try {
      if (photoId.isEmpty) {
        throw 'Photo ID is required';
      }

      await _client.from('photos').delete().eq('id', photoId);

      if (kDebugMode) {
        print("Photo permanently deleted: $photoId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error permanently deleting photo: $e");
      }
      throw 'Failed to permanently delete photo: ${e.toString()}';
    }
  }

  // Get photos with pagination
  Future<List<PhotoModel>> getPhotosPaginated(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('photos')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final resultList =
          (response as List).map((data) => PhotoModel.fromJson(data)).toList();

      if (kDebugMode) {
        print("=======Paginated Photos==============");
        print("Offset: $offset, Limit: $limit, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting paginated photos: $e");
      }
      throw 'Failed to get paginated photos: ${e.toString()}';
    }
  }

  // Search photos by tags
  Future<List<PhotoModel>> searchPhotosByTags(
    String query, {
    String? userId,
  }) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      var request = _client
          .from('photos')
          .select()
          .contains('tags', [query])
          .eq('is_deleted', false);

      if (userId != null && userId.isNotEmpty) {
        request = request.eq('user_id', userId);
      }

      final response = await request.order('created_at', ascending: false);

      final resultList =
          (response as List).map((data) => PhotoModel.fromJson(data)).toList();

      if (kDebugMode) {
        print("=======Search Results==============");
        print("Query: $query, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching photos: $e");
      }
      throw 'Failed to search photos: ${e.toString()}';
    }
  }

  // Get photos count for album
  Future<int> getPhotosCountForAlbum(String albumId) async {
    try {
      if (albumId.isEmpty) {
        throw 'Album ID is required';
      }

      final response = await _client
          .from('photos')
          .select('id')
          .eq('album_id', albumId)
          .eq('is_deleted', false);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting photos count: $e");
      }
      throw 'Failed to get photos count: ${e.toString()}';
    }
  }

  // Get photos count for user
  Future<int> getPhotosCountForUser(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('photos')
          .select('id')
          .eq('user_id', userId)
          .eq('is_deleted', false);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting photos count: $e");
      }
      throw 'Failed to get photos count: ${e.toString()}';
    }
  }

  // Get total size for album
  Future<double> getTotalSizeForAlbum(String albumId) async {
    try {
      if (albumId.isEmpty) {
        throw 'Album ID is required';
      }

      final response = await _client
          .from('photos')
          .select('size')
          .eq('album_id', albumId)
          .eq('is_deleted', false);

      double totalSize = 0.0;
      for (final photo in response as List) {
        totalSize += (photo['size'] ?? 0.0).toDouble();
      }

      if (kDebugMode) {
        print("Total size for album $albumId: $totalSize MB");
      }

      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting total size: $e");
      }
      throw 'Failed to get total size: ${e.toString()}';
    }
  }

  // Get total size for user
  Future<double> getTotalSizeForUser(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('photos')
          .select('size')
          .eq('user_id', userId)
          .eq('is_deleted', false);

      double totalSize = 0.0;
      for (final photo in response as List) {
        totalSize += (photo['size'] ?? 0.0).toDouble();
      }

      if (kDebugMode) {
        print("Total size for user $userId: $totalSize MB");
      }

      return totalSize;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting total size: $e");
      }
      throw 'Failed to get total size: ${e.toString()}';
    }
  }

  // Update photo tags
  Future<void> updatePhotoTags(String photoId, List<String> tags) async {
    try {
      if (photoId.isEmpty) {
        throw 'Photo ID is required';
      }

      await _client
          .from('photos')
          .update({
            'tags': tags,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', photoId);

      if (kDebugMode) {
        print("Photo tags updated: $photoId -> $tags");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating photo tags: $e");
      }
      throw 'Failed to update photo tags: ${e.toString()}';
    }
  }

  // Move photo to another album
  Future<void> movePhotoToAlbum(String photoId, String newAlbumId) async {
    try {
      if (photoId.isEmpty || newAlbumId.isEmpty) {
        throw 'Photo ID and Album ID are required';
      }

      await _client
          .from('photos')
          .update({
            'album_id': newAlbumId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', photoId);

      if (kDebugMode) {
        print("Photo moved: $photoId -> $newAlbumId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error moving photo: $e");
      }
      throw 'Failed to move photo: ${e.toString()}';
    }
  }
}
