import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/booking.dart';
import '../providers/booking_providers.dart';
import '../providers/bookings_list_providers.dart';
import 'add_booking_sheet.dart';
import 'booking_cancel_dialog.dart';
import 'booking_details_screen.dart';
import 'booking_edit_screen.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(bookingsSearchQueryProvider.notifier).state = '';
    setState(() {});
  }

  Future<void> _openDetails(Booking booking) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(
          booking: booking,
          onEdit: () => _editBooking(booking),
          onCancel: () => _cancelBooking(booking),
          onAddPayment: null,
        ),
      ),
    );
  }

  Future<void> _editBooking(Booking booking) async {
    final updated = await Navigator.of(context).push<Booking>(
      MaterialPageRoute(
        builder: (_) => BookingEditScreen(
          booking: booking,
          onSave: (value) =>
              ref.read(bookingControllerProvider).updateBooking(value),
        ),
      ),
    );

    if (updated != null && mounted) {
      Navigator.of(context).pop();
      _showSnack('تم حفظ التعديلات');
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final shouldCancel = await showBookingCancelDialog(context);

    if (shouldCancel != true || !mounted) return;

    try {
      await ref.read(bookingControllerProvider).updateBooking(
            booking.copyWith(status: BookingStatus.cancelled),
          );

      if (!mounted) return;
      Navigator.of(context).pop();
      _showSnack('تم إلغاء الحجز');
    } catch (_) {
      if (mounted) _showSnack('تعذّر إلغاء الحجز', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.textDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncBookings = ref.watch(filteredBookingsProvider);
    final filter = ref.watch(bookingsFilterProvider);
    final query = ref.watch(bookingsSearchQueryProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'الحجوزات',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => showAddBookingSheet(context, DateTime.now()),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة حجز'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(bookingsSearchQueryProvider.notifier).state = value;
                    setState(() {});
                  },
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن عميل أو رقم الحجز',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close, size: 18),
                          ),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.textMid.withValues(alpha: .2),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  scrollDirection: Axis.horizontal,
                  itemCount: BookingsFilter.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final value = BookingsFilter.values[index];
                    return ChoiceChip(
                      label: Text(value.label),
                      selected: filter == value,
                      onSelected: (_) => ref
                          .read(bookingsFilterProvider.notifier)
                          .state = value,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: filter == value ? Colors.white : AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: asyncBookings.when(
                  loading: () => const _LoadingState(),
                  error: (error, _) => _ErrorState(
                    onRetry: () {
                      ref.invalidate(allBookingsProvider);
                      if (query.trim().isNotEmpty) {
                        ref.invalidate(searchBookingsProvider(query));
                      }
                    },
                  ),
                  data: (bookings) => bookings.isEmpty
                      ? _EmptyState(
                          hasQuery: query.trim().isNotEmpty,
                          hasFilter: filter != BookingsFilter.all,
                          onAdd: () =>
                              showAddBookingSheet(context, DateTime.now()),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          itemCount: bookings.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, index) => _BookingCard(
                            booking: bookings[index],
                            onTap: () => _openDetails(bookings[index]),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onTap});
  final Booking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final remaining = booking.amountRemaining;
    return Card(
      color: AppColors.card,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusChip(status: booking.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 15, color: AppColors.textMid),
                  const SizedBox(width: 5),
                  Text(_formatDate(booking.date)),
                  const Spacer(),
                  Text(
                    '#${booking.bookingNo}',
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: AppColors.textMid),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Amount(
                    label: 'الإجمالي',
                    value: booking.amountTotal,
                    currency: booking.currency,
                  ),
                  _Amount(
                    label: 'المدفوع',
                    value: booking.amountPaid,
                    currency: booking.currency,
                  ),
                  _Amount(
                    label: 'المتبقي',
                    value: remaining,
                    currency: booking.currency,
                    color: remaining > 0 ? AppColors.error : AppColors.booked,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.label, required this.value, required this.currency, this.color = AppColors.textDark});
  final String label;
  final double value;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
            const SizedBox(height: 2),
            Text(
              _formatMoney(value, currency),
              textDirection: TextDirection.ltr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      BookingStatus.confirmed => AppColors.booked,
      BookingStatus.partial => AppColors.partial,
      BookingStatus.pending => AppColors.primary,
      BookingStatus.cancelled => AppColors.error,
      BookingStatus.completed => AppColors.booked,
      BookingStatus.archived => AppColors.textMid,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12),
            Text('جارٍ تحميل الحجوزات...'),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery, required this.hasFilter, required this.onAdd});
  final bool hasQuery;
  final bool hasFilter;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final title = hasQuery
        ? 'لا توجد نتائج للبحث'
        : hasFilter
            ? 'لا توجد حجوزات بهذا الفلتر'
            : 'لا توجد حجوزات';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hasQuery ? Icons.search_off : Icons.event_busy_outlined, size: 56, color: AppColors.textMid),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            if (!hasQuery && !hasFilter) ...[
              const SizedBox(height: 6),
              const Text('أضف أول حجز للبدء', style: TextStyle(color: AppColors.textMid)),
              const SizedBox(height: 16),
              ElevatedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('إضافة حجز')),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 52, color: AppColors.error),
            const SizedBox(height: 12),
            const Text('تعذر تحميل الحجوزات', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
          ],
        ),
      );
}

String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

String _formatMoney(double value, String currency) {
  final fixed = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  return '$fixed $currency';
}
