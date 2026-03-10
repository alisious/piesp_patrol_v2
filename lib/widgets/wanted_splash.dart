import 'package:flutter/material.dart';

/// Wyświetla czerwony, migający splash "OSOBA POSZUKIWANA!".
/// Zamyka się automatycznie po 2.5 s lub po kliknięciu poza nim.
Future<void> showWantedSplash(BuildContext context) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'wanted',
    pageBuilder: (_, __, ___) => const WantedSplash(),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 200),
  );
}

/// Migający, pełnoekranowy splash "OSOBA POSZUKIWANA!".
class WantedSplash extends StatefulWidget {
  const WantedSplash({super.key});

  @override
  State<WantedSplash> createState() => _WantedSplashState();
}

class _WantedSplashState extends State<WantedSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red,
      child: Center(
        child: AnimatedBuilder(
          animation: _opacity,
          builder: (context, _) {
            return Opacity(
              opacity: _opacity.value,
              child: Text(
                'OSOBA POSZUKIWANA!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}
