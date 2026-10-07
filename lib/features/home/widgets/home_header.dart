import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// رأس الصفحة الرئيسية — const لأنه لا يتغير أبداً
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 76,
      titleSpacing: 22,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً بك في ميفنت',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMid,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'لوحة التحكم',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
      actions: const [
        _NotificationIcon(),
        Padding(
          padding: EdgeInsets.only(left: 18, right: 16),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person_outline, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            size: 27,
            color: AppColors.primary,
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '3',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
