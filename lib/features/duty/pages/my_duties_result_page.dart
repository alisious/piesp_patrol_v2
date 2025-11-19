// lib/features/duty/pages/my_duties_result_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/duty/data/duty_api.dart';
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
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final request = StartStopDutyRequest(
        dutyId: widget.dutyId!,
        dateTimeUtc: parsed.toUtc().toIso8601String(),
        latitude: 0,
        longitude: 0,
      );
      final response = await dutyApi.startDuty(request);
      if (!mounted) return;

      if ((response.status ?? -1) == 0) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Służba rozpoczęta.')),
        );
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
        setState(() => _isSubmitting = false);
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
            label: 'Rozpocznij',
            fullWidth: true,
            constrainWidthExternally: true,
            enabled: !_isSubmitting,
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

