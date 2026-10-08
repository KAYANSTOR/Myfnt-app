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
    return _db.transaction(() async {
      final now = DateTime.now().toUtc();
      final id = UuidGenerator.random();
      final customerNo =
          (await _db.customersDao.nextCustomerNo(_companyId)) ?? '1';
      final nameKey = TextNormalizer.normalize(name);
      final phoneKey =
          phone == null ? null : TextNormalizer.normalizePhone(phone);
      final searchText = TextNormalizer.buildSearchText([
        customerNo, name, phone, address, notes,
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
      final nowOp = UuidGenerator.random();
      await _db.outboxDao.enqueue(OutboxTableCompanion.insert(
        operationId: nowOp,
        companyId: _companyId,
        entityType: 'customers',
        entityId: id,
        entityKey: '$_companyId|customers|$id',
        operation: 'create',
        payload: {
          'id': id,
          'customerNo': customerNo,
          'name': name,
          'phoneE164': phoneKey,
          'address': address,
          'notes': notes,
        },
        createdAt: now,
        updatedAt: now,
      ));
      return id;
    });
  }

  Future<void> update({
    required String id,
    String? name,
    String? phone,
    String? address,
    String? notes,
  }) async {
    await _db.transaction(() async {
      final existing = await _db.customersDao.getById(id);
      if (existing == null) throw StateError('العميل غير موجود: $id');
      final now = DateTime.now().toUtc();
      final newName = name ?? existing.name;
      final newPhone = phone == null
          ? existing.phoneE164
          : TextNormalizer.normalizePhone(phone);
      final newAddress = address ?? existing.address;
      final newNotes = notes ?? existing.notes;
      final newNameKey = TextNormalizer.normalize(newName);
      final newSearch = TextNormalizer.buildSearchText([
        existing.customerNo, newName, newPhone, newAddress, newNotes,
      ]);
      await (_db.update(_db.customersTable)
            ..where((t) => t.id.equals(id)))
          .write(CustomersTableCompanion(
        name: name == null ? const Value.absent() : Value(newName),
        phoneE164: phone == null ? const Value.absent() : Value(newPhone),
        address: address == null ? const Value.absent() : Value(newAddress),
        notes: notes == null ? const Value.absent() : Value(newNotes),
        nameKey: name == null ? const Value.absent() : Value(newNameKey),
        phoneKey: phone == null ? const Value.absent() : Value(newPhone),
        searchText: Value(newSearch),
        updatedAt: Value(now),
      ));
      await _db.outboxDao.enqueue(OutboxTableCompanion.insert(
        operationId: UuidGenerator.random(),
        companyId: _companyId,
        entityType: 'customers',
        entityId: id,
        entityKey: '$_companyId|customers|$id',
        operation: 'update',
        payload: {
          'id': id,
          'customerNo': existing.customerNo,
          'name': newName,
          'phoneE164': newPhone,
          'address': newAddress,
          'notes': newNotes,
        },
        createdAt: now,
        updatedAt: now,
      ));
    });
  }
}
