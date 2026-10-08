/// مسودة حجز للتحقق، مستقلة عن Drift.
class BookingDraft {
  const BookingDraft({
    required this.name,
    required this.date,
    required this.amount,
    required this.paid,
    this.phone,
    this.hasTime = false,
    this.timeFrom = '09:00',
    this.timeTo = '21:00',
    this.packageId,
    this.packageName,
    this.address,
    this.notes,
    this.status = 'confirmed',
  });

  final String name;
  final String? phone;
  final String date;
  final bool hasTime;
  final String timeFrom;
  final String timeTo;
  final String? packageId;
  final String? packageName;
  final int amount;
  final int paid;
  final String? address;
  final String? notes;
  final String status;
}
