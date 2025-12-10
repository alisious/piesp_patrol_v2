# Dokumentacja

## Instrukcja obsługi

Plik `INSTRUKCJA_OBSLUGI.md` zawiera szczegółową instrukcję obsługi aplikacji.

**📖 Jak używać systemu dokumentacji:** Zobacz [JAK_UZYWAC.md](JAK_UZYWAC.md) - przewodnik po edycji, dodawaniu modułów i generowaniu dokumentów Word.

### Konwersja do Word

Aby przekonwertować instrukcję do formatu Word (.docx):

1. **Zainstaluj Pandoc** (jeśli nie masz):
   - Pobierz z: https://github.com/jgm/pandoc/releases/latest
   - Lub użyj Chocolatey: `choco install pandoc`
   - Lub użyj winget: `winget install --id JohnMacFarlane.Pandoc`

2. **Uruchom skrypt konwersji**:
   ```powershell
   .\docs\convert-to-word.ps1
   ```

   Lub ręcznie:
   ```powershell
   pandoc docs/INSTRUKCJA_OBSLUGI.md -o docs/INSTRUKCJA_OBSLUGI.docx --toc --toc-depth=3
   ```

3. Plik `INSTRUKCJA_OBSLUGI.docx` zostanie utworzony w folderze `docs/`

### Obrazy

Obrazy zrzutów ekranu znajdują się w folderze `docs/images/` i są automatycznie wstawiane podczas konwersji.

**Uwaga:** Obrazy są wykluczone z repozytorium Git (zobacz `.gitignore`).

