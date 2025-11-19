// lib/features/duty/pages/my_duties_result_page.dart
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

class MyDutiesResultPage extends StatelessWidget {
  const MyDutiesResultPage({
    super.key,
    required this.duties,
  });

  final List<DutyDto> duties;

  String _format(String? value) {
    if (value == null || value.isEmpty) return '-';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Moje służby na dziś',
        showBack: true,
      ),
      body: PageContainer(
        maxWidth: 520,
        child: duties.isEmpty
            ? Center(
                child: Text(
                  'Brak zaplanowanych służb.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: duties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final duty = duties[index];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            duty.type ?? 'Służba',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
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
                          const SizedBox(height: 12),
                          Text(
                            'Plan:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start: ${_format(duty.start)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Koniec: ${_format(duty.end)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Realizacja:',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _RealizationInput(dutyId: duty.id),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _RealizationInput extends StatefulWidget {
  const _RealizationInput({required this.dutyId});

  final int? dutyId;

  @override
  State<_RealizationInput> createState() => _RealizationInputState();
}

class _RealizationInputState extends State<_RealizationInput> {
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
    final now = DateTime.now();
    _controller.text = _formatNow(now);
  }

  Future<void> _startDuty() async {
    if (widget.dutyId == null) {
      setState(() {
        _error = 'Brak identyfikatora służby.';
      });
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _error = 'Uzupełnij datę rozpoczęcia.';
      });
      return;
    }

    DateTime? parsed;
    try {
      parsed = DateTime.parse(text);
    } catch (_) {
      parsed = null;
    }

    if (parsed == null) {
      setState(() {
        _error = 'Niepoprawny format daty.';
      });
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

    // Wyślij żądanie rozpoczęcia służby
    try {
      final request = StartStopDutyRequest(
        dutyId: widget.dutyId!,
        dateTimeUtc: parsed.toUtc().toIso8601String(),
        latitude: latitude,
        longitude: longitude,
      );
      final response = await dutyApi.startDuty(request);
      if (!mounted) return;

      if ((response.status ?? -1) == 0) {
        final startedDuty = response.data;
        final dutyType = startedDuty?.type ?? 'służbę';
        final locationMsg = locationObtained
            ? ' (lokalizacja: ${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)})'
            : ' (bez lokalizacji)';
        messenger.showSnackBar(
          SnackBar(content: Text('Rozpoczęto $dutyType$locationMsg')),
        );
        if (startedDuty != null) {
          dutyController.setCurrentDuty(startedDuty);
        }
        if (navigator.mounted) {
          navigator.pop();
        }
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              response.message ?? 'Nie udało się rozpocząć służby.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Błąd rozpoczęcia służby: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputBox(
          controller: _controller,
          label: 'Rozpoczęcie',
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
        SizedBox(
          width: double.infinity,
          child: ButtonSelect(
            label: _isGettingLocation ? 'Pobieranie lokalizacji...' : 'Rozpocznij',
            fullWidth: true,
            constrainWidthExternally: true,
            enabled: !_isSubmitting && !_isGettingLocation,
            onPressedAsync: _startDuty,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
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

