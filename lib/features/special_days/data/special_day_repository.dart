import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/helpers/uuid_generator.dart';
import '../../../core/database/tables.dart';

class SpecialDayRepository {
  SpecialDayRepository({required AppDatabase db, required String companyId, required String actorId, required String actorName}) : _db = db, _companyId = companyId, _actorId = actorId, _actorName = actorName;
  final AppDatabase _db; final String _companyId; final String _actorId; final String _actorName;
  Stream<List<CalendarBlockRow>> watchAll() => _db.specialDaysDao.watchAll(companyId: _companyId);
  Future<List<CalendarBlockRow>> getAll() => _db.specialDaysDao.getAll(companyId: _companyId);
  Future<CalendarBlockRow?> getById(String id) => _db.specialDaysDao.getById(id);
  Future<List<CalendarBlockRow>> getForDate(String dateIso) => _db.specialDaysDao.getForDate(companyId: _companyId, dateIso: dateIso);
  Future<String> add({required String kind, required String title, String? blockDate, String? startDate, String? endDate, List<int>? weekdays, String? notes, String? colorHex}) async {
    if (!{'single', 'range', 'recurring_weekday'}.contains(kind)) throw ArgumentError('نوع اليوم المميز غير صالح: $kind');
    if (kind == 'single' && (blockDate == null || blockDate.isEmpty)) throw ArgumentError('يجب تحديد تاريخ اليوم');
    if (kind == 'range' && (startDate == null || endDate == null)) throw ArgumentError('يجب تحديد بداية ونهاية النطاق');
    return _db.transaction(() async { final now = DateTime.now().toUtc(), id = UuidGenerator.random(); final payload = {'id': id, 'kind': kind, 'title': title, 'blockDate': blockDate, 'startDate': startDate, 'endDate': endDate, 'weekdays': weekdays, 'notes': notes, 'colorHex': colorHex}; await _db.into(_db.calendarBlocksTable).insert(CalendarBlocksTableCompanion.insert(id: id, companyId: _companyId, blockKind: kind, title: title, blockDate: Value(blockDate), startDate: Value(startDate), endDate: Value(endDate), weekdays: Value(weekdays == null ? null : {'days': weekdays}), notes: Value(notes), colorHex: Value(colorHex), createdAt: now, updatedAt: now)); await _enqueue(id, 'create', payload, now); return id; });
  }
  Future<void> delete(String id) async { await _db.transaction(() async { if (await getById(id) == null) return; final now = DateTime.now().toUtc(); await _db.specialDaysDao.deleteBlock(id); await _enqueue(id, 'delete', {'id': id}, now); }); }
  Future<void> _enqueue(String id, String operation, Map<String, dynamic> payload, DateTime now) => _db.outboxDao.enqueue(OutboxTableCompanion.insert(operationId: UuidGenerator.random(), companyId: _companyId, entityType: 'calendar_blocks', entityId: id, entityKey: '$_companyId|calendar_blocks|$id', operation: operation, payload: payload, createdAt: now, updatedAt: now));
}
