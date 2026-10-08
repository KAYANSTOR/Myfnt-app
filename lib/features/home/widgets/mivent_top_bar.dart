import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// الشريط العلوي مطابق لبنية appBar في مستودع القوالب الأصلي.
/// تم تغيير العنوان والهوية فقط ليتناسب مع ميفنت.
class MiventTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MiventTopBar({super.key, this.onViewToggle, this.isGridView = true});

  final VoidCallback? onViewToggle;
  final bool isGridView;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: SizedBox(
              width: kToolbarHeight - 8,
              height: kToolbarHeight - 8,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'ميفنت',
                  style: TextStyle(
                    fontSize: 22,
                    color: isLightMode ? AppColors.textDark : Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: SizedBox(
              width: kToolbarHeight - 8,
              height: kToolbarHeight - 8,
              child: Material(
                color: isLightMode ? Colors.white : AppColors.textDark,
                child: InkWell(
                  borderRadius: BorderRadius.circular(kToolbarHeight),
                  onTap: onViewToggle,
                  child: Icon(
                    isGridView ? Icons.dashboard : Icons.view_agenda,
                    color: isLightMode ? AppColors.textMid : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
