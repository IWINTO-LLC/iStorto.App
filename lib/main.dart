import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/services/product_currency_service.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/services/deep_link_service.dart';
import 'package:istoreto/services/image_upload_service.dart';
import 'package:istoreto/views/splash_screen.dart';
import 'package:sizer/sizer.dart';
import 'controllers/translation_controller.dart';
import 'controllers/auth_controller.dart';
import 'services/supabase_service.dart';
import 'services/storage_service.dart';
import 'translations/translations.dart';
import 'utils/bindings/general_binding.dart';
import 'routes/app_routes.dart';
import 'utils/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إعداد شريط الحالة ليظهر دائماً في جميع الصفحات
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // إعداد شريط الحالة بشكل عام (شفاف مع أيقونات داكنة)
  // يناسب معظم الصفحات البيضاء في التطبيق
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // شفاف ليظهر خلف المحتوى
      statusBarIconBrightness:
          Brightness.dark, // أيقونات داكنة (للخلفيات الفاتحة)
      statusBarBrightness: Brightness.light, // للـ iOS
      systemNavigationBarColor: Colors.black, // شريط التنقل السفلي أبيض
      systemNavigationBarIconBrightness:
          Brightness.light, // أيقونات التنقل داكنة
    ),
  );

  // Initialize Hive (قبل أي استخدام)
  await Hive.initFlutter();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize Storage Service
  await StorageService.instance.init();

  // Initialize Deep Link Service
  await DeepLinkService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize Controllers
    final translationController = Get.put(TranslationController());
    Get.put(AuthController());

    // Initialize VendorRepository first
    if (!Get.isRegistered<VendorRepository>()) {
      Get.lazyPut(() => VendorRepository());
    }

    // Initialize VendorController only if not already initialized
    if (!Get.isRegistered<VendorController>()) {
      Get.put(VendorController());
    }

    if (!Get.isRegistered<CurrencyController>()) {
      Get.put(CurrencyController());
    }
    if (!Get.isRegistered<ProductCurrencyService>()) {
      Get.put(ProductCurrencyService());
    }
    if (!Get.isRegistered<ImageUploadService>()) {
      Get.lazyPut(() => ImageUploadService());
    }
    // Initialize General Bindings (all other controllers)
    final generalBindings = GeneralBindings();
    generalBindings.dependencies();

    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: 'iStoreto',
          debugShowCheckedModeBanner: false,

          // Localization
          locale: translationController.currentLocale,
          fallbackLocale: const Locale('ar'),
          translations: AppTranslations(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
            Locale('es'),
            Locale('hi'),
            Locale('fr'),
            Locale('ko'),
            Locale('de'),
            Locale('tr'),
            Locale('ru'),
          ],

          // Theme
          theme: TAppTheme.lightTheme,
          darkTheme: TAppTheme.lightTheme,
          themeMode: ThemeMode.system,

          // Routes
          getPages: appRoutes,

          // Home page
          home: const SplashScreen(),
        );
      },
    );
  }
}
