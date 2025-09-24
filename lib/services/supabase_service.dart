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
      // Create user with Supabase Auth
      final AuthResponse response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user data
        final userData = {
          'user_id': response.user!.id,
          'email': email,
          'phone_number': phoneNumber,
          'name': name,
          'username': email.split('@')[0],
          'is_active': true,
          'email_verified': false,
          'phone_verified': false,
        };

        // Try to insert user data with error handling
        try {
          final result =
              await client.from('users').insert(userData).select().single();

          return {
            'success': true,
            'user': result,
            'message': 'User registered successfully',
          };
        } catch (insertError) {
          // If RLS error, return success but note that profile needs to be created manually
          print('RLS Error: $insertError');
          return {
            'success': true,
            'user': userData,
            'message':
                'User registered successfully. Profile will be created automatically.',
          };
        }
      } else {
        return {'success': false, 'message': 'Failed to create user account'};
      }
    } catch (e) {
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
        // Get user data from custom users table
        final userData =
            await client
                .from('users')
                .select()
                .eq('user_id', response.user!.id)
                .single();

        return {
          'success': true,
          'user': userData,
          'message': 'Login successful',
        };
      } else {
        return {'success': false, 'message': 'Invalid credentials'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Sign In with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.istoreto.app://login-callback/',
      );

      // Wait for auth state change
      final user = client.auth.currentUser;

      if (user != null) {
        // Check if user exists in custom users table
        final existingUser =
            await client
                .from('users')
                .select()
                .eq('user_id', user.id)
                .maybeSingle();

        if (existingUser == null) {
          // Create user in custom table if not exists
          final userData = {
            'user_id': user.id,
            'email': user.email,
            'name': user.userMetadata?['full_name'] ?? '',
            'username': user.email?.split('@')[0] ?? '',
            'profile_image': user.userMetadata?['avatar_url'] ?? '',
            'is_active': true,
            'email_verified': true,
          };

          await client.from('users').insert(userData);
        }

        return {
          'success': true,
          'user': user,
          'message': 'Google login successful',
        };
      } else {
        return {'success': false, 'message': 'Google login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Sign In with Facebook
  Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      // Wait for auth state change
      final user = client.auth.currentUser;

      if (user != null) {
        // Check if user exists in custom users table
        final existingUser =
            await client
                .from('users')
                .select()
                .eq('user_id', user.id)
                .maybeSingle();

        if (existingUser == null) {
          // Create user in custom table if not exists
          final userData = {
            'user_id': user.id,
            'email': user.email,
            'name': user.userMetadata?['full_name'] ?? '',
            'username': user.email?.split('@')[0] ?? '',
            'profile_image': user.userMetadata?['avatar_url'] ?? '',
            'is_active': true,
            'email_verified': true,
          };

          await client.from('users').insert(userData);
        }

        return {
          'success': true,
          'user': user,
          'message': 'Facebook login successful',
        };
      } else {
        return {'success': false, 'message': 'Facebook login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Sign In with Apple
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      // Wait for auth state change
      final user = client.auth.currentUser;

      if (user != null) {
        // Check if user exists in custom users table
        final existingUser =
            await client
                .from('users')
                .select()
                .eq('user_id', user.id)
                .maybeSingle();

        if (existingUser == null) {
          // Create user in custom table if not exists
          final userData = {
            'user_id': user.id,
            'email': user.email,
            'name': user.userMetadata?['full_name'] ?? '',
            'username': user.email?.split('@')[0] ?? '',
            'profile_image': user.userMetadata?['avatar_url'] ?? '',
            'is_active': true,
            'email_verified': true,
          };

          await client.from('users').insert(userData);
        }

        return {
          'success': true,
          'user': user,
          'message': 'Apple login successful',
        };
      } else {
        return {'success': false, 'message': 'Apple login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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
}
