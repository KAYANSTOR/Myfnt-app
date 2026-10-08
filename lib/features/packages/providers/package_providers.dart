import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/company/company_providers.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart';
import '../data/package_repository.dart';

final packageRepositoryProvider = Provider<PackageRepository>((ref) => PackageRepository(db: ref.watch(appDatabaseProvider), companyId: ref.watch(currentCompanyIdProvider), actorId: ref.watch(currentUserIdProvider), actorName: 'المستخدم المحلي'));
final allPackagesProvider = StreamProvider<List<BookingPackageRow>>((ref) => ref.watch(packageRepositoryProvider).watchAll());
final activePackagesProvider = StreamProvider<List<BookingPackageRow>>((ref) => ref.watch(packageRepositoryProvider).watchActive());
