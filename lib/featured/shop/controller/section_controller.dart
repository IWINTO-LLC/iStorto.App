//
// import 'package:get/get.dart';
// import 'package:istoreto/featured/product/controllers/product_controller.dart';
// import 'package:istoreto/featured/shop/data/section_model.dart';
// // استورد النموذج الذي أنشأته

// class SectionsController extends GetxController {
//   RxList<SectionModel> sections = <SectionModel>[].obs;
//   RxBool loadingSection = false.obs;
//   late String vendorId;
//   SectionsController(this.vendorId);
//   @override
//   void onInit() {
//     super.onInit();
//     fetchSections(); // جلب البيانات عند البدء
//   }

//   void fetchSections() async {
//     ProductController.instance.resetDynamicLists(vendorId);
//     loadingSection.value = true;
//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(vendorId)
//         .collection('organization')
//         .doc('1')
//         .collection('sections')
//         .get();
//     sections.value = snapshot.docs
//         .map((doc) => SectionModel.fromMap(doc.data(), doc.id))
//         .toList();
//     loadingSection.value = false;
//     //  var data = snapshot.data as Map<String, dynamic>;

//     //         termsAr.value=data['terms_ar']??'';
//     //         termsEn.value=data['terms_en']??'';
//     //         aboutusAr.value=data['about_us_ar']??'';
//     //         aboutusEn.value=data['about_us_en']??'';
//     //         privacyAr.value=data['privacy_ar']??'';
//     //         privacyEn.value=data['privacy_en']??'';
//     //         returnPolicyAr.value=data['return_policy_ar']??'';
//     //          returnPolicyEn.value=data['return_policy_en']??'';
//     //          loadPolicies(false);
//   }

//   // void addSection(SectionModel section, String vendorId) async {
//   //   final newDoc = FirebaseFirestore.instance
//   //       .collection('users')
//   //       .doc(vendorId)
//   //       .collection('organization')
//   //       .doc('1')
//   //       .collection('sections')
//   //       .add({'name': section.name, 'arabicName': section.arabicName});

//   //   fetchSections(); // تحديث الأقسام بعد الإضافة
//   // }
// }
