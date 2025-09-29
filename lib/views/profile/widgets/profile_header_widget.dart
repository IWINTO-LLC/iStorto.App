import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/controllers/image_edit_controller.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';

/// مكون رأس الملف الشخصي - يعرض صورة الغلاف والصورة الشخصية ومعلومات المستخدم
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final imageController = Get.put(ImageEditController());

    // تحميل صور المستخدم من قاعدة البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserImages(authController, imageController);
    });

    return Container(
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
        // عرض صورة غلاف محلية أولاً إذا كانت موجودة
        if (imageController.coverImage != null) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(imageController.coverImage!),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        // عرض صورة غلاف من قاعدة البيانات إذا كانت موجودة
        else if (authController.currentUser.value?.accountType == 1) {
          return FutureBuilder(
            future: _getVendorCoverImage(authController.currentUser.value!.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(snapshot.data!),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
              // عرض الطبقة الزرقاء فقط إذا لم تكن هناك صورة غلاف
              return Container();
            },
          );
        }
        // عرض الطبقة الزرقاء إذا لم يكن المستخدم تجاري
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
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Obx(() {
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
                color: Colors.grey.shade800,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${authController.currentUser.value?.email ?? 'user@example.com'}',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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

        // تحميل صورة الغلاف من VendorModel إذا كان المستخدم تجاري
        if (user.accountType == 1) {
          _loadVendorCoverImage(user.id, imageController);
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

  /// تحميل صورة غلاف المتجر
  Future<void> _loadVendorCoverImage(
    String userId,
    ImageEditController imageController,
  ) async {
    try {
      // جلب بيانات المتجر
      final vendorController = Get.find<VendorController>();
      await vendorController.fetchVendorData(userId);

      final vendor = vendorController.vendorData.value;
      if (vendor != null && vendor.organizationCover.isNotEmpty) {
        // تحميل صورة الغلاف
        _loadImageFromUrl(vendor.organizationCover, false, imageController);
      }
    } catch (e) {
      print('خطأ في تحميل صورة غلاف المتجر: $e');
    }
  }

  /// جلب صورة غلاف المتجر
  Future<String> _getVendorCoverImage(String userId) async {
    try {
      final vendorController = Get.find<VendorController>();
      await vendorController.fetchVendorData(userId);

      final vendor = vendorController.vendorData.value;
      if (vendor != null && vendor.organizationCover.isNotEmpty) {
        return vendor.organizationCover;
      }
      return '';
    } catch (e) {
      print('خطأ في جلب صورة غلاف المتجر: $e');
      return '';
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
