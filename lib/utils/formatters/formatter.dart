import 'package:intl/intl.dart';

class TFormatter {
  static String formateDate(DateTime? date) {
    date ??= DateTime.now();

    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String formateNumber(double value) {
    // إذا كان الرقم صحيح، نعرضه بدون كسور عشرية
 
      // إذا كان الرقم عشري، نعرض مرتبتان بعد الفاصلة العشرية
      final formatter = NumberFormat("#,##0.00", "en_US");
      return formatter.format(value);
    
  }

  // دالة للتنسيق النهائي للعرض (مع الكسور العشرية)
  static String formateNumberForDisplay(double value) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    return formatter.format(value);
  }

  // دالة للتنسيق أثناء الكتابة (بدون كسور عشرية)
  static String formateNumberForInput(double value) {
    final formatter = NumberFormat("#,##0", "en_US");
    return formatter.format(value);
  }

  // static String formatedPhoneNumber(String phoneNumber){

  // }
}
