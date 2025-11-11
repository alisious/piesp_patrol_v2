import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/auth/auth_controller.dart';
import 'package:piesp_patrol/features/srp/data/person_controller.dart';
import 'package:piesp_patrol/features/vehicles/data/vehicle_controller.dart';

/// Reużywalny kontener wyświetlający stan użytkownika:
/// - Nazwa użytkownika
/// - Ikona tarczy (Bieżąca służba)
/// - Ikona osoby (Wybrana osoba) - wyświetlana tylko, jeśli wybrana osoba != null
/// - Ikona samochodu (Wybrany pojazd) - wyświetlana tylko, jeśli wybrany pojazd != null
/// 
/// Może być używany jako `bottom` w AppBar (implementuje PreferredSizeWidget).
class CommonStateContainer extends StatelessWidget implements PreferredSizeWidget {
  const CommonStateContainer({
    super.key,
    this.height = 45,
    this.padding = const EdgeInsets.fromLTRB(12, 6, 12, 6),
    this.spacing = 10,
  });

  /// Wysokość kontenera
  final double height;
  
  /// Padding wewnętrzny kontenera
  final EdgeInsetsGeometry padding;
  
  /// Odstęp między elementami
  final double spacing;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final auth = scope.authController as AuthController;
    final personController = scope.personController as PersonController;
    final vehicleController = scope.vehicleController as VehicleController;
    final cs = Theme.of(context).colorScheme;
    
    final userName = auth.meProfile?.userName ?? '---';
    
    return Container(
      width: double.infinity,
      color: cs.primary,
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: _InfoChip(
              bg: cs.surfaceContainerHighest,
              fg: cs.onSurface,
              icon: Icons.account_circle_outlined,
              label: userName,
            ),
          ),
          SizedBox(width: spacing),
          // Ikona tarczy - Bieżąca służba
          _ChipIcon(
            bg: cs.surfaceContainerHighest,
            fg: cs.onSurfaceVariant,
            icon: Icons.shield_outlined,
            tooltip: 'Bieżąca służba',
          ),
          // Dynamiczne ikony: osoba (jeśli wybrana) i samochód (jeśli wybrany)
          AnimatedBuilder(
            animation: Listenable.merge([personController, vehicleController]),
            builder: (context, _) {
              final hasSelectedPerson = personController.selectedPerson != null;
              final hasSelectedVehicle = vehicleController.selectedVehicle != null;
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Spacing przed ikonami
                  SizedBox(width: spacing),
                  // Ikona osoby - Wybrana osoba (tylko jeśli wybrana osoba != null)
                  if (hasSelectedPerson) ...[
                    _ChipIcon(
                      bg: cs.surfaceContainerHighest,
                      fg: cs.onSurfaceVariant,
                      icon: Icons.person_outlined,
                      tooltip: 'Wybrana osoba',
                    ),
                    SizedBox(width: spacing),
                  ],
                  // Ikona samochodu - Wybrany pojazd (tylko jeśli wybrany pojazd != null)
                  if (hasSelectedVehicle) ...[
                    _ChipIcon(
                      bg: cs.surfaceContainerHighest,
                      fg: cs.onSurfaceVariant,
                      icon: Icons.directions_car_outlined,
                      tooltip: 'Wybrany pojazd',
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Ikona w formie chipa (bez tekstu)
class _ChipIcon extends StatelessWidget {
  const _ChipIcon({
    required this.bg,
    required this.fg,
    required this.icon,
    this.tooltip,
  });

  final Color bg;
  final Color fg;
  final IconData icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: fg),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}

/// Chip z ikoną i tekstem
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
  });

  final Color bg;
  final Color fg;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: fg)),
        ],
      ),
    );
  }
}

