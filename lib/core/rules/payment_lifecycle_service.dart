import '../database/app_database.dart';

class PaymentLifecycleService {
  const PaymentLifecycleService();

  bool canEdit(PaymentRow payment) => payment.status == 'posted';
  bool canVoid(PaymentRow payment) => payment.status == 'posted';
  bool isVoided(PaymentRow payment) => payment.status == 'reversed';

  int calculateEditDelta({required int oldAmountMinor, required int newAmountMinor, required String oldDirection, required String newDirection}) =>
      _signed(newAmountMinor, newDirection) - _signed(oldAmountMinor, oldDirection);

  int calculateVoidDelta({required int amountMinor, required String direction}) => -_signed(amountMinor, direction);

  bool wouldGoNegative({required int currentPaid, required int delta}) => currentPaid + delta < 0;

  bool wouldExceedTotal({required int currentPaid, required int delta, required int bookingTotal, required bool allowOverpayment}) =>
      !allowOverpayment && currentPaid + delta > bookingTotal;

  int _signed(int amountMinor, String direction) => direction == 'out' ? -amountMinor : amountMinor;
}
