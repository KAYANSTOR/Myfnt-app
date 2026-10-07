import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(
    // ProviderScope يُغلّف التطبيق كاملاً لتشغيل Riverpod
    const ProviderScope(
      child: MiventApp(),
    ),
  );
}

class MiventApp extends StatelessWidget {
  const MiventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ميفنت',
      theme: appTheme,
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}
