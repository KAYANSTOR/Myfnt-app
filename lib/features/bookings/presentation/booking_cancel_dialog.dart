import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// يعرض تأكيد إلغاء الحجز.
/// يعيد true إذا وافق المستخدم.
Future<bool> showBookingCancelDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 22,
          ),
          SizedBox(width: 8),
          Text(
            'إلغاء الحجز؟',
            style: TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
      content: const Text(
        'سيتم تحويل حالة الحجز إلى «ملغى». يمكنك التراجع لاحقًا عبر تعديل الحجز.',
        style: TextStyle(
          color: AppColors.textMid,
          fontSize: 13.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textMid,
          ),
          child: const Text('تراجع'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: const Text(
            'نعم، إلغاء',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}
