import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/booking.dart';
import '../models/booking_form_models.dart';
import '../widgets/choice_card.dart';
import '../widgets/section_card.dart';
import 'booking_success_screen.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key, required this.initialDate, required this.onSave, this.currencyLabel = 'YER'});
  final DateTime initialDate;
  final Future<void> Function(AddBookingInput input) onSave;
  final String currencyLabel;

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _paidCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  BookingStatus _status = BookingStatus.confirmed;
  BookingPackage _package = BookingPackage.hall;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _date = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _totalCtrl.dispose();
    _paidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  int get _total => int.tryParse(_totalCtrl.text.trim()) ?? 0;
  int get _paid => int.tryParse(_paidCtrl.text.trim()) ?? 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _saving = true; _error = null; });
    final input = AddBookingInput(
      customerName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      startsAt: DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute),
      status: _status,
      package: _package,
      totalMinor: _total * 100,
      paidMinor: _paid * 100,
      notes: _notesCtrl.text.trim(),
    );
    try {
      await widget.onSave(input);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => BookingSuccessScreen(booking: input, onClose: () => Navigator.of(context).popUntil((route) => route.isFirst))));
    } catch (error) {
      if (mounted) setState(() { _saving = false; _error = 'تعذر حفظ الحجز. تحقق من البيانات وحاول مرة أخرى.'; });
    }
  }

  String? _validateName(String? value) => (value == null || value.trim().length < 2) ? 'أدخل اسم العميل (حرفان على الأقل)' : null;
  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^\d]'), '');
    return digits.length < 7 || digits.length > 15 ? 'رقم الهاتف غير صحيح' : null;
  }
  String? _validateTotal(String? value) => (int.tryParse(value?.trim() ?? '') ?? 0) <= 0 ? 'أدخل قيمة أكبر من صفر' : null;
  String? _validatePaid(String? value) => (int.tryParse(value?.trim() ?? '') ?? -1) > _total ? 'المدفوع أكبر من قيمة الحجز' : null;

  @override
  Widget build(BuildContext context) {
    final remaining = _total - _paid;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: const Text('إضافة حجز'), centerTitle: true),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), children: [
          SectionCard(title: 'بيانات العميل', icon: Icons.person_outline, child: Column(children: [
            TextFormField(controller: _nameCtrl, textInputAction: TextInputAction.next, decoration: _decoration('اسم العميل', 'مثال: أحمد محمد', Icons.person_outline), validator: _validateName),
            const SizedBox(height: 12),
            TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: _decoration('رقم الهاتف', '77xxxxxxx', Icons.phone_outlined), validator: _validatePhone),
          ])),
          const SizedBox(height: 12),
          SectionCard(title: 'موعد الحجز', icon: Icons.calendar_today_outlined, child: Column(children: [
            _PickerField(label: 'التاريخ', value: '${_date.year}/${_date.month}/${_date.day}', icon: Icons.calendar_today_outlined, onTap: _pickDate),
            const SizedBox(height: 12),
            _PickerField(label: 'الوقت', value: _time.format(context), icon: Icons.access_time, onTap: _pickTime),
          ])),
          const SizedBox(height: 12),
          SectionCard(title: 'حالة الحجز', icon: Icons.shield_outlined, child: _choiceRow<BookingStatus>(
            options: const [BookingStatus.confirmed, BookingStatus.pending, BookingStatus.partial], selected: _status,
            label: (s) => s.label, icon: (s) => s == BookingStatus.confirmed ? Icons.check_circle_outline : s == BookingStatus.pending ? Icons.schedule : Icons.timelapse,
            accent: (s) => s == BookingStatus.confirmed ? AppColors.success : s == BookingStatus.pending ? AppColors.warning : AppColors.primary,
            onChanged: (s) => setState(() => _status = s),
          )),
          const SizedBox(height: 12),
          SectionCard(title: 'الباقة / المناسبة', icon: Icons.business_center_outlined, child: _choiceRow<BookingPackage>(
            options: BookingPackage.values, selected: _package, label: packageLabel, icon: packageIcon,
            accent: (_) => AppColors.primary, onChanged: (p) => setState(() => _package = p),
          )),
          const SizedBox(height: 12),
          SectionCard(title: 'ملخص الحجز', icon: Icons.account_balance_wallet_outlined, child: Column(children: [
            TextFormField(controller: _totalCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], onChanged: (_) => setState(() {}), decoration: _decoration('قيمة الحجز', widget.currencyLabel, null), validator: _validateTotal),
            const SizedBox(height: 12),
            TextFormField(controller: _paidCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], onChanged: (_) => setState(() {}), decoration: _decoration('المدفوع', widget.currencyLabel, null), validator: _validatePaid),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المتبقي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Text('$remaining ${widget.currencyLabel}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: remaining > 0 ? AppColors.error : AppColors.success))]),
          ])),
          const SizedBox(height: 12),
          SectionCard(title: 'ملاحظات', icon: Icons.notes_outlined, child: TextFormField(controller: _notesCtrl, maxLines: 3, maxLength: 500, decoration: _decoration('', 'اكتب أي ملاحظات إضافية...', null))),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: AppColors.error))),
        ]),
      ),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: Row(children: [
        Expanded(child: OutlinedButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('إلغاء'))),
        const SizedBox(width: 12),
        Expanded(child: FilledButton.icon(onPressed: _saving ? null : _submit, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined), label: Text(_saving ? 'جاري الحفظ...' : 'حفظ الحجز'))),
      ]))),
    );
  }

  Widget _choiceRow<T>({required List<T> options, required T selected, required String Function(T) label, required IconData Function(T) icon, required Color Function(T) accent, required ValueChanged<T> onChanged}) => Row(children: [for (var i = 0; i < options.length; i++) ...[if (i > 0) const SizedBox(width: 8), Expanded(child: ChoiceCard(label: label(options[i]), icon: icon(options[i]), selected: options[i] == selected, accent: accent(options[i]), onTap: () => onChanged(options[i])))] ]);

  InputDecoration _decoration(String label, String? hint, IconData? icon) => InputDecoration(labelText: label.isEmpty ? null : label, hintText: hint, prefixIcon: icon == null ? null : Icon(icon, color: AppColors.primary, size: 20), suffixText: label == 'قيمة الحجز' || label == 'المدفوع' ? widget.currencyLabel : null, filled: true, fillColor: AppColors.card, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.available)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)));
}

class _PickerField extends StatelessWidget {
  const _PickerField({required this.label, required this.value, required this.icon, required this.onTap});
  final String label; final String value; final IconData icon; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: InputDecorator(decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: AppColors.primary, size: 20), filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.available))), child: Text(value, style: const TextStyle(fontSize: 16)));
}
