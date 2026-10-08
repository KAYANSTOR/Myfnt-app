import 'package:flutter/material.dart';
import 'success_palette.dart';

class SuccessActionCard extends StatelessWidget {
  const SuccessActionCard({super.key, required this.title, required this.subtitle, required this.icon, required this.iconBackground, required this.iconColor, this.onTap, this.dashed = false});
  final String title; final String subtitle; final IconData icon; final Color iconBackground; final Color iconColor; final VoidCallback? onTap; final bool dashed;
  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(button: true, enabled: enabled, label: '$title، $subtitle', child: Material(
      color: SuccessPalette.surface, elevation: enabled ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: dashed ? SuccessPalette.border : SuccessPalette.border)),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(12), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: enabled ? iconBackground : iconBackground.withValues(alpha: .5), borderRadius: BorderRadius.circular(18)), child: Icon(icon, size: 26, color: enabled ? iconColor : iconColor.withValues(alpha: .4))),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: enabled ? SuccessPalette.textDark : SuccessPalette.disabledText)),
        const SizedBox(height: 4),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: enabled ? SuccessPalette.muted : SuccessPalette.disabledText)),
      ]))),
    ));
  }
}
