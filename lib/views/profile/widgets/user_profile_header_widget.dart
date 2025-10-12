import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// مكون رأس الملف الشخصي للمستخدم - للعرض فقط
class UserProfileHeaderWidget extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String profileImage;
  final String coverImage;
  final bool isVendor;

  const UserProfileHeaderWidget({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.profileImage,
    required this.coverImage,
    required this.isVendor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // خلفية صورة الغلاف
          _buildCoverImageBackground(),

          // صورة الملف الشخصي
          _buildProfilePicture(),

          // معلومات المستخدم
          _buildUserInfo(),

          // علامة الحساب التجاري
          if (isVendor) _buildVendorBadge(),
        ],
      ),
    );
  }

  /// بناء خلفية صورة الغلاف
  Widget _buildCoverImageBackground() {
    return Positioned.fill(
      child:
          coverImage.isNotEmpty
              ? CachedNetworkImage(
                imageUrl: coverImage,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
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
                    ),
                errorWidget:
                    (context, url, error) => Container(
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
                    ),
              )
              : Container(
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
              ),
    );
  }

  /// بناء صورة الملف الشخصي
  Widget _buildProfilePicture() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
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
          child:
              profileImage.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: profileImage,
                    fit: BoxFit.cover,
                    imageBuilder:
                        (context, imageProvider) =>
                            CircleAvatar(backgroundImage: imageProvider),
                    placeholder:
                        (context, url) => CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => CircleAvatar(
                          backgroundColor: Colors.grey.shade100,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                  )
                  : CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
        ),
      ),
    );
  }

  /// بناء معلومات المستخدم
  Widget _buildUserInfo() {
    return Positioned(
      top: 220,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            userName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            userEmail,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
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

  /// بناء علامة الحساب التجاري
  Widget _buildVendorBadge() {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'حساب تجاري',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
}
