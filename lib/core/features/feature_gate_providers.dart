import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../company/company_providers.dart';
import '../database/database_provider.dart';
import 'feature_gate_service.dart';
import 'models/feature_result.dart';

final featureGateServiceProvider = Provider<FeatureGateService>((ref) => FeatureGateService(db: ref.watch(appDatabaseProvider), companyId: ref.watch(currentCompanyIdProvider)));
final featureResultProvider = FutureProvider.family<FeatureResult, String>((ref, code) => ref.watch(featureGateServiceProvider).resolve(code));
final featureEnabledProvider = FutureProvider.family<bool, String>((ref, code) => ref.watch(featureGateServiceProvider).isEnabled(code));
