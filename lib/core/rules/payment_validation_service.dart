import '../../features/settings/data/settings_repository.dart';
import '../database/tables.dart';
import 'models/validation_result.dart';

class PaymentValidationService {
  PaymentValidationService({required this.settingsRepository});

  final SettingsRepository settingsRepository;
  static const String directionIn = 'in';
  static const String directionOut = 'out';
  static const String methodCash = 'cash';
  static const String methodVoucher = 'voucher';

  Future<ValidationResult> validate({
    required BookingRow booking,
    required int amountMinor,
    required String direction,
    required String method,
    required String date,
  }) async {
    if (amountMinor <= 0) return const ValidationResult.invalid(field: 'amount', message: 'أدخل مبلغًا صحيحًا أكبر من الصفر');
    if (direction != directionIn && direction != directionOut) return const ValidationResult.invalid(field: 'direction', message: 'نوع الحركة غير صحيح');
    if (method != methodCash && method != methodVoucher) return const ValidationResult.invalid(field: 'method', message: 'طريقة الدفع غير صحيحة');
    if (!_isValidIsoDate(date)) return const ValidationResult.invalid(field: 'date', message: 'تاريخ الدفعة غير صحيح');
    if (direction == directionIn) {
      if (booking.status == 'cancelled' || booking.status == 'archived') return const ValidationResult.invalid(field: 'booking', message: 'الحجز ملغى أو مؤرشف؛ لا يمكن تسجيل دفعة');
      final settings = await settingsRepository.get();
      final remaining = _remainingFor(booking);
      if (!(settings?.allowReceiptOverRemaining ?? false) && amountMinor > remaining) {
        return const ValidationResult.invalid(field: 'amount', message: 'الدفعة تتجاوز المبلغ المتبقي؛ فعّل السماح بسند قبض زائد أو عدّل المبلغ');
      }
    } else if (amountMinor > booking.paidMinor) {
      return const ValidationResult.invalid(field: 'amount', message: 'الصرف يتجاوز الرصيد المقبوض المرتبط بهذا الحجز');
    }
    return const ValidationResult.valid();
  }

  int _remainingFor(BookingRow booking) => booking.amountMinor - booking.paidMinor;

  bool _isValidIsoDate(String value) {
    if (value.length != 10 || value[4] != '-' || value[7] != '-') return false;
    final year = int.tryParse(value.substring(0, 4));
    final month = int.tryParse(value.substring(5, 7));
    final day = int.tryParse(value.substring(8, 10));
    if (year == null || month == null || day == null) return false;
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }
}
