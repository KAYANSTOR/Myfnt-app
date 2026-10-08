import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking_form_models.dart';
import '../providers/booking_providers.dart';
import 'add_booking_screen.dart';

/// يفتح نموذج الحجز الكامل المدمج مع BookingRepository.
void showAddBookingSheet(BuildContext context, DateTime date) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddBookingScreen(
        initialDate: date,
        onSave: (input) async {
          final container = ProviderScope.containerOf(context, listen: false);
          await container.read(bookingControllerProvider).addBooking(
                customerName: input.customerName,
                customerPhone: input.phone,
                date: input.startsAt,
                status: input.status,
                note: input.notes.isEmpty ? null : input.notes,
                amountTotal: input.totalMinor / 100,
                amountPaid: input.paidMinor / 100,
                packageName: packageLabel(input.package),
              );
        },
      )));
}
