import 'package:flutter/material.dart';
import 'package:istoreto/views/profile/widgets/profile_header_widget.dart';
import 'package:istoreto/views/profile/widgets/profile_content_widget.dart';
import 'package:istoreto/views/profile/widgets/profile_menu_widget.dart';

/// صفحة الملف الشخصي الرئيسية - تجمع جميع مكونات الملف الشخصي
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // رأس الملف الشخصي
              const ProfileHeaderWidget(),

              // محتوى الملف الشخصي
              const ProfileContentWidget(),

              // قائمة الملف الشخصي
              const ProfileMenuWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
