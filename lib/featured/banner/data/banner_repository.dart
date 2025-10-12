import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'banner_model.dart';

class BannerRepository extends GetxController {
  static BannerRepository get instance => Get.find();
  final _client = Supabase.instance.client;

  // Get all banners
  Future<List<BannerModel>> getAllBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Banners Data==========${response.toString()}====");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => BannerModel.fromJson(data)).toList();
      print("=======Banners Data result ==========${resultList}====");
      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting banners: $e");
      }
      throw 'Failed to get banners: ${e.toString()}';
    }
  }

  // Get active banners only
  Future<List<BannerModel>> getActiveBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('active', true)
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Active Banners==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => BannerModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting active banners: $e");
      }
      throw 'Failed to get active banners: ${e.toString()}';
    }
  }

  // Get vendor banners only
  Future<List<BannerModel>> getVendorBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('active', true)
          .not('vendor_id', 'is', null)
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Vendor Banners==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => BannerModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor banners: $e");
      }
      throw 'Failed to get vendor banners: ${e.toString()}';
    }
  }

  // Get banners for specific vendor
  Future<List<BannerModel>> getVendorBannersById(String vendorId) async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('active', true)
          .eq('vendor_id', vendorId)
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Vendor Banners for $vendorId==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => BannerModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor banners: $e");
      }
      throw 'Failed to get vendor banners: ${e.toString()}';
    }
  }

  // Get all banners for specific vendor (regardless of scope or active status)
  // للاستخدام في صفحة إدارة بانرات التاجر
  Future<List<BannerModel>> getAllVendorBannersByVendorId(
    String vendorId,
  ) async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======All Vendor Banners for $vendorId==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => BannerModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting all vendor banners: $e");
      }
      throw 'Failed to get all vendor banners: ${e.toString()}';
    }
  }

  // Get mixed banners (company + specific vendor)
  Future<List<BannerModel>> getMixedBanners(String? vendorId) async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('active', true)
          .or('scope.eq.company,and(scope.eq.vendor,vendor_id.eq.$vendorId)')
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Mixed Banners==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => BannerModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting mixed banners: $e");
      }
      throw 'Failed to get mixed banners: ${e.toString()}';
    }
  }

  // Get banners by target screen
  Future<List<BannerModel>> getBannersByTargetScreen(
    String targetScreen,
  ) async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('active', true)
          .eq('target_screen', targetScreen)
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Banners for $targetScreen==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => BannerModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting banners by target screen: $e");
      }
      throw 'Failed to get banners by target screen: ${e.toString()}';
    }
  }

  // Get mixed banners for specific target screen
  Future<List<BannerModel>> getMixedBannersForScreen(
    String targetScreen,
    String? vendorId,
  ) async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('active', true)
          .eq('target_screen', targetScreen)
          .or('scope.eq.company,and(scope.eq.vendor,vendor_id.eq.$vendorId)')
          .order('priority', ascending: false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======Mixed Banners for $targetScreen==============");
        print(response.toString());
      }

      final resultList =
          (response as List).map((data) => BannerModel.fromJson(data)).toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting mixed banners for screen: $e");
      }
      throw 'Failed to get mixed banners for screen: ${e.toString()}';
    }
  }

  // Get banner by ID
  Future<BannerModel?> getBannerById(String bannerId) async {
    try {
      if (bannerId.isEmpty) {
        throw 'Banner ID is required';
      }

      final response =
          await _client
              .from('banners')
              .select()
              .eq('id', bannerId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return BannerModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting banner by ID: $e");
      }
      throw 'Failed to get banner: ${e.toString()}';
    }
  }

  // Create new banner
  Future<BannerModel> createBanner(BannerModel banner) async {
    try {
      if (!banner.isValid) {
        throw 'Banner data is invalid';
      }

      final response =
          await _client
              .from('banners')
              .insert(banner.toJson())
              .select()
              .single();

      if (kDebugMode) {
        print("=======Created Banner==============");
        print(response.toString());
      }

      return BannerModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating banner: $e");
      }
      throw 'Failed to create banner: ${e.toString()}';
    }
  }

  // Update banner
  Future<BannerModel> updateBanner(BannerModel banner) async {
    try {
      if (banner.id == null || banner.id!.isEmpty) {
        throw 'Banner ID is required for update';
      }

      final updatedBanner = banner.updateTimestamp();
      final response =
          await _client
              .from('banners')
              .update(updatedBanner.toJson())
              .eq('id', banner.id!)
              .select()
              .single();

      if (kDebugMode) {
        print("=======Updated Banner==============");
        print(response.toString());
      }

      return BannerModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error updating banner: $e");
      }
      throw 'Failed to update banner: ${e.toString()}';
    }
  }

  // Delete banner
  Future<void> deleteBanner(String bannerId) async {
    try {
      if (bannerId.isEmpty) {
        throw 'Banner ID is required';
      }

      await _client.from('banners').delete().eq('id', bannerId);

      if (kDebugMode) {
        print("Banner deleted successfully: $bannerId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting banner: $e");
      }
      throw 'Failed to delete banner: ${e.toString()}';
    }
  }

  // Toggle banner active status
  Future<void> toggleBannerActive(String bannerId, bool isActive) async {
    try {
      if (bannerId.isEmpty) {
        throw 'Banner ID is required';
      }

      await _client
          .from('banners')
          .update({
            'active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bannerId);

      if (kDebugMode) {
        print("Banner active status toggled: $bannerId -> $isActive");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error toggling banner active status: $e");
      }
      throw 'Failed to toggle banner active status: ${e.toString()}';
    }
  }

  // Get banners count
  Future<int> getBannersCount() async {
    try {
      final response = await _client.from('banners').select('id');

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting banners count: $e");
      }
      throw 'Failed to get banners count: ${e.toString()}';
    }
  }

  // Get active banners count
  Future<int> getActiveBannersCount() async {
    try {
      final response = await _client
          .from('banners')
          .select('id')
          .eq('active', true);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting active banners count: $e");
      }
      throw 'Failed to get active banners count: ${e.toString()}';
    }
  }

  // Convert vendor banner to company banner
  Future<void> convertToCompanyBanner(BannerModel banner) async {
    try {
      if (banner.id == null || banner.id!.isEmpty) {
        throw 'Banner ID is required';
      }

      await _client
          .from('banners')
          .update({
            'scope': 'company',
            'vendor_id': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', banner.id!);

      if (kDebugMode) {
        print("Banner converted to company banner: ${banner.id}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error converting banner to company banner: $e");
      }
      throw 'Failed to convert banner to company banner: ${e.toString()}';
    }
  }

  // Delete banner (admin)
  Future<void> deleteBannerAdmin(BannerModel banner) async {
    try {
      if (banner.id == null || banner.id!.isEmpty) {
        throw 'Banner ID is required';
      }

      await _client.from('banners').delete().eq('id', banner.id!);

      if (kDebugMode) {
        print("Banner deleted: ${banner.id}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting banner: $e");
      }
      throw 'Failed to delete banner: ${e.toString()}';
    }
  }

  // Add company banner
  Future<void> addCompanyBanner(BannerModel banner) async {
    try {
      await _client.from('banners').insert({
        'image': banner.image,
        'target_screen': banner.targetScreen,
        'active': banner.active,
        'scope': 'company',
        'vendor_id': null,
        'title': banner.title,
        'description': banner.description,
        'priority': banner.priority ?? 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print("Company banner added successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error adding company banner: $e");
      }
      throw 'Failed to add company banner: ${e.toString()}';
    }
  }

  // Update banner fields
  Future<void> updateBannerFields(
    String bannerId, {
    String? title,
    String? description,
    String? targetScreen,
    int? priority,
    bool? active,
    BannerScope? scope,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (targetScreen != null) updateData['target_screen'] = targetScreen;
      if (priority != null) updateData['priority'] = priority;
      if (active != null) updateData['active'] = active;
      if (scope != null) {
        updateData['scope'] = scope.name;
        if (scope == BannerScope.company) {
          updateData['vendor_id'] = null;
        }
      }

      await _client.from('banners').update(updateData).eq('id', bannerId);

      if (kDebugMode) {
        print("Banner updated successfully: $bannerId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating banner: $e");
      }
      throw 'Failed to update banner: ${e.toString()}';
    }
  }

  // Search banners by target screen
  Future<List<BannerModel>> searchBannersByTargetScreen(
    String targetScreen,
  ) async {
    try {
      if (targetScreen.isEmpty) {
        return [];
      }

      final response = await _client
          .from('banners')
          .select()
          .ilike('target_screen', '%$targetScreen%')
          .order('created_at', ascending: false);

      final resultList =
          (response as List).map((data) => BannerModel.fromJson(data)).toList();

      if (kDebugMode) {
        print("=======Search Results==============");
        print("Target Screen: $targetScreen, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching banners: $e");
      }
      throw 'Failed to search banners: ${e.toString()}';
    }
  }
}
