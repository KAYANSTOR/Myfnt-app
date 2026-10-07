import 'dart:math' as math;

import 'package:flutter/material.dart';

/// زر إجراءات سريعة عائم: يفتح قائمة صغيرة فيها «إضافة حجز» و«إضافة سند قبض».
///
/// المكوّن مسؤول عن العرض واستدعاء الـ callbacks فقط:
/// لا يفتح شاشات، ولا يعتمد على أي Backend أو Database.
class QuickActionsButton extends StatefulWidget {
  const QuickActionsButton({
    super.key,
    required this.onAddBooking,
    required this.onAddReceipt,
  });

  /// يُستدعى عند اختيار «إضافة حجز».
  final VoidCallback onAddBooking;

  /// يُستدعى عند اختيار «إضافة سند قبض».
  final VoidCallback onAddReceipt;

  @override
  State<QuickActionsButton> createState() => _QuickActionsButtonState();
}

class _QuickActionsButtonState extends State<QuickActionsButton>
    with SingleTickerProviderStateMixin {
  static const String _tooltipLabel = 'الإجراءات السريعة';
  static const String _bookingLabel = 'إضافة حجز';
  static const String _receiptLabel = 'إضافة سند قبض';

  static const Duration _animationDuration = Duration(milliseconds: 220);
  static const double _gapAboveFab = 12;
  static const double _gapBetweenActions = 10;
  static const double _screenSidePadding = 16;
  static const double _maxMenuWidth = 300;
  static const Color _barrierColor = Color(0x0F000000);

  final GlobalKey _fabKey = GlobalKey();

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _animationDuration,
  );

  /// 0 = مغلق، 1 = مفتوح.
  late final Animation<double> _progress = _controller.drive(
    CurveTween(curve: Curves.easeOutCubic),
  );

  late final Animation<double> _menuScale = Tween<double>(
    begin: 0.9,
    end: 1,
  ).animate(_progress);

  /// دوران بسيط: علامة + تتحول إلى × (45 درجة).
  late final Animation<double> _iconRotation = Tween<double>(
    begin: 0,
    end: 0.125,
  ).animate(_progress);

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    if (_isOpen) return;

    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null || _fabKey.currentContext == null) return;

    _removeOverlay();
    final OverlayEntry entry = OverlayEntry(builder: _buildOverlay);
    _overlayEntry = entry;
    overlay.insert(entry);

    setState(() => _isOpen = true);
    _controller.forward();
  }

  void _close() {
    if (!_isOpen) return;

    final OverlayEntry? entry = _overlayEntry;
    setState(() => _isOpen = false);
    _controller.reverse().whenComplete(() {
      if (!_isOpen && identical(_overlayEntry, entry)) {
        _removeOverlay();
      }
    });
  }

  void _removeOverlay() {
    final OverlayEntry? entry = _overlayEntry;
    _overlayEntry = null;
    if (entry == null) return;
    if (entry.mounted) {
      entry.remove();
    }
    entry.dispose();
  }

  void _handleAction(VoidCallback action) {
    _close();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      key: _fabKey,
      // تجنّب تعارض Hero إن وُجد زر عائم آخر في نفس المسار.
      heroTag: null,
      tooltip: _tooltipLabel,
      onPressed: _toggle,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: const CircleBorder(),
      elevation: 3,
      child: RotationTransition(
        turns: _iconRotation,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final ColorScheme scheme = Theme.of(overlayContext).colorScheme;
    final Size screenSize = MediaQuery.sizeOf(overlayContext);
    final bool isRtl = Directionality.of(overlayContext) == TextDirection.rtl;

    final RenderBox? fabBox =
        _fabKey.currentContext?.findRenderObject() as RenderBox?;
    if (fabBox == null || !fabBox.hasSize) {
      return const SizedBox.shrink();
    }

    final Offset fabTopLeft = fabBox.localToGlobal(Offset.zero);
    final Size fabSize = fabBox.size;

    // الحافة القريبة من حافة الشاشة (End حسب اتجاه النص) لمحاذاة القائمة مع الزر.
    final double endInset = isRtl
        ? fabTopLeft.dx
        : screenSize.width - fabTopLeft.dx - fabSize.width;
    final double bottomInset = screenSize.height - fabTopLeft.dy + _gapAboveFab;

    final double maxWidth = math.max(
      0.0,
      math.min(_maxMenuWidth, screenSize.width - endInset - _screenSidePadding),
    );
    final double maxHeight = math.max(
      0.0,
      fabTopLeft.dy - _screenSidePadding * 2,
    );

    return Stack(
      children: <Widget>[
        // حاجز شفاف: الضغط خارجه يغلق القائمة، ولا يعطّل بقية الشاشة بعد الإغلاق.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: _close,
            child: const ColoredBox(color: _barrierColor),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: endInset,
              bottom: bottomInset,
            ),
            child: Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: FadeTransition(
                  opacity: _progress,
                  child: ScaleTransition(
                    scale: _menuScale,
                    alignment: Alignment.bottomRight,
                    child: _buildMenu(scheme),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(ColorScheme scheme) {
    final List<_QuickActionData> actions = <_QuickActionData>[
      _QuickActionData(
        label: _bookingLabel,
        icon: Icons.event_available_rounded,
        background: scheme.primaryContainer,
        foreground: scheme.onPrimaryContainer,
        onPressed: widget.onAddBooking,
      ),
      _QuickActionData(
        label: _receiptLabel,
        icon: Icons.receipt_long_rounded,
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
        onPressed: widget.onAddReceipt,
      ),
    ];

    // يُعرض الإجراء الأول في الأسفل (الأقرب للزر الأساسي).
    final List<Widget> children = <Widget>[];
    for (int index = actions.length - 1; index >= 0; index--) {
      children.add(_buildActionTile(actions[index], index, scheme));
      if (index > 0) {
        children.add(const SizedBox(height: _gapBetweenActions));
      }
    }

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: children,
      ),
    );
  }

  Widget _buildActionTile(
    _QuickActionData action,
    int index,
    ColorScheme scheme,
  ) {
    // ظهور متدرّج بسيط: الإجراء الأقرب للزر يظهر أولًا.
    final Animation<double> animation = _controller.drive(
      CurveTween(
        curve: Interval(
          0.15 * index,
          0.15 * index + 0.6,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
        alignment: Alignment.bottomRight,
        child: Semantics(
          button: true,
          label: action.label,
          excludeSemantics: true,
          onTap: () => _handleAction(action.onPressed),
          child: Material(
            color: scheme.surface,
            elevation: 3,
            shadowColor: scheme.shadow,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _handleAction(action.onPressed),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: action.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action.icon,
                        size: 19,
                        color: action.foreground,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بيانات إجراء واحد داخل القائمة (داخلي فقط).
class _QuickActionData {
  const _QuickActionData({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;
}
