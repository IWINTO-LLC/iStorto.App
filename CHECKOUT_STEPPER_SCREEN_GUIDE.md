# دليل صفحة إكمال الطلب مع Stepper

## نظرة عامة

تم إنشاء صفحة جديدة `CheckoutStepperScreen` لإكمال عملية الشراء من السلة مع **Stepper أفقي** يوضح خطوات إتمام الطلب.

## المميزات الرئيسية

### 1. **Stepper أفقي** 🔢
- ✅ 3 خطوات واضحة ومرئية
- ✅ تصميم عصري مع أيقونات سوداء
- ✅ خط ربط بين الخطوات
- ✅ مؤشر بصري للخطوة الحالية

### 2. **الخطوات الثلاث**

#### الخطوة 1: السلة 🛒
- عرض المنتجات مجمعة حسب التجار
- إمكانية اختيار/إلغاء اختيار المنتجات
- حذف أو حفظ المنتجات للاحقاً (Slidable)
- عرض ملف التاجر (VendorProfilePreview)
- حساب المجموع لكل تاجر

#### الخطوة 2: العنوان ووسيلة الدفع 📍💳
- **اختيار العنوان**:
  - عرض العناوين المحفوظة
  - إضافة عنوان جديد
  - تحديد العنوان الافتراضي
- **اختيار وسيلة الدفع**:
  - الدفع عند الاستلام (COD)
  - محفظة iStoreto
  - حسب إعدادات التاجر

#### الخطوة 3: الملخص وإتمام الطلب ✅
- ملخص المنتجات لكل تاجر
- عرض العنوان المختار
- عرض وسيلة الدفع المختارة
- المجموع الكلي
- زر إتمام الطلب

---

## البنية التقنية

### الملف الرئيسي
```
lib/featured/cart/view/checkout_stepper_screen.dart
```

### State Management
```dart
class _CheckoutStepperScreenState extends State<CheckoutStepperScreen> {
  int _currentStep = 0; // الخطوة الحالية
  late ScrollController _scrollController;
  late CartController cartController;
  String selectedPaymentMethod = 'cod';
  Map<String, VendorModel?> vendorProfiles = {};
  bool isLoadingVendors = true;
}
```

### الوظائف الرئيسية

#### 1. التنقل بين الخطوات
```dart
void _nextStep() {
  // التحقق من الشروط قبل الانتقال
  if (_currentStep < 2) {
    setState(() {
      _currentStep++;
    });
  }
}

void _previousStep() {
  if (_currentStep > 0) {
    setState(() {
      _currentStep--;
    });
  }
}
```

#### 2. التحققات
- **الخطوة 1**: التحقق من اختيار منتج واحد على الأقل
- **الخطوة 2**: التحقق من اختيار عنوان ورقم هاتف

#### 3. إتمام الطلب
```dart
Future<void> _completeOrder() async {
  // إنشاء طلبات منفصلة لكل تاجر
  final groupedItems = cartController.groupedByVendor;
  
  for (var entry in groupedItems.entries) {
    // إنشاء OrderModel لكل تاجر
    // إرسال الطلب
    // حذف المنتجات من السلة
  }
  
  // الانتقال لصفحة النجاح
}
```

---

## التصميم

### 1. **AppBar**
```dart
Container
├── Back Button (إذا كانت الخطوة > 0)
├── Title (عنوان الخطوة)
└── Spacer (للموازنة)
```

### 2. **Stepper الأفقي**
```dart
Row
├── Step 1 Indicator (أيقونة + نص)
├── Line Connector
├── Step 2 Indicator
├── Line Connector
└── Step 3 Indicator
```

#### مواصفات مؤشر الخطوة:
- **الحجم**: 40x40 px
- **الشكل**: دائري
- **اللون النشط**: أسود
- **اللون غير النشط**: رمادي فاتح
- **الأيقونة**: بيضاء عند النشاط

### 3. **أزرار التنقل**
```dart
Row
├── Back Button (OutlinedButton - إذا كانت الخطوة > 0)
└── Next/Complete Button (ElevatedButton)
```

#### مواصفات الأزرار:
- **اللون**: أسود
- **الشكل**: مستطيل مع حواف دائرية (12px)
- **الحجم**: full width مع padding
- **Loading**: CircularProgressIndicator أثناء الإرسال

---

## الاستخدام

### من الصفحة الرئيسية
```dart
// في home_search_widget.dart
GestureDetector(
  onTap: () {
    Get.to(
      () => const CheckoutStepperScreen(),
      transition: Transition.rightToLeft,
    );
  },
  child: CartIcon with Badge,
)
```

### من أي مكان آخر
```dart
Get.to(() => const CheckoutStepperScreen());
```

---

## التبعيات

```dart
// Controllers
- CartController
- OrderController
- VendorController
- AuthController
- AddressService

// Models
- OrderModel
- VendorModel
- AddressModel

// Widgets
- VendorCartBlock
- AddressScreen (AddressOrder)
- PaymentMethodSelector
- CartStaticMenuItem
- VendorProfilePreview
- EmptyCartView
- CartShimmer
```

