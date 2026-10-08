// lib/core/database/enums/payment_method.dart

enum PaymentMethod {
  cash('cash', 'نقداً'),
  voucher('voucher', 'سند'),
  transfer('transfer', 'حوالة'),
  cheque('cheque', 'شيك');

  const PaymentMethod(this.value, this.label);
  final String value;
  final String label;

  static PaymentMethod fromValue(String v) => PaymentMethod.values.firstWhere(
        (e) => e.value == v,
        orElse: () => PaymentMethod.cash,
      );
}
