import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/controllers/image_edit_controller.dart';
import 'package:istoreto/featured/product/cashed_network_image_free.dart';

/// مكون رأس الملف الشخصي - يعرض صورة الغلاف والصورة الشخصية ومعلومات المستخدم
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final imageController = Get.put(ImageEditController());

    // Debug: عرض معلومات المستخدم
    debugPrint('═══════════ Profile Header Debug ═══════════');
    debugPrint('👤 User ID: ${authController.currentUser.value?.id}');
    debugPrint('🏪 Vendor ID: ${authController.currentUser.value?.vendorId}');
    debugPrint(
      '🔢 Account Type: ${authController.currentUser.value?.accountType}',
    );
    debugPrint('📧 Email: ${authController.currentUser.value?.email}');
    debugPrint('═══════════════════════════════════════════');

    // تحميل صور المستخدم من قاعدة البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserImages(authController, imageController);
    });

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // خلفية صورة الغلاف
          _buildCoverImageBackground(imageController, authController),

          // صورة الملف الشخصي
          _buildProfilePicture(imageController, authController),

          // معلومات المستخدم
          _buildUserInfo(authController),
        ],
      ),
    );
  }

  /// بناء خلفية صورة الغلاف
  Widget _buildCoverImageBackground(
    ImageEditController imageController,
    AuthController authController,
  ) {
    return Positioned.fill(
      child: Obx(() {
        // عرض loading overlay أثناء رفع صورة الغلاف
        if (imageController.isLoadingCover) {
          final progress = imageController.coverUploadProgress;
          final percentage = (progress * 100).toInt();

          return Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 6,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'uploading_cover_photo'.tr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // عرض صورة غلاف محلية أولاً إذا كانت موجودة
        if (imageController.coverImage != null) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(imageController.coverImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Black opacity overlay for better text visibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        // عرض صورة غلاف من UserModel إذا كانت موجودة
        else if (authController.currentUser.value?.cover != null &&
            authController.currentUser.value!.cover.isNotEmpty) {
          final coverUrl = authController.currentUser.value!.cover;

          debugPrint('🖼️ Loading cover from UserModel: $coverUrl');

          return Stack(
            fit: StackFit.expand,
            children: [
              FreeCaChedNetworkImage(
                url: coverUrl,
                raduis: BorderRadius.zero, // لا حواف دائرية للغلاف
                fit: BoxFit.cover,
              ),
              // Black opacity overlay for better text visibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        // عرض الخلفية الافتراضية إذا لم يكن المستخدم تجاري
        debugPrint(
          'ℹ️ User is not vendor (accountType: ${authController.currentUser.value?.accountType})',
        );
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade300,
                Colors.blue.shade400,
                Colors.white,
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
        );
      }),
    );
  }

  /// بناء صورة الملف الشخصي
  Widget _buildProfilePicture(
    ImageEditController imageController,
    AuthController authController,
  ) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Obx(() {
                // عرض loading overlay أثناء رفع الصورة الشخصية
                if (imageController.isLoadingProfile) {
                  final progress = imageController.profileUploadProgress;
                  final percentage = (progress * 100).toInt();

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 5,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'uploading_profile_photo'.tr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                // عرض صورة محلية أولاً إذا كانت موجودة
                if (imageController.profileImage != null) {
                  return CircleAvatar(
                    backgroundImage: FileImage(imageController.profileImage!),
                  );
                }
                // عرض صورة من قاعدة البيانات إذا كانت موجودة
                else if (authController.currentUser.value?.profileImage !=
                        null &&
                    authController.currentUser.value!.profileImage.isNotEmpty) {
                  return CircleAvatar(
                    backgroundImage: NetworkImage(
                      authController.currentUser.value!.profileImage,
                    ),
                  );
                }
                // عرض أيقونة افتراضية
                else {
                  return CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(Icons.person, size: 60, color: Colors.black),
                  );
                }
              }),
            ),
            // أيقونة تعديل الصورة الشخصية
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _editProfilePhoto(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء معلومات المستخدم
  Widget _buildUserInfo(AuthController authController) {
    return Positioned(
      top: 220,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Obx(
            () => Text(
              authController.displayName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4.0,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            authController.currentUser.value?.email ?? 'user@example.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 3.0,
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // أزرار الإجراءات
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.access_time,
                text: '5 Min',
                onTap: () {},
              ),
              SizedBox(width: 20),
              _buildActionButton(
                icon: Icons.message,
                text: 'Message',
                onTap: () {},
              ),
              SizedBox(width: 20),
              _buildActionButton(
                icon: Icons.location_on,
                text: 'Location',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء زر الإجراء
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// تحميل صور المستخدم من قاعدة البيانات
  void _loadUserImages(
    AuthController authController,
    ImageEditController imageController,
  ) {
    try {
      final user = authController.currentUser.value;
      if (user != null) {
        // تحميل صورة الملف الشخصي من UserModel
        if (user.profileImage.isNotEmpty) {
          _loadImageFromUrl(user.profileImage, true, imageController);
        }

        // تحميل صورة الغلاف من UserModel إذا كانت موجودة
        if (user.cover.isNotEmpty) {
          _loadImageFromUrl(user.cover, false, imageController);
        }
      }
    } catch (e) {
      print('خطأ في تحميل صور المستخدم: $e');
    }
  }

  /// تحميل صورة من URL
  Future<void> _loadImageFromUrl(
    String imageUrl,
    bool isProfile,
    ImageEditController imageController,
  ) async {
    try {
      // هذا يتطلب تحميل الصورة من URL وتحويلها إلى File
      // يمكن استخدام cached_network_image أو تحميل مباشر
      // للآن سنتركه فارغاً وسنعتمد على الصور المحلية
    } catch (e) {
      print('خطأ في تحميل الصورة من URL: $e');
    }
  }

  /// تعديل الصورة الشخصية
  void _editProfilePhoto() {
    final imageController = Get.find<ImageEditController>();
    imageController.showImageSourceDialog(
      title: 'تعديل الصورة الشخصية',
      onCamera: () => imageController.pickFromCamera(isProfile: true),
      onGallery: () => imageController.pickFromGallery(isProfile: true),
    );
  }
}
