import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Settings Section
            _buildSection(
              title: 'Profile Settings',
              children: [
                _buildSettingsItem(
                  icon: Icons.person,
                  title: 'Personal Information',
                  subtitle: 'Update your personal details',
                  onTap: () => _showPersonalInfoDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.photo_camera,
                  title: 'Profile Photo',
                  subtitle: 'Change your profile picture',
                  onTap: () => _showProfilePhotoDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.photo_library,
                  title: 'Cover Photo',
                  subtitle: 'Change your cover image',
                  onTap: () => _showCoverPhotoDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.description,
                  title: 'Bio & Description',
                  subtitle: 'Update your biography and description',
                  onTap: () => _showBioDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Account Settings Section
            _buildSection(
              title: 'Account Settings',
              children: [
                _buildSettingsItem(
                  icon: Icons.email,
                  title: 'Email & Password',
                  subtitle: 'Change your email and password',
                  onTap: () => _showEmailPasswordDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.phone,
                  title: 'Phone Number',
                  subtitle: 'Update your phone number',
                  onTap: () => _showPhoneDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.location_on,
                  title: 'Location',
                  subtitle: 'Update your location',
                  onTap: () => _showLocationDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.business,
                  title: 'Business Account',
                  subtitle: authController.currentUser.value?.accountType == 1
                      ? 'Manage your business account'
                      : 'Upgrade to business account',
                  onTap: () => _showBusinessAccountDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Privacy & Security Section
            _buildSection(
              title: 'Privacy & Security',
              children: [
                _buildSettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Settings',
                  subtitle: 'Control your privacy preferences',
                  onTap: () => _showPrivacyDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.security,
                  title: 'Security',
                  subtitle: 'Manage your security settings',
                  onTap: () => _showSecurityDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Configure notification preferences',
                  onTap: () => _showNotificationsDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.block,
                  title: 'Blocked Users',
                  subtitle: 'Manage blocked users',
                  onTap: () => _showBlockedUsersDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // App Settings Section
            _buildSection(
              title: 'App Settings',
              children: [
                _buildSettingsItem(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'Change app language',
                  onTap: () => _showLanguageDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.palette,
                  title: 'Theme',
                  subtitle: 'Change app theme',
                  onTap: () => _showThemeDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.storage,
                  title: 'Storage',
                  subtitle: 'Manage app storage',
                  onTap: () => _showStorageDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.update,
                  title: 'App Updates',
                  subtitle: 'Check for app updates',
                  onTap: () => _showUpdatesDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Support Section
            _buildSection(
              title: 'Support',
              children: [
                _buildSettingsItem(
                  icon: Icons.help,
                  title: 'Help Center',
                  subtitle: 'Get help and support',
                  onTap: () => _showHelpDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  subtitle: 'Share your feedback with us',
                  onTap: () => _showFeedbackDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.info,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () => _showAboutDialog(),
                ),
                _buildSettingsItem(
                  icon: Icons.contact_support,
                  title: 'Contact Us',
                  subtitle: 'Get in touch with our team',
                  onTap: () => _showContactDialog(),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Danger Zone
            _buildSection(
              title: 'Danger Zone',
              children: [
                _buildSettingsItem(
                  icon: Icons.delete_forever,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  onTap: () => _showDeleteAccountDialog(),
                  isDestructive: true,
                ),
                _buildSettingsItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  onTap: () => _showSignOutDialog(authController),
                  isDestructive: true,
                ),
              ],
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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
        ...children,
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
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
            color: isDestructive
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
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

  // Dialog Methods
  void _showPersonalInfoDialog() {
    _showComingSoonDialog('Personal Information');
  }

  void _showProfilePhotoDialog() {
    _showComingSoonDialog('Profile Photo');
  }

  void _showCoverPhotoDialog() {
    _showComingSoonDialog('Cover Photo');
  }

  void _showBioDialog() {
    _showComingSoonDialog('Bio & Description');
  }

  void _showEmailPasswordDialog() {
    _showComingSoonDialog('Email & Password');
  }

  void _showPhoneDialog() {
    _showComingSoonDialog('Phone Number');
  }

  void _showLocationDialog() {
    _showComingSoonDialog('Location');
  }

  void _showBusinessAccountDialog() {
    _showComingSoonDialog('Business Account');
  }

  void _showPrivacyDialog() {
    _showComingSoonDialog('Privacy Settings');
  }

  void _showSecurityDialog() {
    _showComingSoonDialog('Security');
  }

  void _showNotificationsDialog() {
    _showComingSoonDialog('Notifications');
  }

  void _showBlockedUsersDialog() {
    _showComingSoonDialog('Blocked Users');
  }

  void _showLanguageDialog() {
    _showComingSoonDialog('Language');
  }

  void _showThemeDialog() {
    _showComingSoonDialog('Theme');
  }

  void _showStorageDialog() {
    _showComingSoonDialog('Storage');
  }

  void _showUpdatesDialog() {
    _showComingSoonDialog('App Updates');
  }

  void _showHelpDialog() {
    _showComingSoonDialog('Help Center');
  }

  void _showFeedbackDialog() {
    _showComingSoonDialog('Send Feedback');
  }

  void _showAboutDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('App Name: iStoreTo'),
              SizedBox(height: 8),
              Text('Version: 1.0.0'),
              SizedBox(height: 8),
              Text('Build: 2024.01.01'),
              SizedBox(height: 8),
              Text('Developer: iStoreTo Team'),
            ],
          ),
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

  void _showContactDialog() {
    _showComingSoonDialog('Contact Us');
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showComingSoonDialog('Delete Account');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(AuthController authController) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authController.signOut();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    Get.snackbar(
      feature,
      '$feature feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
      duration: Duration(seconds: 2),
    );
  }
}