---

## خريطة التدفق

```
┌─────────────────────────────────────┐
│     فتح CheckoutStepperScreen      │
│     (من أيقونة السلة)              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│        الخطوة 1: السلة             │
│  - عرض المنتجات حسب التجار         │
│  - اختيار المنتجات                │
│  - حذف/حفظ منتجات                 │
└──────────────┬──────────────────────┘
               │ [اختار منتج واحد على الأقل]
               ▼
┌─────────────────────────────────────┐
│   الخطوة 2: العنوان والدفع         │
│  - اختيار/إضافة عنوان              │
│  - اختيار وسيلة الدفع              │
└──────────────┬──────────────────────┘
               │ [اختار عنوان + هاتف]
               ▼
┌─────────────────────────────────────┐
│      الخطوة 3: الملخص              │
│  - مراجعة المنتجات                │
│  - مراجعة العنوان                 │
│  - مراجعة وسيلة الدفع             │
│  - المجموع الكلي                  │
└──────────────┬──────────────────────┘
               │ [إتمام الطلب]
               ▼
┌─────────────────────────────────────┐
│  إنشاء طلبات منفصلة لكل تاجر       │
│  - حفظ في قاعدة البيانات          │
│  - حذف من السلة                   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│     OrderSuccessScreen             │
│     (صفحة النجاح)                  │
└─────────────────────────────────────┘
```

---

## التحسينات المستقبلية المقترحة

### 1. حفظ الحالة
- ✅ حفظ الخطوة الحالية عند الخروج
- ✅ استعادة الحالة عند العودة

### 2. تحسين UX
- ✅ Animation للانتقال بين الخطوات
- ✅ Swipe للانتقال بين الخطوات
- ✅ تأكيد قبل الخروج من الصفحة

### 3. إضافة ميزات
- ✅ كود الخصم (Coupon)
- ✅ ملاحظات على الطلب
- ✅ جدولة التوصيل
- ✅ اختيار وقت التوصيل

---

## اختبار الصفحة

### سيناريو 1: إتمام طلب عادي
1. ✅ فتح السلة من أيقونة السلة
2. ✅ اختيار منتجات
3. ✅ الانتقال للخطوة التالية
4. ✅ اختيار عنوان
5. ✅ اختيار وسيلة دفع
6. ✅ الانتقال للملخص
7. ✅ إتمام الطلب
8. ✅ عرض صفحة النجاح

### سيناريو 2: الرجوع بين الخطوات
1. ✅ الانتقال للخطوة 2
2. ✅ الرجوع للخطوة 1
3. ✅ تعديل المنتجات
4. ✅ الانتقال مجدداً

### سيناريو 3: التحققات
1. ❌ محاولة الانتقال بدون اختيار منتجات
2. ✅ عرض رسالة تنبيه
3. ❌ محاولة الانتقال بدون اختيار عنوان
4. ✅ عرض رسالة تنبيه

---

## الملفات المعدلة

### 1. `lib/featured/cart/view/checkout_stepper_screen.dart`
**جديد** - الصفحة الرئيسية للـ Stepper

### 2. `lib/featured/home-page/views/widgets/home_search_widget.dart`
**معدل** - تغيير الوجهة من `CartScreen` إلى `CheckoutStepperScreen`

---

## الألوان المستخدمة

| العنصر | اللون |
|--------|-------|
| Stepper Active | `Colors.black` |
| Stepper Inactive | `Colors.grey.shade200` |
| Stepper Line Active | `Colors.black` |
| Stepper Line Inactive | `Colors.grey.shade300` |
| Button Background | `Colors.black` |
| Button Text | `Colors.white` |
| Border Color | `Colors.black` |
| Price Color | `TColors.primary` |

---

## ملاحظات مهمة

### 1. طلبات متعددة
- ✅ يتم إنشاء طلب منفصل لكل تاجر
- ✅ كل طلب له `vendorId` خاص
- ✅ المنتجات مجمعة حسب التاجر

### 2. إدارة الحالة
- ✅ `CartController` للسلة
- ✅ `OrderController` للطلبات
- ✅ `AddressService` للعناوين
- ✅ كل التحديثات تتم بشكل reactive مع `Obx`

### 3. التحقق من البيانات
- ✅ التحقق من اختيار منتج واحد على الأقل
- ✅ التحقق من وجود عنوان
- ✅ التحقق من وجود رقم هاتف
- ✅ عرض رسائل خطأ واضحة

---

## الأيقونات المستخدمة

| الخطوة | الأيقونة |
|--------|----------|
| الخطوة 1 | `Icons.shopping_cart` |
| الخطوة 2 | `Icons.location_on` |
| الخطوة 3 | `Icons.receipt_long` |
| زر التالي | `Icons.arrow_forward` |
| زر الرجوع | `Icons.arrow_back` |
| زر إتمام | `Icons.check` |

**جميع الأيقونات باللون الأسود** ✅

---

**تاريخ الإنشاء:** October 12, 2025
**الحالة:** ✅ جاهز للاستخدام
**الإصدار:** 1.0

