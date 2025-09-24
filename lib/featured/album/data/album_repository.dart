import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/album_model.dart';

class AlbumRepository extends GetxController {
  static AlbumRepository get instance => Get.find();
  final _client = Supabase.instance.client;

  // Get all albums for a user
  Future<List<AlbumModel>> getAlbumsByUser(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('albums')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Albums Data==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => AlbumModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting albums: $e");
      }
      throw 'Failed to get albums: ${e.toString()}';
    }
  }

  // Get album by ID
  Future<AlbumModel?> getAlbumById(String albumId) async {
    try {
      if (albumId.isEmpty) {
        throw 'Album ID is required';
      }

      final response =
          await _client.from('albums').select().eq('id', albumId).maybeSingle();

      if (response == null) {
        return null;
      }

      return AlbumModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting album by ID: $e");
      }
      throw 'Failed to get album: ${e.toString()}';
    }
  }

  // Create new album
  Future<AlbumModel> createAlbum(AlbumModel album) async {
    try {
      if (!album.isValid) {
        throw 'Album data is invalid';
      }

      final response =
          await _client.from('albums').insert(album.toJson()).select().single();

      if (kDebugMode) {
        print("=======Created Album==============");
        print(response.toString());
      }

      return AlbumModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating album: $e");
      }
      throw 'Failed to create album: ${e.toString()}';
    }
  }

  // Update album
  Future<AlbumModel> updateAlbum(AlbumModel album) async {
    try {
      if (album.id == null || album.id!.isEmpty) {
        throw 'Album ID is required for update';
      }

      final updatedAlbum = album.updateTimestamp();
      final response =
          await _client
              .from('albums')
              .update(updatedAlbum.toJson())
              .eq('id', album.id!)
              .select()
              .single();

      if (kDebugMode) {
        print("=======Updated Album==============");
        print(response.toString());
      }

      return AlbumModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating album: $e");
      }
      throw 'Failed to update album: ${e.toString()}';
    }
  }

  // Delete album
  Future<void> deleteAlbum(String albumId) async {
    try {
      if (albumId.isEmpty) {
        throw 'Album ID is required';
      }

      await _client.from('albums').delete().eq('id', albumId);

      if (kDebugMode) {
        print("Album deleted successfully: $albumId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting album: $e");
      }
      throw 'Failed to delete album: ${e.toString()}';
    }
  }

  // Update album cover
  Future<void> updateAlbumCover(String albumId, String coverUrl) async {
    try {
      if (albumId.isEmpty) {
        throw 'Album ID is required';
      }

      await _client
          .from('albums')
          .update({
            'cover_url': coverUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', albumId);

      if (kDebugMode) {
        print("Album cover updated: $albumId -> $coverUrl");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating album cover: $e");
      }
      throw 'Failed to update album cover: ${e.toString()}';
    }
  }

  // Update album photo count
  Future<void> updateAlbumPhotoCount(String albumId, int photoCount) async {
    try {
      if (albumId.isEmpty) {
        throw 'Album ID is required';
      }

      await _client
          .from('albums')
          .update({
            'photo_count': photoCount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', albumId);

      if (kDebugMode) {
        print("Album photo count updated: $albumId -> $photoCount");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating album photo count: $e");
      }
      throw 'Failed to update album photo count: ${e.toString()}';
    }
  }

  // Update album total size
  Future<void> updateAlbumTotalSize(String albumId, double totalSize) async {
    try {
      if (albumId.isEmpty) {
        throw 'Album ID is required';
      }

      await _client
          .from('albums')
          .update({
            'total_size': totalSize,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', albumId);

      if (kDebugMode) {
        print("Album total size updated: $albumId -> $totalSize");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating album total size: $e");
      }
      throw 'Failed to update album total size: ${e.toString()}';
    }
  }

  // Search albums by name
  Future<List<AlbumModel>> searchAlbums(String query, {String? userId}) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      var request = _client.from('albums').select().ilike('name', '%$query%');

      if (userId != null && userId.isNotEmpty) {
        request = request.eq('user_id', userId);
      }

      final response = await request.order('created_at', ascending: false);

      final resultList =
          (response as List).map((data) => AlbumModel.fromJson(data)).toList();

      if (kDebugMode) {
        print("=======Search Results==============");
        print("Query: $query, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching albums: $e");
      }
      throw 'Failed to search albums: ${e.toString()}';
    }
  }

  // Get albums count for user
  Future<int> getAlbumsCount(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('albums')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting albums count: $e");
      }
      throw 'Failed to get albums count: ${e.toString()}';
    }
  }

  // Get total size for user
  Future<double> getTotalSizeForUser(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      final response = await _client
          .from('albums')
          .select('total_size')
          .eq('user_id', userId);

      double totalSize = 0.0;
      for (final album in response as List) {
        totalSize += (album['total_size'] ?? 0.0).toDouble();
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

  // Rename album
  Future<void> renameAlbum(String albumId, String newName) async {
    try {
      if (albumId.isEmpty || newName.isEmpty) {
        throw 'Album ID and new name are required';
      }

      await _client
          .from('albums')
          .update({
            'name': newName,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', albumId);

      if (kDebugMode) {
        print("Album renamed: $albumId -> $newName");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error renaming album: $e");
      }
      throw 'Failed to rename album: ${e.toString()}';
    }
  }
}
