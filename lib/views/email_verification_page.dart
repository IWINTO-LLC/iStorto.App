import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/utils/constants/color.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final AuthController _authController = Get.find<AuthController>();
  final RxBool _isResending = false.obs;
  final RxInt _countdown = 60.obs;
  final RxBool _canResend = false.obs;

  String get email => Get.arguments?['email'] ?? '';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _startCountdown();
    _checkEmailVerification();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _canResend.value = false;
    _countdown.value = 60;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_countdown.value > 0) {
        _countdown.value--;
        return true;
      } else {
        _canResend.value = true;
        return false;
      }
    });
  }

  void _checkEmailVerification() async {
    // Check every 5 seconds if email is verified
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_authController.isLoggedIn) {
        final user = _authController.currentUser.value;
        if (user != null && user.emailVerified) {
          timer.cancel();
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
    });
  }

  Future<void> _resendVerificationEmail() async {
    try {
      _isResending.value = true;

      final result = await _authController.resendVerificationEmail(email);

      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          'verification_email_sent'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        _startCountdown();
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
      Get.snackbar(
        'error'.tr,
        'something_went_wrong'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isResending.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Header
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          // Email Icon
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: TColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              size: 50,
                              //color: TColors.primary,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Title
                          Text(
                            'verify_your_email'.tr,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              //color: TColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'email_verification_description'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Email address
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: TColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: TColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'email_verification_instructions'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Resend Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => ElevatedButton(
                    onPressed:
                        _canResend.value && !_isResending.value
                            ? _resendVerificationEmail
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isResending.value
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              _canResend.value
                                  ? 'resend_verification_email'.tr
                                  : 'resend_in_seconds'.tr.replaceAll(
                                    '{seconds}',
                                    _countdown.value.toString(),
                                  ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Check Status Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    await _authController.checkEmailVerification();
                    if (_authController.currentUser.value?.emailVerified ==
                        true) {
                      Get.offAllNamed('/home');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: TColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'check_verification_status'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Back to Login
              TextButton(
                onPressed: () {
                  Get.offAllNamed('/login');
                },
                child: Text(
                  'back_to_login'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
