import 'package:flutter/material.dart';

class ArrowButton extends StatelessWidget {
  const ArrowButton({
    super.key,
    required this.title,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.radius = 12,
    this.enabled = true,
  });

  final String title;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    // Delikatniejsze obramowanie w jasnym trybie (outlineVariant), a w ciemnym zwykłe outline
    final borderColor = isLight ? cs.outlineVariant : cs.outline;
    
    // Kolor tekstu i ikony zależny od stanu enabled
    final textColor = enabled ? cs.onSurface : cs.onSurface.withValues(alpha: 0.38);
    final iconColor = enabled ? cs.onSurfaceVariant : cs.onSurfaceVariant.withValues(alpha: 0.38);

    return Material(
      color: cs.surface, // tło jak strona
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: enabled ? onTap : null,
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
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
