import '../../database/app_database.dart';
import '../api/api_client.dart';
import '../models/sync_result.dart';

class PullWorker {
  PullWorker({required this.db, required this.api});
  final AppDatabase db;
  final ApiClient api;

  Future<PullResult> pull({int limit = 250}) async {
    if (!api.isEnabled) return PullResult.empty();
    // تطبيق التغييرات وتحديث cursor مؤجل لمرحلة ربط Laravel.
    return PullResult.empty();
  }
}
