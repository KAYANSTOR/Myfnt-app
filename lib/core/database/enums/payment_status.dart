// lib/core/database/enums/payment_status.dart

/// حالة الدفعة (لا تُحذف — تُلغى محاسبياً).
enum PaymentStatus {
  /// مُرحَّل (الوضع الافتراضي).
  posted('posted', 'فعّال'),

  /// ملغى محاسبياً (Reversal).
  /// لا يُحذف الصف، بل يُعلَّم.
  reversed('reversed', 'ملغى محاسبياً');

  const PaymentStatus(this.value, this.label);
  final String value;
  final String label;

  static PaymentStatus fromValue(String v) => PaymentStatus.values.firstWhere(
        (e) => e.value == v,
        orElse: () => PaymentStatus.posted,
      );
}
