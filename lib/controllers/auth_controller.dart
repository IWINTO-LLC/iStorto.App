import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:istoreto/services/supabase_service.dart';
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
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
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

  // Load current user from Supabase Auth
  Future<void> _loadCurrentUser() async {
    final authUser = _supabaseService.currentUser;
    if (authUser != null) {
      try {
        final user = await _userRepository.getUserByUserId(authUser.id);
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
        // Store email before clearing form
        final userEmail = emailController.text.trim();

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

        // Navigate to email verification page
        Get.offAllNamed('/email-verification', arguments: {'email': userEmail});
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
            arguments: {'email': loginEmailController.text.trim()},
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

        // Clear form
        loginEmailController.clear();
        loginPasswordController.clear();

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

      final updatedUser = await _userRepository.updateUserByUserId(
        currentUser.value!.userId,
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
        currentUser.value!.userId,
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
        currentUser.value!.userId,
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

      // Get.snackbar(
      //   'success'.tr,
      //   'welcome_guest'.tr,
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   duration: const Duration(seconds: 3),
      // );

      // Navigate to home
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'guest_login_failed'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;

      await SupabaseService.client.auth.resetPasswordForEmail(email);

      Get.snackbar(
        'success'.tr,
        'reset_password_email_sent'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_send_reset_email'.tr,
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

  // Resend verification email
  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      await SupabaseService.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      return {
        'success': true,
        'message': 'Verification email sent successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Check email verification status
  Future<void> checkEmailVerification() async {
    final authUser = _supabaseService.currentUser;
    if (authUser != null) {
      // Refresh user data
      await _loadCurrentUser();

      if (currentUser.value?.emailVerified == true) {
        Get.snackbar(
          'success'.tr,
          'email_verified_successfully'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Get.offAllNamed('/home');
      }
    }
  }

  // Verify email with token
  Future<Map<String, dynamic>> verifyEmailWithToken(String token) async {
    try {
      final response = await SupabaseService.client.auth.verifyOTP(
        token: token,
        type: OtpType.email,
      );

      if (response.user != null) {
        // Update user verification status
        await _userRepository.verifyEmail(response.user!.id);
        await _loadCurrentUser();

        return {'success': true, 'message': 'Email verified successfully'};
      } else {
        return {'success': false, 'message': 'Invalid verification token'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
