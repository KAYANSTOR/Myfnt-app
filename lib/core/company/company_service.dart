// lib/core/company/company_service.dart
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

const String kLocalCompanyId = '00000000-0000-4000-8000-000000000001';
const String kLocalUserId = '00000000-0000-4000-8000-000000000002';
const String kLocalSettingsId = '00000000-0000-4000-8000-000000000003';

class CompanyService {
  CompanyService(this._db);

  final AppDatabase _db;

  Future<CompanyRow> ensureLocalCompany() async {
    return _db.transaction(() async {
      var company = await (_db.select(_db.companiesTable)
            ..where((t) => t.id.equals(kLocalCompanyId)))
          .getSingleOrNull();

      if (company == null) {
        final now = DateTime.now().toUtc();
        await _db.into(_db.companiesTable).insert(
              CompaniesTableCompanion.insert(
                id: kLocalCompanyId,
                name: 'نشاطي',
                source: const Value('offline_app'),
                createdAt: now,
                updatedAt: now,
              ),
            );
        company = await (_db.select(_db.companiesTable)
              ..where((t) => t.id.equals(kLocalCompanyId)))
            .getSingle();
      }

      final user = await (_db.select(_db.usersTable)
            ..where((t) => t.id.equals(kLocalUserId)))
          .getSingleOrNull();

      if (user == null) {
        final now = DateTime.now().toUtc();
        await _db.into(_db.usersTable).insert(
              UsersTableCompanion.insert(
                id: kLocalUserId,
                name: 'المستخدم المحلي',
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      final settings = await (_db.select(_db.companySettingsTable)
            ..where((t) => t.id.equals(kLocalSettingsId)))
          .getSingleOrNull();

      if (settings == null) {
        final now = DateTime.now().toUtc();
        await _db.into(_db.companySettingsTable).insert(
              CompanySettingsTableCompanion.insert(
                id: kLocalSettingsId,
                companyId: kLocalCompanyId,
                requiredFields: const {},
                reminderDays: const [10, 7, 3, 1, 0],
                updatedAt: now,
              ),
            );
      }

      return company;
    });
  }
}
