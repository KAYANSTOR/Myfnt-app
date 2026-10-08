/// نتيجة حل ميزة واحدة.
class FeatureResult {
  const FeatureResult({
    required this.code,
    required this.enabled,
    required this.source,
    this.limit,
    this.used,
    this.remaining,
    this.periodType,
    this.config,
  });

  final String code;
  final bool enabled;
  final int? limit;
  final int? used;
  final int? remaining;
  final String? periodType;
  final Map<String, dynamic>? config;
  final String source;

  bool get isPeriodic => periodType == 'monthly' || periodType == 'yearly' || periodType == 'subscription';
  bool get hasNumericLimit => limit != null;
}

class FeatureCheck {
  const FeatureCheck({required this.ok, required this.result, this.errorCode, this.errorMessage});
  final bool ok;
  final FeatureResult result;
  final String? errorCode;
  final String? errorMessage;
  static FeatureCheck pass(FeatureResult r) => FeatureCheck(ok: true, result: r);
  static FeatureCheck fail(FeatureResult r, {required String code, required String message}) => FeatureCheck(ok: false, result: r, errorCode: code, errorMessage: message);
}

class FeatureErrorCodes {
  FeatureErrorCodes._();
  static const featureNotAvailable = 'FEATURE_NOT_AVAILABLE';
  static const planLimitReached = 'PLAN_LIMIT_REACHED';
  static const monthlyLimitReached = 'MONTHLY_LIMIT_REACHED';
  static const yearlyLimitReached = 'YEARLY_LIMIT_REACHED';
  static const storageLimitReached = 'STORAGE_LIMIT_REACHED';
  static const subscriptionExpired = 'SUBSCRIPTION_EXPIRED';
  static const companyNotApproved = 'COMPANY_NOT_APPROVED';
}
