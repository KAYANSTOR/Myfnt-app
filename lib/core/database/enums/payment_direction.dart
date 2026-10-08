// lib/core/database/enums/payment_direction.dart

/// اتجاه الدفعة.
enum PaymentDirection {
  /// قبض (من العميل إلينا).
  incoming('in', 'قبض'),

  /// صرف (منّا للعميل — استرداد).
  outgoing('out', 'صرف');

  const PaymentDirection(this.value, this.label);
  final String value;
  final String label;

  static PaymentDirection fromValue(String v) =>
      PaymentDirection.values.firstWhere(
        (e) => e.value == v,
        orElse: () => PaymentDirection.incoming,
      );
}
