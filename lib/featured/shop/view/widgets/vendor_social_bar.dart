import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_model.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:istoreto/utils/common/widgets/shimmers/shimmer.dart';
import 'package:istoreto/utils/common/widgets/texts/widgets/bottom_menu_item.dart';

class VendorSocialLinksBar extends StatefulWidget {
  final double iconSize;
  final String vendorId;
  const VendorSocialLinksBar({
    super.key,
    this.iconSize = 28,
    required this.vendorId,
  });

  @override
  State<VendorSocialLinksBar> createState() => _VendorSocialLinksBarState();
}

class _VendorSocialLinksBarState extends State<VendorSocialLinksBar> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = VendorController.instance;
      final profile = controller.vendorData.value;
      final userId = widget.vendorId;
      if (profile.userId != userId || profile == VendorModel.empty()) {
        return TShimmerEffect(width: 180, height: 32);
      }

      final social = profile.socialLink;
      final links = <Map<String, String>>[];

      void addLink(String platform, String url, bool isVisible) {
        if (url.trim().isNotEmpty && isVisible) {
          links.add({'platform': platform, 'url': url});
        }
      }

      addLink('website', social!.website, social!.visibleWebsite);
      addLink('facebook', social.facebook, social.visibleFacebook);
      addLink('instagram', social.instagram, social.visibleInstagram);
      addLink('tiktok', social.tiktok, social.visibleTiktok);
      addLink('whatsapp', social.whatsapp, social.visibleWhatsapp);
      addLink('youtube', social.youtube, social.visibleYoutube);
      addLink('x', social.x, social.visibleX);
      addLink('linkedin', social.linkedin, social.visibleLinkedin);
      addLink('location', social.location, social.location.trim().isNotEmpty);

      final phoneNumbers =
          social.phones.where((p) => p.trim().isNotEmpty).toList();
      if (phoneNumbers.isNotEmpty) {
        links.add({'platform': 'phone', 'url': 'showPhones'});
      }

      if (links.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            key: const ValueKey('links'),
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              height: widget.iconSize + 16,
              child: Center(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: links.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final link = links[index];
                    final platform = link['platform']!;
                    var url = link['url']!;

                    if (platform == 'whatsapp' && !url.startsWith('http')) {
                      final cleaned = url.replaceAll(RegExp(r'[^0-9]'), '');
                      url = 'https://wa.me/cleaned';
                    }

                    return GestureDetector(
                      onTap: () async {
                        if (platform == 'phone') {
                          _showPhoneSelector(context, phoneNumbers);
                        } else if (platform == 'location') {
                          // فتح تطبيق الخرائط الافتراضي
                          final url = link['url']!;
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('لا يمكن فتح الخريطة: $url'),
                              ),
                            );
                          }
                        } else {
                          try {
                            final canLaunch = await canLaunchUrlString(url);
                            if (canLaunch) {
                              await launchUrlString(url);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('لا يمكن فتح الرابط: $url'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('حدث خطأ أثناء فتح الرابط: $e'),
                              ),
                            );
                          }
                        }
                      },
                      child: _getSocialIcon(platform, widget.iconSize),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showPhoneSelector(BuildContext context, List<String> phones) {
    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                ...phones.map(
                  (phone) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BuildBottomMenuItem(
                      icon: const Icon(Icons.phone),
                      leading: IconButton(
                        icon: const Icon(CupertinoIcons.add_circled),
                        tooltip: 'حفظ في جهات الاتصال',
                        onPressed: () {
                          _saveToContacts(context, phone);
                        },
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        launchUrlString('tel:$phone');
                      },
                      text: phone,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _getSocialIcon(String platform, double size) {
    final path = switch (platform.toLowerCase()) {
      'facebook' => FontAwesomeIcons.facebook,
      'instagram' => FontAwesomeIcons.instagram,
      'tiktok' => FontAwesomeIcons.tiktok,
      'whatsapp' => FontAwesomeIcons.whatsapp,
      'youtube' => FontAwesomeIcons.youtube,
      'x' => FontAwesomeIcons.x,
      'linkedin' => FontAwesomeIcons.linkedin,
      'website' => FontAwesomeIcons.webflow,
      'phone' => FontAwesomeIcons.phone,
      'location' => FontAwesomeIcons.locationDot,
      _ => FontAwesomeIcons.locationPin,
    };

    return Icon(path, size: size);
  }

  void _saveToContacts(BuildContext context, String phone) async {
    try {
      await launchUrlString(
        'content://com.android.contacts/contacts?phone=$phone',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إرسال الرقم للحفظ في جهات الاتصال')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('لم يتمكن من الحفظ: $e')));
    }
  }
}
