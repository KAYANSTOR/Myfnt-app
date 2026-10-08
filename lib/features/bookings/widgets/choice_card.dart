import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key, required this.label, required this.icon, required this.selected, required this.onTap, this.accent = AppColors.primary});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : AppColors.textDark;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? accent.withValues(alpha: .10) : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? accent : AppColors.available, width: selected ? 1.5 : 1),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 23, color: color),
              const SizedBox(height: 5),
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
            ]),
          ),
        ),
      ),
    );
  }
}
