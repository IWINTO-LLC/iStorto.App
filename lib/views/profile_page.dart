import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/views/initial_commercial_page.dart';
import 'package:istoreto/views/admin/admin_zone_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Gradient Section with Profile
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple.shade300,
                    Colors.purple.shade400,
                    Colors.white,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Back Button
                  Positioned(
                    top: 50,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  // Profile Picture
                  Positioned(
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
                            child: CircleAvatar(
                              backgroundColor: Colors.purple.shade100,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.purple.shade400,
                              ),
                            ),
                          ),
                          // Edit Icon
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showEditProfileDialog(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade400,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // User Info
                  Positioned(
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Action Buttons Row
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
                  ),
                ],
              ),
            ),

            // Content Section
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About Section
                    _buildSection(
                      title: 'About',
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'I\'m a cool person and I like to study technology. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Interests Section
                    _buildSection(
                      title: 'Interests',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildInterestChip(
                            'Science',
                            Icons.science,
                            Colors.blue,
                          ),
                          _buildInterestChip(
                            'Technology',
                            Icons.computer,
                            Colors.pink,
                          ),
                          _buildInterestChip(
                            'Design',
                            Icons.palette,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Menu Items
                    _buildMenuSection(authController),

                    // Add extra padding at the bottom for better scrolling
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
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

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInterestChip(String text, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(AuthController authController) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.person,
          title: 'Personal Information',
          subtitle: 'Update your personal details',
          onTap: () => _showEditProfileDialog(Get.context!),
        ),
        _buildMenuItem(
          icon: Icons.business,
          title: 'Business Account',
          subtitle:
              authController.currentUser.value?.accountType == 1
                  ? 'Manage your business'
                  : 'Create commercial account',
          onTap: () {
            if (authController.currentUser.value?.accountType == 1) {
              Get.to(
                () => MarketPlaceView(
                  editMode: true,
                  vendorId: authController.currentUser.value!.id,
                ),
              );
            } else {
              Get.to(() => const InitialCommercialPage());
            }
          },
        ),
        _buildMenuItem(
          icon: Icons.admin_panel_settings,
          title: 'Admin Zone',
          subtitle: 'Manage categories and content',
          onTap: () => Get.to(() => const AdminZonePage()),
        ),
        _buildMenuItem(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences and configuration',
          onTap: () => _showSettingsDialog(Get.context!),
        ),
        _buildMenuItem(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () => _showHelpDialog(Get.context!),
        ),
        SizedBox(height: 20),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: () => _showLogoutDialog(Get.context!, authController),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.blue,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade400,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Text('Profile editing feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Text('Settings feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help & Support'),
          content: Text('Help and support feature coming soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('logout'.tr),
          content: Text('logout_confirmation'.tr),
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
                Navigator.of(context).pop();
                authController.signOut();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'logout'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
