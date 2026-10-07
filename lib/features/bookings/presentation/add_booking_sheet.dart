import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/booking.dart';
import '../providers/booking_providers.dart';

/// Bottom Sheet لإضافة حجز جديد
void showAddBookingSheet(BuildContext context, DateTime date) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (_) => AddBookingSheet(date: date),
  );
}

class AddBookingSheet extends ConsumerStatefulWidget {
  const AddBookingSheet({super.key, required this.date});
  final DateTime date;

  @override
  ConsumerState<AddBookingSheet> createState() => _AddBookingSheetState();
}

class _AddBookingSheetState extends ConsumerState<AddBookingSheet> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  BookingStatus _status = BookingStatus.confirmed;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'الرجاء إدخال اسم العميل');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref.read(bookingControllerProvider).addBooking(
            customerName: name,
            date: widget.date,
            status: _status,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم حفظ الحجز بنجاح')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء الحفظ';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final dateLabel =
        '${widget.date.day} ${months[widget.date.month - 1]} ${widget.date.year}';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حجز جديد — $dateLabel',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'اسم العميل',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _noteController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'ملاحظة (اختياري)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_outlined),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          const Text('حالة الحجز:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: BookingStatus.values
                .where((s) => s != BookingStatus.cancelled)
                .map(
                  (s) => ChoiceChip(
                    label: Text(s.label),
                    selected: _status == s,
                    onSelected: (_) => setState(() => _status = s),
                    selectedColor: AppColors.primaryLight,
                  ),
                )
                .toList(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'جاري الحفظ...' : 'حفظ الحجز'),
            ),
          ),
        ],
      ),
    );
  }
}
