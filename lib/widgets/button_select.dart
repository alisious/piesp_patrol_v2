import 'package:flutter/material.dart';

class ButtonSelect extends StatefulWidget {
  const ButtonSelect({
    super.key,
    required this.onPressedAsync,
    this.label = 'Wybierz',
    this.enabled = true,
    this.fullWidth = true,
    this.icon = Icons.check,
    this.height = 44,
    this.showErrorSnackBar = true,
    this.errorToMessage,
    this.style,
    this.expandOnMobile = true,   // NEW: zawsze pełna szerokość na telefonie
    this.mobileBreakpoint = 600,  // NEW: szerokość ekranu w px (Material)
    this.constrainWidthExternally = false,
  });

  final Future<void> Function() onPressedAsync;
  final String label;
  final bool enabled;
  final bool fullWidth;
  final IconData icon;
  final double height;
  final bool showErrorSnackBar;
  final String Function(Object error)? errorToMessage;
  final ButtonStyle? style;

  /// Gdy true, na ekranach wąskich (<= mobileBreakpoint) przycisk zajmie 100% szerokości,
  /// nawet wewnątrz Row/Center itp.
  final bool expandOnMobile;
  final double mobileBreakpoint;
  /// Gdy true, rodzic odpowiada za ograniczenie szerokości (np. SizedBox/Expanded).
  /// ButtonSelect nie owija się w SizedBox(width: double.infinity).
  final bool constrainWidthExternally;

  @override
  State<ButtonSelect> createState() => _ButtonSelectState();
}

class _ButtonSelectState extends State<ButtonSelect> {
  bool _loading = false;

  Future<void> _handlePress() async {
    if (_loading || !widget.enabled) return;
    setState(() => _loading = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      await widget.onPressedAsync();
    } catch (err) {
      if (widget.showErrorSnackBar) {
        final msg = widget.errorToMessage?.call(err) ??
            (err is Exception ? err.toString() : 'Wystąpił błąd.');
        if (mounted) {
          messenger.showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenW = MediaQuery.sizeOf(context).width;
    final forceFullWidthMobile =
        widget.expandOnMobile && screenW <= widget.mobileBreakpoint;

    final content = _loading
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Text(widget.label),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon),
              const SizedBox(width: 8),
              Text(widget.label),
            ],
          );

    final btn = FilledButton(
      onPressed: (widget.enabled && !_loading) ? _handlePress : null,
      style: widget.style ??
          FilledButton.styleFrom(
            minimumSize: Size(
              (widget.fullWidth || forceFullWidthMobile) ? double.infinity : 0,
              widget.height,
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
      child: content,
    );

    // Wymuś pełną szerokość na mobile nawet w Row/Center,
    // chyba że oczekujemy, że zrobi to rodzic.
    if (!widget.constrainWidthExternally &&
        (widget.fullWidth || forceFullWidthMobile)) {
      return SizedBox(width: double.infinity, child: btn);
    }
    return btn;
  }
}

