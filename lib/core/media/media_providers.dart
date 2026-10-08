import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../company/company_providers.dart';
import 'media_service.dart';

final mediaServiceProvider = Provider<MediaService>((ref) => MediaService(companyId: ref.watch(currentCompanyIdProvider)));
