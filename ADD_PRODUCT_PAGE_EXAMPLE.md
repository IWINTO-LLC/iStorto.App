# أمثلة استخدام صفحة إضافة المنتج
# Add Product Page Usage Examples

---

## 🚀 Quick Start | البداية السريعة

### الطريقة الأساسية:

```dart
import 'package:istoreto/views/vendor/add_product_page.dart';

// في أي صفحة:
Get.to(() => AddProductPage(vendorId: 'vendor_123'));
```

---

## 📍 أماكن الاستخدام | Where to Use

### 1. في صفحة المتجر (MarketPlaceView)

```dart
// lib/featured/shop/view/market_place_view.dart

Scaffold(
  appBar: AppBar(
    title: Text('My Products'),
    actions: [
      // زر إضافة منتج
      IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          Get.to(() => AddProductPage(vendorId: widget.vendorId));
        },
        tooltip: 'add_new_product'.tr,
      ),
    ],
  ),
  // FloatingActionButton بديل
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => Get.to(() => AddProductPage(vendorId: widget.vendorId)),
    icon: Icon(Icons.add),
    label: Text('add_new_product'.tr),
    backgroundColor: TColors.primary,
  ),
)
```

---

### 2. في صفحة المنتجات (Vendor Products Page)

```dart
// في صفحة عرض منتجات التاجر

AppBar(
  title: Text('search_products'.tr),
  actions: [
    IconButton(
      icon: Icon(Icons.add_shopping_cart),
      onPressed: () {
        Get.to(() => AddProductPage(vendorId: vendorId));
      },
    ),
  ],
)
```

---

### 3. في Admin Zone

```dart
// lib/views/admin/admin_zone_page.dart

ListTile(
  leading: Icon(Icons.inventory, color: Colors.blue),
  title: Text('add_new_product'.tr),
  subtitle: Text('إضافة منتج جديد للمتجر'),
  trailing: Icon(Icons.arrow_forward_ios),
  onTap: () {
    final authController = Get.find<AuthController>();
    final vendorId = authController.currentUser.value?.vendorId;
    
    if (vendorId != null) {
      Get.to(() => AddProductPage(vendorId: vendorId));
    } else {
      Get.snackbar(
        'error'.tr,
        'vendor_id_not_found'.tr,
        backgroundColor: Colors.red.shade100,
      );
    }
  },
)
```

---

### 4. من Navigation Menu

```dart
// في القائمة الجانبية (Drawer)

Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        child: Text('iStoreto'),
      ),
      
      // للتجار فقط
      if (authController.currentUser.value?.accountType == 1)
        ListTile(
          leading: Icon(Icons.add_box),
          title: Text('add_new_product'.tr),
          onTap: () {
            Navigator.pop(context); // إغلاق الـ Drawer
            Get.to(() => AddProductPage(
              vendorId: authController.currentUser.value!.vendorId!,
            ));
          },
        ),
    ],
  ),
)
```

---

### 5. من Bottom Sheet Actions

```dart
// عند الضغط مطولاً على منتج أو في قائمة opciones

void _showProductActions(BuildContext context, String vendorId) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add, color: Colors.green),
              title: Text('add_new_product'.tr),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => AddProductPage(vendorId: vendorId));
              },
            ),
            // ... باقي الخيارات
          ],
        ),
      );
    },
  );
}
```

---

### 6. في صفحة الإحصائيات

```dart
// Dashboard أو Statistics Page

Card(
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.green.shade100,
      child: Icon(Icons.add, color: Colors.green),
    ),
    title: Text('add_new_product'.tr),
    subtitle: Text('${products.length} products'),
    trailing: ElevatedButton(
      onPressed: () => Get.to(() => AddProductPage(vendorId: vendorId)),
      child: Text('Add'),
    ),
  ),
)
```

---

### 7. مع التحقق من الحساب

