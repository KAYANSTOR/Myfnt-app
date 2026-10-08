class BookingLifecycleService {
  const BookingLifecycleService();

  static const List<int> supportedTemporaryHours = [12, 24, 48];

  bool canTransition({required String from, required String to}) {
    if (from == to) return true;
    const allowed = <String, Set<String>>{
      'active': {'cancelled', 'completed', 'archived'},
      'cancelled': {'active', 'archived'},
      'completed': {'archived'},
      'archived': <String>{},
    };
    return (allowed[from] ?? <String>{}).contains(to);
  }

  bool canCancel(String status) => status == 'active' || status == 'pending';
  bool canRestore(String status) => status == 'cancelled';
  bool canComplete(String status) => status == 'active';

  bool isTemporaryExpired({required String status, required int? temporaryExpiresAt, DateTime? now}) {
    if (status != 'pending' || temporaryExpiresAt == null) return false;
    return (now ?? DateTime.now()).millisecondsSinceEpoch >= temporaryExpiresAt;
  }

  int? temporaryRemainingHours({required String status, required int? temporaryExpiresAt, DateTime? now}) {
    if (status != 'pending' || temporaryExpiresAt == null) return null;
    final milliseconds = temporaryExpiresAt - (now ?? DateTime.now()).millisecondsSinceEpoch;
    if (milliseconds <= 0) return 0;
    return (milliseconds / Duration.millisecondsPerHour).ceil();
  }

  DateTime computeTemporaryExpiry({required int hours, DateTime? from}) =>
      (from ?? DateTime.now()).add(Duration(hours: hours));

  bool isValidTemporaryHours(int hours) => supportedTemporaryHours.contains(hours);

  String temporaryStatusText({
    required String status,
    required bool depositPending,
    required int depositRequired,
    required int paid,
    required int? temporaryExpiresAt,
    String currencyLabel = '',
    DateTime? now,
  }) {
    if (status != 'pending') return '';
    if (depositPending) {
      final remaining = (depositRequired - paid).clamp(0, depositRequired);
      if (remaining > 0) return 'بانتظار استكمال العربون: $remaining${currencyLabel.isEmpty ? '' : ' $currencyLabel'}';
    }
    if (temporaryExpiresAt == null) return 'مؤقت دون تاريخ انتهاء';
    final hours = temporaryRemainingHours(status: status, temporaryExpiresAt: temporaryExpiresAt, now: now);
    if (hours == null || hours <= 0) return 'انتهت مدة المؤقت';
    return 'متبقي $hours ساعة للمؤقت';
  }

  bool shouldAutoComplete({required String status, required String eventDate, DateTime? now}) {
    if (status != 'active') return false;
    final parsed = _tryParseIsoDate(eventDate);
    if (parsed == null) return false;
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    return today.difference(parsed).inDays > 7;
  }

  DateTime? _tryParseIsoDate(String value) {
    if (value.length != 10 || value[4] != '-' || value[7] != '-') return null;
    final year = int.tryParse(value.substring(0, 4));
    final month = int.tryParse(value.substring(5, 7));
    final day = int.tryParse(value.substring(8, 10));
    if (year == null || month == null || day == null) return null;
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day ? date : null;
  }
}
