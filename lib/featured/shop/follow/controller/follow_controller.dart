import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/vendor_model.dart';
import '../../../../models/user_model.dart';

class FollowController extends GetxController {
  static FollowController get instance => Get.find();
  final _client = Supabase.instance.client;

  RxInt followersCount = 0.obs;
  var isFollowing = false.obs;
  var isLoading = false.obs;

  // التحقق من حالة المتابعة
  Future<void> checkFollowStatus(String userId, String vendorId) async {
    try {
      isFollowing.value = await isFollowed(userId, vendorId);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking follow status: $e');
      }
    }
  }

  // متابعة متجر
  Future<void> followUser(String userId, String vendorId) async {
    try {
      isLoading.value = true;

      await _client.from('user_follows').insert({
        'user_id': userId,
        'vendor_id': vendorId,
        'created_at': DateTime.now().toIso8601String(),
      });

      isFollowing.value = true;

      // تحديث عدد المتابعين
      await getFollowersCount(vendorId);

      if (kDebugMode) {
        print('User $userId followed vendor $vendorId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error following user: $e');
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // إلغاء متابعة متجر
  Future<void> unfollowUser(String userId, String vendorId) async {
    try {
      isLoading.value = true;

      await _client
          .from('user_follows')
          .delete()
          .eq('user_id', userId)
          .eq('vendor_id', vendorId);

      isFollowing.value = false;

      // تحديث عدد المتابعين
      await getFollowersCount(vendorId);

      if (kDebugMode) {
        print('User $userId unfollowed vendor $vendorId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unfollowing user: $e');
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // الحصول على قائمة المتابعين لمتجر
  Future<List<UserModel>> getFollowers(String vendorId) async {
    try {
      final response = await _client
          .from('user_follows')
          .select('''
            user_id,
            users!user_follows_user_id_fkey (
              id,
              email,
              raw_user_meta_data,
              email_confirmed_at,
              created_at,
              updated_at
            )
          ''')
          .eq('vendor_id', vendorId);

      if (kDebugMode) {
        print("=======Followers Data==============");
        print(response.toString());
      }

      final resultList =
          (response as List)
              .map((data) => UserModel.fromAuthUsersJson(data['users']))
              .toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting followers: $e");
      }
      throw 'Failed to get followers: ${e.toString()}';
    }
  }

  // الحصول على قائمة المتاجر المتابعة من قبل المستخدم
  Future<List<VendorModel>> getFollowing(String userId) async {
    try {
      final response = await _client
          .from('user_follows')
          .select('''
            vendor_id,
            vendors!user_follows_vendor_id_fkey (
              id,
              user_id,
              organization_name,
              organization_bio,
              organization_logo,
              is_verified,
              organization_activated
            )
          ''')
          .eq('user_id', userId);

      if (kDebugMode) {
        print("=======Following Data==============");
        print(response.toString());
      }

      final resultList =
          (response as List)
              .map((data) => VendorModel.fromJson(data['vendors']))
              .toList();

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting following: $e");
      }
      throw 'Failed to get following: ${e.toString()}';
    }
  }

  // التحقق من حالة المتابعة
  Future<bool> isFollowed(String userId, String vendorId) async {
    try {
      final response =
          await _client
              .from('user_follows')
              .select('id')
              .eq('user_id', userId)
              .eq('vendor_id', vendorId)
              .maybeSingle();

      isFollowing.value = response != null;
      return isFollowing.value;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking follow status: $e');
      }
      return false;
    }
  }

  // الحصول على عدد المتابعين
  Future<int> getFollowersCount(String vendorId) async {
    try {
      final response = await _client
          .from('user_follows')
          .select('id')
          .eq('vendor_id', vendorId);

      followersCount.value = (response as List).length;
      return followersCount.value;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting followers count: $e');
      }
      return 0;
    }
  }

  // الحصول على عدد المتابعات للمستخدم
  Future<int> getFollowingCount(String userId) async {
    try {
      final response = await _client
          .from('user_follows')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting following count: $e');
      }
      return 0;
    }
  }

  // البحث في المتابعين
  Future<List<UserModel>> searchFollowers(String vendorId, String query) async {
    try {
      if (query.isEmpty) {
        return await getFollowers(vendorId);
      }

      final response = await _client
          .from('user_follows')
          .select('''
            user_id,
            users!user_follows_user_id_fkey (
              id,
              email,
              raw_user_meta_data,
              email_confirmed_at,
              created_at,
              updated_at
            )
          ''')
          .eq('vendor_id', vendorId)
          .ilike('users.raw_user_meta_data->>name', '%$query%');

      final resultList =
          (response as List)
              .map((data) => UserModel.fromAuthUsersJson(data['users']))
              .toList();

      if (kDebugMode) {
        print("=======Search Followers Results==============");
        print("Query: $query, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching followers: $e");
      }
      throw 'Failed to search followers: ${e.toString()}';
    }
  }

  // البحث في المتابعات
  Future<List<VendorModel>> searchFollowing(String userId, String query) async {
    try {
      if (query.isEmpty) {
        return await getFollowing(userId);
      }

      final response = await _client
          .from('user_follows')
          .select('''
            vendor_id,
            vendors!user_follows_vendor_id_fkey (
              id,
              user_id,
              organization_name,
              organization_bio,
              organization_logo,
              is_verified,
              organization_activated
            )
          ''')
          .eq('user_id', userId)
          .ilike('vendors.organization_name', '%$query%');

      final resultList =
          (response as List)
              .map((data) => VendorModel.fromJson(data['vendors']))
              .toList();

      if (kDebugMode) {
        print("=======Search Following Results==============");
        print("Query: $query, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error searching following: $e");
      }
      throw 'Failed to search following: ${e.toString()}';
    }
  }

  // الحصول على إحصائيات المتابعة
  Future<Map<String, int>> getFollowStats(String userId) async {
    try {
      final followingCount = await getFollowingCount(userId);

      return {
        'following': followingCount,
        'followers': 0, // This would need to be calculated differently
      };
    } catch (e) {
      if (kDebugMode) {
        print("Error getting follow stats: $e");
      }
      return {'following': 0, 'followers': 0};
    }
  }

  // تبديل حالة المتابعة
  Future<void> toggleFollow(String userId, String vendorId) async {
    try {
      if (isFollowing.value) {
        await unfollowUser(userId, vendorId);
      } else {
        await followUser(userId, vendorId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling follow: $e');
      }
      rethrow;
    }
  }

  // الحصول على المتابعين مع التصفح التدريجي
  Future<List<UserModel>> getFollowersPaginated(
    String vendorId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('user_follows')
          .select('''
            user_id,
            users!user_follows_user_id_fkey (
              id,
              email,
              raw_user_meta_data,
              email_confirmed_at,
              created_at,
              updated_at
            )
          ''')
          .eq('vendor_id', vendorId)
          .range(offset, offset + limit - 1);

      final resultList =
          (response as List)
              .map((data) => UserModel.fromAuthUsersJson(data['users']))
              .toList();

      if (kDebugMode) {
        print("=======Paginated Followers==============");
        print("Offset: $offset, Limit: $limit, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting paginated followers: $e");
      }
      throw 'Failed to get paginated followers: ${e.toString()}';
    }
  }

  // الحصول على المتابعات مع التصفح التدريجي
  Future<List<VendorModel>> getFollowingPaginated(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('user_follows')
          .select('''
            vendor_id,
            vendors!user_follows_vendor_id_fkey (
              id,
              user_id,
              organization_name,
              organization_bio,
              organization_logo,
              is_verified,
              organization_activated
            )
          ''')
          .eq('user_id', userId)
          .range(offset, offset + limit - 1);

      final resultList =
          (response as List)
              .map((data) => VendorModel.fromJson(data['vendors']))
              .toList();

      if (kDebugMode) {
        print("=======Paginated Following==============");
        print("Offset: $offset, Limit: $limit, Results: ${resultList.length}");
      }

      return resultList;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting paginated following: $e");
      }
      throw 'Failed to get paginated following: ${e.toString()}';
    }
  }
}
