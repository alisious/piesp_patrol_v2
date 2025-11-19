// lib/features/duty/pages/current_duty_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/core/services/location_service.dart';
import 'package:piesp_patrol/features/duty/data/duty_api.dart';
import 'package:piesp_patrol/features/duty/data/duty_controller.dart';
import 'package:piesp_patrol/features/duty/data/duty_dtos.dart';
import 'package:piesp_patrol/widgets/button_select.dart';
import 'package:piesp_patrol/widgets/common_appbar.dart';
import 'package:piesp_patrol/widgets/input_box.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class CurrentDutyPage extends StatelessWidget {
  const CurrentDutyPage({super.key});

  String _format(String? value, {bool withSeconds = false}) {
    if (value == null || value.isEmpty) return '-';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    final base =
        '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    if (withSeconds) {
      return '$base:${local.second.toString().padLeft(2, '0')}';
    }
    return base;
  }

  Widget _buildDutyCard(BuildContext context, DutyDto duty) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              duty.type ?? 'Służba',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if ((duty.unit ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                duty.unit!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Plan',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _InfoRow(label: 'Start', value: _format(duty.start)),
            const SizedBox(height: 4),
            _InfoRow(label: 'Koniec', value: _format(duty.end)),
            const SizedBox(height: 16),
            Text(
              'Realizacja',
              style: theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            _InfoRow(label: 'Lokalizacja startu', value: _formatCoords(duty.actualStartLatitude, duty.actualStartLongitude)),
            const SizedBox(height: 4),
            _InfoRow(label: 'Start', value: _format(duty.actualStart, withSeconds: true)),
            const SizedBox(height: 4),
            _InfoRow(label: 'Status', value: duty.status?.toString() ?? '-'),
            const SizedBox(height: 24),
            _FinishDutyPanel(dutyId: duty.id),
          ],
        ),
      ),
    );
  }

  String _formatCoords(double? lat, double? lon) {
    if (lat == null || lon == null) return '-';
    return '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.read(context);
    final dutyController = services.dutyController as DutyController;

    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Aktywna służba',
        showBack: true,
      ),
      body: PageContainer(
        maxWidth: 520,
        child: AnimatedBuilder(
          animation: dutyController,
          builder: (context, _) {
            final duty = dutyController.currentDuty;
            if (duty == null) {
              return Center(
                child: Text(
                  'Nie masz rozpoczętej służby.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _buildDutyCard(context, duty),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _FinishDutyPanel extends StatefulWidget {
  const _FinishDutyPanel({required this.dutyId});

  final int? dutyId;

  @override
  State<_FinishDutyPanel> createState() => _FinishDutyPanelState();
}

class _FinishDutyPanelState extends State<_FinishDutyPanel> {
  late final TextEditingController _controller;
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatNow(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  void _setNow() {
    _controller.text = _formatNow(DateTime.now());
  }

  Future<void> _stopDuty() async {
    if (widget.dutyId == null) {
      setState(() => _error = 'Brak identyfikatora służby.');
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Uzupełnij datę zakończenia.');
      return;
    }

    DateTime? parsed;
    try {
      parsed = DateTime.parse(text);
    } catch (_) {
      parsed = null;
    }

    if (parsed == null) {
      setState(() => _error = 'Niepoprawny format daty.');
      return;
    }

    final services = AppScope.read(context);
    final dutyApi = services.dutyApi as DutyApi;
    final dutyController = services.dutyController as DutyController;
    final locationService = services.locationService as LocationService;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _isSubmitting = true;
      _isGettingLocation = true;
      _error = null;
    });

    // Pobierz lokalizację
    double latitude = 0.0;
    double longitude = 0.0;
    bool locationObtained = false;

    try {
      final location = await locationService.getCurrentLocation();
      if (location != null) {
        latitude = location.latitude;
        longitude = location.longitude;
        locationObtained = true;
      }
    } on LocationError catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isGettingLocation = false;
      });

      // Pokaż dialog z opcjami
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => _LocationErrorDialog(error: e),
      );

      if (shouldContinue != true) {
        // Użytkownik anulował
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
        return;
      }
      // Kontynuuj bez lokalizacji (latitude i longitude pozostają 0.0)
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isGettingLocation = false;
      });

      // Nieoczekiwany błąd - zapytaj czy kontynuować
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Błąd lokalizacji'),
          content: Text('Wystąpił nieoczekiwany błąd podczas pobierania lokalizacji: ${e.toString()}\n\nCzy chcesz kontynuować bez lokalizacji?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Kontynuuj'),
            ),
          ],
        ),
      );

      if (shouldContinue != true) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
        return;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }

    // Wyślij żądanie zakończenia służby
    try {
      final request = StartStopDutyRequest(
        dutyId: widget.dutyId!,
        dateTimeUtc: parsed.toUtc().toIso8601String(),
        latitude: latitude,
        longitude: longitude,
      );

      final response = await dutyApi.stopDuty(request);
      if (!mounted) return;

      if ((response.status ?? -1) == 0) {
        final dutyType = response.data?.type ?? 'służbę';
        final locationMsg = locationObtained
            ? ' (lokalizacja: ${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)})'
            : ' (bez lokalizacji)';
        messenger.showSnackBar(
          SnackBar(content: Text('Zakończono $dutyType$locationMsg')),
        );
        dutyController.clearCurrentDuty();
        navigator.pop();
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? 'Nie udało się zakończyć służby.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputBox(
          controller: _controller,
          label: 'Zakończenie',
          hint: 'rrrr-MM-dd HH:mm',
          preset: InputPreset.text,
          suffixIcon: Tooltip(
            message: 'Teraz',
            child: IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: _setNow,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ButtonSelect(
          label: _isGettingLocation ? 'Pobieranie lokalizacji...' : 'Zakończ',
          enabled: !_isSubmitting && !_isGettingLocation,
          onPressedAsync: _stopDuty,
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }
}

/// Dialog wyświetlany w przypadku błędu lokalizacji
class _LocationErrorDialog extends StatelessWidget {
  const _LocationErrorDialog({required this.error});

  final LocationError error;

  Future<void> _openSettings(BuildContext context, LocationService locationService) async {
    Navigator.of(context).pop(false); // Zamknij dialog
    if (error.type == LocationErrorType.permissionDeniedForever ||
        error.type == LocationErrorType.permissionDenied) {
      await locationService.openAppSettings();
    } else if (error.type == LocationErrorType.locationServiceDisabled) {
      await locationService.openLocationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.read(context);
    final locationService = services.locationService as LocationService;
    final theme = Theme.of(context);

    String actionButtonText = 'Otwórz ustawienia';
    VoidCallback? actionButtonOnPressed;

    if (error.type == LocationErrorType.permissionDeniedForever ||
        error.type == LocationErrorType.permissionDenied) {
      actionButtonText = 'Otwórz ustawienia aplikacji';
      actionButtonOnPressed = () => _openSettings(context, locationService);
    } else if (error.type == LocationErrorType.locationServiceDisabled) {
      actionButtonText = 'Włącz GPS';
      actionButtonOnPressed = () => _openSettings(context, locationService);
    }

    return AlertDialog(
      title: const Text('Błąd lokalizacji'),
      content: Text(error.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Anuluj'),
        ),
        if (actionButtonOnPressed != null)
          TextButton(
            onPressed: actionButtonOnPressed,
            child: Text(actionButtonText),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
          child: const Text('Kontynuuj bez lokalizacji'),
        ),
      ],
    );
  }
}

