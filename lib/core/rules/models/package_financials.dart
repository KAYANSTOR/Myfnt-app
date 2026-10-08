import '../../database/tables.dart';

/// نتيجة حساب السعر والعربون لباقة في تاريخ معين.
class PackageFinancials {
  const PackageFinancials({
    required this.package,
    required this.price,
    required this.deposit,
    required this.currency,
    required this.pendingDate,
    required this.isSeason,
  });

  final BookingPackageRow package;
  final int? price;
  final int deposit;
  final String currency;
  final bool pendingDate;
  final bool isSeason;
}

class DepositStatus {
  const DepositStatus({
    required this.requiredDeposit,
    required this.paid,
    required this.remaining,
    required this.isFulfilled,
    required this.hasShortfall,
    required this.isInvalid,
  });

  final int requiredDeposit;
  final int paid;
  final int remaining;
  final bool isFulfilled;
  final bool hasShortfall;
  final bool isInvalid;
}
