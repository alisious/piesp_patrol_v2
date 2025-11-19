// lib/features/duty/pages/my_duties_result_page.dart
import 'package:flutter/material.dart';
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
                          _RealizationInput(),
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
  const _RealizationInput();

  @override
  State<_RealizationInput> createState() => _RealizationInputState();
}

class _RealizationInputState extends State<_RealizationInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            onPressedAsync: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Rozpoczęcie służby - funkcja w przygotowaniu.',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}