import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'special_days_dao.g.dart';

@DriftAccessor(tables: [CalendarBlocksTable])
class SpecialDaysDao extends DatabaseAccessor<AppDatabase> with _$SpecialDaysDaoMixin {
  SpecialDaysDao(super.db);
  Stream<List<CalendarBlockRow>> watchAll({required String companyId}) =>
      (select(calendarBlocksTable)..where((t) => t.companyId.equals(companyId))..orderBy([(t) => OrderingTerm.asc(t.blockDate), (t) => OrderingTerm.asc(t.startDate)])).watch();
  Future<List<CalendarBlockRow>> getAll({required String companyId}) =>
      (select(calendarBlocksTable)..where((t) => t.companyId.equals(companyId))..orderBy([(t) => OrderingTerm.asc(t.blockDate)])).get();
  Future<CalendarBlockRow?> getById(String id) => (select(calendarBlocksTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<List<CalendarBlockRow>> getForDate({required String companyId, required String dateIso}) async {
    final all = await getAll(companyId: companyId);
    return all.where((b) {
      if (b.blockKind == 'single') return b.blockDate == dateIso;
      if (b.blockKind == 'range' && b.startDate != null && b.endDate != null) {
        return dateIso.compareTo(b.startDate!) >= 0 && dateIso.compareTo(b.endDate!) <= 0;
      }
      return b.blockKind == 'recurring_weekday' && b.startDate != null && dateIso.compareTo(b.startDate!) >= 0;
    }).toList();
  }
  Future<int> insert(CalendarBlocksTableCompanion entry) => into(calendarBlocksTable).insert(entry);
  Future<bool> updateBlock(CalendarBlocksTableCompanion entry) => update(calendarBlocksTable).replace(entry);
  Future<int> deleteBlock(String id) => (delete(calendarBlocksTable)..where((t) => t.id.equals(id))).go();
}
