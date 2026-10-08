import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'alert_rules_dao.g.dart';

@DriftAccessor(tables: [AlertRulesTable])
class AlertRulesDao extends DatabaseAccessor<AppDatabase> with _$AlertRulesDaoMixin {
  AlertRulesDao(super.db);
  Stream<List<AlertRuleRow>> watchAll({required String companyId}) =>
      (select(alertRulesTable)..where((t) => t.companyId.equals(companyId))..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  Stream<List<AlertRuleRow>> watchEnabled({required String companyId}) =>
      (select(alertRulesTable)..where((t) => t.companyId.equals(companyId) & t.enabled.equals(true))..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  Future<List<AlertRuleRow>> getAll({required String companyId}) => (select(alertRulesTable)..where((t) => t.companyId.equals(companyId))).get();
  Future<AlertRuleRow?> getById(String id) => (select(alertRulesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<List<AlertRuleRow>> getByEventCode({required String companyId, required String eventCode}) =>
      (select(alertRulesTable)..where((t) => t.companyId.equals(companyId) & t.eventCode.equals(eventCode))).get();
  Future<int> maxSortOrder(String companyId) async {
    final q = selectOnly(alertRulesTable)..addColumns([alertRulesTable.sortOrder.max()])..where(alertRulesTable.companyId.equals(companyId));
    return (await q.getSingle()).read(alertRulesTable.sortOrder.max()) ?? 0;
  }
  Future<int> insert(AlertRulesTableCompanion entry) => into(alertRulesTable).insert(entry);
  Future<bool> updateRule(AlertRulesTableCompanion entry) => update(alertRulesTable).replace(entry);
  Future<int> deleteRule(String id) => (delete(alertRulesTable)..where((t) => t.id.equals(id))).go();
}
