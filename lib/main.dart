// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/company/company_providers.dart';
import 'core/features/feature_gate_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(child: MyfntApp()),
  );
}

class MyfntApp extends StatelessWidget {
  const MyfntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Myfnt',
      theme: appTheme,
      home: const _BootstrapGate(),
    );
  }
}

/// بوابة التهيئة — تضمن وجود الشركة والمستخدم والإعدادات
/// قبل عرض الواجهة الرئيسية.
class _BootstrapGate extends ConsumerWidget {
  const _BootstrapGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(companyBootstrapProvider);

    return bootstrap.when(
      loading: () => const _SplashScreen(),
      error: (error, _) => _ErrorScreen(message: error.toString()),
      data: (_) => const _SeedGate(),
    );
  }
}

class _SeedGate extends ConsumerStatefulWidget {
  const _SeedGate();

  @override
  ConsumerState<_SeedGate> createState() => _SeedGateState();
}

class _SeedGateState extends ConsumerState<_SeedGate> {
  bool _seeded = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        await ref.read(featureGateServiceProvider).ensureSeeded();
        if (mounted) setState(() => _seeded = true);
      } catch (error) {
        if (mounted) setState(() => _error = error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _ErrorScreen(message: _error.toString());
    if (!_seeded) return const _SplashScreen();
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: HomeScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تهيئة التطبيق...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'فشل تحميل التطبيق',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
