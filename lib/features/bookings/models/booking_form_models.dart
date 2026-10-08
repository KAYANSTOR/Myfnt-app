import 'package:flutter/material.dart';

import '../domain/booking.dart';

enum BookingPackage { hall, chalet, house }

class AddBookingInput {
  const AddBookingInput({
    required this.customerName,
    required this.phone,
    required this.startsAt,
    required this.status,
    required this.package,
    required this.totalMinor,
    required this.paidMinor,
    required this.notes,
  });

  final String customerName;
  final String phone;
  final DateTime startsAt;
  final BookingStatus status;
  final BookingPackage package;
  final int totalMinor;
  final int paidMinor;
  final String notes;

  int get remainingMinor => totalMinor - paidMinor;
}

String packageLabel(BookingPackage value) => switch (value) {
      BookingPackage.house => 'بيت',
      BookingPackage.chalet => 'شالية',
      BookingPackage.hall => 'قاعة',
    };

IconData packageIcon(BookingPackage value) => switch (value) {
      BookingPackage.house => Icons.house_outlined,
      BookingPackage.chalet => Icons.holiday_village_outlined,
      BookingPackage.hall => Icons.apartment_outlined,
    };
