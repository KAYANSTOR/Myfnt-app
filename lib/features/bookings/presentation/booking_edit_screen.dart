import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/booking.dart';

typedef BookingSaveCallback = Future<void> Function(Booking updated);

class BookingEditScreen extends ConsumerStatefulWidget {
  const BookingEditScreen({
    super.key,
    required this.booking,
    this.onSave,
  });

  final Booking booking;
  final BookingSaveCallback? onSave;

  @override
  ConsumerState<BookingEditScreen> createState() => _BookingEditScreenState();
}

class _BookingEditScreenState extends ConsumerState<BookingEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _totalCtrl;
  late final TextEditingController _paidCtrl;

  late DateTime _date;
  late BookingStatus _status;

  bool _saving = false;

  bool get _isReadOnly => widget.booking.status == BookingStatus.cancelled;
  bool get _canSave =>
      !_isReadOnly && widget.onSave != null && !_saving;

  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    _nameCtrl = TextEditingController(text: b.customerName);
    _noteCtrl = TextEditingController(text: b.note ?? '');
    _totalCtrl = TextEditingController(text: _doubleToInput(b.amountTotal));
    _paidCtrl = TextEditingController(text: _doubleToInput(b.amountPaid));
    _date = b.date;
    _status = b.status;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noteCtrl.dispose();
    _totalCtrl.dispose();
    _paidCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
      helpText: 'اختر تاريخ الحجز',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final total = _parseDouble(_totalCtrl.text);
    final paid = _parseDouble(_paidCtrl.text);
    if (total == null || paid == null) {
      _snack('قيمة المبلغ غير صحيحة', isError: true);
      return;
    }
    if (paid > total) {
      _snack('المدفوع أكبر من الإجمالي', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = widget.booking.copyWith(
        customerName: _nameCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
        date: _date,
        status: _status,
        amountTotal: total,
        amountPaid: paid,
      );
      await widget.onSave!(updated);
      if (!mounted) return;
      Navigator.of(context).pop(updated);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('تعذّر حفظ التعديلات', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.textDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: AppColors.textDark,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'تعديل الحجز',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          actions: [
            if (_canSave)
              TextButton(
                onPressed: _save,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'حفظ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: _isReadOnly
              ? const _ReadOnlyBody()
              : Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _Section(
                        title: 'بيانات العميل',
                        icon: Icons.person_outline,
                        children: [
                          _Field(
                            controller: _nameCtrl,
                            label: 'اسم العميل',
                            icon: Icons.badge_outlined,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'الاسم مطلوب'
                                    : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Section(
                        title: 'الموعد',
                        icon: Icons.event_outlined,
                        children: [
                          _PickerTile(
                            label: 'التاريخ',
                            value: _formatDate(_date),
                            icon: Icons.calendar_today_outlined,
                            onTap: _pickDate,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Section(
                        title: 'الحالة',
                        icon: Icons.flag_outlined,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: BookingStatus.values
                                .map(
                                  (s) => ChoiceChip(
                                    label: Text(s.label),
                                    selected: _status == s,
                                    onSelected: (_) =>
                                        setState(() => _status = s),
                                    selectedColor: AppColors.primaryLight,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Section(
                        title: 'المبالغ',
                        icon: Icons.payments_outlined,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _Field(
                                  controller: _totalCtrl,
                                  label: 'الإجمالي',
                                  icon: Icons.summarize_outlined,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                  ],
                                  validator: (v) {
                                    final d = _parseDouble(v ?? '');
                                    if (d == null) return 'قيمة غير صحيحة';
                                    if (d < 0) return 'قيمة سالبة';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _Field(
                                  controller: _paidCtrl,
                                  label: 'المدفوع',
                                  icon: Icons.account_balance_wallet_outlined,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                  ],
                                  validator: (v) {
                                    final d = _parseDouble(v ?? '');
                                    if (d == null) return 'قيمة غير صحيحة';
                                    final t =
                                        _parseDouble(_totalCtrl.text);
                                    if (t != null && d > t) {
                                      return 'أكبر من الإجمالي';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _RemainingPreview(
                            total: _parseDouble(_totalCtrl.text) ?? 0,
                            paid: _parseDouble(_paidCtrl.text) ?? 0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _Section(
                        title: 'ملاحظات',
                        icon: Icons.notes_outlined,
                        children: [
                          _Field(
                            controller: _noteCtrl,
                            label: 'ملاحظة',
                            icon: Icons.edit_note_outlined,
                            maxLines: 3,
                            minLines: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class _ReadOnlyBody extends StatelessWidget {
  const _ReadOnlyBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.partial.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.partial.withValues(alpha: .3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.partial, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'هذا الحجز ملغى ولا يمكن تعديله.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
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
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.minLines,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMid),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.textMid.withValues(alpha: .2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.textMid.withValues(alpha: .2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textMid, fontSize: 13),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.textMid.withValues(alpha: .2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textMid),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textMid,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.expand_more,
                  size: 16, color: AppColors.textMid),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemainingPreview extends StatelessWidget {
  const _RemainingPreview({required this.total, required this.paid});
  final double total;
  final double paid;

  @override
  Widget build(BuildContext context) {
    final remaining = (total - paid).clamp(0, double.infinity);
    final isPaid = remaining == 0 && total > 0;
    final color = isPaid ? AppColors.booked : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          Icon(
            isPaid ? Icons.check_circle_outline : Icons.info_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'المتبقي',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            _formatMoney(remaining),
            textDirection: TextDirection.ltr,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
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

String _formatDate(DateTime d) {
  const months = [
    'يناير','فبراير','مارس','أبريل','مايو','يونيو',
    'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String _doubleToInput(double v) {
  if (v == 0) return '';
  final s = v.toStringAsFixed(2);
  if (s.endsWith('.00')) return s.substring(0, s.length - 3);
  return s;
}

double? _parseDouble(String raw) {
  final t = raw.trim().replaceAll(',', '').replaceAll(' ', '');
  if (t.isEmpty) return 0;
  return double.tryParse(t);
}

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
