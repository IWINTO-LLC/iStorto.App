# دليل تحديث UserModel - Account Type Guide

## 🎯 نظرة عامة - Overview

تم إضافة معامل `accountType` إلى `UserModel` لتمييز نوع الحساب (عادي أو تجاري).

Added `accountType` parameter to `UserModel` to distinguish between account types (regular or commercial).

## ✨ التحديثات المنجزة - Completed Updates

### 1. إضافة معامل accountType - Added accountType Parameter
```dart
final int accountType; // 0: regular, 1: commercial
```

### 2. تحديث Constructor - Updated Constructor
```dart
UserModel({
  // ... existing parameters
  this.accountType = 0, // Default to regular account
  // ... rest of parameters
});
```

### 3. تحديث fromJson - Updated fromJson
```dart
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    // ... existing fields
    accountType: json['account_type'] as int? ?? 0,
    // ... rest of fields
  );
}
```

### 4. تحديث toJson - Updated toJson
```dart
Map<String, dynamic> toJson() {
  return {
    // ... existing fields
    'account_type': accountType,
    // ... rest of fields
  };
}
```

### 5. تحديث Factory Methods - Updated Factory Methods

#### createForRegistration
```dart
factory UserModel.createForRegistration({
  // ... existing parameters
  int accountType = 0, // Default to regular account
}) {
  // ... implementation
}
```

#### createForSocialLogin
```dart
factory UserModel.createForSocialLogin({
  // ... existing parameters
  int accountType = 0, // Default to regular account
}) {
  // ... implementation
}
```

### 6. تحديث copyWith - Updated copyWith
```dart
UserModel copyWith({
  // ... existing parameters
  int? accountType,
  // ... rest of parameters
}) {
  return UserModel(
    // ... existing assignments
    accountType: accountType ?? this.accountType,
    // ... rest of assignments
  );
}
```

## 🔧 الدوال المساعدة الجديدة - New Helper Methods

### 1. التحقق من نوع الحساب - Account Type Checks
```dart
// Check if account is commercial
bool get isCommercialAccount {
  return accountType == 1;
}

// Check if account is regular
bool get isRegularAccount {
  return accountType == 0;
}
```

### 2. أسماء العرض - Display Names
```dart
// Get account type display name (English)
String get accountTypeDisplayName {
  switch (accountType) {
    case 1:
      return 'Commercial';
    case 0:
    default:
      return 'Regular';
  }
}

// Get account type display name (Arabic)
String get accountTypeDisplayNameAr {
  switch (accountType) {
    case 1:
      return 'تجاري';
    case 0:
    default:
      return 'عادي';
  }
}
```

## 📊 قيم accountType - Account Type Values

| القيمة - Value | النوع - Type | الوصف - Description |
|----------------|--------------|---------------------|
| `0` | Regular | حساب عادي - Regular Account |
| `1` | Commercial | حساب تجاري - Commercial Account |

## 🚀 كيفية الاستخدام - How to Use

### 1. إنشاء حساب عادي - Create Regular Account
```dart
final user = UserModel.createForRegistration(
  userId: 'user123',
  email: 'user@example.com',
  accountType: 0, // Regular account (default)
);
```

### 2. إنشاء حساب تجاري - Create Commercial Account
```dart
final user = UserModel.createForRegistration(
  userId: 'user123',
  email: 'user@example.com',
  accountType: 1, // Commercial account
);
```

### 3. التحقق من نوع الحساب - Check Account Type
```dart
if (user.isCommercialAccount) {
  // Handle commercial account
  print('This is a commercial account');
} else if (user.isRegularAccount) {
  // Handle regular account
  print('This is a regular account');
}
```

### 4. عرض نوع الحساب - Display Account Type
```dart
// English
Text(user.accountTypeDisplayName); // "Commercial" or "Regular"

// Arabic
Text(user.accountTypeDisplayNameAr); // "تجاري" or "عادي"
```

### 5. تحديث نوع الحساب - Update Account Type
```dart
// Convert regular account to commercial
final updatedUser = user.copyWith(accountType: 1);

// Convert commercial account to regular
final updatedUser = user.copyWith(accountType: 0);
```

## 🔄 التكامل مع النظام - System Integration

### 1. في صفحة الملف الشخصي - In Profile Page
```dart
// Show account type badge
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: user.isCommercialAccount ? Colors.green : Colors.blue,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    user.accountTypeDisplayName,
    style: TextStyle(color: Colors.white, fontSize: 12),
  ),
)
```

### 2. في نظام المصادقة - In Authentication System
```dart
// After successful commercial account creation
final updatedUser = currentUser.copyWith(accountType: 1);
```

### 3. في التحقق من الصلاحيات - In Permission Checks
```dart
// Check if user can access commercial features
if (user.isCommercialAccount) {
  // Show commercial features
  showCommercialDashboard();
} else {
  // Show regular features
  showRegularDashboard();
}
```

## 📱 أمثلة عملية - Practical Examples

### 1. عرض نوع الحساب في ProfilePage
```dart
Row(
  children: [
    Text('Account Type: '),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: user.isCommercialAccount ? Colors.green : Colors.blue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.accountTypeDisplayName,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    ),
  ],
)
```

### 2. إخفاء/إظهار الميزات حسب نوع الحساب
```dart
if (user.isCommercialAccount) {
  // Show commercial account features
  CommercialAccountFeatures(),
} else {
  // Show regular account features
  RegularAccountFeatures(),
}
```

### 3. تحديث نوع الحساب بعد إنشاء حساب تجاري
```dart
// In InitialCommercialController after successful creation
final updatedUser = currentUser.copyWith(accountType: 1);
// Update user in AuthController
```

## 🎉 النتيجة النهائية - Final Result

تم تحديث `UserModel` بنجاح ليدعم:
- تمييز نوع الحساب (عادي/تجاري)
- دوال مساعدة للتحقق من نوع الحساب
- أسماء عرض باللغتين العربية والإنجليزية
- تكامل كامل مع باقي النظام

`UserModel` has been successfully updated to support:
- Account type distinction (regular/commercial)
- Helper methods for account type checking
- Display names in both Arabic and English
- Full integration with the rest of the system

🚀 **UserModel جاهز للاستخدام مع دعم نوع الحساب!** - **UserModel is ready to use with account type support!**
