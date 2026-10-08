import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [CompanySettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);
  Stream<CompanySettingsRow?> watch({required String companyId}) =>
      (select(companySettingsTable)..where((t) => t.companyId.equals(companyId))).watchSingleOrNull();
  Future<CompanySettingsRow?> get({required String companyId}) =>
      (select(companySettingsTable)..where((t) => t.companyId.equals(companyId))).getSingleOrNull();
  Future<int> insert(CompanySettingsTableCompanion entry) => into(companySettingsTable).insert(entry);
  Future<bool> updateSettings(CompanySettingsTableCompanion entry) => update(companySettingsTable).replace(entry);
}
