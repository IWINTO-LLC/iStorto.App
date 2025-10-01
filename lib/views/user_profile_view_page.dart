import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/view/market_place_view.dart';
import 'package:istoreto/views/profile/widgets/user_profile_header_widget.dart';
import 'package:istoreto/views/profile/widgets/user_profile_content_widget.dart';
import 'package:istoreto/views/profile/widgets/user_profile_actions_widget.dart';
import 'package:istoreto/views/profile/widgets/user_profile_shimmer_widget.dart';
import 'package:istoreto/repositories/user_repository.dart';
import 'package:istoreto/models/user_model.dart';

/// صفحة عرض الملف الشخصي للمستخدم للآخرين - غير قابلة للتعديل
class UserProfileViewPage extends StatefulWidget {
  final String userId;
  final String? userName; // اسم المستخدم للعرض في العنوان

  const UserProfileViewPage({super.key, required this.userId, this.userName});

  @override
  State<UserProfileViewPage> createState() => _UserProfileViewPageState();
}

class _UserProfileViewPageState extends State<UserProfileViewPage> {
  final VendorController _vendorController = Get.find<VendorController>();
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = true;
  bool _isVendor = false;
  String _userDisplayName = '';
  String _userEmail = '';
  String _userProfileImage = '';
  String _userCoverImage = '';
  String _userBio = '';
  String _userBrief = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// تحميل بيانات المستخدم
  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // جلب بيانات المستخدم من قاعدة البيانات
      UserModel? userData;
      try {
        userData = await _userRepository.getUserById(widget.userId);
      } catch (e) {
        print('خطأ في جلب بيانات المستخدم: $e');
      }

      // تحميل بيانات المتجر
      await _vendorController.fetchVendorData(widget.userId);
      final vendorData = _vendorController.vendorData.value;

      // التحقق من وجود بيانات متجر
      if (vendorData.organizationName.isNotEmpty) {
        // المستخدم لديه متجر
        setState(() {
          _isVendor = true;
          _userDisplayName = vendorData.organizationName;
          _userEmail = userData?.email ?? 'مستخدم@example.com';
          _userProfileImage = vendorData.organizationLogo;
          _userCoverImage = vendorData.organizationCover;
          _userBio =
              vendorData.organizationBio.isNotEmpty
                  ? vendorData.organizationBio
                  : 'متجر معتمد في التطبيق';
          _userBrief =
              vendorData.brief.isNotEmpty
                  ? vendorData.brief
                  : 'مرحباً بك في متجرنا';
        });
      } else if (userData != null) {
        // المستخدم عادي بدون متجر
        setState(() {
          _isVendor = userData!.accountType == 1;
          _userDisplayName =
              userData.displayName.isNotEmpty
                  ? userData.displayName
                  : widget.userName ?? 'مستخدم';
          _userEmail = userData.email ?? 'مستخدم@example.com';
          _userProfileImage = userData.profileImage;
          _userCoverImage = '';
          _userBio = 'مستخدم نشط في التطبيق';
          _userBrief = 'مرحباً بك في ملفي الشخصي';
        });
      } else {
        // مستخدم غير موجود أو زائر
        setState(() {
          _isVendor = false;
          _userDisplayName = widget.userName ?? 'مستخدم';
          _userEmail = 'مستخدم@example.com';
          _userProfileImage = '';
          _userCoverImage = '';
          _userBio = 'مستخدم في التطبيق';
          _userBrief = 'مرحباً بك';
        });
      }
    } catch (e) {
      print('خطأ في تحميل بيانات المستخدم: $e');
      // عرض بيانات افتراضية في حالة الخطأ
      setState(() {
        _isVendor = false;
        _userDisplayName = widget.userName ?? 'مستخدم';
        _userEmail = 'مستخدم@example.com';
        _userProfileImage = '';
        _userCoverImage = '';
        _userBio = 'مستخدم في التطبيق';
        _userBrief = 'مرحباً بك';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _userDisplayName.isNotEmpty ? _userDisplayName : 'الملف الشخصي',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // زر المشاركة
          IconButton(
            icon: Icon(Icons.share, color: Colors.grey.shade800),
            onPressed: _shareProfile,
          ),
        ],
      ),
      body:
          _isLoading
              ? UserProfileShimmerWidget()
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // رأس الملف الشخصي
                    UserProfileHeaderWidget(
                      userName: _userDisplayName,
                      userEmail: _userEmail,
                      profileImage: _userProfileImage,
                      coverImage: _userCoverImage,
                      isVendor: _isVendor,
                    ),

                    // محتوى الملف الشخصي
                    UserProfileContentWidget(
                      bio: _userBio,
                      brief: _userBrief,
                      isVendor: _isVendor,
                    ),

                    // أزرار الإجراءات
                    UserProfileActionsWidget(
                      userId: widget.userId,
                      isVendor: _isVendor,
                      onViewStore: _viewStore,
                    ),

                    // مساحة إضافية في الأسفل
                    SizedBox(height: 100),
                  ],
                ),
              ),
    );
  }

  /// عرض المتجر
  void _viewStore() {
    if (_isVendor) {
      Get.to(() => MarketPlaceView(editMode: false, vendorId: widget.userId));
    }
  }

  /// مشاركة الملف الشخصي
  void _shareProfile() {
    // TODO: تنفيذ مشاركة الملف الشخصي
    Get.snackbar(
      'مشاركة',
      'ميزة المشاركة قريباً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
      duration: Duration(seconds: 2),
    );
  }
}
