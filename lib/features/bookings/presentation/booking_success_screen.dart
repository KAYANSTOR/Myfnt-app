import 'package:flutter/material.dart';
import '../models/booking_form_models.dart';
import 'success_action_card.dart';
import 'success_palette.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking, required this.onClose, this.onSendSms, this.onPreviewDocument, this.onSendWhatsApp});
  final AddBookingInput booking;
  final VoidCallback onClose;
  final VoidCallback? onSendSms;
  final VoidCallback? onPreviewDocument;
  final VoidCallback? onSendWhatsApp;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SuccessPalette.background,
        body: SafeArea(child: Column(children: [
          Container(color: SuccessPalette.surface, padding: const EdgeInsets.fromLTRB(12, 12, 12, 16), child: Row(children: [
            IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded, color: SuccessPalette.primary)),
            const Expanded(child: Column(children: [Text('تم بنجاح', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SuccessPalette.primary)), SizedBox(height: 2), Text('تمت إضافة الحجز', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: SuccessPalette.textDark))])),
            const SizedBox(width: 48),
          ])),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 32, 20, 24), children: [
            Center(child: Container(width: 84, height: 84, decoration: BoxDecoration(gradient: const LinearGradient(colors: [SuccessPalette.successStart, SuccessPalette.successEnd]), borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.check_rounded, color: Colors.white, size: 44))),
            const SizedBox(height: 28),
            Text('تم حفظ الحجز بنجاح — ${booking.customerName}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: SuccessPalette.textDark)),
            const SizedBox(height: 8),
            Text('${booking.startsAt.year}/${booking.startsAt.month}/${booking.startsAt.day} · ${packageLabel(booking.package)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: SuccessPalette.muted)),
            const SizedBox(height: 36),
            GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: .92, children: [
              SuccessActionCard(title: 'رسالة نصية', subtitle: 'SMS', icon: Icons.chat_bubble_rounded, iconBackground: SuccessPalette.primarySoft, iconColor: SuccessPalette.primary, onTap: onSendSms),
              SuccessActionCard(title: 'معاينة السند', subtitle: 'عرض / طباعة / PDF', icon: Icons.receipt_long_outlined, iconBackground: SuccessPalette.primarySoft, iconColor: SuccessPalette.primary, onTap: onPreviewDocument),
              const SuccessActionCard(title: 'التفاصيل والخدمات', subtitle: 'قريباً', icon: Icons.checklist_rounded, iconBackground: SuccessPalette.primarySoft, iconColor: SuccessPalette.primary, dashed: true),
              SuccessActionCard(title: 'رسالة واتساب', subtitle: 'إرسال تفاصيل الحجز', icon: Icons.forum_rounded, iconBackground: SuccessPalette.whatsappSoft, iconColor: SuccessPalette.whatsapp, onTap: onSendWhatsApp),
            ]),
          ])),
        ]),
      );
}
