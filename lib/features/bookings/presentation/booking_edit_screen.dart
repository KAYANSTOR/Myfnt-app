import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/booking.dart';

typedef BookingSaveCallback = Future<void> Function(Booking updated);

class BookingEditScreen extends StatefulWidget {
  const BookingEditScreen({super.key, required this.booking, required this.onSave});
  final Booking booking;
  final BookingSaveCallback onSave;
  @override
  State<BookingEditScreen> createState() => _BookingEditScreenState();
}

class _BookingEditScreenState extends State<BookingEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _total;
  late final TextEditingController _paid;
  late final TextEditingController _note;
  late DateTime _date;
  late DateTime? _start;
  late DateTime? _end;
  late BookingStatus _status;
  bool _saving = false;

  bool get _readOnly => widget.booking.status == BookingStatus.cancelled || widget.booking.status == BookingStatus.completed || widget.booking.status == BookingStatus.archived;

  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    _name = TextEditingController(text: b.customerName);
    _phone = TextEditingController(text: b.customerPhone ?? '');
    _total = TextEditingController(text: (b.amountMinor / 100).toStringAsFixed(0));
    _paid = TextEditingController(text: (b.paidMinor / 100).toStringAsFixed(0));
    _note = TextEditingController(text: b.note ?? '');
    _date = b.eventDate;
    _start = b.startsAt;
    _end = b.endsAt;
    _status = b.status;
  }

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _total.dispose(); _paid.dispose(); _note.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final value = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100), cancelText: 'إلغاء', confirmText: 'تأكيد');
    if (value != null) setState(() => _date = value);
  }

  Future<void> _pickTime({required bool start}) async {
    final current = start ? _start : _end;
    final value = await showTimePicker(context: context, initialTime: current == null ? const TimeOfDay(hour: 10, minute: 0) : TimeOfDay.fromDateTime(current), cancelText: 'إلغاء', confirmText: 'تأكيد');
    if (value == null) return;
    final date = DateTime(_date.year, _date.month, _date.day, value.hour, value.minute);
    setState(() { if (start) { _start = date; } else { _end = date; } });
  }

  Future<void> _save() async {
    if (_readOnly || !(_formKey.currentState?.validate() ?? false)) return;
    final total = (int.parse(_total.text) * 100);
    final paid = (int.parse(_paid.text) * 100);
    if (paid > total) { _message('المدفوع أكبر من الإجمالي'); return; }
    if (_start != null && _end != null && !_end!.isAfter(_start!)) { _message('وقت النهاية يجب أن يكون بعد البداية'); return; }
    final updated = widget.booking.copyWith(
      customerName: _name.text.trim(),
      customerPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      eventDate: DateTime(_date.year, _date.month, _date.day),
      startsAt: _start,
      endsAt: _end,
      status: _status,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      amountMinor: total,
      paidMinor: paid,
      updatedAt: DateTime.now().toUtc(),
    );
    setState(() => _saving = true);
    try { await widget.onSave(updated); if (mounted) Navigator.of(context).pop(updated); } catch (_) { if (mounted) { setState(() => _saving = false); _message('تعذر حفظ التعديلات'); } }
  }

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(title: const Text('تعديل الحجز'), actions: [if (!_readOnly) TextButton(onPressed: _saving ? null : _save, child: const Text('حفظ'))]),
        body: _readOnly ? Center(child: Text('هذا الحجز ${widget.booking.status.label} ولا يمكن تعديله')) : Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
          _section('بيانات العميل', Icons.person_outline, [
            TextFormField(controller: _name, decoration: _decoration('اسم العميل'), validator: (v) => v == null || v.trim().isEmpty ? 'الاسم مطلوب' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: _decoration('رقم الهاتف'), validator: (v) => (v ?? '').trim().isEmpty ? 'رقم الهاتف مطلوب' : null),
          ]),
          const SizedBox(height: 12),
          _section('الموعد', Icons.event_outlined, [
            _picker('التاريخ', '${_date.year}/${_date.month}/${_date.day}', Icons.calendar_today_outlined, _pickDate),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: _picker('من', _start == null ? 'غير محدد' : _time(_start!), Icons.schedule_outlined, () => _pickTime(start: true))), const SizedBox(width: 8), Expanded(child: _picker('إلى', _end == null ? 'غير محدد' : _time(_end!), Icons.schedule_outlined, () => _pickTime(start: false)))]),
          ]),
          const SizedBox(height: 12),
          _section('حالة الحجز', Icons.shield_outlined, [Wrap(spacing: 8, runSpacing: 8, children: [BookingStatus.confirmed, BookingStatus.partial, BookingStatus.pending].map((s) => ChoiceChip(label: Text(s.label), selected: _status == s, onSelected: (_) => setState(() => _status = s))).toList())]),
          const SizedBox(height: 12),
          _section('المبالغ', Icons.payments_outlined, [
            TextFormField(controller: _total, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: _decoration('الإجمالي'), validator: (v) => int.tryParse(v ?? '') == null ? 'أدخل رقمًا صحيحًا' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _paid, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: _decoration('المدفوع'), validator: (v) => int.tryParse(v ?? '') == null ? 'أدخل رقمًا صحيحًا' : null),
          ]),
          const SizedBox(height: 12),
          _section('ملاحظات', Icons.notes_outlined, [TextFormField(controller: _note, maxLines: 4, maxLength: 500, decoration: _decoration('ملاحظات'))]),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined), label: Text(_saving ? 'جاري الحفظ...' : 'حفظ التعديلات')),
        ])),
      );

  Widget _section(String title, IconData icon, List<Widget> children) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.available)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: AppColors.primary, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w800))]), const SizedBox(height: 12), ...children]));
  Widget _picker(String label, String value, IconData icon, VoidCallback onTap) => InkWell(onTap: onTap, child: InputDecorator(decoration: _decoration(label).copyWith(prefixIcon: Icon(icon, color: AppColors.primary)), child: Text(value)));
  InputDecoration _decoration(String label) => InputDecoration(labelText: label, filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.available)));
  String _time(DateTime value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
