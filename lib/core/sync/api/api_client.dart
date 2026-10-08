import '../models/sync_result.dart';

abstract class ApiClient {
  Future<PushBatchResponse> push(List<Map<String, dynamic>> commands);
  Future<PullBatchResponse> pull({String? cursor, int limit = 250});
  bool get isEnabled;
  String get transportMode;
}

class MockApiClient implements ApiClient {
  @override
  bool get isEnabled => false;
  @override
  String get transportMode => 'mock';
  @override
  Future<PushBatchResponse> push(List<Map<String, dynamic>> commands) async => const PushBatchResponse(ok: false, results: [], message: 'MockTransportDisabled: لا يوجد خادم حقيقي متصل. لم تُفرَّغ الطابور.', statusCode: 503, retryable: true);
  @override
  Future<PullBatchResponse> pull({String? cursor, int limit = 250}) async => const PullBatchResponse(ok: false, changes: [], message: 'MockTransportDisabled: Pull معطّل حتى ربط Laravel.', statusCode: 503);
}
