import 'package:flutter/material.dart';

class ArrowButton extends StatelessWidget {
  const ArrowButton({
    super.key,
    required this.title,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.radius = 12,
  });

  final String title;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    // Delikatniejsze obramowanie w jasnym trybie (outlineVariant), a w ciemnym zwykłe outline
    final borderColor = isLight ? cs.outlineVariant : cs.outline;

    return Material(
      color: cs.surface, // tło jak strona
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface, // czytelny w obu trybach
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: cs.onSurfaceVariant, // subtelniejsza strzałka
              ),
            ],
          ),
        ),
      ),
    );
  }
}
