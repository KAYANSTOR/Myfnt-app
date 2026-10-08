// lib/core/database/enums/outbox_status.dart

/// حالات طابور المزامنة.
///
/// State Machine:
///   pending → sending → synced (يُحذف)
///                     → failed (يُعاد)
///                     → conflict (مراجعة يدوية)
enum OutboxStatus {
  /// بانتظار الإرسال.
  pending('pending'),

  /// أُرسل، بانتظار الرد.
  sending('sending'),

  /// نجح (سيُحذف من الطابور).
  synced('synced'),

  /// فشل قابل لإعادة المحاولة.
  failed('failed'),

  /// تعارض يحتاج مراجعة يدوية.
  conflict('conflict'),

  /// استُبدل بأمر أحدث (Optimization).
  superseded('superseded');

  const OutboxStatus(this.value);
  final String value;

  static OutboxStatus fromValue(String v) => OutboxStatus.values.firstWhere(
        (e) => e.value == v,
        orElse: () => OutboxStatus.pending,
      );
}
