import '../../features/settings/data/settings_repository.dart';
import '../database/app_database.dart';
import 'models/package_financials.dart';

class SeasonPricingService {
  SeasonPricingService({required this.settingsRepository});

  final SettingsRepository settingsRepository;

  Future<bool> isSeasonDate(DateTime date) async {
    final settings = await settingsRepository.get();
    if (settings == null || !settings.seasonEnabled) return false;
    final start = settings.seasonStartMmdd;
    final end = settings.seasonEndMmdd;
    if (!_isValidMmDd(start) || !_isValidMmDd(end)) {
      return false;
    }
    final mmdd = _formatMmDd(date);
    if (start.compareTo(end) <= 0) {
      return mmdd.compareTo(start) >= 0 && mmdd.compareTo(end) <= 0;
    }
    return mmdd.compareTo(start) >= 0 || mmdd.compareTo(end) <= 0;
  }

  bool hasSeasonPrice(BookingPackageRow package) => package.seasonPriceMinor > 0;

  Future<PackageFinancials> computeFinancials({
    required BookingPackageRow package,
    DateTime? date,
  }) async {
    final hasDifferentSeason = package.seasonPriceMinor > 0 &&
        package.seasonPriceMinor != package.regularPriceMinor;
    if (date == null) {
      return PackageFinancials(
        package: package,
        price: hasDifferentSeason ? null : package.regularPriceMinor,
        deposit: package.defaultDepositMinor,
        currency: package.currency,
        pendingDate: hasDifferentSeason,
        isSeason: false,
      );
    }
    final isSeason = await isSeasonDate(date);
    final price = isSeason && package.seasonPriceMinor > 0
        ? package.seasonPriceMinor
        : package.regularPriceMinor;
    return PackageFinancials(
      package: package,
      price: price,
      deposit: package.defaultDepositMinor,
      currency: package.currency,
      pendingDate: false,
      isSeason: isSeason,
    );
  }

  Future<int> priceForPackage({required BookingPackageRow package, required DateTime date}) async =>
      (await computeFinancials(package: package, date: date)).price ?? package.regularPriceMinor;

  DepositStatus computeDepositStatus({required int requiredDeposit, required int paid, int? price}) {
    final remaining = (requiredDeposit - paid).clamp(0, requiredDeposit);
    return DepositStatus(
      requiredDeposit: requiredDeposit,
      paid: paid,
      remaining: remaining,
      isFulfilled: paid >= requiredDeposit,
      hasShortfall: paid < requiredDeposit,
      isInvalid: price != null && requiredDeposit > price,
    );
  }

  String _formatMmDd(DateTime date) => '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool _isValidMmDd(String value) {
    if (value.length != 5 || value[2] != '-') return false;
    final month = int.tryParse(value.substring(0, 2));
    final day = int.tryParse(value.substring(3, 5));
    return month != null && day != null && month >= 1 && month <= 12 && day >= 1 && day <= 31;
  }
}
