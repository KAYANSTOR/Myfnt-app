import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/helpers/uuid_generator.dart';
import '../../../core/database/tables.dart';

class PackageRepository {
  PackageRepository({required AppDatabase db, required String companyId, required String actorId, required String actorName}) : _db = db, _companyId = companyId, _actorId = actorId, _actorName = actorName;
  final AppDatabase _db; final String _companyId; final String _actorId; final String _actorName;
  Stream<List<BookingPackageRow>> watchAll() => _db.packagesDao.watchAll(companyId: _companyId);
  Stream<List<BookingPackageRow>> watchActive() => _db.packagesDao.watchActive(companyId: _companyId);
  Future<List<BookingPackageRow>> getAll() => _db.packagesDao.getAll(companyId: _companyId);
  Future<BookingPackageRow?> getById(String id) => _db.packagesDao.getById(id);
  Future<List<BookingPackageVersionRow>> getVersions(String id) => _db.packagesDao.getVersionsForPackage(id);

  Future<String> add({required String name, String? icon, String? description, int regularPriceMinor = 0, int seasonPriceMinor = 0, int defaultDepositMinor = 0, String currency = 'YER', bool allowDoubleBooking = false, bool allowDiscount = true}) => _writePackage(name: name, icon: icon, description: description, regularPriceMinor: regularPriceMinor, seasonPriceMinor: seasonPriceMinor, defaultDepositMinor: defaultDepositMinor, currency: currency, allowDoubleBooking: allowDoubleBooking, allowDiscount: allowDiscount);

  Future<String> _writePackage({required String name, String? icon, String? description, required int regularPriceMinor, required int seasonPriceMinor, required int defaultDepositMinor, required String currency, required bool allowDoubleBooking, required bool allowDiscount}) async {
    return _db.transaction(() async {
      if (await _db.packagesDao.getByName(companyId: _companyId, name: name) != null) throw StateError('يوجد باقة بنفس الاسم: $name');
      final now = DateTime.now().toUtc(), id = UuidGenerator.random(), op = UuidGenerator.random(), version = 1;
      final sort = await _db.packagesDao.maxSortOrder(_companyId) + 1;
      final payload = <String, dynamic>{'id': id, 'name': name, 'icon': icon, 'description': description, 'regularPriceMinor': regularPriceMinor, 'seasonPriceMinor': seasonPriceMinor, 'defaultDepositMinor': defaultDepositMinor, 'currency': currency, 'allowDoubleBooking': allowDoubleBooking, 'allowDiscount': allowDiscount, 'packageVersion': version};
      await _db.into(_db.bookingPackagesTable).insert(BookingPackagesTableCompanion.insert(id: id, companyId: _companyId, name: name, icon: Value(icon), description: Value(description), regularPriceMinor: Value(regularPriceMinor), seasonPriceMinor: Value(seasonPriceMinor), defaultDepositMinor: Value(defaultDepositMinor), currency: Value(currency), allowDoubleBooking: Value(allowDoubleBooking), allowDiscount: Value(allowDiscount), packageVersion: const Value(1), sortOrder: Value(sort), status: const Value('active'), createdAt: now, updatedAt: now));
      await _db.into(_db.bookingPackageVersionsTable).insert(BookingPackageVersionsTableCompanion.insert(id: UuidGenerator.random(), companyId: _companyId, packageId: id, version: version, snapshot: payload, reason: const Value('initial'), effectiveFrom: now));
      await _outbox(op, 'booking_packages', id, 'create', payload, now);
      return id;
    });
  }

  Future<void> update({required String id, String? name, String? icon, String? description, int? regularPriceMinor, int? seasonPriceMinor, int? defaultDepositMinor, String? currency, bool? allowDoubleBooking, bool? allowDiscount}) async {
    await _db.transaction(() async {
      final old = await _db.packagesDao.getById(id); if (old == null) throw StateError('الباقة غير موجودة: $id');
      if (name != null && name != old.name && await _db.packagesDao.getByName(companyId: _companyId, name: name, excludeId: id) != null) throw StateError('يوجد باقة أخرى بنفس الاسم: $name');
      final now = DateTime.now().toUtc(), version = old.packageVersion + 1;
      final payload = <String, dynamic>{'id': id, 'name': name ?? old.name, 'icon': icon ?? old.icon, 'description': description ?? old.description, 'regularPriceMinor': regularPriceMinor ?? old.regularPriceMinor, 'seasonPriceMinor': seasonPriceMinor ?? old.seasonPriceMinor, 'defaultDepositMinor': defaultDepositMinor ?? old.defaultDepositMinor, 'currency': currency ?? old.currency, 'allowDoubleBooking': allowDoubleBooking ?? old.allowDoubleBooking, 'allowDiscount': allowDiscount ?? old.allowDiscount, 'packageVersion': version};
      await (_db.update(_db.bookingPackagesTable)..where((t) => t.id.equals(id))).write(BookingPackagesTableCompanion(name: name == null ? const Value.absent() : Value(name), icon: icon == null ? const Value.absent() : Value(icon), description: description == null ? const Value.absent() : Value(description), regularPriceMinor: regularPriceMinor == null ? const Value.absent() : Value(regularPriceMinor), seasonPriceMinor: seasonPriceMinor == null ? const Value.absent() : Value(seasonPriceMinor), defaultDepositMinor: defaultDepositMinor == null ? const Value.absent() : Value(defaultDepositMinor), currency: currency == null ? const Value.absent() : Value(currency), allowDoubleBooking: allowDoubleBooking == null ? const Value.absent() : Value(allowDoubleBooking), allowDiscount: allowDiscount == null ? const Value.absent() : Value(allowDiscount), packageVersion: Value(version), updatedAt: Value(now)));
      await _db.into(_db.bookingPackageVersionsTable).insert(BookingPackageVersionsTableCompanion.insert(id: UuidGenerator.random(), companyId: _companyId, packageId: id, version: version, snapshot: payload, reason: const Value('update'), effectiveFrom: now));
      await _outbox(UuidGenerator.random(), 'booking_packages', id, 'update', payload, now);
    });
  }
  Future<void> _setStatus(String id, String status) async { await _db.transaction(() async { final row = await getById(id); if (row == null) throw StateError('الباقة غير موجودة: $id'); final now = DateTime.now().toUtc(); await _db.packagesDao.setStatus(id: id, status: status, at: now); await _outbox(UuidGenerator.random(), 'booking_packages', id, 'update', {'id': id, 'status': status}, now); }); }
  Future<void> hide(String id) => _setStatus(id, 'hidden'); Future<void> unhide(String id) => _setStatus(id, 'active'); Future<void> archive(String id) => _setStatus(id, 'archived');
  Future<void> _outbox(String op, String type, String id, String operation, Map<String, dynamic> payload, DateTime now) => _db.outboxDao.enqueue(OutboxTableCompanion.insert(operationId: op, companyId: _companyId, entityType: type, entityId: id, entityKey: '$_companyId|$type|$id', operation: operation, payload: payload, createdAt: now, updatedAt: now));
}
