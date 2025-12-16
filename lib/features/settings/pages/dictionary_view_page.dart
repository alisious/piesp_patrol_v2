import 'package:flutter/material.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/piesp/data/piesp_dictionary_service.dart' show PiespDictionaryService;
import 'package:piesp_patrol/features/piesp/data/piesp_dictionaries_dtos.dart' show PiespWartoscSlownikowaLite;

class DictionaryViewPage extends StatefulWidget {
  const DictionaryViewPage({
    super.key,
    required this.dictionaryName,
    required this.dictionaryId,
  });

  final String dictionaryName;
  final String dictionaryId;

  @override
  State<DictionaryViewPage> createState() => _DictionaryViewPageState();
}

class _DictionaryViewPageState extends State<DictionaryViewPage> {
  List<PiespWartoscSlownikowaLite> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDictionary();
  }

  Future<void> _loadDictionary() async {
    final scope = AppScope.read(context);
    final service = scope.piespDictionaryService as PiespDictionaryService;
    final items = await service.getDictionaryLocal(widget.dictionaryId);
    
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionaryName),
        centerTitle: true,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Słownik jest pusty. Zaktualizuj słownik, aby zobaczyć zawartość.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _DictionaryItemText(
                      item: item,
                      index: index + 1,
                    );
                  },
                ),
    );
  }
}

class _DictionaryItemText extends StatelessWidget {
  const _DictionaryItemText({
    required this.item,
    required this.index,
  });

  final PiespWartoscSlownikowaLite item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    // Sprawdź wartości, ignorując string "null" i puste stringi
    String? kod;
    if (item.kod != null) {
      final trimmed = item.kod!.trim();
      if (trimmed.isNotEmpty && trimmed.toLowerCase() != 'null') {
        kod = trimmed;
      }
    }
    
    String? wartoscOpisowa;
    if (item.wartoscOpisowa != null) {
      final trimmed = item.wartoscOpisowa!.trim();
      if (trimmed.isNotEmpty && trimmed.toLowerCase() != 'null') {
        wartoscOpisowa = trimmed;
      }
    }
    
    String displayText = '';
    if (kod != null) {
      displayText = kod;
      if (wartoscOpisowa != null) {
        displayText += ' - $wartoscOpisowa';
      }
    } else if (wartoscOpisowa != null) {
      displayText = wartoscOpisowa;
    } else {
      // Jeśli oba są null, pokaż informację o pustym elemencie
      displayText = '(pusty element)';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$index. $displayText',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: cs.onSurface,
        ),
      ),
    );
  }
}

