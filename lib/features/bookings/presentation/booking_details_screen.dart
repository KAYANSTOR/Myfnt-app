import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/booking.dart';

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen({
    super.key,
    required this.booking,
    this.onEdit,
    this.onCancel,
    this.onAddPayment,
  });

  final Booking booking;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onAddPayment;

  bool get _isReadOnly => booking.status == BookingStatus.cancelled;

  bool get _canEdit => !_isReadOnly && onEdit != null;
  bool get _canCancel => !_isReadOnly && onCancel != null;
  bool get _canAddPayment => !_isReadOnly && onAddPayment != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: AppColors.textDark,
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'رجوع',
          ),
          title: const Text(
            'تفاصيل الحجز',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          actions: [
            if (_canEdit)
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('تعديل'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _HeaderCard(booking: booking),
              const SizedBox(height: 12),
              _CustomerCard(name: booking.customerName),
              const SizedBox(height: 12),
              _ScheduleCard(date: booking.date, createdAt: booking.createdAt),
              const SizedBox(height: 12),
              _AmountsCard(booking: booking),
              if ((booking.note ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _NoteCard(note: booking.note!.trim()),
              ],
              const SizedBox(height: 20),
              _Actions(
                canEdit: _canEdit,
                canCancel: _canCancel,
                canAddPayment: _canAddPayment,
                onEdit: onEdit,
                onCancel: onCancel,
                onAddPayment: onAddPayment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// رأس: رقم الحجز + اسم العميل + الحالة
// ─────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle(booking.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.color.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: s.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(s.icon, color: s.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatBookingNumber(booking.id),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fallback(booking.customerName, 'عميل غير محدد'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMid,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(status: booking.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: s.color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 12, color: s.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: s.color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// بطاقة العميل
// ─────────────────────────────────────────────────────────────
class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'العميل',
      icon: Icons.person_outline,
      children: [
        _DetailRow(label: 'الاسم', value: _fallback(name, 'غير محدد')),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// بطاقة الموعد
// ─────────────────────────────────────────────────────────────
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.date, this.createdAt});
  final DateTime date;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'الموعد',
      icon: Icons.event_outlined,
      children: [
        _DetailRow(label: 'التاريخ', value: _formatDate(date)),
        if (createdAt != null)
          _DetailRow(label: 'أُنشئ في', value: _formatDate(createdAt!)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// بطاقة المبالغ
// ─────────────────────────────────────────────────────────────
class _AmountsCard extends StatelessWidget {
  const _AmountsCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final remaining = booking.amountRemaining;
    final isPartial = booking.amountPaid > 0 && remaining > 0;
    return _DetailCard(
      title: 'المبالغ',
      icon: Icons.payments_outlined,
      children: [
        _AmountRow(
          label: 'الإجمالي',
          value: _formatMoney(booking.amountTotal),
        ),
        _AmountRow(
          label: 'المدفوع',
          value: _formatMoney(booking.amountPaid),
          valueColor: booking.amountPaid > 0 ? AppColors.booked : null,
        ),
        _AmountRow(
          label: 'المتبقي',
          value: _formatMoney(remaining),
          valueColor: remaining > 0 ? AppColors.error : AppColors.booked,
          emphasize: isPartial,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// بطاقة الملاحظة
// ─────────────────────────────────────────────────────────────
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'ملاحظات',
      icon: Icons.notes_outlined,
      children: [
        Text(
          note,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// الأزرار السفلية
// ─────────────────────────────────────────────────────────────
class _Actions extends StatelessWidget {
  const _Actions({
    required this.canEdit,
    required this.canCancel,
    required this.canAddPayment,
    this.onEdit,
    this.onCancel,
    this.onAddPayment,
  });

  final bool canEdit;
  final bool canCancel;
  final bool canAddPayment;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onAddPayment;

  @override
  Widget build(BuildContext context) {
    final showRow = canEdit || canCancel;
    return Column(
      children: [
        if (canAddPayment)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddPayment,
              icon: const Icon(Icons.add_card_outlined, size: 18),
              label: const Text('إضافة دفعة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (canAddPayment && showRow) const SizedBox(height: 10),
        if (showRow)
          Row(
            children: [
              if (canEdit)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('تعديل الحجز'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: .4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (canEdit && canCancel) const SizedBox(width: 10),
              if (canCancel)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('إلغاء الحجز'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: .4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widgets مساعدة
// ─────────────────────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textMid.withValues(alpha: .12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMid, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize ? AppColors.textDark : AppColors.textMid,
                fontSize: emphasize ? 14 : 13,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: valueColor ?? AppColors.textDark,
              fontSize: emphasize ? 15 : 14,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// أدوات
// ─────────────────────────────────────────────────────────────
class _StatusStyle {
  const _StatusStyle(this.color, this.icon);
  final Color color;
  final IconData icon;
}

_StatusStyle _statusStyle(BookingStatus status) {
  switch (status) {
    case BookingStatus.confirmed:
      return _StatusStyle(AppColors.booked, Icons.check_circle_outline);
    case BookingStatus.partial:
      return _StatusStyle(AppColors.partial, Icons.pie_chart_outline);
    case BookingStatus.pending:
      return _StatusStyle(AppColors.textMid, Icons.hourglass_empty);
    case BookingStatus.cancelled:
      return _StatusStyle(AppColors.error, Icons.cancel_outlined);
  }
}

String _fallback(String? value, String fb) {
  final v = value?.trim() ?? '';
  return v.isEmpty ? fb : v;
}

String _formatBookingNumber(int id) => '#${id.toString().padLeft(3, '0')}';

String _formatDate(DateTime d) {
  const months = [
    'يناير','فبراير','مارس','أبريل','مايو','يونيو',
    'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

/// يحوّل double إلى نص بفاصل الآلاف ومنزلتين عشريتين عند الحاجة.
String _formatMoney(double amount) {
  final cents = (amount * 100).round();
  final negative = cents < 0;
  final abs = cents.abs();
  final whole = abs ~/ 100;
  final frac = abs % 100;

  final s = whole.toString();
  final parts = <String>[];
  for (int i = s.length; i > 0; i -= 3) {
    final start = i - 3 < 0 ? 0 : i - 3;
    parts.insert(0, s.substring(start, i));
  }

  final buf = StringBuffer();
  if (negative) buf.write('-');
  buf.write(parts.join(','));
  if (frac > 0) {
    buf
      ..write('.')
      ..write(frac.toString().padLeft(2, '0'));
  }
  return buf.toString();
}
