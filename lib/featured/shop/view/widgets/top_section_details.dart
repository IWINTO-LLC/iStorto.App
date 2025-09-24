// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:sizer/sizer.dart';
//
// import 'package:istoreto/core/constants/text_styles.dart';
// import 'package:istoreto/featured/admin/data/utils/available_clippers.dart';
// import 'package:istoreto/featured/admin/presentation/widgets/profile/profile_image.dart';
//
// import 'package:istoreto/featured/social/presentation/widgets/posts/network/display/display_image_full.dart';

// class TopSectionDetails extends StatelessWidget {
//   const TopSectionDetails({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     var localizations = AppLocalizations.of(context);
//     var user = VendorController.instance.profilData;
//     return Column(
//       children: [
//         Stack(alignment: Alignment.topCenter, children: [
//           Container(
//             width: 100.w,
//             height: 70.h,
//             color: Colors.white,
//           ),
//           if (user.bannerImage != 'loading')
//             user.bannerImage == ''
//                 ? ClipPath(
//                     clipper: getSelectedClipper(userMap['clipper'] ?? ''),
//                     child: Container(
//                       width: 100.w,
//                       height: 60.h,
//                       color: Colors.grey,
//                     ),
//                   )
//                 : ClipPath(
//                     clipper: getSelectedClipper(userMap['clipper'] ?? ''),
//                     child: Container(
//                       width: 100.w,
//                       height: 60.h,
//                       color: Colors.white,
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       NetworkImageContainerFullSize(
//                                           userMap!['bannerImage'] ?? '')));
//                         },
//                         child: ShaderMask(
//                           shaderCallback: (bounds) {
//                             return (userMap!['applyBannerShader'] ?? false)
//                                 ? LinearGradient(
//                                     begin: Alignment
//                                         .bottomCenter, // Start fade at bottom
//                                     end: Alignment.topCenter, // Fade upward
//                                     colors: [
//                                       Colors
//                                           .transparent, // Fully transparent at bottom
//                                       Colors.white.withOpacity(
//                                           0.6), // Light fade in the middle
//                                       Colors.white, // Fully visible at top
//                                     ],
//                                     stops: const [
//                                       0,
//                                       0.2,
//                                       0.5
//                                     ], // Control smoothness of fade
//                                   ).createShader(bounds)
//                                 : const LinearGradient(
//                                     colors: [
//                                       Colors.white,
//                                       Colors.white,
//                                     ],
//                                   ).createShader(bounds);
//                           },
//                           blendMode: BlendMode.dstIn,
//                           child: CachedNetworkImage(
//                             imageUrl: user.bannerImage,
//                             imageBuilder: (context, imageProvider) => Container(
//                               decoration: BoxDecoration(
//                                 image: DecorationImage(
//                                   image: imageProvider,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             placeholder: (context, url) => Shimmer.fromColors(
//                               baseColor: Colors.grey[400]!,
//                               highlightColor: Colors.grey[350]!,
//                               child: Container(
//                                 width: 100.w,
//                                 height: 60.h,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             errorWidget: (context, url, error) => Container(
//                               width: 100.w,
//                               height: 60.h,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//           if (user.bannerImage == 'loading')
//             ClipPath(
//               clipper: getSelectedClipper(userMap['clipper'] ?? ''),
//               child: Container(
//                 width: 100.w,
//                 height: 60.h,
//                 color: Colors.grey,
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.grey[400]!,
//                   highlightColor: Colors.grey[350]!,
//                   child: Container(
//                     width: 100.w,
//                     height: 60.h,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//           Positioned(
//             bottom: 0,
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                             NetworkImageContainerFullSize(user.profileImage)));
//               },
//               child: UserProfileImageWidget(
//                 imgUrl: user.profileImage,
//                 size: 150,
//                 withShadow: true,
//                 allowChange: false,
//               ),
//             ),
//           ),
//         ]),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(
//               height: 6,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if ((userMap['isVerified'] ?? false) == true)
//                   SvgPicture.asset(
//                     'assets/icons/verified.svg',
//                     width: 23,
//                     height: 22,
//                     color: primary,
//                   ),
//                 if ((userMap['isVerified'] ?? false) == true)
//                   const SizedBox(
//                     width: 6,
//                   ),
//                 if (user.isOrganization == true)
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => ViewTemplate1(
//                                     userId: userId,
//                                     map: userMap!,
//                                   )));
//                     },
//                     child: Container(
//                       color: Colors.transparent,
//                       child: const Icon(
//                         Icons.storefront,
//                         size: 25,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(
//               height: 3,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   user.organizationName,
//                   style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black,
//                       fontFamily: 'Nunito Sans'),
//                 ),
//               ],
//             ),
//             if (userMap['profession'] != null && userMap['profession'] != '')
//               Text(
//                 userMap['profession'],
//                 style: const TextStyle(
//                     fontSize: 13,
//                     color: Colors.black,
//                     fontFamily: 'Nunito Sans'),
//               ),
//             if (userMap['showStats'] ?? true)
//               Container(
//                 margin: const EdgeInsets.only(top: 12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 25.w,
//                       child: Column(
//                         children: [
//                           Text(
//                             userMap['posts'].toString(),
//                             style: headline3,
//                           ),
//                           Text(
//                             localizations
//                                 .translate('user_profile_top_section.posts'),
//                             style: bodyText2,
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       width: 25.w,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             userMap['likes'].toString(),
//                             style: headline3,
//                           ),
//                           Text(
//                             localizations
//                                 .translate('user_profile_top_section.likes'),
//                             style: bodyText2,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Tooltip(
//                       message: localizations
//                           .translate('user_profile_top_section.total_donations')
//                           .replaceFirst('{name}', userMap['name']),
//                       child: SizedBox(
//                         width: 25.w,
//                         child: Column(
//                           children: [
//                             Text(
//                               abbreviateValue(userMap['supports'] *
//                                   ref
//                                       .read(winicoinsUsdRateProvider.notifier)
//                                       .state),
//                               style: headline3,
//                             ),
//                             Text(
//                               localizations.translate(
//                                   'user_profile_top_section.donates'),
//                               style: bodyText2,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             if (userMap['bio'] != '')
//               Column(
//                 children: [
//                   SizedBox(
//                     height: (userMap['showStats'] ?? true) ? 16 : 12,
//                   ),
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 25),
//                     child: Text(
//                       userMap['bio'],
//                       textAlign: TextAlign.center,
//                       textDirection: TextDirection.ltr,
//                       style: bodyText1,
//                     ),
//                   ),
//                 ],
//               ),
//             Column(
//               children: [
//                 const SizedBox(
//                   height: 12,
//                 ),
//                 SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     spacing: 12,
//                     children: [
//                       // address
//                       if ((userMap['address'] ?? '') != '' &&
//                           (userMap['isAddressVisible'] ?? false))
//                         GestureDetector(
//                           onTap: () async {
//                             try {
//                               final url = userMap!['address'].startsWith('http')
//                                   ? userMap['address']
//                                   : 'https://${userMap['address']}';
//                               await launchUrl(Uri.parse(url));
//                             } catch (e) {
//                               log(e.toString());
//                             }
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: SvgPicture.asset(
//                               'assets/svg/pin.svg',
//                               width: 28,
//                               height: 28,
//                             ),
//                           ),
//                         ),
//                       // Website
//                       if ((userMap['website'] ?? '') != '' &&
//                           (userMap['isWebsiteVisible'] ?? false))
//                         GestureDetector(
//                           onTap: () async {
//                             try {
//                               final url = userMap!['website'].startsWith('http')
//                                   ? userMap['website']
//                                   : 'https://${userMap['website']}';
//                               await launchUrl(Uri.parse(url));
//                             } catch (e) {
//                               log(e.toString());
//                             }
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: SvgPicture.asset(
//                               'assets/svg/web.svg',
//                               width: 28,
//                               height: 28,
//                               color: primary,
//                             ),
//                           ),
//                         ),

//                       // Email
//                       if ((userMap['email'] ?? '') != '' &&
//                           (userMap['isEmailActionVisible'] ?? false))
//                         GestureDetector(
//                           onTap: () async {
//                             final Email email = Email(
//                               body: '',
//                               subject: '',
//                               recipients: [userMap!['email']],
//                             );
//                             await FlutterEmailSender.send(email);
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: SvgPicture.asset(
//                               'assets/svg/email.svg',
//                               width: 26,
//                               height: 26,
//                             ),
//                           ),
//                         ),

//                       // Phone
//                       if ((userMap['phone'] ?? '') != '' &&
//                           (userMap['isPhoneActionVisible'] ?? false))
//                         GestureDetector(
//                           onTap: () async {
//                             final url = Uri.parse('tel:${userMap!['phone']}');
//                             if (await canLaunchUrl(url)) {
//                               await launchUrl(url);
//                             } else {
//                               log('Could not launch $url');
//                             }
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: SvgPicture.asset(
//                               'assets/svg/phone.svg',
//                               width: 26,
//                               height: 26,
//                             ),
//                           ),
//                         ),

//                       // LinkedIn
//                       if ((userMap['linkedIn'] ?? '') != '' &&
//                           (userMap['isLinkedInActionVisible'] ?? false))
//                         GestureDetector(
//                           onTap: () async {
//                             final url = userMap!['linkedIn'].startsWith('http')
//                                 ? userMap['linkedIn']
//                                 : 'https://${userMap['linkedIn']}';
//                             await launchUrl(Uri.parse(url));
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: SvgPicture.asset(
//                               'assets/svg/linkedIn.svg',
//                               width: 26,
//                               height: 26,
//                             ),
//                           ),
//                         ),

//                       // YouTube
//                       if ((userMap['youtube'] ?? '') != '' &&
//                           (userMap['isYoutubeActionVisible'] ?? false))
//                         GestureDetector(
//                           onTap: () async {
//                             final url = userMap!['youtube'].startsWith('http')
//                                 ? userMap['youtube']
//                                 : 'https://${userMap['youtube']}';
//                             await launchUrl(Uri.parse(url));
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: SvgPicture.asset(
//                               'assets/svg/youtube.svg',
//                               width: 26,
//                               height: 26,
//                             ),
//                           ),
//                         ),

//                       // Facebook
//                       if ((userMap['facebook'] ?? '') != '' &&
//                           (userMap['isFacebookActionVisible'] ?? false))
//                         GestureDetector(
//                           onTap: () async {
//                             final url = userMap!['facebook'].startsWith('http')
//                                 ? userMap['facebook']
//                                 : 'https://${userMap['facebook']}';
//                             await launchUrl(Uri.parse(url));
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: SvgPicture.asset(
//                               'assets/svg/facebook.svg',
//                               width: 26,
//                               height: 26,
//                             ),
//                           ),
//                         ),

//                       // Instagram
//                       if ((userMap['instagram'] ?? '') != '' &&
//                           (userMap['isInstagramActionVisible'] ?? false))
//                         GestureDetector(
//                           onTap: () async {
//                             final url = userMap!['instagram'].startsWith('http')
//                                 ? userMap['instagram']
//                                 : 'https://${userMap['instagram']}';
//                             await launchUrl(Uri.parse(url));
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: SvgPicture.asset(
//                               'assets/svg/instagram.svg',
//                               width: 26,
//                               height: 26,
//                             ),
//                           ),
//                         ),

//                       // X (Twitter)
//                       if ((userMap['x'] ?? '') != '' &&
//                           (userMap['isXActionVisible'] ?? false))
//                         GestureDetector(
//                           onTap: () async {
//                             final url = userMap!['x'].startsWith('http')
//                                 ? userMap['x']
//                                 : 'https://${userMap['x']}';
//                             await launchUrl(Uri.parse(url));
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: SvgPicture.asset(
//                               'assets/svg/x.svg',
//                               width: 26,
//                               height: 26,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             /* if (!((userMap['phone'] ?? '') != '' &&
//                    (userMap['isPhoneActionVisible'] ?? false)) &&
//                !((userMap['email'] ?? '') != '' &&
//                    (userMap['isEmailActionVisible'] ?? false)))
//              if ((userMap['website'] ?? '') != '' &&
//                  (userMap['isWebsiteVisible'] ?? false))
//                Column(
//                  children: [
//                    const SizedBox(
//                      height: 12,
//                    ),
//                    GestureDetector(
//                      onTap: () async {
//                        try {
//                          final url =
//                              userMap!['website'].startsWith('http')
//                                  ? userMap['website']
//                                  : 'https://${userMap['website']}';
//                          await launchUrl(Uri.parse(url));
//                        } catch (e) {
//                          log(e.toString());
//                        }
//                      },
//                      child: SizedBox(
//                        width: 70.w,
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: [
//                            SvgPicture.asset(
//                              'assets/icons/link.svg',
//                              color: primary,
//                              width: 16,
//                              height: 16,
//                            ),
//                            const SizedBox(
//                              width: 6,
//                            ),
//                            Flexible(
//                              fit: FlexFit.loose,
//                              child: Text(
//                                userMap['website'],
//                                overflow: TextOverflow.ellipsis,
//                                style: bodyText1.copyWith(color: primary),
//                              ),
//                            ),
//                          ],
//                        ),
//                      ),
//                    ),
//                  ],
//                ), */
//             const SizedBox(
//               height: 24,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ((snapshot.connectionState != ConnectionState.waiting))
//                     ? FollowButton(
//                         myId: userId_,
//                         userId: userMap['uid'],
//                         primary: primary,
//                         smallText14White:
//                             bodyText2.copyWith(color: Colors.white),
//                       )
//                     : Container(
//                         width: 40.w,
//                         height: 40,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(15),
//                             color: instaGrey),
//                       ),
//                 GestureDetector(
//                   onTap: () async {
//                     profileShareOptions(userMap!, context, ref);
//                   },
//                   child: Container(
//                     width: 40.w,
//                     height: 40,
//                     decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(15),
//                         color: instaGrey),
//                     child: Center(
//                       child: Text(
//                         localizations.translate(
//                             'user_profile_top_section.share_profile'),
//                         style: bodyText1,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: 10.w,
//                   height: 40,
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       color: instaGrey),
//                   child: PullDownButton(
//                     routeTheme: PullDownMenuRouteTheme(
//                       backgroundColor: primary,
//                     ),
//                     itemBuilder: (context) => [
//                       PullDownMenuItem(
//                         title: localizations.translate(
//                             'user_profile_top_section.send_winicoins'),
//                         itemTheme: PullDownMenuItemTheme(
//                             textStyle: headline3.copyWith(color: Colors.white)),
//                         iconColor: Colors.white,
//                         onTap: () async {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => SendToSelectedUser(
//                                         selectedUserId: userId,
//                                         selectedUserData: null,
//                                       )));
//                         },
//                       ),
//                     ],
//                     buttonBuilder: (context, showMenu) => CupertinoButton(
//                       onPressed: showMenu,
//                       padding: EdgeInsets.zero,
//                       child: const Icon(
//                         CupertinoIcons.ellipsis_vertical,
//                         color: Colors.black,
//                         size: 22,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ],
//     );
//   }
// }
