// lib/core/database/converters/utc_datetime_converter.dart
import 'package:drift/drift.dart';

/// DateTime Converter — كل التواريخ UTC ISO-8601.
///
/// Contract:
///   - يُخزَّن كنص UTC.
///   - يُعاد كـ DateTime UTC.
///   - التحويل إلى Asia/Aden يتم في طبقة العرض فقط.
class UtcDateTimeConverter extends TypeConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse(fromDb).toUtc();

  @override
  String toSql(DateTime value) => value.toUtc().toIso8601String();
}

/// نسخة تدعم NULL.
class NullableUtcDateTimeConverter
    extends TypeConverter<DateTime?, String?> {
  const NullableUtcDateTimeConverter();

  @override
  DateTime? fromSql(String? fromDb) =>
      fromDb == null ? null : DateTime.parse(fromDb).toUtc();

  @override
  String? toSql(DateTime? value) => value?.toUtc().toIso8601String();
}

/// تاريخ فقط (بلا وقت) — يُخزَّن كـ `YYYY-MM-DD`.
///
/// مفيد لحقول مثل `event_date` حيث الوقت غير مهم.
/// يمنع مشاكل DST ويسهّل المقارنة النصية.
class DateOnlyConverter extends TypeConverter<DateTime, String> {
  const DateOnlyConverter();

  @override
  DateTime fromSql(String fromDb) => DateTime.parse('${fromDb}T00:00:00Z');

  @override
  String toSql(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
