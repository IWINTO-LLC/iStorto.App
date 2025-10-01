import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:istoreto/models/user_model.dart';
import 'package:istoreto/repositories/user_repository.dart';

class ViewPersonalInfoPage extends StatelessWidget {
  final String? userId;

  const ViewPersonalInfoPage({super.key, this.userId});

  Future<UserModel> _fetchUserData() async {
    final userRepository = UserRepository();

    // If userId is provided, fetch that user's data
    // Otherwise, get current logged-in user
    if (userId != null && userId!.isNotEmpty) {
      final user = await userRepository.getUserById(userId!);
      if (user == null) {
        throw Exception('User not found');
      }
      return user;
    } else {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }
      return currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isCurrentUser =
        userId == null ||
        userId!.isEmpty ||
        userId == authController.currentUser.value?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('personal_information'.tr),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Only show edit button for current user
          if (isCurrentUser)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Navigate to edit page
                Get.toNamed('/edit-personal-info');
              },
            ),
        ],
      ),
      body: FutureBuilder<UserModel>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading user data',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: Text('no_user_data'.tr));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Photo Section
                _buildSection(
                  context: context,
                  title: 'profile_photo'.tr,
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            user.profileImage.isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: user.profileImage,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        color: Colors.blue.shade100,
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: Colors.blue.shade100,
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                )
                                : Container(
                                  color: Colors.blue.shade100,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.blue.shade400,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Personal Information Section
                _buildSection(
                  context: context,
                  title: 'personal_information'.tr,
                  child: Column(
                    children: [
                      _buildInfoCard(
                        context: context,
                        icon: Icons.person,
                        label: 'full_name'.tr,
                        value:
                            user.displayName.isNotEmpty
                                ? user.displayName
                                : 'not_set'.tr,
                        iconColor: Colors.blue,
                      ),
                      SizedBox(height: 12),
                      _buildInfoCard(
                        context: context,
                        icon: Icons.email,
                        label: 'email'.tr,
                        value: user.email ?? 'not_set'.tr,
                        iconColor: Colors.orange,
                      ),
                      SizedBox(height: 12),
                      _buildInfoCard(
                        context: context,
                        icon: Icons.phone,
                        label: 'phone_number'.tr,
                        value:
                            'not_set'
                                .tr, // Phone field not available in UserModel
                        iconColor: Colors.green,
                      ),
                      SizedBox(height: 12),
                      _buildInfoCard(
                        context: context,
                        icon: Icons.location_on,
                        label: 'location'.tr,
                        value:
                            'not_set'
                                .tr, // Location field not available in UserModel
                        iconColor: Colors.red,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Bio Section
                _buildSection(
                  context: context,
                  title: 'bio_description'.tr,
                  child: _buildInfoCard(
                    context: context,
                    icon: Icons.description,
                    label: 'bio'.tr,
                    value: 'not_set'.tr, // Bio field not available in UserModel
                    iconColor: Colors.purple,
                    isMultiline: true,
                  ),
                ),

                SizedBox(height: 30),

                // Account Type Section
                _buildSection(
                  context: context,
                  title: 'account_type'.tr,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            user.accountType == 1
                                ? [Colors.green.shade400, Colors.green.shade600]
                                : [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (user.accountType == 1
                                  ? Colors.green
                                  : Colors.blue)
                              .withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            user.accountType == 1
                                ? Icons.business
                                : Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.accountType == 1
                                    ? 'business_account'.tr
                                    : 'personal_account'.tr,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                user.accountType == 1
                                    ? 'business_account_description'.tr
                                    : 'personal_account_description'.tr,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Account Statistics Section (Optional)
                _buildSection(
                  context: context,
                  title: 'account_statistics'.tr,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.calendar_today,
                          label: 'member_since'.tr,
                          value: _formatDate(user.createdAt),
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.verified_user,
                          label: 'status'.tr,
                          value: 'active'.tr,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isMultiline = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: isMultiline ? 5 : 1,
                  overflow:
                      isMultiline
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'not_available'.tr;

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} ${'days_ago'.tr}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${'months_ago'.tr}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${'years_ago'.tr}';
    }
  }
}
