import 'package:drift/drift.dart';
import '../database/app_database.dart';

class SequenceService {
  SequenceService({required this.db, required this.companyId});
  final AppDatabase db;
  final String companyId;

  Future<int> _next(String table, String column, {String? extraWhere}) async {
    final where = extraWhere == null ? 'company_id = ?' : 'company_id = ? AND $extraWhere';
    final row = await db.customSelect(
      'SELECT MAX(CAST($column AS INTEGER)) AS max_no FROM $table WHERE $where',
      variables: [Variable<String>(companyId)],
    ).getSingleOrNull();
    return (row?.read<int?>('max_no') ?? 0) + 1;
  }
  Future<int> nextBookingNo() => _next('bookings', 'booking_no');
  Future<int> nextCustomerNo() => _next('customers', 'customer_no');
  Future<int> nextReceiptNo() => _next('payments', 'receipt_no');
  Future<int> nextMovementNo() => _next('payments', 'movement_no', extraWhere: 'movement_no IS NOT NULL');
}
