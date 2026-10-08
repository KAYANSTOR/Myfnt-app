// lib/core/database/converters/json_converter.dart
import 'dart:convert';
import 'package:drift/drift.dart';

/// JSON Converters — للتخزين المرن (Snapshots, Payload, Config).
///
/// Contract:
///   - JSON صالح فقط.
///   - UTF-8 encoding.
///   - يستخدم في: Outbox.payload, Audit.before/after, Settings.communicationPolicy.
class JsonMapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) =>
      jsonDecode(fromDb) as Map<String, dynamic>;

  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}

/// نسخة تدعم NULL (للتعديلات التي بلا قبل/بعد).
class NullableJsonMapConverter
    extends TypeConverter<Map<String, dynamic>?, String?> {
  const NullableJsonMapConverter();

  @override
  Map<String, dynamic>? fromSql(String? fromDb) =>
      fromDb == null ? null : jsonDecode(fromDb) as Map<String, dynamic>;

  @override
  String? toSql(Map<String, dynamic>? value) =>
      value == null ? null : jsonEncode(value);
}

/// قوائم JSON (للـ changedFields, reminderDays).
class JsonListConverter extends TypeConverter<List<dynamic>, String> {
  const JsonListConverter();

  @override
  List<dynamic> fromSql(String fromDb) =>
      jsonDecode(fromDb) as List<dynamic>;

  @override
  String toSql(List<dynamic> value) => jsonEncode(value);
}

/// قوائم نصية (للـ String-only lists).
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
