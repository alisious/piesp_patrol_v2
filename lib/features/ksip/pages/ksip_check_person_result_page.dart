// lib/features/ksip/pages/ksip_check_person_result_page.dart
import 'package:flutter/material.dart';
import 'package:piesp_patrol/features/ksip/data/ksip_sprawdzenie_osoby_dtos.dart';
import 'package:piesp_patrol/widgets/common_appbar.dart';

class KsipCheckPersonResultPage extends StatelessWidget {
  const KsipCheckPersonResultPage({
    super.key,
    required this.response,
  });

  final KsipSprawdzenieOsobyResponseDto response;

  @override
  Widget build(BuildContext context) {
    final hasPerson = response.person != null;
    final hasOffenseRecords = response.offenseRecords.isNotEmpty;

    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Sprawdzenie osoby w ruchu drogowym',
        showBack: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Informacja o braku danych
              if (!hasPerson && !hasOffenseRecords)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Brak danych osoby lub wykroczeń',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),

              // Dane osoby
              if (hasPerson)
                _section(
                  context,
                  title: 'Dane osoby',
                  children: _buildPersonSection(context, response.person!),
                  initiallyExpanded: true,
                ),

              // Rekordy wykroczeń
              if (hasOffenseRecords)
                _section(
                  context,
                  title: 'Wykroczenia (${response.offenseRecords.length})',
                  children: _buildOffenseRecordsSection(context, response.offenseRecords),
                  initiallyExpanded: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(title),
        initiallyExpanded: initiallyExpanded,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  List<Widget> _rows(Map<String, String?> items) {
    final list = <Widget>[];
    items.forEach((label, value) {
      final v = (value ?? '').trim();
      if (v.isNotEmpty) {
        list.add(_row(label, v));
      }
    });
    return list;
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPersonSection(
    BuildContext context,
    KsipPersonDto person,
  ) {
    return _rows({
      'Imię': person.firstName,
      'Nazwisko': person.lastName,
      'PESEL': person.peselNumber,
      'Data urodzenia': _formatDate(person.birthDate),
    });
  }

  List<Widget> _buildOffenseRecordsSection(
    BuildContext context,
    List<KsipOffenseRecordDto> records,
  ) {
    final widgets = <Widget>[];

    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      if (i > 0) {
        widgets.add(const Divider(height: 24));
      }

      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Wykroczenie ${i + 1}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));

      // Podstawowe informacje o wykroczeniu
      widgets.addAll(
        _rows({
          'Data zdarzenia': _formatDate(record.incidentDate),
          'Data zapłaty mandatu': _formatDate(record.finePaymentDate),
          'Data walidacji decyzji': _formatDate(record.validationOfDecisionDate),
        }),
      );

      // Klasyfikacja wykroczenia
      if (record.classification != null) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Klasyfikacja',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 4));

        final classification = record.classification!;
        // Kod klasyfikacji prawnej i kod klasyfikacji w układzie dwukolumnowym
        widgets.addAll(
          _rows({
            'Kod klasyfikacji prawnej': classification.legalClassificationCode,
            'Kod klasyfikacji': classification.classificationCode,
          }),
        );
        
        // Opis na pełnej szerokości
        if (classification.description != null && classification.description!.trim().isNotEmpty) {
          widgets.add(const SizedBox(height: 8));
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opis',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    classification.description!,
                  ),
                ],
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  String? _formatDate(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) return null;
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString; // Jeśli nie można sparsować, zwróć oryginał
    }
  }
}

