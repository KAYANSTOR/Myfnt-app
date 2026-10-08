// lib/core/database/helpers/uuid_generator.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// مولّد UUIDv8 حتمي (Deterministic).
///
/// Contract:
///   - نفس (companyId, table, legacyId) → نفس UUID دائماً.
///   - متوافق مع RFC 9562 (UUIDv8).
///   - ليس سراً أمنياً — من يعرف المدخلات يعرف الناتج.
///
/// الفائدة:
///   - يمنع التكرار عند إعادة التشغيل.
///   - يسمح بـ Idempotency على الخادم.
///   - ثابت عبر الأجهزة.
class UuidGenerator {
  static const _uuid = Uuid();
  static const _namespace = 'MYFNT-OFFLINE-ID-v2';
  static final _cache = <String, String>{};

  /// UUIDv8 حتمي من مدخلات ثابتة.
  static String generate({
    required String companyId,
    required String table,
    required String legacyId,
  }) {
    final key = '$companyId|$table|$legacyId';
    return _cache.putIfAbsent(key, () => _compute(key));
  }

  /// UUIDv4 عشوائي (للكيانات المستقلة).
  /// يُستخدم في: Outbox.opId, Audit.id, Notification.id.
  static String random() => _uuid.v4();

  static String _compute(String key) {
    final hash = sha256.convert(utf8.encode('$_namespace|$key'));
    final bytes = hash.bytes.sublist(0, 16);

    // اضبط version=8 و variant=10xx (RFC 9562).
    bytes[6] = (bytes[6] & 0x0F) | 0x80;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    return _format(bytes);
  }

  static String _format(List<int> b) {
    String hex(int start, int end) => b
        .sublist(start, end)
        .map((x) => x.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }

  /// مسح الذاكرة المؤقتة (للاختبارات فقط).
  static void clearCache() => _cache.clear();
}
