import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:istoreto/utils/constants/color.dart';
import 'package:istoreto/controllers/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
              Text(
                'create_account'.tr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'join_us_now'.tr,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),

              const SizedBox(height: 40),

              // Form
              Form(
                key: controller.registerFormKey,
                child: Column(
                  children: [
                    // Name Field
                    TextFormField(
                      controller: controller.nameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => controller.validateName(value),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: controller.emailController,
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
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: GestureDetector(
                            child: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onTap: () => controller.togglePasswordVisibility(),
                          ),
                        ),
                        validator:
                            (value) => controller.validatePassword(value),
                      ),
                    ),

                    // const SizedBox(height: 20),

                    // // Phone Number Field
                    // TextFormField(
                    //   controller: controller.phoneController,
                    //   keyboardType: TextInputType.phone,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Phone Number',
                    //     prefixIcon: Icon(Icons.phone_outlined),
                    //   ),
                    //   validator: (value) => controller.validatePhone(value),
                    // ),
                    const SizedBox(height: 30),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : () => controller.register(),
                          // style: ElevatedButton.styleFrom(
                          //   backgroundColor: TColors.primary,
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          // ),
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
                                    'register'.tr,
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

                    const SizedBox(height: 30),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'already_have_account'.tr,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'login'.tr,
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
}
