import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import 'api/api_client.dart';
import 'models/sync_result.dart';
import 'sync_engine.dart';

final apiClientProvider = Provider<ApiClient>((ref) => MockApiClient());
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(db: ref.watch(appDatabaseProvider), api: ref.watch(apiClientProvider));
  ref.onDispose(engine.dispose);
  return engine;
});
final syncStatusProvider = StreamProvider<SyncStatus>((ref) => ref.watch(syncEngineProvider).statusStream);
