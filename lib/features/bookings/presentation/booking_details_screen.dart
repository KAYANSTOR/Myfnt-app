import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/booking.dart';

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen({super.key, required this.booking, this.onEdit, this.onCancel, this.onAddPayment, this.onCallCustomer});
  final Booking booking;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onAddPayment;
  final VoidCallback? onCallCustomer;

  bool get _readOnly => booking.status == BookingStatus.cancelled || booking.status == BookingStatus.completed || booking.status == BookingStatus.archived;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(title: const Text('تفاصيل الحجز'), actions: [if (!_readOnly && onEdit != null) TextButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 17), label: const Text('تعديل'))]),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
          _Header(booking: booking),
          const SizedBox(height: 12),
          _Card(title: 'العميل', icon: Icons.person_outline, children: [
            _Row(label: 'الاسم', value: booking.customerName),
            _Row(label: 'رقم الهاتف', value: booking.customerPhone ?? 'غير محدد', trailing: booking.customerPhone != null && onCallCustomer != null ? IconButton(onPressed: onCallCustomer, icon: const Icon(Icons.phone_outlined), color: AppColors.primary) : null),
          ]),
          const SizedBox(height: 12),
          _Card(title: 'الموعد', icon: Icons.event_outlined, children: [
            _Row(label: 'التاريخ', value: _date(booking.eventDate)),
            _Row(label: 'من', value: booking.startsAt == null ? 'الوقت غير محدد' : _time(booking.startsAt!)),
            _Row(label: 'إلى', value: booking.endsAt == null ? 'الوقت غير محدد' : _time(booking.endsAt!)),
          ]),
          const SizedBox(height: 12),
          _Card(title: 'المبالغ', icon: Icons.payments_outlined, children: [
            _Row(label: 'الإجمالي', value: _money(booking.amountMinor)),
            _Row(label: 'المدفوع', value: _money(booking.paidMinor), color: booking.paidMinor > 0 ? AppColors.success : null),
            _Row(label: 'المتبقي', value: _money(booking.amountRemainingMinor), color: booking.amountRemainingMinor > 0 ? AppColors.error : AppColors.success, bold: true),
          ]),
          const SizedBox(height: 12),
          _Card(title: 'الملاحظات', icon: Icons.notes_outlined, children: [Text(booking.note?.trim().isNotEmpty == true ? booking.note!.trim() : 'لا توجد ملاحظات', style: const TextStyle(color: AppColors.textMid))]),
          const SizedBox(height: 20),
          if (!_readOnly) ...[
            if (onAddPayment != null) FilledButton.icon(onPressed: onAddPayment, icon: const Icon(Icons.add_card_outlined), label: const Text('إضافة دفعة')),
            if (onCancel != null) ...[const SizedBox(height: 8), OutlinedButton.icon(onPressed: onCancel, icon: const Icon(Icons.cancel_outlined), label: const Text('إلغاء الحجز'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error))],
          ],
        ]),
      );

  static String _date(DateTime value) => '${value.year}/${value.month}/${value.day}';
  static String _time(DateTime value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  String _money(int minor) => '${(minor / 100).toStringAsFixed(2)} ${booking.currency}';
}

class _Header extends StatelessWidget {
  const _Header({required this.booking});
  final Booking booking;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.primary.withValues(alpha: .25))),
        child: Row(children: [
          CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(Icons.event_note_outlined, color: AppColors.primaryDark)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.bookingNo, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)), const SizedBox(height: 4), Text(booking.customerName, style: const TextStyle(color: AppColors.textMid))])),
          _Status(status: booking.status),
        ]),
      );
}

class _Status extends StatelessWidget {
  const _Status({required this.status});
  final BookingStatus status;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _color.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)), child: Text(status.label, style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w700)));
  Color get _color => switch (status) { BookingStatus.confirmed => AppColors.success, BookingStatus.partial => AppColors.warning, BookingStatus.pending => AppColors.info, BookingStatus.cancelled => AppColors.error, BookingStatus.completed => AppColors.success, BookingStatus.archived => AppColors.textMid };
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.icon, required this.children});
  final String title; final IconData icon; final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.available)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 20, color: AppColors.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark))]), const SizedBox(height: 10), ...children]));
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.trailing, this.color, this.bold = false});
  final String label; final String value; final Widget? trailing; final Color? color; final bool bold;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: AppColors.textMid))), Text(value, style: TextStyle(color: color ?? AppColors.textDark, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)), if (trailing != null) trailing! ]));
}
