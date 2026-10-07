# ميفنت (Mivent)

تطبيق Flutter عربي لإدارة الحجوزات وتنظيم المواعيد من خلال تقويم شهري بسيط وواضح.

## المزايا الحالية (الشاشة الرئيسية)

- واجهة عربية كاملة باتجاه RTL.
- تقويم شهري بتواريخ حقيقية (DateTime) مع التنقل بين الأشهر والعودة إلى اليوم الحالي.
- حالات الأيام: مؤكد، مؤقت، ومتاح — مرتبطة بحجوزات حقيقية وليست أرقامًا ثابتة.
- ملخص سريع لعدد الأيام المحجوزة والمتاحة.
- قائمة حجوزات اليوم مع فلاتر (الكل / اليوم / القادمة / مؤكد / مؤقت).
- تفاصيل الحجز عبر Bottom Sheet.
- حالات الشاشة: Loading، Empty، Error، Offline، Syncing.
- شريط تنقل سفلي وزر إضافة حجز.
- تصميم Material 3 بهوية ميفنت الدافئة ومتجاوب للهواتف.

## هيكل المشروع

```
lib/
  main.dart
  core/
    constants/app_colors.dart
    theme/app_theme.dart
  features/
    home/
      domain/models/booking.dart
      data/repositories/
        booking_repository.dart
        mock_booking_repository.dart
      presentation/
        controllers/home_controller.dart
        pages/home_page.dart
        widgets/
          calendar_widget.dart
          booking_card.dart
          booking_list_section.dart
          booking_detail_sheet.dart
          empty_state.dart
          status_chip.dart
```

## التشغيل

```bash
flutter pub get
flutter run
```

## الاختبارات

```bash
flutter test
flutter analyze
```

## ملاحظة

هذه المرحلة تقتصر على الشاشة الرئيسية فقط. باقي الشاشات (العملاء، الدفعات، التقارير، المصادقة، Backend) ستُضاف لاحقًا.
