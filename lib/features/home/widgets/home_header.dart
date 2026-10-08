import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// الشريط العلوي — تصميم مطابق للمرجع (أزرار دائرية + حالة الاتصال)
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              // الأيقونات اليسرى: إشعارات + بحث
              _CircleIconButton(
                icon: Icons.notifications_none_rounded,
                badgeCount: 0,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('لا توجد إشعارات جديدة')),
                  );
                },
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                icon: Icons.search_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('البحث سيُفعّل لاحقًا')),
                  );
                },
              ),

              // العنوان في الوسط
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Myfnt',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_done_rounded,
                          size: 13,
                          color: Color(0xFF22C55E),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'بيانات محلية',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.wifi_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'متصل',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // الأيقونات اليمنى: تحديث + قائمة
              _CircleIconButton(
                icon: Icons.refresh_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('جاري التحديث...')),
                  );
                },
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                icon: Icons.menu_rounded,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('القائمة ستُفعّل لاحقًا')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// زر دائري أبيض بأيقونة — مطابق للتصميم المرجعي
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFF0E6EB),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          if (badgeCount != null)
            Positioned(
              top: -2,
              left: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