```dart
// وظيفة helper للتحقق قبل الانتقال

void navigateToAddProduct() {
  final authController = Get.find<AuthController>();
  final user = authController.currentUser.value;
  
  // التحقق من نوع الحساب
  if (user?.accountType != 1) {
    Get.snackbar(
      'error'.tr,
      'business_account_required'.tr,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade800,
      icon: Icon(Icons.business, color: Colors.orange),
    );
    return;
  }
  
  // التحقق من vendor_id
  if (user?.vendorId == null) {
    Get.snackbar(
      'error'.tr,
      'vendor_setup_incomplete'.tr,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
    return;
  }
  
  // الانتقال للصفحة
  Get.to(() => AddProductPage(vendorId: user!.vendorId!));
}

// استخدام:
IconButton(
  icon: Icon(Icons.add),
  onPressed: navigateToAddProduct,
)
```

---

## 🎨 UI Customization Examples | أمثلة تخصيص الواجهة

### مثال 1: تغيير لون الزر الرئيسي

```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,  // ← بدلاً من TColors.primary
    foregroundColor: Colors.white,
  ),
  child: Text('save_product'.tr),
)
```

### مثال 2: إضافة أيقونة مخصصة للتصنيف

```dart
DropdownMenuItem<VendorCategoryModel>(
  value: category,
  child: Row(
    children: [
      // استخدام أيقونة مخصصة حسب نوع الفئة
      Icon(
        _getCategoryIcon(category.title),
        size: 18,
        color: _getCategoryColor(category.title),
      ),
      SizedBox(width: 12),
      Text(category.title),
    ],
  ),
)

IconData _getCategoryIcon(String title) {
  if (title.contains('Food')) return Icons.restaurant;
  if (title.contains('Tech')) return Icons.computer;
  return Icons.category;
}
```

### مثال 3: إضافة وصف توضيحي

```dart
// بعد كل حقل:
Text(
  'helper_text_here'.tr,
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey.shade600,
    fontStyle: FontStyle.italic,
  ),
)
```

---

## 🔄 Integration with Existing Code | التكامل مع الكود الموجود

### استبدال الصفحة القديمة:

```dart
// قبل (Before):
Get.to(() => CreateProduct(
  vendorId: vendorId,
  sectionId: 'some_id',
  type: 'some_type',
  initialList: products,
  sectorTitle: sectorModel,
));

// بعد (After):
Get.to(() => AddProductPage(vendorId: vendorId));
// ← أبسط بكثير!
```

### الاحتفاظ بالكود القديم:

```dart
// إذا كنت تريد خيارين:
void showAddProductOptions(String vendorId) {
  showDialog(
    context: Get.context!,
    builder: (context) {
      return AlertDialog(
        title: Text('choose_add_method'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('quick_add'.tr),
              subtitle: Text('new_modern_interface'.tr),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => AddProductPage(vendorId: vendorId));
              },
            ),
            ListTile(
              title: Text('advanced_add'.tr),
              subtitle: Text('old_interface_with_more_options'.tr),
              onTap: () {
                Navigator.pop(context);
                // الصفحة القديمة
              },
            ),
          ],
        ),
      );
    },
  );
}
```

---

## ⚡ Performance Tips | نصائح الأداء

### 1. **Cache Categories:**

```dart
// في VendorCategoryRepository
final Map<String, List<VendorCategoryModel>> _cache = {};

Future<List<VendorCategoryModel>> getVendorCategories(String vendorId) async {
  // Check cache first
  if (_cache.containsKey(vendorId)) {
    return _cache[vendorId]!;
  }
  
  // Fetch from database
  final categories = await _fetchFromDB(vendorId);
  _cache[vendorId] = categories;
  return categories;
}
```

### 2. **Lazy Load Images:**

```dart
// تحميل الصور فقط عند الحاجة
ListView.builder(
  itemBuilder: (context, index) {
    return FutureBuilder(
      future: _loadImageWhenNeeded(index),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Shimmer(...);
        return Image.file(snapshot.data!);
      },
    );
  },
)
```

