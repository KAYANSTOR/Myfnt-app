import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/settings_providers.dart';
import '../company/company_providers.dart';
import '../database/database_provider.dart';
import 'booking_lifecycle_service.dart';
import 'booking_validation_service.dart';
import 'payment_lifecycle_service.dart';
import 'payment_validation_service.dart';
import 'season_pricing_service.dart';

final seasonPricingServiceProvider = Provider<SeasonPricingService>((ref) => SeasonPricingService(
      settingsRepository: ref.watch(settingsRepositoryProvider),
    ));

final bookingValidationServiceProvider = Provider<BookingValidationService>((ref) => BookingValidationService(
      db: ref.watch(appDatabaseProvider),
      companyId: ref.watch(currentCompanyIdProvider),
      settingsRepository: ref.watch(settingsRepositoryProvider),
    ));

final bookingLifecycleServiceProvider = Provider<BookingLifecycleService>((ref) => const BookingLifecycleService());

final paymentValidationServiceProvider = Provider<PaymentValidationService>((ref) => PaymentValidationService(
      settingsRepository: ref.watch(settingsRepositoryProvider),
    ));

final paymentLifecycleServiceProvider = Provider<PaymentLifecycleService>((ref) => const PaymentLifecycleService());
