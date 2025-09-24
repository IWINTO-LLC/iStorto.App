import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:istoreto/featured/sector/model/sector_model.dart';

const String appName = 'iStoreto';
String mediaPath = 'https://iwinto.cloud/uploads/';
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
var initialSector = [
  SectorModel(name: 'offers', englishName: 'Offers', vendorId: ''),
  SectorModel(name: 'all', englishName: 'Product', vendorId: ''),
  SectorModel(name: 'all1', englishName: 'Product A', vendorId: ''),
  SectorModel(name: 'all2', englishName: 'Product B', vendorId: ''),
  SectorModel(name: 'all3', englishName: 'Product C', vendorId: ''),
  SectorModel(name: 'sales', englishName: 'Sales', vendorId: ''),
  SectorModel(name: 'foryou', englishName: 'foryou', vendorId: ''),
  SectorModel(name: 'newArrival', englishName: 'New Arrival', vendorId: ''),
  SectorModel(name: 'mixlin1', englishName: 'جرب هذا', vendorId: ''),
  SectorModel(name: 'mixone', englishName: 'Mix Item', vendorId: ''),
  SectorModel(name: 'mixlin2', englishName: 'Voutures', vendorId: ''),
  //mixlin1
];
// var initialSector = [
//   SectorModel(name: 'offers', englishName: 'Offers'),
//   SectorModel(name: 'all', englishName: 'Product'),
//   SectorModel(name: 'all1', englishName: 'Product A'),
//   SectorModel(name: 'all2', englishName: 'Product B',),
//   SectorModel(name: 'all3', englishName: 'Product C'),
//   SectorModel(name: 'sales', englishName: 'Sales'),
//   SectorModel(name: 'foryou', englishName: 'foryou'),
//   SectorModel(
//       name: 'newArrival',
//       englishName: 'New Arrival'),
//   SectorModel(name: 'mixlin1', englishName: 'جرب هذا'),
//   SectorModel(
//       name: 'mixone', englishName: 'Mix Item'),
//   SectorModel(
//       name: 'mixlin2', englishName: 'Voutures'),
//   //mixlin1
// ];

/// قائمة اللغات المدعومة في المتجر (استخدمها عند بناء Maps للمنتج أو في أي مكان آخر)
