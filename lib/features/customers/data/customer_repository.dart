// ignore_for_file: prefer_initializing_formals
// lib/features/customers/data/customer_repository.dart
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/helpers/text_normalizer.dart';
import '../../../core/database/helpers/uuid_generator.dart';

class CustomerRepository {
  CustomerRepository({
    required AppDatabase db,
    required String companyId,
  })  : _db = db,
        _companyId = companyId;

  final AppDatabase _db;
  final String _companyId;

  Stream<List<CustomerRow>> watchAll() =>
      _db.customersDao.watchAll(companyId: _companyId);

  Future<CustomerRow?> getById(String id) => _db.customersDao.getById(id);

  Future<String> add({
    required String name,
    String? phone,
    String? address,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final id = UuidGenerator.random();
    final customerNo =
        (await _db.customersDao.nextCustomerNo(_companyId)) ?? '1';
    final nameKey = TextNormalizer.normalize(name);
    final phoneKey =
        phone == null ? null : TextNormalizer.normalizePhone(phone);
    final searchText = TextNormalizer.buildSearchText([
      customerNo,
      name,
      phone,
      address,
      notes,
    ]);

    await _db.into(_db.customersTable).insert(
          CustomersTableCompanion.insert(
            id: id,
            companyId: _companyId,
            customerNo: customerNo,
            name: name,
            phoneE164: Value(phoneKey),
            address: Value(address),
            notes: Value(notes),
            nameKey: nameKey,
            phoneKey: Value(phoneKey),
            searchText: searchText,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return id;
  }
}
