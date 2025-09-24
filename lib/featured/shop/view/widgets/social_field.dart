// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// import 'package:get/get.dart';
// import 'package:istoreto/featured/shop/controller/vendor_controller.dart';

// import 'package:istoreto/featured/shop/data/social-link.dart';

// class SocialLinkEditor extends StatefulWidget {
//   final String platform;
//   final String label;
//   final String hintText;

//   const SocialLinkEditor({
//     super.key,
//     required this.platform,
//     required this.label,
//     this.hintText = '',
//   });

//   @override
//   State<SocialLinkEditor> createState() => _SocialLinkEditorState();
// }

// class _SocialLinkEditorState extends State<SocialLinkEditor> {
//   late TextEditingController textController;
//   late RxBool isVisible;

//   @override
//   void initState() {
//     super.initState();
//     final controller = VendorController.instance;
//     final social = controller.profileData.value.socialLink;

//     final url = _getPlatformUrl(social, widget.platform);
//     final visible = _getPlatformVisible(social, widget.platform);

//     textController = TextEditingController(text: url);
//     isVisible = RxBool(visible);
//   }

//   @override
//   void dispose() {
//     textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = VendorController.instance;

//     return Obx(() {
//       return Row(
//         children: [
//           _getSocialIcon(widget.platform),
//           const SizedBox(width: 12),
//           Expanded(
//             child: TextFormField(
//               controller: textController,
//               decoration: InputDecoration(
//                 hintText: AppLocalizations.of(
//                   context,
//                 ).translate(widget.hintText),
//               ),
//               onChanged: (val) {
//                 _updateSocialLink(
//                   controller,
//                   widget.platform,
//                   val.trim(),
//                   isVisible.value,
//                 );
//               },
//             ),
//           ),
//           Switch(
//             value: isVisible.value,
//             onChanged: (val) {
//               isVisible.value = val;
//               _updateSocialLink(
//                 controller,
//                 widget.platform,
//                 textController.text.trim(),
//                 val,
//               );
//             },
//           ),
//         ],
//       );
//     });
//   }

//   void _updateSocialLink(
//     VendorController controller,
//     String platform,
//     String url,
//     bool visible,
//   ) {
//     final current = controller.profileData.value.socialLink;
//     SocialLink updated = current;

//     switch (platform.toLowerCase()) {
//       case 'facebook':
//         updated = current.copyWith(facebook: url, visibleFacebook: visible);
//         break;
//       case 'instagram':
//         updated = current.copyWith(instagram: url, visibleInstagram: visible);
//         break;
//       case 'website':
//         updated = current.copyWith(website: url, visibleWebsite: visible);
//         break;
//       case 'tiktok':
//         updated = current.copyWith(tiktok: url, visibleTiktok: visible);
//         break;
//       case 'whatsapp':
//         updated = current.copyWith(whatsapp: url, visibleWhatsapp: visible);
//         break;
//       case 'youtube':
//         updated = current.copyWith(youtube: url, visibleYoutube: visible);
//         break;
//       case 'x':
//         updated = current.copyWith(x: url, visibleX: visible);
//         break;
//       case 'linkedin':
//         updated = current.copyWith(linkedin: url, visibleLinkedin: visible);
//         break;
//       default:
//         break;
//     }

//     controller.profileData.value = controller.profileData.value.copyWith(
//       socialLink: updated,
//     );
//   }

//   String _getPlatformUrl(SocialLink link, String platform) {
//     return switch (platform.toLowerCase()) {
//       'facebook' => link.facebook,
//       'instagram' => link.instagram,
//       'website' => link.website,
//       'tiktok' => link.tiktok,
//       'whatsapp' => link.whatsapp,
//       'youtube' => link.youtube,
//       'x' => link.x,
//       'linkedin' => link.linkedin,
//       _ => '',
//     };
//   }

//   bool _getPlatformVisible(SocialLink link, String platform) {
//     return switch (platform.toLowerCase()) {
//       'facebook' => link.visibleFacebook,
//       'instagram' => link.visibleInstagram,
//       'website' => link.visibleWebsite,
//       'tiktok' => link.visibleTiktok,
//       'whatsapp' => link.visibleWhatsapp,
//       'youtube' => link.visibleYoutube,
//       'x' => link.visibleX,
//       'linkedin' => link.visibleLinkedin,
//       _ => true,
//     };
//   }

//   Widget _getSocialIcon(String platform) {
//     final path = switch (platform.toLowerCase()) {
//       'facebook' => 'assets/images/ecommerce/icons/facebook.svg',
//       'instagram' => 'assets/images/ecommerce/icons/insta.svg',
//       'tiktok' => 'assets/images/ecommerce/icons/tiktok.svg',
//       'whatsapp' => 'assets/images/ecommerce/icons/whats.svg',
//       'youtube' => 'assets/images/ecommerce/icons/youtube.svg',
//       'x' => 'assets/images/ecommerce/icons/x.svg',
//       'linkedin' => 'assets/images/ecommerce/icons/linkedin.svg',
//       'website' => 'assets/images/ecommerce/icons/web.svg',
//       'phone' => 'assets/images/ecommerce/icons/phone.svg',
//       _ => 'assets/images/ecommerce/icons/web.svg',
//     };

//     return SvgPicture.asset(path, width: 26, height: 26);
//   }
// }
