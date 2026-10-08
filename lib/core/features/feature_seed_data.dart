/// بيانات الكتالوج المحلي والخطط الافتراضية.
class FeatureSeedData {
  FeatureSeedData._();

  static const List<Map<String, dynamic>> features = [
    {'code': 'bookings_limit', 'nameAr': 'عدد الحجوزات', 'group': 'bookings', 'type': 'limit', 'unit': 'booking', 'strategy': 'row_count', 'period': 'current'},
    {'code': 'users_limit', 'nameAr': 'عدد المستخدمين', 'group': 'users', 'type': 'limit', 'unit': 'user', 'strategy': 'row_count', 'period': 'current'},
    {'code': 'sms_monthly_limit', 'nameAr': 'الرسائل الشهرية', 'group': 'messages', 'type': 'quota', 'unit': 'message', 'strategy': 'usage_counter', 'period': 'monthly'},
    {'code': 'sms_yearly_limit', 'nameAr': 'الرسائل السنوية', 'group': 'messages', 'type': 'quota', 'unit': 'message', 'strategy': 'usage_counter', 'period': 'yearly'},
    {'code': 'message_numbers_limit', 'nameAr': 'أرقام الرسائل', 'group': 'messages', 'type': 'limit', 'unit': 'phone', 'strategy': 'row_count', 'period': 'current'},
    {'code': 'packages_limit', 'nameAr': 'عدد الباقات', 'group': 'bookings', 'type': 'limit', 'unit': 'package', 'strategy': 'row_count', 'period': 'current'},
    {'code': 'google_calendar_sync', 'nameAr': 'مزامنة Google Calendar', 'group': 'integrations', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'google_drive_sync', 'nameAr': 'مزامنة Google Drive', 'group': 'integrations', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'cloud_sync', 'nameAr': 'مزامنة السحابة', 'group': 'integrations', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'integration_accounts_limit', 'nameAr': 'حسابات التكامل', 'group': 'integrations', 'type': 'limit', 'unit': 'account', 'strategy': 'row_count', 'period': 'current'},
    {'code': 'manual_backup', 'nameAr': 'نسخة يدوية', 'group': 'backup', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'daily_backup', 'nameAr': 'نسخة يومية', 'group': 'backup', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'backup_storage_bytes', 'nameAr': 'مساحة النسخ', 'group': 'backup', 'type': 'storage', 'unit': 'byte', 'strategy': 'storage', 'period': 'current'},
    {'code': 'backup_retention_limit', 'nameAr': 'عدد النسخ المحفوظة', 'group': 'backup', 'type': 'limit', 'unit': 'backup', 'strategy': 'row_count', 'period': 'current'},
    {'code': 'trash_restore', 'nameAr': 'الاستعادة من المهملات', 'group': 'trash', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'trash_retention_days', 'nameAr': 'مدة الاحتفاظ', 'group': 'trash', 'type': 'limit', 'unit': 'day', 'strategy': 'config', 'period': 'current'},
    {'code': 'bookings_excel_export', 'nameAr': 'تصدير Excel', 'group': 'exports', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'exports_monthly_limit', 'nameAr': 'التصدير الشهري', 'group': 'exports', 'type': 'quota', 'unit': 'export', 'strategy': 'usage_counter', 'period': 'monthly'},
    {'code': 'booking_receipt_download', 'nameAr': 'تنزيل سند الحجز', 'group': 'documents', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'payment_receipt_download', 'nameAr': 'تنزيل سند القبض', 'group': 'documents', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'auto_message_send', 'nameAr': 'إرسال تلقائي', 'group': 'messages', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'custom_sms_gateway', 'nameAr': 'بوابة SMS مخصصة', 'group': 'messages', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'advanced_message_center', 'nameAr': 'مركز رسائل متقدم', 'group': 'messages', 'type': 'boolean', 'strategy': 'switch'},
    {'code': 'advanced_company_settings', 'nameAr': 'إعدادات شركة متقدمة', 'group': 'settings', 'type': 'config', 'strategy': 'config'},
    {'code': 'calendar_customization', 'nameAr': 'تخصيص التقويم', 'group': 'calendar', 'type': 'config', 'strategy': 'config'},
    {'code': 'booking_form_customization', 'nameAr': 'تخصيص نموذج الحجز', 'group': 'bookings', 'type': 'boolean', 'strategy': 'switch'},
  ];

