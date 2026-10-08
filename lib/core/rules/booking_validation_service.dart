import 'package:drift/drift.dart';

import '../../features/settings/data/settings_repository.dart';
import '../database/app_database.dart';
import 'models/booking_draft.dart';
import 'models/validation_result.dart';

class BookingValidationService {
  BookingValidationService({required this.db, required this.companyId, required this.settingsRepository});

  final AppDatabase db;
  final String companyId;
  final SettingsRepository settingsRepository;

  Future<ValidationResult> validate(BookingDraft draft, {String? previousId}) async {
    if (draft.name.trim().length < 2) {
      return const ValidationResult.invalid(field: 'name', message: 'اسم العميل قصير جدًا');
    }
    if (!_isValidIsoDate(draft.date)) {
      return const ValidationResult.invalid(field: 'date', message: 'اختر تاريخًا صحيحًا');
    }
    final settings = await settingsRepository.get();
    final requiredFields = settings?.requiredFields ?? const <String, dynamic>{};
    final allowOverpayment = settings?.allowBookingOverpayment ?? false;
    final phone = (draft.phone ?? '').trim();
    if (requiredFields['phone'] == true && phone.isEmpty) {
      return const ValidationResult.invalid(field: 'phone', message: 'رقم الهاتف حقل إجباري');
    }
    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      return const ValidationResult.invalid(field: 'phone', message: 'رقم الهاتف غير صحيح');
    }
    if (draft.amount < 0) {
      return const ValidationResult.invalid(field: 'amount', message: 'أدخل مبلغًا صحيحًا غير سالب');
    }
    if (draft.paid < 0) {
      return const ValidationResult.invalid(field: 'paid', message: 'أدخل مبلغًا صحيحًا غير سالب');
    }
    if (draft.paid > draft.amount && !allowOverpayment) {
      return const ValidationResult.invalid(field: 'paid', message: 'المدفوع أكبر من إجمالي قيمة الحجز؛ فعّل السماح بالدفع الزائد أو عدّل المبلغ');
    }
    if (draft.hasTime) {
      if (!_isValidTime(draft.timeFrom) || !_isValidTime(draft.timeTo)) {
        return const ValidationResult.invalid(field: 'time', message: 'صيغة الوقت غير صحيحة');
      }
      if (draft.timeTo.compareTo(draft.timeFrom) <= 0) {
        return const ValidationResult.invalid(field: 'time', message: 'يجب أن يكون وقت النهاية بعد وقت البداية');
      }
    }
    if (requiredFields['package'] == true && (draft.packageId == null || draft.packageId!.isEmpty)) {
      return const ValidationResult.invalid(field: 'package', message: 'الباقة حقل إجباري');
    }
    if (requiredFields['amount'] == true && draft.amount <= 0) {
      return const ValidationResult.invalid(field: 'amount', message: 'المبلغ حقل إجباري ويجب أن يكون أكبر من 0');
    }
    if (requiredFields['notes'] == true && (draft.notes == null || draft.notes!.trim().isEmpty)) {
      return const ValidationResult.invalid(field: 'notes', message: 'الملاحظات حقل إجباري');
    }
    if (requiredFields['address'] == true && (draft.address == null || draft.address!.trim().isEmpty)) {
      return const ValidationResult.invalid(field: 'address', message: 'عنوان المناسبة حقل إجباري');
    }
    if (draft.packageId != null && draft.packageId!.isNotEmpty) {
      final package = await db.packagesDao.getById(draft.packageId!);
      if (package == null) {
        return const ValidationResult.invalid(field: 'package', message: 'الباقة غير موجودة');
      }
      if (!package.allowDoubleBooking && await _hasDuplicateOnDate(date: draft.date, packageId: draft.packageId!, excludeId: previousId)) {
        return ValidationResult.invalid(field: 'package', message: 'الباقة «${package.name}» لا تسمح بالحجز مرتين في نفس التاريخ');
      }
    }
    return const ValidationResult.valid();
  }

  Future<bool> _hasDuplicateOnDate({required String date, required String packageId, String? excludeId}) async {
    final excludeClause = excludeId != null ? ' AND b.id != ?' : '';
    final variables = <Variable<Object>>[
      Variable<String>(companyId), Variable<String>(date),
      const Variable<String>('cancelled'), const Variable<String>('archived'),
      Variable<String>(packageId), if (excludeId != null) Variable<String>(excludeId),
    ];
    final rows = await db.customSelect(
      'SELECT b.id AS id FROM bookings b INNER JOIN booking_details d ON d.booking_id = b.id '
      'WHERE b.company_id = ? AND b.event_date = ? AND b.status NOT IN (?, ?) AND d.package_id = ?$excludeClause LIMIT 1',
      variables: variables,
      readsFrom: {db.bookingsTable, db.bookingDetailsTable},
    ).get();
    return rows.isNotEmpty;
  }

  bool _isValidIsoDate(String value) {
    if (value.length != 10 || value[4] != '-' || value[7] != '-') return false;
    final year = int.tryParse(value.substring(0, 4));
    final month = int.tryParse(value.substring(5, 7));
    final day = int.tryParse(value.substring(8, 10));
    if (year == null || month == null || day == null) return false;
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }

  bool _isValidPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    return digits.isEmpty || (digits.length >= 7 && digits.length <= 15);
  }

  bool _isValidTime(String value) {
    if (value.length != 5 || value[2] != ':') return false;
    final hour = int.tryParse(value.substring(0, 2));
    final minute = int.tryParse(value.substring(3, 5));
    return hour != null && minute != null && hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }
}
