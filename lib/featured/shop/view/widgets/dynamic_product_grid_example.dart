import 'package:flutter/material.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/shop/view/widgets/dynamic_product_grid_widget.dart';
import 'package:sizer/sizer.dart';

/// مثال على استخدام DynamicProductGridWidget
class DynamicProductGridExample extends StatelessWidget {
  const DynamicProductGridExample({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة المنتجات المثال
    final List<ProductModel> sampleProducts = [
      ProductModel(
        id: '1',
        title: 'منتج مثال 1',
        description: 'وصف المنتج الأول',
        price: 100.0,
        vendorId: 'vendor1',
        // إضافة باقي الخصائص المطلوبة...
      ),
      ProductModel(
        id: '2',
        title: 'منتج مثال 2',
        description: 'وصف المنتج الثاني',
        price: 150.0,
        vendorId: 'vendor1',
        // إضافة باقي الخصائص المطلوبة...
      ),
      // يمكن إضافة المزيد من المنتجات...
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('مثال على Dynamic Product Grid')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // مثال 1: عرض منتجات عادية
            DynamicProductGridWidget(
              cardWidth: 45.w,
              cardHeight: 60.w,
              products: sampleProducts,
              withTitle: true,
              sectionTitle: 'المنتجات المميزة',
              sectorName: 'featured',
              showDotsIndicator: true,
              onProductTap: (product, index) {
                print('تم النقر على المنتج: ${product.title}');
                // يمكن إضافة منطق مخصص هنا
              },
            ),

            const SizedBox(height: 20),

            // مثال 2: عرض منتجات متوسطة الحجم
            DynamicProductGridWidget(
              cardWidth: 40.w,
              cardHeight: 55.w,
              products: sampleProducts,
              withTitle: true,
              sectionTitle: 'منتجات أخرى',
              sectorName: 'other',
              showDotsIndicator: false,
            ),

            const SizedBox(height: 20),

            // مثال 3: عرض منتجات صغيرة بدون ترجمة
            DynamicProductGridWidget(
              cardWidth: 25.w,
              cardHeight: 35.w,
              products: sampleProducts,
              withTitle: false,
              sectionTitle: '',
              sectorName: 'small',
              showDotsIndicator: false,
              enableTranslation: false,
            ),

            const SizedBox(height: 20),

            // مثال 4: عرض منتجات بدون عناوين
            DynamicProductGridWidget(
              cardWidth: 50.w,
              cardHeight: 70.w,
              products: sampleProducts,
              withTitle: false,
              withPadding: false,
              sectionTitle: '',
              sectorName: 'no-title',
              showDotsIndicator: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// مثال على استخدام الـ widget مع قائمة فارغة
class EmptyProductsExample extends StatelessWidget {
  const EmptyProductsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicProductGridWidget(
      cardWidth: 45.w,
      cardHeight: 60.w,
      products: [], // قائمة فارغة
      withTitle: true,
      sectionTitle: 'لا توجد منتجات',
      sectorName: 'empty',
    );
  }
}

/// مثال على استخدام الـ widget مع callback مخصص
class CustomCallbacksExample extends StatelessWidget {
  const CustomCallbacksExample({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> products = [
      // قائمة المنتجات...
    ];

    return DynamicProductGridWidget(
      cardWidth: 45.w,
      cardHeight: 60.w,
      products: products,
      withTitle: true,
      sectionTitle: 'منتجات مخصصة',
      sectorName: 'custom',
      onProductTap: (product, index) {
        // سلوك مخصص عند النقر على المنتج
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(product.title),
                content: Text('تم النقر على المنتج في الفهرس $index'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('موافق'),
                  ),
                ],
              ),
        );
      },
    );
  }
}
