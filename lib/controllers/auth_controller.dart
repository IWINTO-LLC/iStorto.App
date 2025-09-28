import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/services/supabase_service.dart';
import 'package:istoreto/services/storage_service.dart';
import 'package:istoreto/repositories/user_repository.dart';
import 'package:istoreto/models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  final SupabaseService _supabaseService = SupabaseService();
  final UserRepository _userRepository = UserRepository();

  // Form Keys
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Login Controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Observable Variables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isLoginPasswordHidden = true.obs;
  final RxBool rememberMe = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.onClose();
  }

  // Load saved credentials
  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await StorageService.instance.getLoginCredentials();
      if (credentials['rememberMe'] == true) {
        loginEmailController.text = credentials['email'];
        loginPasswordController.text = credentials['password'];
        rememberMe.value = true;
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  // Check for auto-login
  Future<bool> checkAutoLogin() async {
    try {
      // Check if user is already logged in via Supabase
      final authUser = _supabaseService.currentUser;
      if (authUser != null) {
        await _loadCurrentUser();
        return true;
      }

      // Check if user has valid saved credentials
      final hasValidCredentials =
          await StorageService.instance.hasValidCredentials();
      if (hasValidCredentials) {
        final credentials = await StorageService.instance.getLoginCredentials();

        // Try to login with saved credentials
        final result = await _supabaseService.signInWithEmail(
          email: credentials['email'],
          password: credentials['password'],
        );

        if (result['success']) {
          await _loadCurrentUser();

          // Update session
          if (currentUser.value != null) {
            await StorageService.instance.saveUserSession(
              userId: currentUser.value!.id,
              email: currentUser.value!.email ?? '',
              isLoggedIn: true,
            );
          }

          return true;
        } else {
          // Clear invalid credentials
          await StorageService.instance.clearLoginCredentials();
        }
      }

      return false;
    } catch (e) {
      print('Error checking auto-login: $e');
      return false;
    }
  }

  // Load current user from Supabase Auth
  Future<void> _loadCurrentUser() async {
    final authUser = _supabaseService.currentUser;
    if (authUser != null) {
      try {
        final user = await _userRepository.getUserById(authUser.id);
        if (user != null) {
          currentUser.value = user;
        } else {
          // If user not found in our database, create a temporary user object
          final tempUser = UserModel(
            id: authUser.id,
            userId: authUser.id,
            name:
                authUser.userMetadata?['name'] ??
                authUser.email?.split('@')[0] ??
                'User',
            email: authUser.email,
            phoneNumber: authUser.phone,
            profileImage: '',
            bio: '',
            brief: '',
            isActive: true,
            emailVerified: authUser.emailConfirmedAt != null,
            phoneVerified: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          currentUser.value = tempUser;
        }
      } catch (e) {
        // If there's an error, create a temporary user object
        final tempUser = UserModel(
          id: authUser.id,
          userId: authUser.id,
          name:
              authUser.userMetadata?['name'] ??
              authUser.email?.split('@')[0] ??
              'User',
          email: authUser.email,
          phoneNumber: authUser.phone,
          profileImage: '',
          bio: '',
          brief: '',
          isActive: true,
          emailVerified: authUser.emailConfirmedAt != null,
          phoneVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        currentUser.value = tempUser;
      }
    }
  }

  // Toggle Password Visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Toggle Login Password Visibility
  void toggleLoginPasswordVisibility() {
    isLoginPasswordHidden.value = !isLoginPasswordHidden.value;
  }

  // Validation Methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required'.tr;
    }
    if (!GetUtils.isEmail(value)) {
      return 'email_invalid'.tr;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required'.tr;
    }
    if (value.length < 6) {
      return 'password_min_length'.tr;
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'phone_required'.tr;
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'phone_invalid'.tr;
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'name_required'.tr;
    }
    if (value.length < 2) {
      return 'name_min_length'.tr;
    }
    return null;
  }

  // Register Method
  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final result = await _supabaseService.registerUser(
        email: emailController.text.trim(),
        password: passwordController.text,
        phoneNumber: phoneController.text.trim(),
        name: nameController.text.trim(),
      );

      if (result['success']) {
        // Load user data
        await _loadCurrentUser();

        Get.snackbar(
          'success'.tr,
          'account_created'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Clear form
        emailController.clear();
        passwordController.clear();
        phoneController.clear();
        nameController.clear();

        // Navigate directly to home page
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'] ?? 'registration_failed'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign In Method
  Future<void> signIn() async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final result = await _supabaseService.signInWithEmail(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );

      if (result['success']) {
        // Load user data
        await _loadCurrentUser();

        // Save login credentials if remember me is checked
        await StorageService.instance.saveLoginCredentials(
          email: loginEmailController.text.trim(),
          password: loginPasswordController.text,
          rememberMe: rememberMe.value,
        );

        // Save user session
        if (currentUser.value != null) {
          await StorageService.instance.saveUserSession(
            userId: currentUser.value!.id,
            email: currentUser.value!.email ?? '',
            isLoggedIn: true,
          );
        }

        Get.snackbar(
          'success'.tr,
          'login_successful'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Clear form only if remember me is not checked
        if (!rememberMe.value) {
          loginEmailController.clear();
          loginPasswordController.clear();
        }

        // Navigate to home
        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'] ?? 'login_failed'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Social Media Login Methods
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final result = await _supabaseService.signInWithGoogle();

      if (result['success']) {
        // Load user data
        await _loadCurrentUser();

        // Check if email is verified in our database
        final user = currentUser.value;
        if (user != null && !user.emailVerified) {
          // Email not verified, redirect to verification page
          Get.snackbar(
            'email_not_verified'.tr,
            'please_verify_email_first'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          Get.offAllNamed(
            '/email-verification',
            arguments: {'email': user.email ?? ''},
          );
          return;
        }

        Get.snackbar(
          'success'.tr,
          'login_successful'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'] ?? 'google_login_failed'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      isLoading.value = true;

      final result = await _supabaseService.signInWithFacebook();

      if (result['success']) {
        // Load user data
        await _loadCurrentUser();

        // Check if email is verified in our database
        final user = currentUser.value;
        if (user != null && !user.emailVerified) {
          // Email not verified, redirect to verification page
          Get.snackbar(
            'email_not_verified'.tr,
            'please_verify_email_first'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          Get.offAllNamed(
            '/email-verification',
            arguments: {'email': user.email ?? ''},
          );
          return;
        }

        Get.snackbar(
          'success'.tr,
          'login_successful'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'] ?? 'facebook_login_failed'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;

      final result = await _supabaseService.signInWithApple();

      if (result['success']) {
        // Load user data
        await _loadCurrentUser();

        // Check if email is verified in our database
        final user = currentUser.value;
        if (user != null && !user.emailVerified) {
          // Email not verified, redirect to verification page
          Get.snackbar(
            'email_not_verified'.tr,
            'please_verify_email_first'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          Get.offAllNamed(
            '/email-verification',
            arguments: {'email': user.email ?? ''},
          );
          return;
        }

        Get.snackbar(
          'success'.tr,
          'login_successful'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        Get.offAllNamed('/home');
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'] ?? 'apple_login_failed'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? phoneNumber,
    String? defaultCurrency,
  }) async {
    if (currentUser.value == null) return;

    try {
      isLoading.value = true;

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (defaultCurrency != null)
        updates['default_currency'] = defaultCurrency;

      final updatedUser = await _userRepository.updateUser(
        currentUser.value!.id,
        updates,
      );

      if (updatedUser != null) {
        currentUser.value = updatedUser;
        Get.snackbar(
          'success'.tr,
          'profile_updated'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'update_failed'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update profile image
  Future<void> updateProfileImage(String imageUrl) async {
    if (currentUser.value == null) return;

    try {
      isLoading.value = true;

      final updatedUser = await _userRepository.updateProfileImage(
        currentUser.value!.id,
        imageUrl,
      );

      if (updatedUser != null) {
        currentUser.value = updatedUser;
        Get.snackbar(
          'success'.tr,
          'profile_image_updated'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'update_failed'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update default currency
  Future<void> updateDefaultCurrency(String currency) async {
    if (currentUser.value == null) return;

    try {
      isLoading.value = true;

      final updatedUser = await _userRepository.updateDefaultCurrency(
        currentUser.value!.id,
        currency,
      );

      if (updatedUser != null) {
        currentUser.value = updatedUser;
        Get.snackbar(
          'success'.tr,
          'currency_updated'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'update_failed'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      currentUser.value = null;

      // Clear user session but keep credentials if remember me is checked
      await StorageService.instance.clearUserSession();

      // Clear form fields
      loginEmailController.clear();
      loginPasswordController.clear();
      rememberMe.value = false;

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'signout_failed'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Guest Login
  Future<void> guestLogin() async {
    try {
      isLoading.value = true;

      // Test database connection by trying to load some data
      final productsResult = await _supabaseService.getProductsForGuest();
      final categoriesResult = await _supabaseService.getCategoriesForGuest();

      // Create a guest user profile
      final guestUser = UserModel(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Guest User',
        email: null,
        phoneNumber: null,
        profileImage: '',
        bio: '',
        brief: '',
        isActive: true,
        emailVerified: false,
        phoneVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Set as current user
      currentUser.value = guestUser;

      // Show success message with database status
      String message = 'welcome_guest'.tr;
      if (productsResult['success'] && categoriesResult['success']) {
        message += ' - Database connected successfully';
      } else {
        message += ' - Database connection issues detected';
      }

      Get.snackbar(
        'success'.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to home
      Get.offAllNamed('/home');
    } catch (e) {
      print('Guest login error: $e');
      Get.snackbar(
        'error'.tr,
        'guest_login_failed'.tr + ': ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Send verification email for unverified users
  Future<void> sendVerificationForUnverifiedUser(String email) async {
    try {
      isLoading.value = true;

      // Validate email first
      if (email.trim().isEmpty) {
        Get.snackbar(
          'error'.tr,
          'email_required'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (!GetUtils.isEmail(email.trim())) {
        Get.snackbar(
          'error'.tr,
          'email_invalid'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final result = await resendVerificationEmail(email.trim());

      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          'verification_email_sent'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'] ?? 'failed_to_send_email'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Send verification error: $e');
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;

      // Validate email first
      if (email.trim().isEmpty) {
        Get.snackbar(
          'error'.tr,
          'email_required'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      if (!GetUtils.isEmail(email.trim())) {
        Get.snackbar(
          'error'.tr,
          'email_invalid'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      await SupabaseService.client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.flutterquickstart://reset-password',
      );

      Get.snackbar(
        'success'.tr,
        'reset_password_email_sent'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Forgot password error: $e');
      String errorMessage = 'failed_to_send_reset_email'.tr;

      if (e.toString().contains('Invalid email')) {
        errorMessage = 'email_not_found'.tr;
      } else if (e.toString().contains('rate limit')) {
        errorMessage = 'too_many_requests'.tr;
      } else if (e.toString().contains('network')) {
        errorMessage = 'network_error'.tr;
      }

      Get.snackbar(
        'error'.tr,
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => currentUser.value != null;

  // Get current user display name
  String get displayName {
    if (currentUser.value != null) {
      return currentUser.value!.displayName;
    }
    return 'Guest';
  }

  // Get current user initials
  String get userInitials {
    if (currentUser.value != null) {
      return currentUser.value!.initials;
    }
    return 'G';
  }

  // Get current user default currency
  String get userDefaultCurrency {
    if (currentUser.value != null) {
      return currentUser.value!.defaultCurrency;
    }
    return 'USD';
  }

  // Resend verification email (disabled - no email verification required)
  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    // Email verification is disabled, return success
    return {'success': true, 'message': 'Email verification is not required'};
  }

  // Check email verification status (disabled - no verification required)
  Future<void> checkEmailVerification() async {
    // Email verification is disabled, always redirect to home
    Get.offAllNamed('/home');
  }

  // Verify email with token (disabled - no verification required)
  Future<Map<String, dynamic>> verifyEmailWithToken(String token) async {
    // Email verification is disabled, return success
    return {'success': true, 'message': 'Email verification is not required'};
  }
}
