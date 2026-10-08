// lib/core/company/company_service.dart
//
// خدمة الشركة — تضمن وجود شركة محلية على الجهاز.
//
// في هذه المرحلة: شركة واحدة ثابتة (single-tenant local).
// لاحقاً: تُستبدل بـ auth حقيقي.

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/tables.dart';

/// معرّفات ثابتة للشركة والمستخدم المحليين.
/// صيغة UUIDv4 صالحة (version=4، variant=8).
const String kLocalCompanyId = '00000000-0000-4000-8000-000000000001';
const String kLocalUserId = '00000000-0000-4000-8000-000000000002';
const String kLocalSettingsId = '00000000-0000-4000-8000-000000000003';

class CompanyService {
  CompanyService(this._db);

  final AppDatabase _db;

  /// يضمن وجود الشركة + المستخدم + الإعدادات.
  /// آمن للاستدعاء عدة مرات (idempotent).
  Future<CompanyRow> ensureLocalCompany() async {
    return _db.transaction(() async {
      // 1. الشركة.
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

      // 2. المستخدم المحلي.
      final user = await (_db.select(_db.usersTable)
            ..where((t) => t.id.equals(kLocalUserId)))
          .getSingleOrNull();

      if (user == null) {
        final now = DateTime.now().toUtc();
        await _db.into(_db.usersTable).insert(
              UsersTableCompanion.insert(
                id: kLocalUserId,
                companyId: kLocalCompanyId,
                displayName: 'أنا',
                role: const Value('owner'),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      // 3. الإعدادات.
      final settings = await (_db.select(_db.companySettingsTable)
            ..where((t) => t.id.equals(kLocalSettingsId)))
          .getSingleOrNull();

      if (settings == null) {
        final now = DateTime.now().toUtc();
        await _db.into(_db.companySettingsTable).insert(
              CompanySettingsTableCompanion.insert(
                id: kLocalSettingsId,
                companyId: kLocalCompanyId,
                currencyCode: const Value('SAR'),
                currencySymbol: const Value('ر.س'),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }

      return company;
    });
  }
}
