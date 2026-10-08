import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'message_numbers_dao.g.dart';

@DriftAccessor(tables: [CompanyMessageNumbersTable])
class MessageNumbersDao extends DatabaseAccessor<AppDatabase> with _$MessageNumbersDaoMixin {
  MessageNumbersDao(super.db);
  Stream<List<CompanyMessageNumberRow>> watchAll({required String companyId}) =>
      (select(companyMessageNumbersTable)..where((t) => t.companyId.equals(companyId))..orderBy([(t) => OrderingTerm.asc(t.channel), (t) => OrderingTerm.desc(t.isDefault), (t) => OrderingTerm.asc(t.createdAt)])).watch();
  Stream<List<CompanyMessageNumberRow>> watchActive({required String companyId}) =>
      (select(companyMessageNumbersTable)..where((t) => t.companyId.equals(companyId) & t.status.equals('active'))..orderBy([(t) => OrderingTerm.asc(t.channel)])).watch();
  Future<List<CompanyMessageNumberRow>> getAll({required String companyId}) => (select(companyMessageNumbersTable)..where((t) => t.companyId.equals(companyId))).get();
  Future<CompanyMessageNumberRow?> getById(String id) => (select(companyMessageNumbersTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<List<CompanyMessageNumberRow>> getByChannel({required String companyId, required String channel}) => (select(companyMessageNumbersTable)..where((t) => t.companyId.equals(companyId) & t.channel.equals(channel))).get();
  Future<bool> existsByChannelAndPhone({required String companyId, required String channel, required String phoneE164, String? excludeId}) async {
    final q = select(companyMessageNumbersTable)..where((t) => t.companyId.equals(companyId) & t.channel.equals(channel) & t.phoneE164.equals(phoneE164));
    if (excludeId != null) q.where((t) => t.id.equals(excludeId).not());
    return await q.getSingleOrNull() != null;
  }
  Future<int> unsetChannelDefaults({required String companyId, required String channel}) =>
      (update(companyMessageNumbersTable)..where((t) => t.companyId.equals(companyId) & t.channel.equals(channel))).write(const CompanyMessageNumbersTableCompanion(isDefault: Value(false)));
  Future<int> insert(CompanyMessageNumbersTableCompanion entry) => into(companyMessageNumbersTable).insert(entry);
  Future<bool> updateNumber(CompanyMessageNumbersTableCompanion entry) => update(companyMessageNumbersTable).replace(entry);
  Future<int> deleteNumber(String id) => (delete(companyMessageNumbersTable)..where((t) => t.id.equals(id))).go();
}
