import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// شريط Myfnt السفلي — تصميم محزوز مع زر إضافة مركزي
class MyfntBottomNavigation extends StatefulWidget {
  const MyfntBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.onAddPressed,
  });

  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onAddPressed;

  @override
  State<MyfntBottomNavigation> createState() => _MyfntBottomNavigationState();
}

class _MyfntBottomNavigationState extends State<MyfntBottomNavigation>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final List<_MyfntTabIconData> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      _MyfntTabIconData(
        index: 0,
        label: 'التقويم',
        icon: Icons.calendar_month_outlined,
        selectedIcon: Icons.calendar_month,
      ),
      _MyfntTabIconData(
        index: 1,
        label: 'الحجوزات',
        icon: Icons.event_note_outlined,
        selectedIcon: Icons.event_note,
      ),
      _MyfntTabIconData(
        index: 2,
        label: 'الدفعات',
        icon: Icons.payments_outlined,
        selectedIcon: Icons.payments,
      ),
      _MyfntTabIconData(
        index: 3,
        label: 'حسابي',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
    ];
    _tabs[widget.selectedIndex].isSelected = true;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant MyfntBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _setSelection(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final tab in _tabs) {
      tab.animationController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: 92 + bottomInset,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return PhysicalShape(
                color: AppColors.card,
                elevation: 16,
                shadowColor: AppColors.primary.withValues(alpha: .20),
                clipper: _MyfntTabClipper(
                  radius: Tween<double>(begin: 0, end: 1)
                          .animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.fastOutSlowIn,
                          ))
                          .value *
                      38,
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 62,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 8, right: 8, top: 4),
                        child: Row(
                          children: <Widget>[
                            Expanded(child: _tab(0)),
                            Expanded(child: _tab(1)),
                            SizedBox(
                              width: Tween<double>(begin: 0, end: 1)
                                      .animate(CurvedAnimation(
                                        parent: _animationController,
                                        curve: Curves.fastOutSlowIn,
                                      ))
                                      .value *
                                  64,
                            ),
                            Expanded(child: _tab(2)),
                            Expanded(child: _tab(3)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: bottomInset),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SizedBox(
              width: 76,
              height: 100,
              child: Align(
                alignment: Alignment.topCenter,
                child: ScaleTransition(
                  alignment: Alignment.center,
                  scale: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.fastOutSlowIn,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: .4),
                            offset: const Offset(8, 16),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          splashColor: Colors.white.withValues(alpha: .12),
                          onTap: widget.onAddPressed,
                          child: Semantics(
                            label: 'إضافة حجز جديد',
                            button: true,
                            child: Icon(Icons.add, color: Colors.white, size: 32),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(int index) {
    return _MyfntTabIcon(
      tab: _tabs[index],
      onTap: () => widget.onIndexChanged(index),
    );
  }

  void _setSelection(int index) {
    if (index < 0 || index >= _tabs.length) return;
    setState(() {
      for (final tab in _tabs) {
        tab.isSelected = tab.index == index;
      }
    });
  }
}

class _MyfntTabIcon extends StatefulWidget {
  const _MyfntTabIcon({required this.tab, required this.onTap});
  final _MyfntTabIconData tab;
  final VoidCallback onTap;

  @override
  State<_MyfntTabIcon> createState() => _MyfntTabIconState();
}

class _MyfntTabIconState extends State<_MyfntTabIcon>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.tab.animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    return AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: Semantics(
          button: true,
          selected: tab.isSelected,
          label: tab.label,
          child: InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              widget.onTap();
              if (!tab.isSelected) {
                tab.animationController?.forward(from: 0);
              }
            },
            child: IgnorePointer(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  ScaleTransition(
                    scale: Tween<double>(begin: .88, end: 1).animate(
                      CurvedAnimation(
                        parent: tab.animationController!,
                        curve:
                            const Interval(.1, 1, curve: Curves.fastOutSlowIn),
                      ),
                    ),
                    child: Icon(
                      tab.isSelected ? tab.selectedIcon : tab.icon,
                      size: 26,
                      color: tab.isSelected
                          ? AppColors.primaryDark
                          : AppColors.textMid,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 6,
                    right: 0,
                    child: _particle(tab.animationController!, 8),
                  ),
                  Positioned(
                    top: 0,
                    left: 6,
                    bottom: 8,
                    child: _particle(tab.animationController!, 4),
                  ),
                  Positioned(
                    top: 6,
                    right: 8,
                    bottom: 0,
                    child: _particle(tab.animationController!, 6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _particle(AnimationController controller, double size) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(.5, .8, curve: Curves.fastOutSlowIn),
        ),
      ),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _MyfntTabIconData {
  _MyfntTabIconData({
    required this.index,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  bool isSelected = false;
  AnimationController? animationController;
}

class _MyfntTabClipper extends CustomClipper<Path> {
  const _MyfntTabClipper({this.radius = 38});
  final double radius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final value = radius * 2;
    path.lineTo(0, 0);
    path.arcTo(
      Rect.fromLTWH(0, 0, radius, radius),
      _radians(180),
      _radians(90),
      false,
    );
    path.arcTo(
      Rect.fromLTWH(
        ((size.width / 2) - value / 2) - radius + value * .04,
        0,
        radius,
        radius,
      ),
      _radians(270),
      _radians(70),
      false,
    );
    path.arcTo(
      Rect.fromLTWH((size.width / 2) - value / 2, -value / 2, value, value),
      _radians(160),
      _radians(-140),
      false,
    );
    path.arcTo(
      Rect.fromLTWH(
        (size.width - ((size.width / 2) - value / 2)) - value * .04,
        0,
        radius,
        radius,
      ),
      _radians(200),
      _radians(70),
      false,
    );
    path.arcTo(
      Rect.fromLTWH(size.width - radius, 0, radius, radius),
      _radians(270),
      _radians(90),
      false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  double _radians(double degree) => (math.pi / 180) * degree;

  @override
  bool shouldReclip(_MyfntTabClipper oldClipper) => true;
}
