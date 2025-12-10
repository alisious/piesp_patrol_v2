import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/piesp/data/piesp_dictionary_service.dart' show PiespDictionaryService, PiespDictionaryId;

class DictionariesPage extends StatelessWidget {
  const DictionariesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Słowniki'),
        centerTitle: true,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _dictionaries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final dictionary = _dictionaries[index];
          return _DictionaryPanel(
            key: ValueKey(dictionary.id),
            name: dictionary.name,
            dictionaryId: dictionary.id,
          );
        },
      ),
    );
  }

  static const List<_DictionaryInfo> _dictionaries = [
    _DictionaryInfo(
      name: 'Powód sprawdzenia',
      id: PiespDictionaryId.powodSprawdzenia,
    ),
    _DictionaryInfo(
      name: 'Rodzaj czynności',
      id: PiespDictionaryId.rodzajCzynnosci,
    ),
  ];
}

class _DictionaryInfo {
  final String name;
  final String id;

  const _DictionaryInfo({required this.name, required this.id});
}

class _DictionaryPanel extends StatefulWidget {
  const _DictionaryPanel({
    super.key,
    required this.name,
    required this.dictionaryId,
  });

  final String name;
  final String dictionaryId;

  @override
  State<_DictionaryPanel> createState() => _DictionaryPanelState();
}

class _DictionaryPanelState extends State<_DictionaryPanel> {
  DateTime? _lastUpdateDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastUpdateDate();
  }

  Future<void> _loadLastUpdateDate() async {
    final scope = AppScope.read(context);
    final service = scope.piespDictionaryService as PiespDictionaryService;
    final date = await service.getDictionaryLastUpdateDate(widget.dictionaryId);
    if (mounted) {
      setState(() {
        _lastUpdateDate = date;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpdate() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    // Pokaż komunikat o rozpoczęciu aktualizacji
    messenger.showSnackBar(
      SnackBar(
        content: Text('Aktualizacja słownika "${widget.name}" w trakcie...'),
        duration: const Duration(minutes: 1),
      ),
    );

    try {
      final scope = AppScope.read(context);
      final service = scope.piespDictionaryService as PiespDictionaryService;

      final result = await service.refreshDictionary(widget.dictionaryId);

      if (!mounted) return;

      messenger.hideCurrentSnackBar();

      final message = (result.status == 0)
          ? (result.message ?? 'Słownik "${widget.name}" został zaktualizowany.')
          : (result.message ?? 'Błąd aktualizacji słownika "${widget.name}".');

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: result.status == 0 ? null : Colors.red,
        ),
      );

      // Po udanej aktualizacji odśwież datę
      if (result.status == 0) {
        await _loadLastUpdateDate();
      }
    } catch (e) {
      if (!mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Błąd aktualizacji słownika "${widget.name}": ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Nigdy nie aktualizowany';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Przed chwilą';
        }
        return '${difference.inMinutes} ${_pluralize(difference.inMinutes, 'minutę', 'minuty', 'minut')} temu';
      }
      return '${difference.inHours} ${_pluralize(difference.inHours, 'godzinę', 'godziny', 'godzin')} temu';
    } else if (difference.inDays == 1) {
      return 'Wczoraj';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${_pluralize(difference.inDays, 'dzień', 'dni', 'dni')} temu';
    } else {
      // Format: DD.MM.YYYY HH:MM
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day.$month.$year $hour:$minute';
    }
  }

  String _pluralize(int count, String one, String few, String many) {
    if (count == 1) return one;
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return few;
    }
    return many;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _handleUpdate,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Aktualizuj'),
                ),
              ],
            ),
            if (!_isLoading) ...[
              const SizedBox(height: 8),
              Text(
                _formatDate(_lastUpdateDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