  static const Map<String, Map<String, dynamic>> plans = {
    'BASIC': {'bookings_limit': 100, 'users_limit': 1, 'sms_monthly_limit': 40, 'sms_yearly_limit': 400, 'message_numbers_limit': 1, 'packages_limit': 5, 'google_calendar_sync': false, 'google_drive_sync': false, 'cloud_sync': false, 'integration_accounts_limit': 0, 'manual_backup': false, 'daily_backup': false, 'backup_storage_bytes': 0, 'backup_retention_limit': 0, 'trash_restore': false, 'trash_retention_days': 7, 'bookings_excel_export': false, 'exports_monthly_limit': 0, 'booking_receipt_download': true, 'payment_receipt_download': true, 'auto_message_send': false, 'custom_sms_gateway': false, 'advanced_message_center': false, 'advanced_company_settings': false, 'calendar_customization': false, 'booking_form_customization': false},
    'PLUS': {'bookings_limit': 1000, 'users_limit': 3, 'sms_monthly_limit': 150, 'sms_yearly_limit': 1500, 'message_numbers_limit': 3, 'packages_limit': 15, 'google_calendar_sync': true, 'google_drive_sync': true, 'cloud_sync': true, 'integration_accounts_limit': 2, 'manual_backup': true, 'daily_backup': false, 'backup_storage_bytes': 1073741824, 'backup_retention_limit': 3, 'trash_restore': true, 'trash_retention_days': 30, 'bookings_excel_export': true, 'exports_monthly_limit': 10, 'booking_receipt_download': true, 'payment_receipt_download': true, 'auto_message_send': false, 'custom_sms_gateway': false, 'advanced_message_center': true, 'advanced_company_settings': false, 'calendar_customization': true, 'booking_form_customization': true},
    'SUPER': {'bookings_limit': 5000, 'users_limit': 6, 'sms_monthly_limit': 400, 'sms_yearly_limit': 4000, 'message_numbers_limit': 5, 'packages_limit': 30, 'google_calendar_sync': true, 'google_drive_sync': true, 'cloud_sync': true, 'integration_accounts_limit': 5, 'manual_backup': true, 'daily_backup': true, 'backup_storage_bytes': 5368709120, 'backup_retention_limit': 10, 'trash_restore': true, 'trash_retention_days': 90, 'bookings_excel_export': true, 'exports_monthly_limit': 50, 'booking_receipt_download': true, 'payment_receipt_download': true, 'auto_message_send': true, 'custom_sms_gateway': false, 'advanced_message_center': true, 'advanced_company_settings': true, 'calendar_customization': true, 'booking_form_customization': true},
    'ULTRA': {'bookings_limit': null, 'users_limit': null, 'sms_monthly_limit': null, 'sms_yearly_limit': null, 'message_numbers_limit': null, 'packages_limit': null, 'google_calendar_sync': true, 'google_drive_sync': true, 'cloud_sync': true, 'integration_accounts_limit': null, 'manual_backup': true, 'daily_backup': true, 'backup_storage_bytes': null, 'backup_retention_limit': null, 'trash_restore': true, 'trash_retention_days': 365, 'bookings_excel_export': true, 'exports_monthly_limit': null, 'booking_receipt_download': true, 'payment_receipt_download': true, 'auto_message_send': true, 'custom_sms_gateway': true, 'advanced_message_center': true, 'advanced_company_settings': true, 'calendar_customization': true, 'booking_form_customization': true},
  };
}
