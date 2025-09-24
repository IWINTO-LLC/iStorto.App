import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/view/policy_webview_page.dart';
import 'package:istoreto/featured/shop/controller/policy_controller.dart';
import 'package:istoreto/featured/shop/view/policy_page.dart';
import 'package:istoreto/featured/product/cashed_network_image_free.dart';
import 'package:readmore/readmore.dart';

import 'package:sizer/sizer.dart';

import 'package:istoreto/utils/common/styles/styles.dart';
import 'package:istoreto/utils/common/widgets/appbar/custom_app_bar.dart';
import 'package:istoreto/utils/common/widgets/buttons/customFloatingButton.dart';
import 'package:istoreto/utils/common/widgets/custom_widgets.dart';
import 'package:istoreto/utils/loader/loader_widget.dart';

class PolicyDisplayPage extends StatelessWidget {
  final String vendorId;

  PolicyDisplayPage({required this.vendorId});

  // دالة لفتح الرابط في WebView
  void _openWebView(BuildContext context, String url, String title) {
    if (url.trim().isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PolicyWebViewPage(url: url.trim(), title: title),
      ),
    );
  }

  // دالة لبناء عرض السياسة مع الرابط
  Widget _buildPolicyWithLink(
    BuildContext context,
    String title,
    String content,
    String link,
    bool isCustom,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titilliumBold.copyWith(fontSize: isCustom ? 16 : 18),
        ),
        SizedBox(height: 10),
        if (content.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(16),

            // decoration: BoxDecoration(
            //   color: Colors.grey[50],
            //   borderRadius: BorderRadius.circular(8),
            //   border: Border.all(color: Colors.grey[300]!),
            // ),
            child: ReadMoreText(
              content,
              trimLines: 3,
              colorClickableText: Colors.blue,
              textAlign: TextAlign.justify,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'readMore'.tr,
              trimExpandedText: 'showLess'.tr,
              style: titilliumRegular.copyWith(fontSize: 14),
              moreStyle: titilliumBold.copyWith(
                fontSize: 14,
                color: Colors.blue,
              ),
              lessStyle: titilliumBold.copyWith(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ),
          if (link.isNotEmpty) SizedBox(height: 16),
        ],
        if (link.isNotEmpty) ...[
          InkWell(
            onTap: () => _openWebView(context, link, title),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   isArabicLocale() ? "عرض السياسة على الويب" : "View Policy on Web",
                        //   style: titilliumBold.copyWith(
                        //     fontSize: 14,
                        //     color: Colors.blue[700],
                        //   ),
                        // ),
                        // SizedBox(height: 4),
                        Text(
                          link,
                          style: titilliumRegular.copyWith(
                            fontSize: 12,
                            color: Colors.blue[600],
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final policyController = Get.put(PolicyController());

    return Scaffold(
      appBar: CustomAppBar(title: "store_settings_store_policies".tr),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: policyController.getPolicyData(vendorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: TLoaderWidget());
            }
            if (!snapshot.hasData) {
              return Center(
                child: Image.asset(
                  'assets/images/liquid_loading.gif',
                  width: 50.w,
                  height: 50.w,
                ),
              );
            }

            var data = snapshot.data ?? {};

            // استخراج البيانات مع التحقق من عدم الفراغ
            String aboutUs = data['about_us']?.toString().trim() ?? '';
            String privacy = data['privacy']?.toString().trim() ?? '';
            String returnPolicy =
                data['return_policy']?.toString().trim() ?? '';
            String terms = data['terms']?.toString().trim() ?? '';

            // استخراج الحقول الجديدة مع فحص وجودها أولاً
            String certificate = '';
            String license = '';
            if (data.containsKey('certificate')) {
              certificate = data['certificate']?.toString().trim() ?? '';
            }
            if (data.containsKey('license')) {
              license = data['license']?.toString().trim() ?? '';
            }

            // استخراج الروابط
            String aboutUsLink = data['about_us_link']?.toString().trim() ?? '';
            String privacyLink = data['privacy_link']?.toString().trim() ?? '';
            String returnPolicyLink =
                data['return_policy_link']?.toString().trim() ?? '';
            String termsLink = data['terms_link']?.toString().trim() ?? '';

            // استخراج الروابط الجديدة مع فحص وجودها أولاً
            String certificateLink = '';
            String licenseLink = '';
            if (data.containsKey('certificate_link')) {
              certificateLink =
                  data['certificate_link']?.toString().trim() ?? '';
            }
            if (data.containsKey('license_link')) {
              licenseLink = data['license_link']?.toString().trim() ?? '';
            }

            // استخراج الصور وملفات PDF مع فحص وجودها أولاً
            List<String> certificateImages = [];
            String certificatePDF = '';
            List<String> licenseImages = [];
            String licensePDF = '';

            if (data.containsKey('certificate_pdf')) {
              certificatePDF = data['certificate_pdf']?.toString().trim() ?? '';
            }
            if (data.containsKey('license_pdf')) {
              licensePDF = data['license_pdf']?.toString().trim() ?? '';
            }

            if (data.containsKey('certificate_images') &&
                data['certificate_images'] != null) {
              certificateImages = List<String>.from(data['certificate_images']);
            }
            if (data.containsKey('license_images') &&
                data['license_images'] != null) {
              licenseImages = List<String>.from(data['license_images']);
            }

            // التحقق من وجود سياسات مخصصة غير فارغة
            List<Map<String, dynamic>> customPolicies = [];
            if (data['custom_policies'] != null) {
              var policiesList = data['custom_policies'] as List;
              customPolicies =
                  policiesList
                      .where((policy) {
                        final title = policy['title']?.toString().trim() ?? '';
                        final content =
                            policy['content']?.toString().trim() ?? '';
                        final link = policy['link']?.toString().trim() ?? '';
                        return title.isNotEmpty &&
                            (content.isNotEmpty || link.isNotEmpty);
                      })
                      .map((policy) => policy as Map<String, dynamic>)
                      .toList();
            }

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Directionality(
                      textDirection:
                          Get.locale?.languageCode == 'ar'
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // السياسات الأساسية - فقط إذا كان هناك محتوى أو رابط
                          // if (aboutUs.isNotEmpty || aboutUsLink.isNotEmpty ||
                          //     privacy.isNotEmpty || privacyLink.isNotEmpty ||
                          //     returnPolicy.isNotEmpty || returnPolicyLink.isNotEmpty ||
                          //     terms.isNotEmpty || termsLink.isNotEmpty) ...[
                          //   Text(
                          //     isArabicLocale() ? "السياسات الأساسية" : "Basic Policies",
                          //     style: titilliumBold.copyWith(fontSize: 20, color: Colors.black87),
                          //   ),
                          //   SizedBox(height: 20),
                          // ],

                          // من نحن - فقط إذا كان هناك محتوى أو رابط
                          if (aboutUs.isNotEmpty || aboutUsLink.isNotEmpty) ...[
                            _buildPolicyWithLink(
                              context,
                              Get.locale?.languageCode == 'ar'
                                  ? "📜من نحن:"
                                  : "📜About Us:",
                              aboutUs,
                              aboutUsLink,
                              false,
                            ),
                            SizedBox(height: 20),
                            TCustomWidgets.buildDivider(),
                            SizedBox(height: 20),
                          ],

                          // سياسة الخصوصية - فقط إذا كان هناك محتوى أو رابط
                          if (privacy.isNotEmpty || privacyLink.isNotEmpty) ...[
                            _buildPolicyWithLink(
                              context,
                              Get.locale?.languageCode == 'ar'
                                  ? "🔒سياسة الخصوصية:"
                                  : "🔒Privacy Policy:",
                              privacy,
                              privacyLink,
                              false,
                            ),
                            SizedBox(height: 10),
                            TCustomWidgets.buildDivider(),
                            SizedBox(height: 10),
                          ],

                          // سياسة الإرجاع - فقط إذا كان هناك محتوى أو رابط
                          if (returnPolicy.isNotEmpty ||
                              returnPolicyLink.isNotEmpty) ...[
                            _buildPolicyWithLink(
                              context,
                              Get.locale?.languageCode == 'ar'
                                  ? "🔄سياسة الإرجاع:"
                                  : "🔄Return Policy:",
                              returnPolicy,
                              returnPolicyLink,
                              false,
                            ),
                            SizedBox(height: 10),
                            TCustomWidgets.buildDivider(),
                            SizedBox(height: 10),
                          ],

                          // الشروط والأحكام - فقط إذا كان هناك محتوى أو رابط
                          if (terms.isNotEmpty || termsLink.isNotEmpty) ...[
                            _buildPolicyWithLink(
                              context,
                              Get.locale?.languageCode == 'ar'
                                  ? "📜الشروط والبنود:"
                                  : "📜Terms & Conditions:",
                              terms,
                              termsLink,
                              false,
                            ),
                            SizedBox(height: 20),
                            TCustomWidgets.buildDivider(),
                            SizedBox(height: 20),
                          ],

                          // الشهادات - فقط إذا كان هناك محتوى أو رابط أو صور أو PDF
                          if (certificate.isNotEmpty ||
                              certificateLink.isNotEmpty ||
                              certificateImages.isNotEmpty ||
                              certificatePDF.isNotEmpty) ...[
                            _buildPolicyWithImagesAndPDF(
                              context,
                              Get.locale?.languageCode == 'ar'
                                  ? "🏆الشهادات:"
                                  : "🏆Certificates:",
                              certificate,
                              certificateLink,
                              certificateImages,
                              certificatePDF,
                              false,
                            ),
                            SizedBox(height: 20),
                            TCustomWidgets.buildDivider(),
                            SizedBox(height: 20),
                          ],

                          // التراخيص - فقط إذا كان هناك محتوى أو رابط أو صور أو PDF
                          if (license.isNotEmpty ||
                              licenseLink.isNotEmpty ||
                              licenseImages.isNotEmpty ||
                              licensePDF.isNotEmpty) ...[
                            _buildPolicyWithImagesAndPDF(
                              context,
                              Get.locale?.languageCode == 'ar'
                                  ? "📋التراخيص:"
                                  : "📋Licenses:",
                              license,
                              licenseLink,
                              licenseImages,
                              licensePDF,
                              false,
                            ),
                            SizedBox(height: 20),
                            TCustomWidgets.buildDivider(),
                            SizedBox(height: 20),
                          ],

                          // السياسات المخصصة - فقط إذا كانت موجودة وغير فارغة
                          if (customPolicies.isNotEmpty) ...[
                            // SizedBox(height: 40),
                            // Text(
                            //   isArabicLocale() ? "السياسات المخصصة" : "Custom Policies",
                            //   style: titilliumBold.copyWith(fontSize: 20, color: Colors.black87),
                            // ),
                            SizedBox(height: 10),

                            ...customPolicies.map((policy) {
                              final title = policy['title'] as String? ?? '';
                              final content =
                                  policy['content'] as String? ?? '';
                              final link = policy['link'] as String? ?? '';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPolicyWithLink(
                                    context,
                                    title,
                                    content,
                                    link,
                                    true,
                                  ),
                                  SizedBox(height: 20),
                                  TCustomWidgets.buildDivider(),
                                  SizedBox(height: 20),
                                ],
                              );
                            }).toList(),
                          ],

                          // رسالة إذا لم تكن هناك سياسات
                          if (aboutUs.isEmpty &&
                              aboutUsLink.isEmpty &&
                              privacy.isEmpty &&
                              privacyLink.isEmpty &&
                              returnPolicy.isEmpty &&
                              returnPolicyLink.isEmpty &&
                              terms.isEmpty &&
                              termsLink.isEmpty &&
                              certificate.isEmpty &&
                              certificateLink.isEmpty &&
                              certificateImages.isEmpty &&
                              certificatePDF.isEmpty &&
                              license.isEmpty &&
                              licenseLink.isEmpty &&
                              licenseImages.isEmpty &&
                              licensePDF.isEmpty &&
                              customPolicies.isEmpty) ...[
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.policy_outlined,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    Get.locale?.languageCode == 'ar'
                                        ? "لا توجد سياسات متاحة"
                                        : "No policies available",
                                    style: titilliumRegular.copyWith(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    Get.locale?.languageCode == 'ar'
                                        ? "سيتم عرض السياسات هنا عند إضافتها"
                                        : "Policies will appear here when added",
                                    style: titilliumRegular.copyWith(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: true, // TODO: Check if user is vendor
                    child: Positioned(
                      bottom: 0,
                      left: Get.locale?.languageCode == 'ar' ? 16 : null,
                      right: Get.locale?.languageCode == 'ar' ? null : 16,
                      child: CustomFloatActionButton(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PolicyPage(vendorId: vendorId),
                              ),
                            ),
                        icon: Icons.edit,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // دالة لبناء عرض السياسة مع الصور وملفات PDF
  Widget _buildPolicyWithImagesAndPDF(
    BuildContext context,
    String title,
    String content,
    String link,
    List<String> images,
    String pdfFile,
    bool isCustom,
  ) {
    // التحقق من وجود أي محتوى للعرض
    bool hasContent =
        content.isNotEmpty ||
        link.isNotEmpty ||
        images.isNotEmpty ||
        pdfFile.isNotEmpty;

    // إذا لم يكن هناك أي محتوى، لا نعرض أي شيء
    if (!hasContent) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titilliumBold.copyWith(fontSize: isCustom ? 16 : 18),
        ),
        SizedBox(height: 10),

        if (content.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(16),
            child: ReadMoreText(
              content,
              trimLines: 3,
              colorClickableText: Colors.blue,
              textAlign: TextAlign.justify,
              trimMode: TrimMode.Line,
              trimCollapsedText:
                  Get.locale?.languageCode == 'ar'
                      ? '... اقرأ المزيد'
                      : '... Read more',
              trimExpandedText:
                  Get.locale?.languageCode == 'ar' ? ' اظهر أقل' : ' Show less',
              style: titilliumRegular.copyWith(fontSize: 14),
              moreStyle: titilliumBold.copyWith(
                fontSize: 14,
                color: Colors.blue,
              ),
              lessStyle: titilliumBold.copyWith(
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
          ),
          if (link.isNotEmpty || images.isNotEmpty || pdfFile.isNotEmpty)
            SizedBox(height: 16),
        ],

        // عرض الصور
        if (images.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_library, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      Get.locale?.languageCode == 'ar'
                          ? "الصور المرفقة"
                          : "Attached Images",
                      style: titilliumBold.copyWith(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                    Spacer(),
                    Text(
                      "${images.length} ${Get.locale?.languageCode == 'ar' ? "صورة" : "image${images.length > 1 ? 's' : ''}"}",
                      style: titilliumRegular.copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _openImageGallery(context, images, index),
                        child: Container(
                          width: 110,
                          margin: EdgeInsets.only(
                            right: index < images.length - 1 ? 8 : 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: FreeCaChedNetworkImage(
                            url: images[index],
                            fit: BoxFit.fitWidth,
                            raduis: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],

        // عرض ملف PDF
        if (pdfFile.isNotEmpty) ...[
          InkWell(
            onTap: () => _openPDF(context, pdfFile, title),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, size: 24, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Get.locale?.languageCode == 'ar'
                              ? "ملف PDF مرفق"
                              : "Attached PDF File",
                          style: titilliumBold.copyWith(
                            fontSize: 14,
                            color: Colors.red[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          pdfFile.split('/').last,
                          style: titilliumRegular.copyWith(
                            fontSize: 12,
                            color: Colors.red[600],
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 16, color: Colors.red),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
        ],

        // عرض الرابط
        if (link.isNotEmpty) ...[
          InkWell(
            onTap: () => _openWebView(context, link, title),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.link, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          link,
                          style: titilliumRegular.copyWith(
                            fontSize: 12,
                            color: Colors.blue[600],
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // دالة لفتح معرض الصور
  void _openImageGallery(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) =>
                ImageGalleryPage(images: images, initialIndex: initialIndex),
      ),
    );
  }

  // دالة لفتح ملف PDF
  void _openPDF(BuildContext context, String pdfUrl, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PDFViewerPage(pdfUrl: pdfUrl, title: title),
      ),
    );
  }
}

// صفحة معرض الصور
class ImageGalleryPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  ImageGalleryPage({required this.images, required this.initialIndex});

  @override
  _ImageGalleryPageState createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "${_currentIndex + 1} / ${widget.images.length}",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (widget.images.length > 1) ...[
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                if (_currentIndex > 0) {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed: () {
                if (_currentIndex < widget.images.length - 1) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            return Center(
              child: InteractiveViewer(
                child: FreeCaChedNetworkImage(
                  url: widget.images[index],
                  fit: BoxFit.contain,
                  raduis: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// صفحة عرض PDF
class PDFViewerPage extends StatelessWidget {
  final String pdfUrl;
  final String title;

  PDFViewerPage({required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  Get.locale?.languageCode == 'ar' ? "ملف PDF" : "PDF File",
                  style: titilliumBold.copyWith(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  pdfUrl.split('/').last,
                  style: titilliumRegular.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // هنا يمكن إضافة منطق فتح PDF في WebView أو تطبيق خارجي
                    // يمكن استخدام url_launcher لفتح الملف في تطبيق PDF
                  },
                  icon: Icon(Icons.open_in_new),
                  label: Text(
                    Get.locale?.languageCode == 'ar'
                        ? "فتح الملف"
                        : "Open File",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
