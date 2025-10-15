import 'dart:typed_data';
import 'package:istoreto/utils/constants/constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Register User
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String phoneNumber,
    required String name,
  }) async {
    try {
      // Create user with Supabase Auth (without email verification)
      final AuthResponse response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile data
        final userProfileData = {
          'id': response.user!.id,
          'user_id': response.user!.id, // إضافة user_id
          'email': email,
          'phone_number': phoneNumber,
          'name': name,
          'username': email.split('@')[0],
          'is_active': true,
          'email_verified': true, // Set to true to skip verification
          'phone_verified': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Try to insert user profile data
        try {
          final result =
              await client
                  .from('user_profiles')
                  .insert(userProfileData)
                  .select()
                  .single();

          // Skip verification email - user is automatically verified
          print(
            'User registered successfully without email verification: $email',
          );

          return {
            'success': true,
            'user': result,
            'message': 'User registered successfully.',
          };
        } catch (insertError) {
          print('Error creating user profile: $insertError');
          return {
            'success': false,
            'message':
                'Failed to create user profile: ${insertError.toString()}',
          };
        }
      } else {
        return {'success': false, 'message': 'Failed to create user account'};
      }
    } catch (e) {
      print('Registration error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Sign In with Email
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get user data from user_profiles table
        try {
          final userData =
              await client
                  .from('user_profiles')
                  .select()
                  .eq('id', response.user!.id)
                  .single();

          return {
            'success': true,
            'user': userData,
            'message': 'Login successful',
          };
        } catch (e) {
          // If user profile doesn't exist, create it
          print('User profile not found, creating one: $e');

          final userProfileData = {
            'id': response.user!.id,
            'user_id': response.user!.id,
            'email': email,
            'name': email.split('@')[0],
            'username': email.split('@')[0],
            'is_active': true,
            'email_verified': true, // Skip email verification
            'phone_verified': false,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };

          try {
            final result =
                await client
                    .from('user_profiles')
                    .insert(userProfileData)
                    .select()
                    .single();

            return {
              'success': true,
              'user': result,
              'message': 'Login successful',
            };
          } catch (insertError) {
            print('Error creating user profile: $insertError');
            return {
              'success': true,
              'user': userProfileData,
              'message': 'Login successful (profile creation failed)',
            };
          }
        }
      } else {
        return {'success': false, 'message': 'Invalid credentials'};
      }
    } catch (e) {
      print('Sign in error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Sign In with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final bool success = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
      );

      if (success) {
        // Wait a moment for auth state to update
        await Future.delayed(const Duration(seconds: 2));
        final user = client.auth.currentUser;
        if (user != null) {
          // Check if user exists in custom users table
          final existingUser =
              await client
                  .from('user_profiles')
                  .select()
                  .eq('id', user.id)
                  .maybeSingle();

          if (existingUser == null) {
            // Create user in custom table if not exists
            final userProfileData = {
              'id': user.id,
              'user_id': user.id, // إضافة user_id
              'email': user.email,
              'name':
                  user.userMetadata?['full_name'] ??
                  user.email?.split('@')[0] ??
                  'User',
              'username': user.email?.split('@')[0] ?? '',
              'profile_image': user.userMetadata?['avatar_url'] ?? '',
              'is_active': true,
              'email_verified': true,
              'phone_verified': false,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            };

            await client.from('user_profiles').insert(userProfileData);
          }

          return {
            'success': true,
            'user': existingUser ?? user,
            'message': 'Google login successful',
          };
        } else {
          return {
            'success': false,
            'message': 'Google login failed - no user returned',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Google login failed - no user returned',
        };
      }
    } catch (e) {
      print('Google login error: $e');
      return {
        'success': false,
        'message': 'Google login failed: ${e.toString()}',
      };
    }
  }

  // Sign In with Facebook
  Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      final bool success = await client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
      );

      if (success) {
        // Wait a moment for auth state to update
        await Future.delayed(const Duration(seconds: 2));
        final user = client.auth.currentUser;

        if (user != null) {
          // Check if user exists in custom users table
          final existingUser =
              await client
                  .from('user_profiles')
                  .select()
                  .eq('id', user.id)
                  .maybeSingle();

          if (existingUser == null) {
            // Create user in custom table if not exists
            final userProfileData = {
              'id': user.id,
              'user_id': user.id, // إضافة user_id
              'email': user.email,
              'name':
                  user.userMetadata?['full_name'] ??
                  user.email?.split('@')[0] ??
                  'User',
              'username': user.email?.split('@')[0] ?? '',
              'profile_image': user.userMetadata?['avatar_url'] ?? '',
              'is_active': true,
              'email_verified': true,
              'phone_verified': false,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            };

            await client.from('user_profiles').insert(userProfileData);
          }

          return {
            'success': true,
            'user': existingUser ?? user,
            'message': 'Facebook login successful',
          };
        } else {
          return {
            'success': false,
            'message': 'Facebook login failed - no user returned',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Facebook login failed - OAuth failed',
        };
      }
    } catch (e) {
      print('Facebook login error: $e');
      return {
        'success': false,
        'message': 'Facebook login failed: ${e.toString()}',
      };
    }
  }

  // Sign In with Apple
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      final bool success = await client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.flutterquickstart://login-callback',
      );

      if (success) {
        // Wait a moment for auth state to update
        await Future.delayed(const Duration(seconds: 2));
        final user = client.auth.currentUser;

        if (user != null) {
          // Check if user exists in custom users table
          final existingUser =
              await client
                  .from('user_profiles')
                  .select()
                  .eq('id', user.id)
                  .maybeSingle();

          if (existingUser == null) {
            // Create user in custom table if not exists
            final userProfileData = {
              'id': user.id,
              'user_id': user.id, // إضافة user_id
              'email': user.email,
              'name':
                  user.userMetadata?['full_name'] ??
                  user.email?.split('@')[0] ??
                  'User',
              'username': user.email?.split('@')[0] ?? '',
              'profile_image': user.userMetadata?['avatar_url'] ?? '',
              'is_active': true,
              'email_verified': true,
              'phone_verified': false,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            };

            await client.from('user_profiles').insert(userProfileData);
          }

          return {
            'success': true,
            'user': existingUser ?? user,
            'message': 'Apple login successful',
          };
        } else {
          return {
            'success': false,
            'message': 'Apple login failed - no user returned',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Apple login failed - OAuth failed',
        };
      }
    } catch (e) {
      print('Apple login error: $e');
      return {
        'success': false,
        'message': 'Apple login failed: ${e.toString()}',
      };
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get Current User
  User? get currentUser => client.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Get products for guest users
  Future<Map<String, dynamic>> getProductsForGuest() async {
    try {
      final response = await client
          .from('products')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(20);

      return {
        'success': true,
        'data': response,
        'message': 'Products loaded successfully',
      };
    } catch (e) {
      print('Error loading products for guest: $e');
      return {
        'success': false,
        'data': [],
        'message': 'Failed to load products: ${e.toString()}',
      };
    }
  }

  // Get categories for guest users
  Future<Map<String, dynamic>> getCategoriesForGuest() async {
    try {
      final response = await client
          .from('categories')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return {
        'success': true,
        'data': response,
        'message': 'Categories loaded successfully',
      };
    } catch (e) {
      print('Error loading categories for guest: $e');
      return {
        'success': false,
        'data': [],
        'message': 'Failed to load categories: ${e.toString()}',
      };
    }
  }

  // Create vendor account
  Future<Map<String, dynamic>> createVendor(
    Map<String, dynamic> vendorData,
  ) async {
    try {
      final result =
          await client.from('vendors').insert(vendorData).select().single();

      return {
        'success': true,
        'data': result,
        'message': 'Vendor created successfully',
      };
    } catch (e) {
      print('Error creating vendor: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update user account type
  Future<Map<String, dynamic>> updateUserAccountType(
    String userId,
    int accountType,
  ) async {
    try {
      final result =
          await client
              .from('user_profiles')
              .update({'account_type': accountType})
              .eq('id', userId)
              .select()
              .single();

      return {
        'success': true,
        'data': result,
        'message': 'Account type updated successfully',
      };
    } catch (e) {
      print('Error updating account type: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get vendor by user ID
  Future<Map<String, dynamic>> getVendorByUserId(String userId) async {
    try {
      final result =
          await client.from('vendors').select().eq('user_id', userId).single();

      return {
        'success': true,
        'data': result,
        'message': 'Vendor fetched successfully',
      };
    } catch (e) {
      print('Error fetching vendor: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Upload image to Supabase Storage
  Future<Map<String, dynamic>> uploadImageToStorage(
    List<int> bytes,
    String path,
  ) async {
    try {
      final result = await client.storage
          .from('images')
          .uploadBinary(path, Uint8List.fromList(bytes));

      // Get public URL
      final url = client.storage.from('images').getPublicUrl(path);

      return {
        'success': true,
        'url': url,
        'path': result,
        'message': 'Image uploaded successfully',
      };
    } catch (e) {
      print('Error uploading image: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete image from Supabase Storage
  Future<Map<String, dynamic>> deleteImageFromStorage(String path) async {
    try {
      await client.storage.from('images').remove([path]);

      return {'success': true, 'message': 'Image deleted successfully'};
    } catch (e) {
      print('Error deleting image: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update vendor with selected major categories
  Future<void> updateVendorCategories(
    String vendorId,
    String selectedCategories,
  ) async {
    try {
      await client
          .from('vendors')
          .update({
            'selected_major_categories': selectedCategories,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', vendorId);
    } catch (e) {
      print('Error updating vendor categories: $e');
      rethrow;
    }
  }
}
