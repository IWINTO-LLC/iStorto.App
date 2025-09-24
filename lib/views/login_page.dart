import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/views/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: TColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              Center(
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'welcome_back'.tr,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'sign_in_to_continue'.tr,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Form
              Form(
                key: controller.loginFormKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: controller.loginEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) => controller.validateEmail(value),
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    Obx(
                      () => TextFormField(
                        controller: controller.loginPasswordController,
                        obscureText: controller.isLoginPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: GestureDetector(
                            child: Icon(
                              controller.isLoginPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onTap:
                                () =>
                                    controller.toggleLoginPasswordVisibility(),
                          ),
                        ),
                        validator:
                            (value) => controller.validatePassword(value),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            () =>
                                _showForgotPasswordDialog(context, controller),
                        child: Text(
                          'forgot_password'.tr,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : () => controller.signIn(),

                          child:
                              controller.isLoading.value
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    'login'.tr,
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

                    // Social Media Links
                    Text(
                      'or_continue_with'.tr,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          icon: FontAwesomeIcons.google,
                          color: const Color(0xFFDB4437),
                          onTap: () => controller.signInWithGoogle(),
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          icon: FontAwesomeIcons.facebook,
                          color: const Color(0xFF4267B2),
                          onTap: () => controller.signInWithFacebook(),
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          icon: FontAwesomeIcons.apple,
                          color: Colors.black,
                          onTap: () => controller.signInWithApple(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Guest Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => controller.guestLogin(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: TColors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'login_as_guest'.tr,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'dont_have_account'.tr,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () => Get.to(() => const RegisterPage()),
                          child: Text(
                            'register'.tr,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.copyWith(
                              color: TColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Center(child: FaIcon(icon, size: 24, color: color)),
      ),
    );
  }

  void _showForgotPasswordDialog(
    BuildContext context,
    AuthController controller,
  ) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('forgot_password'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('forgot_password_description'.tr),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) => controller.validateEmail(value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'cancel'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  controller.forgotPassword(emailController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
              child: Text(
                'send_reset_email'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