---

## 🎁 Bonus Features | ميزات إضافية يمكن إضافتها

### 1. **حفظ كمسودة:**

```dart
ElevatedButton(
  onPressed: () => _saveDraft(),
  child: Text('save_as_draft'.tr),
)

Future<void> _saveDraft() async {
  // حفظ البيانات محلياً
  final draft = {
    'title': _titleController.text,
    'description': _descriptionController.text,
    // ...
  };
  await StorageService.instance.write('product_draft', draft);
}
```

### 2. **استعادة المسودة:**

```dart
@override
void initState() {
  super.initState();
  _loadDraft();
}

Future<void> _loadDraft() async {
  final draft = await StorageService.instance.read('product_draft');
  if (draft != null) {
    _titleController.text = draft['title'] ?? '';
    _descriptionController.text = draft['description'] ?? '';
    // ...
  }
}
```

### 3. **Duplicate Product:**

```dart
// نسخ منتج موجود
AddProductPage(
  vendorId: vendorId,
  initialData: existingProduct,  // ← parameter جديد
)
```

---

## 🎯 Real-World Example | مثال واقعي كامل

```dart
// في صفحة منتجات التاجر

class VendorProductsPage extends StatelessWidget {
  final String vendorId;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_products'.tr),
        actions: [
          // زر إضافة منتج
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () => _addNewProduct(context),
          ),
        ],
      ),
      body: ProductsList(vendorId: vendorId),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewProduct(context),
        icon: Icon(Icons.add),
        label: Text('add_product'.tr),
      ),
    );
  }
  
  void _addNewProduct(BuildContext context) {
    Get.to(
      () => AddProductPage(vendorId: vendorId),
      transition: Transition.rightToLeftWithFade,
      duration: Duration(milliseconds: 300),
    );
  }
}
```

---

## 📱 Screenshots Description | وصف الشاشات

### Screen 1: Basic Information
```
╔════════════════════════════════════╗
║  📋 المعلومات الأساسية               ║
╠════════════════════════════════════╣
║  [اسم المنتج        ] 🛍️           ║
║  ───────────────────────────        ║
║  [الوصف (4 lines)  ] 📝           ║
║  ───────────────────────────        ║
║  [الحد الأدنى: 1   ] 📦           ║
╚════════════════════════════════════╝
```

### Screen 2: Category & Section
```
╔════════════════════════════════════╗
║  🗂️ التصنيف والقسم                  ║
╠════════════════════════════════════╣
║  [التصنيف ▼        ] 📁 [+]       ║
║    • بدون تصنيف    ← جديد!        ║
║    • فئة 1                          ║
║    • فئة 2                          ║
║  ───────────────────────────        ║
║  [القسم ▼          ] 📊           ║
║    • All Products                   ║
║    • Offers                         ║
║    • Sales                          ║
╚════════════════════════════════════╝
```

### Screen 3: Pricing
```
╔════════════════════════════════════╗
║  💰 التسعير                         ║
╠════════════════════════════════════╣
║  [سعر البيع: 100  ] 💵 ← مطلوب   ║
║  [الخصم: 20%      ] 📉 → auto    ║
║  [السعر الأصلي:125] 🏷️ → calc   ║
╚════════════════════════════════════╝
```

### Screen 4: Images
```
╔════════════════════════════════════╗
║  📷 صور المنتج                      ║
╠════════════════════════════════════╣
║  [img] [img] [img] → scroll →      ║
║  ───────────────────────────        ║
║  [📷 Camera]  [🖼️ Gallery]        ║
╚════════════════════════════════════╝
```

---

## 🔧 Advanced Examples | أمثلة متقدمة

### With Permission Check:

