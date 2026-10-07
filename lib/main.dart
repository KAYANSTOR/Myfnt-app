import 'package:flutter/material.dart';
import 'package:mivent/core/theme/app_theme.dart';
import 'package:mivent/features/home/presentation/pages/home_page.dart';

void main() {
  runApp(const MiventApp());
}

class MiventApp extends StatelessWidget {
  const MiventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ميفنت',
      theme: AppTheme.light,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomePage(),
    );
  }
}
