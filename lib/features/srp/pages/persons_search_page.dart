// lib/features/srp/pages/persons_search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piesp_patrol/core/routing/routes.dart';
import 'package:piesp_patrol/core/app_scope.dart';
import 'package:piesp_patrol/features/srp/data/srp_api.dart';
import 'package:piesp_patrol/features/srp/data/srp_dtos.dart';
import 'package:piesp_patrol/widgets/responsive.dart';

class PersonsSearchPage extends StatefulWidget {
  const PersonsSearchPage({super.key});

  @override
  State<PersonsSearchPage> createState() => _PersonsSearchPageState();
}

class _PersonsSearchPageState extends State<PersonsSearchPage> {
  final _peselCtrl = TextEditingController();
  final _nazwiskoCtrl = TextEditingController();
  final _imie1Ctrl = TextEditingController();
  final _imie2Ctrl = TextEditingController();
  final _imieOjcaCtrl = TextEditingController();
  final _imieMatkiCtrl = TextEditingController();
  final _dataUrodzCtrl = TextEditingController();
  final _dataUrodzOdCtrl = TextEditingController();
  final _dataUrodzDoCtrl = TextEditingController();

  bool? _czyZyje;
  bool _loading = false;

  int _peselLen = 0;
 
  @override
  void initState() {
    super.initState();
    _peselCtrl.addListener(_onPeselChanged);
  }

  void _onPeselChanged() {
    final len = _peselCtrl.text.length;
    if (len != _peselLen) {
      setState(() => _peselLen = len);
    }
  }

  @override
  void dispose() {
    _peselCtrl.removeListener(_onPeselChanged);
    _peselCtrl.dispose();
    _nazwiskoCtrl.dispose();
    _imie1Ctrl.dispose();
    _imie2Ctrl.dispose();
    _imieOjcaCtrl.dispose();
    _imieMatkiCtrl.dispose();
    _dataUrodzCtrl.dispose();
    _dataUrodzOdCtrl.dispose();
    _dataUrodzDoCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSearch() async {
    setState(() => _loading = true);

    final req = SearchPersonRequestDto(
      pesel: _nullIfEmpty(_peselCtrl.text),
      nazwisko: _nullIfEmpty(_nazwiskoCtrl.text),
      imiePierwsze: _nullIfEmpty(_imie1Ctrl.text),
      imieDrugie: _nullIfEmpty(_imie2Ctrl.text),
      imieOjca: _nullIfEmpty(_imieOjcaCtrl.text),
      imieMatki: _nullIfEmpty(_imieMatkiCtrl.text),
      dataUrodzenia: _nullIfEmpty(_dataUrodzCtrl.text),
      dataUrodzeniaOd: _nullIfEmpty(_dataUrodzOdCtrl.text),
      dataUrodzeniaDo: _nullIfEmpty(_dataUrodzDoCtrl.text),
      czyZyje: _czyZyje,
    );

    final srpApi = AppScope.of(context).srpApi as SrpApi;
    final res = await srpApi.searchPerson(request: req);

    if (!mounted) return;

    if (res.isOk) {
      setState(() => _loading = false);
      final list = res.value;
      if (list.isEmpty) {
        _showSnack('Nie znaleziono osób spełniających kryteria.');
        return;
      }
      Navigator.pushNamed(
        context, 
        AppRoutes.srpPersonsSearchResults,
        arguments: SrpPersonsSearchResultsArgs(results: list)
        );
    } else {
      setState(() => _loading = false);
      _showSnack(
        res.error.message.isNotEmpty
            ? res.error.message
            : 'Wystąpił błąd podczas wyszukiwania.',
      );
    }
  }

  String? _nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyszukaj osoby'),
        centerTitle: true,
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: PageContainer(
        maxWidth: 480,
        child: ListView(
          children: [
            // === PESEL z licznikiem L/11 po prawej i twardym limitem 11 cyfr ===
            TextField(
              controller: _peselCtrl,
              decoration: InputDecoration(
                labelText: 'PESEL',
                helperText:
                    'Podaj PESEL lub (Nazwisko i Imię pierwsze). Datę w formacie yyyy-MM-dd.',
                // licznik po prawej stronie w polu
                suffix: Text(
                  '$_peselLen/11',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _nazwiskoCtrl,
              decoration: const InputDecoration(labelText: 'Nazwisko'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _imie1Ctrl,
              decoration: const InputDecoration(labelText: 'Imię pierwsze'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _imie2Ctrl,
              decoration: const InputDecoration(labelText: 'Imię drugie'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _imieOjcaCtrl,
              decoration: const InputDecoration(labelText: 'Imię ojca'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _imieMatkiCtrl,
              decoration: const InputDecoration(labelText: 'Imię matki'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _dataUrodzCtrl,
              decoration: const InputDecoration(
                labelText: 'Data urodzenia (yyyy-MM-dd)',
              ),
              keyboardType: TextInputType.datetime,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dataUrodzOdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Data ur. od (yyyy-MM-dd)',
                    ),
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dataUrodzDoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Data ur. do (yyyy-MM-dd)',
                    ),
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<bool?>(
              initialValue: _czyZyje,
              items: const [
                DropdownMenuItem<bool?>(
                  value: null,
                  child: Text('Czy żyje: (nieistotne)'),
                ),
                DropdownMenuItem<bool>(value: true, child: Text('Czy żyje: TAK')),
                DropdownMenuItem<bool>(value: false, child: Text('Czy żyje: NIE')),
              ],
              onChanged: (v) => setState(() => _czyZyje = v),
              decoration: const InputDecoration(labelText: 'Status życia'),
            ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _loading ? null : _onSearch,
              icon: const Icon(Icons.search),
              label: const Text('Wyszukaj'),
            ),
            
            const SizedBox(height: 8),

            if (_loading) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
