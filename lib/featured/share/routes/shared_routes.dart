import 'package:flutter/material.dart';
import 'package:istoreto/featured/share/view/product_loader.dart';
import 'package:istoreto/navigation_menu.dart';

class SharedRoute {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');

    // share product
    if (uri?.pathSegments.contains('product') == true) {
      final productId = uri!.queryParameters['id'] ?? uri.pathSegments.last;
      return MaterialPageRoute(
        builder:
            (_) => SafeArea(child: ProductLoaderPage(productId: productId)),
      );
    }

    // cart share
    // if (uri?.pathSegments.contains('shared_cart') == true) {
    //   final sharedCartId = uri!.queryParameters['id'];
    //   if (sharedCartId != null) {
    //     return MaterialPageRoute(
    //       builder: (_) => SharedCartViewPage(sharedCartId: sharedCartId),
    //     );
    //   }
    // }

    //other routes
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const NavigationMenu());
      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: SafeArea(
                  child: Center(child: Text(" page is not found")),
                ),
              ),
        );
    }
  }
}
