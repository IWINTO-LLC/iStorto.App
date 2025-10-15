import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';

const String appName = 'iStorto';
//String mediaPath = 'https://iwinto.cloud/uploads/';
const String supabaseUrl = 'https://jfveosdooutphhjyvcis.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmdmVvc2Rvb3V0cGhoanl2Y2lzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxOTQyOTMsImV4cCI6MjA3Mzc3MDI5M30.GFx5obizbjERtgoqt_iBvHZAH0qgUmWABLwK-YoXg5E';

const String googleTranslateApiKey =
    'AIzaSyAy7BhTXaRPmrRh5icYY-cUPX3p9sioo-Y'; // ضع مفتاحك هنا
const cardBackgroundColor = Color(0xFF21222D);
const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFFFFFFFF);
const backgroundColor = Color(0xFF15131C);
const seleccionColor = Color.fromARGB(255, 137, 165, 221);
var arabicFonts = GoogleFonts.tajawal().fontFamily;
const englishFonts = 'Tajawal-Medium';
const numberFonts = 'Poppins';
const defaultPadding = 20.0;
const productSharelink = "https://iwinto.com/product/";
const storeSharelink = "https://iwinto.com/Shop/";
var cartRadius = BorderRadius.circular(50);

// ============================================
// الأقسام الافتراضية (Fallback فقط)
// ============================================
// ⚠️ ملاحظة: هذه القائمة تُستخدم فقط كـ Fallback في حالة:
//   1. فشل الاتصال بقاعدة البيانات
//   2. التاجر ليس لديه أقسام بعد
//   3. حدوث خطأ أثناء تحميل الأقسام
//
// ✅ الاستخدام الطبيعي: الأقسام تُحمّل من جدول vendor_sections
// ✅ محدّثة لتطابق البنية الديناميكية الجديدة (17 حقل)
// ============================================
var initialSector = [
  // 1. العروض - Offers
  SectorModel(
    name: 'offers',
    englishName: 'Offers',
    arabicName: 'العروض',
    vendorId: '',
    displayType: 'grid',
    itemsPerRow: 4,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 1,
  ),

  // 2. وصل حديثاً - Just Arrived
  SectorModel(
    name: 'all',
    englishName: 'Just Arrived',
    arabicName: 'وصل حديثًا',
    vendorId: '',
    displayType: 'grid',
    itemsPerRow: 3,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 2,
  ),

  // 3. عروض لا تُفوّت - Unmissable Deals
  SectorModel(
    name: 'sales',
    englishName: 'Unmissable Deals',
    arabicName: 'عروض لا تُفوّت',
    vendorId: '',
    displayType: 'slider',
    itemsPerRow: 1,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 3,
  ),

  // 4. مختاراتنا لك - Handpicked for You
  SectorModel(
    name: 'newArrival',
    englishName: 'Handpicked for You',
    arabicName: 'مختاراتنا لك',
    vendorId: '',
    displayType: 'grid',
    itemsPerRow: 3,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 4,
  ),

  // 5. حصرياً لدينا - Exclusive to Us
  SectorModel(
    name: 'featured',
    englishName: 'Exclusive to Us',
    arabicName: 'حصريًا لدينا',
    vendorId: '',
    displayType: 'grid',
    itemsPerRow: 3,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 5,
  ),

  // 6. الأناقة اليومية - Everyday Elegance
  SectorModel(
    name: 'foryou',
    englishName: 'Everyday Elegance',
    arabicName: 'الأناقة اليومية',
    vendorId: '',
    displayType: 'grid',
    itemsPerRow: 4,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 6,
  ),

  // 7. هدايا مميزة - Unique Gift Ideas
  SectorModel(
    name: 'mixlin1',
    englishName: 'Unique Gift Ideas',
    arabicName: 'هدايا مميزة',
    vendorId: '',
    displayType: 'custom',
    itemsPerRow: 2,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 7,
  ),

  // 8. منتجات تحت الطلب - Made to Order
  SectorModel(
    name: 'mixone',
    englishName: 'Made to Order',
    arabicName: 'منتجات تحت الطلب',
    vendorId: '',
    displayType: 'slider',
    itemsPerRow: 1,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 8,
  ),

  // 9. تخفيضات نهاية الموسم - End-of-Season Sale
  SectorModel(
    name: 'mixlin2',
    englishName: 'End-of-Season Sale',
    arabicName: 'تخفيضات نهاية الموسم',
    vendorId: '',
    displayType: 'grid',
    itemsPerRow: 3,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 9,
  ),

  // 10. لمسة فخامة - A Touch of Luxury
  SectorModel(
    name: 'all1',
    englishName: 'A Touch of Luxury',
    arabicName: 'لمسة فخامة',
    vendorId: '',
    displayType: 'grid',
    itemsPerRow: 3,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 10,
  ),

  // 11. لا تفوّت الفرصة - Don't Miss Out
  SectorModel(
    name: 'all2',
    englishName: 'Don\'t Miss Out',
    arabicName: 'لا تفوّت الفرصة',
    vendorId: '',
    displayType: 'grid',
    itemsPerRow: 3,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 11,
  ),

  // 12. الأفضل لك - Your Perfect Match
  SectorModel(
    name: 'all3',
    englishName: 'Your Perfect Match',
    arabicName: 'الأفضل لك',
    vendorId: '',
    displayType: 'grid',
    itemsPerRow: 3,
    isActive: true,
    isVisibleToCustomers: true,
    sortOrder: 12,
  ),
];

/// قائمة اللغات المدعومة في المتجر (استخدمها عند بناء Maps للمنتج أو في أي مكان آخر)
