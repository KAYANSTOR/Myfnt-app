// lib/core/database/helpers/money_utils.dart

/// تحويلات المبالغ: Major (double) ↔ Minor (int).
///
/// Contract:
///   - العملة الافتراضية: YER (ريال يمني).
///   - Minor Unit = 1/100 من العملة.
///   - لا أخطاء floating point.
///
/// الاستخدام:
///   final minor = 3000.50.toMinor();  // 300050
///   final major = 300050.toMajor();   // 3000.50
extension MoneyConversion on num {
  /// يحوّل 3000.50 → 300050.
  int toMinor() => (this * 100).round();
}

extension MinorConversion on int {
  /// يحوّل 300050 → 3000.50.
  double toMajor() => this / 100.0;

  /// يعرض "3,000.50".
  String toDisplay({int decimals = 2}) =>
      (this / 100).toStringAsFixed(decimals);
}

/// مساعدات إضافية للمال.
class MoneyFormat {
  MoneyFormat._();

  /// الحد الأقصى الآمن (JS-safe integer / 2).
  /// أكبر من ذلك قد يسبب فقدان دقة في JSON عبر الخادم.
  static const int maxSafeMinor = 9007199254740991;

  /// التحقق من أن المبلغ ضمن الحدود.
  static bool isValid(int minorUnits) =>
      minorUnits >= 0 && minorUnits <= maxSafeMinor;
}
