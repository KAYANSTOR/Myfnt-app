import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../company/company_providers.dart';
import '../database/database_provider.dart';
import 'sequence_service.dart';

final sequenceServiceProvider = Provider<SequenceService>((ref) => SequenceService(db: ref.watch(appDatabaseProvider), companyId: ref.watch(currentCompanyIdProvider)));
