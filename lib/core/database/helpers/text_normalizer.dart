// lib/core/database/helpers/text_normalizer.dart

/// توحيد النص العربي للبحث.
///
/// Contract:
///   - "أحمد" → "احمد"
///   - "فاطمة" → "فاطمه"
///   - "مُحَمَّد" → "محمد"
///   - الفراغات المتعددة → فراغ واحد.
///
/// يُستخدم لتوليد:
///   - nameKey (للعميل)
///   - searchText (للحجز)
///   - phoneKey (للعميل)
class TextNormalizer {
  static final _diacritics = RegExp(r'[\u064B-\u0652\u0670\u0640]');
  static final _whitespace = RegExp(r'\s+');

  /// توحيد كامل للنص العربي.
  static String normalize(String input) {
    var s = input.toLowerCase();
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
    s = s.replaceAll('ى', 'ي');
    s = s.replaceAll('ة', 'ه');
    s = s.replaceAll('ؤ', 'و');
    s = s.replaceAll('ئ', 'ي');
    s = s.replaceAll(_diacritics, '');
    s = s.replaceAll(_whitespace, ' ').trim();
    return s;
  }

  /// توحيد الهاتف: أرقام فقط + توحيد الصيغة الدولية.
  ///
  /// "0777123456" → "967777123456" (لليمن افتراضياً).
  /// "+967 77 712 3456" → "967777123456".
  static String normalizePhone(String input, {String defaultCountry = '967'}) {
    var digits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';

    // أزل 00 من البداية.
    if (digits.startsWith('00')) digits = digits.substring(2);

    // أزل 0 من البداية.
    if (digits.startsWith('0')) digits = digits.substring(1);

    // إذا لم يبدأ بـ 967 وأطواله 9 (رقم يمني محلي)، أضف كود الدولة.
    if (!digits.startsWith(defaultCountry) && digits.length == 9) {
      digits = '$defaultCountry$digits';
    }

    return digits;
  }

  /// توليد نص بحث موحّد من عدة حقول.
  /// مثال: buildSearchText(['أحمد', '777123456', 'B-001'])
  ///     → "احمد 967777123456 b-001"
  static String buildSearchText(Iterable<String?> parts) {
    return parts
        .whereType<String>()
        .where((p) => p.isNotEmpty)
        .map(normalize)
        .join(' ');
  }
}
