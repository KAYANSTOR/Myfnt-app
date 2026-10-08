// lib/core/database/converters/uuid_converter.dart
import 'package:drift/drift.dart';

/// UUID Converter — يضمن أن كل معرّف قانوني.
///
/// Contract:
///   - يُخزَّن UUID كنص lowercase.
///   - يُرفض أي نص ليس بصيغة UUID.
///   - متوافق مع RFC 9562 (UUIDv8).
///
/// يُستخدم في كل جدول له معرّف يُزامَن (Bookings, Customers, Payments...).
class UuidConverter extends TypeConverter<String, String> {
  const UuidConverter();

  static final _regex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static bool isValid(String? value) =>
      value != null && _regex.hasMatch(value);

  @override
  String fromSql(String fromDb) => fromDb.toLowerCase();

  @override
  String toSql(String value) {
    if (!isValid(value)) {
      throw ArgumentError(
        'IDENTITY_CONTRACT_VIOLATION: "$value" ليس UUID صالح.',
      );
    }
    return value.toLowerCase();
  }
}
