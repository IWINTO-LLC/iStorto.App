import 'package:flutter/material.dart';
import 'package:istoreto/data/models/category_model.dart';
import 'package:istoreto/featured/category/view/all_category/widgets/category_grid_item.dart';
import 'package:istoreto/featured/product/data/product_model.dart';
import 'package:istoreto/featured/shop/view/widgets/dynamic_product_grid_widget.dart';
import 'package:sizer/sizer.dart';

/// مثال على عرض الفئات مع المنتجات تحتها
class CategoryWithProductsExample extends StatefulWidget {
  const CategoryWithProductsExample({super.key});

  @override
  State<CategoryWithProductsExample> createState() =>
      _CategoryWithProductsExampleState();
}

class _CategoryWithProductsExampleState
    extends State<CategoryWithProductsExample> {
  CategoryModel? selectedCategory;

  // قائمة الفئات المثال
  final List<CategoryModel> categories = [
    CategoryModel(
      id: '1',
      title: 'إلكترونيات',
      icon: 'https://example.com/electronics.png',
    ),
    CategoryModel(
      id: '2',
      title: 'ملابس',
      icon: 'https://example.com/clothing.png',
    ),
    CategoryModel(
      id: '3',
      title: 'منزل ومطبخ',
      icon: 'https://example.com/home.png',
    ),
  ];

  // قائمة المنتجات المثال
  final List<ProductModel> allProducts = [
    ProductModel(
      id: '1',
      title: 'لابتوب',
      description: 'لابتوب عالي المواصفات',
      price: 2500.0,
      vendorId: 'vendor1',
    ),
    ProductModel(
      id: '2',
      title: 'هاتف ذكي',
      description: 'هاتف ذكي حديث',
      price: 800.0,
      vendorId: 'vendor1',
    ),
    ProductModel(
      id: '3',
      title: 'قميص',
      description: 'قميص قطني ناعم',
      price: 50.0,
      vendorId: 'vendor2',
    ),
    ProductModel(
      id: '4',
      title: 'طقم أطباق',
      description: 'طقم أطباق سيراميك',
      price: 120.0,
      vendorId: 'vendor3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفئات مع المنتجات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم الفئات
            _buildCategoriesSection(),

            const SizedBox(height: 20),

            // قسم المنتجات للفئة المحددة
            if (selectedCategory != null) _buildProductsSection(),
          ],
        ),
      ),
    );
  }

  /// بناء قسم الفئات
  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اختر فئة:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140, // ارتفاع مناسب للفئات
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory?.id == category.id;

                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    child: TCategoryGridItem(
                      category: category,
                      editMode: false,
                      selected: isSelected,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// بناء قسم المنتجات
  Widget _buildProductsSection() {
    // تصفية المنتجات حسب الفئة المحددة (مثال بسيط)
    final categoryProducts = _getProductsForCategory(selectedCategory!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Text(
                'منتجات ${selectedCategory!.title}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${categoryProducts.length} منتج',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // عرض المنتجات
          if (categoryProducts.isEmpty)
            _buildEmptyProductsState()
          else
            _buildProductsGrid(categoryProducts),
        ],
      ),
    );
  }

  /// بناء شبكة المنتجات
  Widget _buildProductsGrid(List<ProductModel> products) {
    return DynamicProductGridWidget(
      cardWidth: 45.w,
      cardHeight: 60.w,
      products: products,
      withTitle: false,
      sectionTitle: '',
      sectorName: selectedCategory!.id ?? '',
      showDotsIndicator: true,
      enableTranslation: true,
      onProductTap: (product, index) {
        _showProductDetails(product, index);
      },
    );
  }

  /// بناء حالة عدم وجود منتجات
  Widget _buildEmptyProductsState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات في هذه الفئة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إضافة منتجات قريباً',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  /// الحصول على المنتجات للفئة المحددة
  List<ProductModel> _getProductsForCategory(CategoryModel category) {
    // هذا مثال بسيط - في التطبيق الحقيقي ستأتي البيانات من قاعدة البيانات
    switch (category.id) {
      case '1': // إلكترونيات
        return allProducts
            .where(
              (p) => p.title.contains('لابتوب') || p.title.contains('هاتف'),
            )
            .toList();
      case '2': // ملابس
        return allProducts.where((p) => p.title.contains('قميص')).toList();
      case '3': // منزل ومطبخ
        return allProducts.where((p) => p.title.contains('طقم')).toList();
      default:
        return [];
    }
  }

  /// عرض تفاصيل المنتج
  void _showProductDetails(ProductModel product, int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(product.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الوصف: ${product.description}'),
                const SizedBox(height: 8),
                Text('السعر: ${product.price.toStringAsFixed(2)} ريال'),
                const SizedBox(height: 8),
                Text('رقم التاجر: ${product.vendorId}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddToCartMessage(product);
                },
                child: const Text('إضافة للسلة'),
              ),
            ],
          ),
    );
  }

  /// عرض رسالة إضافة للسلة
  void _showAddToCartMessage(ProductModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${product.title} للسلة'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'عرض السلة',
          textColor: Colors.white,
          onPressed: () {
            // يمكن إضافة منطق عرض السلة هنا
          },
        ),
      ),
    );
  }
}

/// مثال مبسط للاستخدام
class SimpleCategoryProductsExample extends StatelessWidget {
  const SimpleCategoryProductsExample({super.key});

  @override
  Widget build(BuildContext context) {
    // قائمة منتجات ثابتة
    final products = [
      ProductModel(
        id: '1',
        title: 'منتج مثال 1',
        description: 'وصف المنتج الأول',
        price: 100.0,
        vendorId: 'vendor1',
      ),
      ProductModel(
        id: '2',
        title: 'منتج مثال 2',
        description: 'وصف المنتج الثاني',
        price: 150.0,
        vendorId: 'vendor1',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('مثال مبسط')),
      body: DynamicProductGridWidget(
        cardWidth: 45.w,
        cardHeight: 60.w,
        products: products,
        withTitle: true,
        sectionTitle: 'المنتجات المميزة',
        sectorName: 'featured',
        showDotsIndicator: true,
        enableTranslation: true,
        onProductTap: (product, index) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم النقر على ${product.title}')),
          );
        },
      ),
    );
  }
}
