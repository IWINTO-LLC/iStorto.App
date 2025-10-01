import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:istoreto/featured/currency/controller/currency_controller.dart';
import 'package:istoreto/featured/product/services/product_currency_service.dart';
import 'package:istoreto/featured/shop/controller/vendor_controller.dart';
import 'package:istoreto/featured/shop/data/vendor_repository.dart';
import 'package:istoreto/navigation_menu.dart';
import 'package:istoreto/services/image_upload_service.dart';
import 'package:istoreto/views/splash_screen.dart';
import 'package:istoreto/views/login_page.dart';
import 'package:istoreto/views/register_page.dart';
import 'package:istoreto/views/email_verification_page.dart';
import 'package:sizer/sizer.dart';
import 'controllers/translation_controller.dart';
import 'controllers/auth_controller.dart';
import 'services/supabase_service.dart';
import 'services/storage_service.dart';
import 'translations/translations.dart';
import 'utils/bindings/general_binding.dart';
import 'views/cart_page.dart';
import 'views/favorites_page.dart';
import 'views/orders_page.dart';
import 'views/profile_page.dart';
import 'utils/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Initialize Storage Service
  await StorageService.instance.init();

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
          darkTheme: TAppTheme.darkTheme,
          themeMode: ThemeMode.system,

          // Routes
          getPages: [
            GetPage(name: '/', page: () => const SplashScreen()),
            GetPage(name: '/home', page: () => const NavigationMenu()),
            GetPage(name: '/login', page: () => const LoginPage()),
            GetPage(name: '/register', page: () => const RegisterPage()),
            GetPage(
              name: '/email-verification',
              page: () => const EmailVerificationPage(),
            ),
            GetPage(name: '/favorites', page: () => const FavoritesPage()),
            GetPage(name: '/orders', page: () => const OrdersPage()),
            GetPage(name: '/cart', page: () => const CartPage()),
            GetPage(name: '/profile', page: () => const ProfilePage()),
          ],

          // Home page
          home: const SplashScreen(),
        );
      },
    );
  }
}
