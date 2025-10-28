import 'package:flutter/material.dart';

/// Prosty „klawisz” z napisem i strzałką po prawej.
/// - tło jak strona (surface)
/// - biała ramka 1 px
/// - kompaktowa wysokość (52)
/// - normalna czcionka
class ArrowButton extends StatelessWidget {
  const ArrowButton({
    super.key,
    required this.title,
    required this.onTap,
    this.height = 52,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String title;
  final VoidCallback onTap;
  final double height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400, // normalna czcionka
                    color: cs.onSurface,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}