```dart
Future<void> addProductWithPermissions(String vendorId) async {
  // 1. تحقق من الأذونات
  final cameraPermission = await Permission.camera.request();
  final storagePermission = await Permission.storage.request();
  
  if (!cameraPermission.isGranted || !storagePermission.isGranted) {
    Get.snackbar(
      'error'.tr,
      'permissions_required'.tr,
    );
    return;
  }
  
  // 2. افتح الصفحة
  Get.to(() => AddProductPage(vendorId: vendorId));
}
```

### With Analytics:

```dart
void addProductWithAnalytics(String vendorId) {
  // Log event
  Analytics.logEvent('add_product_opened', {
    'vendor_id': vendorId,
    'timestamp': DateTime.now().toString(),
  });
  
  // Navigate
  Get.to(() => AddProductPage(vendorId: vendorId))?.then((value) {
    if (value == true) {
      Analytics.logEvent('product_created_success');
    }
  });
}
```

### With Pre-filled Data:

```dart
// يمكنك تعديل الصفحة لتدعم بيانات أولية

class AddProductPage extends StatefulWidget {
  final String vendorId;
  final ProductModel? initialProduct;  // ← parameter جديد
  
  const AddProductPage({
    required this.vendorId,
    this.initialProduct,
  });
}

// ثم في initState:
@override
void initState() {
  super.initState();
  if (widget.initialProduct != null) {
    _titleController.text = widget.initialProduct!.title;
    _descriptionController.text = widget.initialProduct!.description ?? '';
    _priceController.text = widget.initialProduct!.price.toString();
    // ...
  }
  _loadData();
}
```

---

## 🎭 Complete Example | مثال كامل

```dart
// ملف كامل لكيفية استخدام الصفحة في سياق حقيقي

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:istoreto/controllers/auth_controller.dart';
import 'package:istoreto/views/vendor/add_product_page.dart';

class VendorDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final vendorId = authController.currentUser.value?.vendorId;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('vendor_dashboard'.tr),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // إحصائيات سريعة
            _buildStatsCard(vendorId),
            SizedBox(height: 20),
            
            // إجراءات سريعة
            _buildQuickActions(vendorId),
            SizedBox(height: 20),
            
            // منتجات حديثة
            _buildRecentProducts(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions(String? vendorId) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_actions'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          
          // زر إضافة منتج
          _buildActionButton(
            icon: Icons.add_shopping_cart,
            title: 'add_new_product'.tr,
            subtitle: 'إضافة منتج جديد للمتجر',
            color: Colors.green,
            onTap: () {
              if (vendorId != null) {
                Get.to(() => AddProductPage(vendorId: vendorId));
              } else {
                Get.snackbar('Error', 'Vendor ID not found');
              }
            },
          ),
          
          // المزيد من الأزرار...
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatsCard(String? vendorId) {
    return Container(); // Implementation
  }
  
  Widget _buildRecentProducts() {
    return Container(); // Implementation
  }
}
```

---

## ✅ Checklist | القائمة المرجعية

قبل استخدام الصفحة، تأكد من:

- [x] ProductController مُهيأ
- [x] VendorCategoryRepository مُهيأ
- [x] ImagePicker configured (permissions في AndroidManifest.xml و Info.plist)
- [x] Supabase Storage configured
- [x] Translation keys added (EN & AR)
- [x] vendorId متاح ومُمرر للصفحة
- [x] User is logged in (accountType = 1)
- [x] Vendor profile exists

---

## 🎉 Conclusion | الخلاصة

الصفحة الجديدة توفر:
- ✅ واجهة نظيفة وبسيطة
- ✅ تصميم حديث مشابه لصفحة البنرات
- ✅ خيار "بدون تصنيف"
- ✅ اختيار Section
- ✅ حساب تلقائي للأسعار
- ✅ معاينة الصور
- ✅ Validation شاملة
- ✅ ترجمة كاملة

**جاهز للاستخدام الفوري!** 🚀

---

**Created:** October 11, 2025  
**Version:** 1.0.0

