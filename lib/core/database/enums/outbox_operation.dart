// lib/core/database/enums/outbox_operation.dart

/// نوع العملية في الطابور.
enum OutboxOperation {
  create('create'),
  update('update'),
  delete('delete'),
  archive('archive'),
  correct('correct'), // تعديل مالي (Payment)
  reverse('reverse'), // إلغاء مالي (Payment)
  approve('approve'); // موافقة (SMS Approval)

  const OutboxOperation(this.value);
  final String value;

  static OutboxOperation fromValue(String v) =>
      OutboxOperation.values.firstWhere(
        (e) => e.value == v,
        orElse: () => OutboxOperation.update,
      );
}
