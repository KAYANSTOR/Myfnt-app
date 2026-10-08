import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/helpers/uuid_generator.dart';
import 'feature_seed_data.dart';
import 'models/feature_result.dart';

class FeatureGateService {
  FeatureGateService({required this._db, required this._companyId});
  final AppDatabase _db;
  final String _companyId;

  Future<void> ensureSeeded() async {
    await _db.transaction(() async {
      if ((await _db.select(_db.featureCatalogTable).get()).isEmpty) {
        final now = DateTime.now().toUtc();
        for (var i = 0; i < FeatureSeedData.features.length; i++) {
          final f = FeatureSeedData.features[i];
          await _db.into(_db.featureCatalogTable).insert(FeatureCatalogTableCompanion.insert(id: UuidGenerator.random(), code: f['code'] as String, nameAr: f['nameAr'] as String, groupCode: f['group'] as String, featureType: f['type'] as String, defaultPeriodType: Value(f['period'] as String?), unit: Value(f['unit'] as String?), countStrategy: Value(f['strategy'] as String? ?? 'switch'), sortOrder: Value(i), updatedAt: now));
        }
      }
      if ((await _db.select(_db.planFeaturesTable).get()).isEmpty) {
        final now = DateTime.now().toUtc();
        for (final plan in FeatureSeedData.plans.entries) {
          for (final entry in plan.value.entries) {
            final descriptor = FeatureSeedData.features.firstWhere((f) => f['code'] == entry.key);
            final type = descriptor['type'] as String;
            final value = entry.value;
            await _db.into(_db.planFeaturesTable).insert(PlanFeaturesTableCompanion.insert(id: UuidGenerator.random(), planCode: plan.key, featureCode: entry.key, enabled: Value(_isValueEnabled(value, type)), limitValue: Value(_extractLimit(value, type)), periodType: Value(descriptor['period'] as String?), updatedAt: now));
          }
        }
      }
    });
  }

  bool _isValueEnabled(dynamic value, String type) => value == null || (type == 'boolean' ? value == true : type == 'config' || (value is num ? value > 0 : value != false));
  int? _extractLimit(dynamic value, String type) => value is num && type != 'boolean' && type != 'config' ? value.toInt() : null;

  Future<FeatureResult> resolve(String featureCode) async {
    var enabled = false; int? limit; String? periodType; Map<String, dynamic>? config; var source = 'default';
    final planCode = await _currentPlanCode();
    final plan = await (_db.select(_db.planFeaturesTable)..where((t) => t.planCode.equals(planCode) & t.featureCode.equals(featureCode))).getSingleOrNull();
    if (plan != null) { enabled = plan.enabled; limit = plan.limitValue; periodType = plan.periodType; config = plan.configJson; source = 'plan'; }
    final override = await (_db.select(_db.companyFeatureOverridesTable)..where((t) => t.companyId.equals(_companyId) & t.featureCode.equals(featureCode) & t.status.equals('active'))).getSingleOrNull();
    if (override != null) { enabled = override.enabledOverride ?? enabled; limit = override.limitOverride ?? limit; periodType = override.periodTypeOverride ?? periodType; config = override.configOverrideJson ?? config; source = 'override'; }
    int? used; int? remaining;
    if (_isPeriodic(periodType)) { final counter = await (_db.select(_db.usageCountersTable)..where((t) => t.companyId.equals(_companyId) & t.metricCode.equals(featureCode) & t.periodKey.equals(_periodKeyFor(periodType)))).getSingleOrNull(); used = counter?.usedCount ?? 0; if (limit != null) remaining = (limit - used).clamp(0, limit); } else if (limit != null && limit > 0) { remaining = limit; }
    return FeatureResult(code: featureCode, enabled: enabled, limit: limit, used: used, remaining: remaining, periodType: periodType, config: config, source: source);
  }
  Future<bool> isEnabled(String featureCode) async => (await resolve(featureCode)).enabled;
  Future<int?> remaining(String featureCode) async => (await resolve(featureCode)).remaining;

  Future<FeatureCheck> check(String featureCode, {int delta = 1}) async {
    final result = await resolve(featureCode);
    if (!result.enabled) return FeatureCheck.fail(result, code: FeatureErrorCodes.featureNotAvailable, message: 'الميزة غير متاحة في خطتك الحالية');
    if (result.limit != null && result.used != null && result.used! + delta > result.limit!) {
      final code = switch (result.periodType) {'monthly' => FeatureErrorCodes.monthlyLimitReached, 'yearly' => FeatureErrorCodes.yearlyLimitReached, _ => FeatureErrorCodes.planLimitReached};
      return FeatureCheck.fail(result, code: code, message: 'تم بلوغ الحد: ${result.used}/${result.limit}');
    }
    return FeatureCheck.pass(result);
  }

  Future<void> consume(String featureCode, {int delta = 1}) async {
    if (delta <= 0) return;
    final result = await resolve(featureCode); if (!_isPeriodic(result.periodType)) return;
    final periodKey = _periodKeyFor(result.periodType); final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      final existing = await (_db.select(_db.usageCountersTable)..where((t) => t.companyId.equals(_companyId) & t.metricCode.equals(featureCode) & t.periodKey.equals(periodKey))).getSingleOrNull();
      if (existing == null) {
        await _db.into(_db.usageCountersTable).insert(UsageCountersTableCompanion.insert(id: UuidGenerator.random(), companyId: _companyId, metricCode: featureCode, periodKey: periodKey, usedCount: Value(delta), limitSnapshot: Value(result.limit), updatedAt: now));
      } else {
        await (_db.update(_db.usageCountersTable)..where((t) => t.id.equals(existing.id))).write(UsageCountersTableCompanion(usedCount: Value(existing.usedCount + delta), updatedAt: Value(now)));
      }
    });
  }

  Future<String> _currentPlanCode() async { final sub = await (_db.select(_db.companySubscriptionsTable)..where((t) => t.companyId.equals(_companyId) & t.status.equals('active'))..orderBy([(t) => OrderingTerm.desc(t.startsAt)])..limit(1)).getSingleOrNull(); return sub?.planCode ?? 'ULTRA'; }
  bool _isPeriodic(String? period) => period == 'monthly' || period == 'yearly' || period == 'subscription';
  String _periodKeyFor(String? period) { final now = DateTime.now().toUtc(); if (period == 'yearly') return '${now.year}'; if (period == 'monthly') return '${now.year}-${now.month.toString().padLeft(2, '0')}'; return 'lifetime'; }
}
