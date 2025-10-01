import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:istoreto/models/user_model.dart';
import 'package:istoreto/services/supabase_service.dart';

class UserRepository {
  static final SupabaseClient _client = SupabaseService.client;
  static const String _tableName = 'user_profiles';

  // Create a new user
  Future<UserModel?> createUser(UserModel user) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .insert(user.toJson())
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String id) async {
    try {
      // Join with vendors table to get vendor_id if user is a vendor
      final response =
          await _client
              .from(_tableName)
              .select('*, vendors!inner(id)')
              .eq('id', id)
              .maybeSingle();

      if (response == null) {
        // Try without vendor join (for non-vendor users)
        final userResponse =
            await _client.from(_tableName).select().eq('id', id).single();
        return UserModel.fromJson(userResponse);
      }

      // Extract vendor_id from the nested vendors data
      final userData = Map<String, dynamic>.from(response);
      if (userData['vendors'] != null && userData['vendors'] is List) {
        final vendors = userData['vendors'] as List;
        if (vendors.isNotEmpty && vendors[0]['id'] != null) {
          userData['vendor_id'] = vendors[0]['id'];
        }
      }
      userData.remove('vendors'); // Remove nested data

      return UserModel.fromJson(userData);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user by ID: $e');
      }
      return null;
    }
  }

  // Get user by user_id (Supabase Auth ID)
  Future<UserModel?> getUserByUserId(String userId) async {
    try {
      // Join with vendors table to get vendor_id if user is a vendor
      final response =
          await _client
              .from(_tableName)
              .select('*, vendors!inner(id)')
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) {
        // Try without vendor join (for non-vendor users)
        final userResponse =
            await _client
                .from(_tableName)
                .select()
                .eq('user_id', userId)
                .single();
        return UserModel.fromJson(userResponse);
      }

      // Extract vendor_id from the nested vendors data
      final userData = Map<String, dynamic>.from(response);
      if (userData['vendors'] != null && userData['vendors'] is List) {
        final vendors = userData['vendors'] as List;
        if (vendors.isNotEmpty && vendors[0]['id'] != null) {
          userData['vendor_id'] = vendors[0]['id'];
        }
      }
      userData.remove('vendors'); // Remove nested data

      return UserModel.fromJson(userData);
    } catch (e) {
      print('Error getting user by user_id: $e');
      return null;
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response =
          await _client.from(_tableName).select().eq('email', email).single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .select()
              .eq('username', username)
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  // Update user
  Future<UserModel?> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from(_tableName)
              .update(updates)
              .eq('id', id)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  // Update user by user_id
  Future<UserModel?> updateUserByUserId(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from(_tableName)
              .update(updates)
              .eq('user_id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating user by user_id: $e');
      return null;
    }
  }

  // Delete user
  Future<bool> deleteUser(String id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .select('id')
              .eq('email', email)
              .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .select('id')
              .eq('username', username)
              .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking username existence: $e');
      return false;
    }
  }

  // Get all users (with pagination)
  Future<List<UserModel>> getAllUsers({int limit = 50, int offset = 0}) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Search users by name or username
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .or('name.ilike.%$query%,username.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Update user profile image
  Future<UserModel?> updateProfileImage(String userId, String imageUrl) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .update({
                'profile_image': imageUrl,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating profile image: $e');
      return null;
    }
  }

  // Update user bio
  Future<UserModel?> updateBio(String userId, String bio) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .update({
                'bio': bio,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating bio: $e');
      return null;
    }
  }

  // Update user default currency
  Future<UserModel?> updateDefaultCurrency(
    String userId,
    String currency,
  ) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .update({
                'default_currency': currency,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating default currency: $e');
      return null;
    }
  }

  // Verify email
  Future<UserModel?> verifyEmail(String userId) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .update({
                'email_verified': true,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error verifying email: $e');
      return null;
    }
  }

  // Verify phone
  Future<UserModel?> verifyPhone(String userId) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .update({
                'phone_verified': true,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error verifying phone: $e');
      return null;
    }
  }

  // Deactivate user
  Future<UserModel?> deactivateUser(String userId) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .update({
                'is_active': false,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error deactivating user: $e');
      return null;
    }
  }

  // Activate user
  Future<UserModel?> activateUser(String userId) async {
    try {
      final response =
          await _client
              .from(_tableName)
              .update({
                'is_active': true,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error activating user: $e');
      return null;
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats() async {
    try {
      // Get total users count
      final totalUsersResponse = await _client.from(_tableName).select('id');

      // Get active users count
      final activeUsersResponse = await _client
          .from(_tableName)
          .select('id')
          .eq('is_active', true);

      // Get verified users count
      final verifiedUsersResponse = await _client
          .from(_tableName)
          .select('id')
          .eq('email_verified', true);

      return {
        'total': (totalUsersResponse as List).length,
        'active': (activeUsersResponse as List).length,
        'verified': (verifiedUsersResponse as List).length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {'total': 0, 'active': 0, 'verified': 0};
    }
  }
}
