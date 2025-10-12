import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'vendor_model.dart';
import 'social-link.dart';

class VendorRepository extends GetxController {
  static VendorRepository get instance => Get.find();
  final _client = Supabase.instance.client;

  // Get vendor by ID with social links
  Future<VendorModel?> getVendorById(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      // Use the view that includes social links
      final response =
          await _client
              .from('vendors_with_social_links')
              .select()
              .eq('id', vendorId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      if (kDebugMode) {
        print("=======Vendor Data with Social Links==============");
        print(response.toString());
      }

      return _mapVendorWithSocialLinks(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor by ID: $e");
      }
      throw 'Failed to get vendor: ${e.toString()}';
    }
  }

  // Get vendor by user ID with social links
  Future<VendorModel?> getVendorByUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw 'User ID is required';
      }

      // Use the view that includes social links
      final response =
          await _client
              .from('vendors_with_social_links')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      if (kDebugMode) {
        print("=======Vendor by User ID with Social Links==============");
        print(response.toString());
      }

      return _mapVendorWithSocialLinks(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor by user ID: $e");
      }
      throw 'Failed to get vendor by user ID: ${e.toString()}';
    }
  }

  // Get all active vendors with social links
  Future<List<VendorModel>> getAllActiveVendors() async {
    try {
      final response = await _client
          .from('vendors_with_social_links')
          .select()
          .eq('organization_activated', true)
          .eq('organization_deleted', false)
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print("=======All Active Vendors with Social Links==============");
        print(response.toString());
      }

      final resultList =
          (response as List)
              .map((data) => _mapVendorWithSocialLinks(data))
              .toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting all active vendors: $e");
      }
      throw 'Failed to get all active vendors: ${e.toString()}';
    }
  }

  // Create new vendor
  Future<VendorModel> createVendor(VendorModel vendor) async {
    try {
      if (!vendor.isValid) {
        throw 'Vendor data is invalid';
      }

      final response =
          await _client
              .from('vendors')
              .insert(vendor.toJson())
              .select()
              .single();

      if (kDebugMode) {
        print("=======Created Vendor==============");
        print(response.toString());
      }

      return VendorModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("Error creating vendor: $e");
      }
      throw 'Failed to create vendor: ${e.toString()}';
    }
  }

  // Update vendor profile
  Future<VendorModel> updateVendorProfile(
    String vendorId,
    VendorModel vendor,
  ) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      final updatedVendor = vendor.updateTimestamp();
      final updateData = updatedVendor.toJson();

      // Debug: Print what we're trying to update
      if (kDebugMode) {
        print("📤 Attempting to update vendor:");
        print("Vendor ID: $vendorId");
        print("User ID in data: ${updateData['user_id']}");
        print("Update data: $updateData");
      }

      // Remove 'id' from update data to prevent conflicts
      updateData.remove('id');

      // Ensure user_id is present for RLS check
      if (updateData['user_id'] == null) {
        throw 'user_id is required for RLS policy check';
      }

      // Update vendor basic info
      final response =
          await _client
              .from('vendors')
              .update(updateData)
              .eq('id', vendorId)
              .select()
              .single();

      // Update social links if they exist
      if (updatedVendor.socialLink != null) {
        await updateVendorSocialLinks(vendorId, updatedVendor.socialLink!);
      }

      if (kDebugMode) {
        print("✅ Updated Vendor Profile Successfully");
        print(response.toString());
      }

      // Return the updated vendor with social links
      return await getVendorById(vendorId) ?? VendorModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error updating vendor profile: $e");
      }
      throw 'Failed to update vendor profile: ${e.toString()}';
    }
  }

  // Update specific field
  Future<void> updateField({
    required String vendorId,
    required String fieldName,
    required dynamic newValue,
  }) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      await _client
          .from('vendors')
          .update({
            fieldName: newValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      if (kDebugMode) {
        print('✅ تم تحديث الحقل "$fieldName" إلى "$newValue" بنجاح');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ حدث خطأ أثناء التحديث: $e');
      }
      throw 'Failed to update field: ${e.toString()}';
    }
  }

  // Delete vendor (soft delete)
  Future<void> deleteVendor(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      await _client
          .from('vendors')
          .update({
            'organization_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      if (kDebugMode) {
        print("Vendor deleted successfully: $vendorId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting vendor: $e");
      }
      throw 'Failed to delete vendor: ${e.toString()}';
    }
  }

  // Permanently delete vendor
  Future<void> permanentlyDeleteVendor(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      await _client.from('vendors').delete().eq('id', vendorId);

      if (kDebugMode) {
        print("Vendor permanently deleted: $vendorId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error permanently deleting vendor: $e");
      }
      throw 'Failed to permanently delete vendor: ${e.toString()}';
    }
  }

  // Search vendors by organization name with social links
  Future<List<VendorModel>> searchVendors(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final response = await _client
          .from('vendors_with_social_links')
          .select()
          .ilike('organization_name', '%$query%')
          .eq('organization_activated', true)
          .eq('organization_deleted', false)
          .order('created_at', ascending: false);

      final resultList =
          (response as List)
              .map((data) => _mapVendorWithSocialLinks(data))
              .toList();

      if (kDebugMode) {
        print("=======Search Results with Social Links==============");
        print("Query: $query, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching vendors: $e");
      }
      throw 'Failed to search vendors: ${e.toString()}';
    }
  }

  // Get vendors count
  Future<int> getVendorsCount() async {
    try {
      final response = await _client
          .from('vendors')
          .select('id')
          .eq('organization_activated', true)
          .eq('organization_deleted', false);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendors count: $e");
      }
      throw 'Failed to get vendors count: ${e.toString()}';
    }
  }

  // Activate/Deactivate vendor
  Future<void> toggleVendorActivation(String vendorId, bool isActive) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      await _client
          .from('vendors')
          .update({
            'organization_activated': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);

      if (kDebugMode) {
        print("Vendor activation toggled: $vendorId -> $isActive");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error toggling vendor activation: $e");
      }
      throw 'Failed to toggle vendor activation: ${e.toString()}';
    }
  }

  // Map vendor data with social links from the view
  VendorModel _mapVendorWithSocialLinks(Map<String, dynamic> data) {
    try {
      // Create SocialLink from the view data
      final socialLink = SocialLink(
        facebook: data['facebook'] ?? '',
        x: data['x'] ?? '',
        instagram: data['instagram'] ?? '',
        website: data['website'] ?? '',
        linkedin: data['linkedin'] ?? '',
        whatsapp: data['whatsapp'] ?? '',
        tiktok: data['tiktok'] ?? '',
        youtube: data['youtube'] ?? '',
        location: data['location'] ?? '',
        phones: data['phones'] != null ? List<String>.from(data['phones']) : [],
        visibleFacebook: data['visible_facebook'] ?? true,
        visibleX: data['visible_x'] ?? true,
        visibleInstagram: data['visible_instagram'] ?? true,
        visibleWebsite: data['visible_website'] ?? true,
        visibleLinkedin: data['visible_linkedin'] ?? true,
        visibleWhatsapp: data['visible_whatsapp'] ?? true,
        visibleTiktok: data['visible_tiktok'] ?? true,
        visibleYoutube: data['visible_youtube'] ?? true,
        visiblePhones: data['visible_phones'] ?? true,
      );

      // Create VendorModel with social links
      return VendorModel(
        id: data['id'],
        userId: data['user_id'],
        organizationName: data['organization_name'] ?? '',
        organizationBio: data['organization_bio'] ?? '',
        bannerImage: data['cover_image'] ?? '',

        organizationLogo: data['organization_logo'] ?? '',
        organizationCover: data['organization_cover'] ?? '',
        website: data['website'] ?? '',
        brief: data['brief'] ?? '',
        exclusiveId: data['exclusive_id'] ?? '',
        storeMessage: data['store_message'] ?? '',
        inExclusive: data['in_exclusive'] ?? false,
        isSubscriber: data['is_subscriber'] ?? false,
        isVerified: data['is_verified'] ?? false,
        isRoyal: data['is_royal'] ?? false,
        enableIwintoPayment: data['enable_iwinto_payment'] ?? false,
        enableCod: data['enable_cod'] ?? false,
        organizationDeleted: data['organization_deleted'] ?? false,
        organizationActivated: data['organization_activated'] ?? true,
        defaultCurrency: data['default_currency'] ?? 'USD',
        selectedMajorCategories: data['selected_major_categories'],
        socialLink: socialLink,
        createdAt:
            data['created_at'] != null
                ? DateTime.parse(data['created_at'])
                : null,
        updatedAt:
            data['updated_at'] != null
                ? DateTime.parse(data['updated_at'])
                : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error mapping vendor with social links: $e");
      }
      // Fallback to regular VendorModel.fromJson if mapping fails
      return VendorModel.fromJson(data);
    }
  }

  // Update vendor social links
  Future<void> updateVendorSocialLinks(
    String vendorId,
    SocialLink socialLink,
  ) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      // First, get the user_id from the vendor
      final vendorResponse =
          await _client
              .from('vendors')
              .select('user_id')
              .eq('id', vendorId)
              .maybeSingle();

      if (vendorResponse == null) {
        throw 'Vendor not found';
      }

      final userId = vendorResponse['user_id'];
      if (userId == null) {
        throw 'Vendor has no user_id';
      }

      // Check if social links record exists
      final existingRecord =
          await _client
              .from('social_links')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();

      final socialLinkData = {
        'user_id': userId,
        'facebook': socialLink.facebook,
        'x': socialLink.x,
        'instagram': socialLink.instagram,
        'website': socialLink.website,
        'linkedin': socialLink.linkedin,
        'whatsapp': socialLink.whatsapp,
        'tiktok': socialLink.tiktok,
        'youtube': socialLink.youtube,
        'location': socialLink.location,
        'phones': socialLink.phones,
        'visible_facebook': socialLink.visibleFacebook,
        'visible_x': socialLink.visibleX,
        'visible_instagram': socialLink.visibleInstagram,
        'visible_website': socialLink.visibleWebsite,
        'visible_linkedin': socialLink.visibleLinkedin,
        'visible_whatsapp': socialLink.visibleWhatsapp,
        'visible_tiktok': socialLink.visibleTiktok,
        'visible_youtube': socialLink.visibleYoutube,
        'visible_phones': socialLink.visiblePhones,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingRecord != null) {
        // Update existing record
        await _client
            .from('social_links')
            .update(socialLinkData)
            .eq('user_id', userId);

        if (kDebugMode) {
          print("Social links updated for user_id: $userId");
        }
      } else {
        // Insert new record
        await _client.from('social_links').insert(socialLinkData);

        if (kDebugMode) {
          print("Social links inserted for user_id: $userId");
        }
      }

      if (kDebugMode) {
        print(
          "✅ Vendor social links saved successfully: vendorId=$vendorId, userId=$userId",
        );
        print("Social link data: $socialLinkData");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error updating vendor social links: $e");
      }
      throw 'Failed to update vendor social links: ${e.toString()}';
    }
  }

  // Get vendor social links only
  Future<SocialLink?> getVendorSocialLinks(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      // First, get the user_id from the vendor
      final vendorResponse =
          await _client
              .from('vendors')
              .select('user_id')
              .eq('id', vendorId)
              .maybeSingle();

      if (vendorResponse == null) {
        throw 'Vendor not found';
      }

      final userId = vendorResponse['user_id'];
      if (userId == null) {
        return null;
      }

      final response =
          await _client
              .from('social_links')
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return SocialLink(
        facebook: response['facebook'] ?? '',
        x: response['x'] ?? '',
        instagram: response['instagram'] ?? '',
        website: response['website'] ?? '',
        linkedin: response['linkedin'] ?? '',
        whatsapp: response['whatsapp'] ?? '',
        tiktok: response['tiktok'] ?? '',
        youtube: response['youtube'] ?? '',
        location: response['location'] ?? '',
        phones:
            response['phones'] != null
                ? List<String>.from(response['phones'])
                : [],
        visibleFacebook: response['visible_facebook'] ?? true,
        visibleX: response['visible_x'] ?? true,
        visibleInstagram: response['visible_instagram'] ?? true,
        visibleWebsite: response['visible_website'] ?? true,
        visibleLinkedin: response['visible_linkedin'] ?? true,
        visibleWhatsapp: response['visible_whatsapp'] ?? true,
        visibleTiktok: response['visible_tiktok'] ?? true,
        visibleYoutube: response['visible_youtube'] ?? true,
        visiblePhones: response['visible_phones'] ?? true,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor social links: $e");
      }
      throw 'Failed to get vendor social links: ${e.toString()}';
    }
  }

  /// جلب إحصائيات التاجر (عدد المنتجات، المتابعين، العروض)
  Future<Map<String, int>> getVendorStats(String vendorId) async {
    try {
      if (vendorId.isEmpty) {
        throw 'Vendor ID is required';
      }

      // جلب عدد المنتجات (غير المحذوفة)
      final productsResponse = await _client
          .from('products')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false);

      // جلب عدد العروض (المنتجات التي لها old_price أكبر من price)
      final offersResponse = await _client
          .from('products')
          .select('id')
          .eq('vendor_id', vendorId)
          .eq('is_deleted', false)
          .gt('old_price', 0);

      // جلب عدد المتابعين
      final followersResponse = await _client
          .from('user_follows')
          .select('id')
          .eq('vendor_id', vendorId);

      final productsCount = (productsResponse as List).length;
      final offersCount = (offersResponse as List).length;
      final followersCount = (followersResponse as List).length;

      if (kDebugMode) {
        print(
          'Vendor Stats - Products: $productsCount, Offers: $offersCount, Followers: $followersCount',
        );
      }

      return {
        'products_count': productsCount,
        'offers_count': offersCount,
        'followers_count': followersCount,
      };
    } catch (e) {
      if (kDebugMode) {
        print("Error getting vendor stats: $e");
      }
      return {'products_count': 0, 'offers_count': 0, 'followers_count': 0};
    }
  }

  /// التحقق من متابعة المستخدم للتاجر
  Future<bool> isFollowingVendor(String userId, String vendorId) async {
    try {
      final response =
          await _client
              .from('user_follows')
              .select('id')
              .eq('user_id', userId)
              .eq('vendor_id', vendorId)
              .maybeSingle();

      return response != null;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking follow status: $e");
      }
      return false;
    }
  }

  /// متابعة تاجر
  Future<bool> followVendor(String userId, String vendorId) async {
    try {
      // التحقق من عدم وجود متابعة سابقة
      final isAlreadyFollowing = await isFollowingVendor(userId, vendorId);
      if (isAlreadyFollowing) {
        return false; // Already following
      }

      await _client.from('user_follows').insert({
        'user_id': userId,
        'vendor_id': vendorId,
      });

      if (kDebugMode) {
        print('User $userId followed vendor $vendorId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error following vendor: $e");
      }
      return false;
    }
  }

  /// إلغاء متابعة تاجر
  Future<bool> unfollowVendor(String userId, String vendorId) async {
    try {
      await _client
          .from('user_follows')
          .delete()
          .eq('user_id', userId)
          .eq('vendor_id', vendorId);

      if (kDebugMode) {
        print('User $userId unfollowed vendor $vendorId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error unfollowing vendor: $e");
      }
      return false;
    }
  }

  /// جلب عدد المتابعين الفعلي للتاجر
  Future<int> getFollowersCount(String vendorId) async {
    try {
      final response = await _client
          .from('user_follows')
          .select('id')
          .eq('vendor_id', vendorId);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting followers count: $e");
      }
      return 0;
    }
  }
}
