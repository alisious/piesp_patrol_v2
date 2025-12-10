# Instrukcja użytkowania systemu dokumentacji

## Struktura folderów

```
docs/
├── INSTRUKCJA_OBSLUGI.md          # Główny plik instrukcji (Markdown)
├── convert-to-word.ps1             # Skrypt konwersji do Word
├── README.md                       # Opis dokumentacji
├── JAK_UZYWAC.md                  # Ten plik
└── images/                         # Folder na zrzuty ekranu
    ├── login_page_1.png
    ├── login_page_2.png
    ├── settings_page_1.png
    ├── settings_page_2.png
    └── reset_pin_page.png
```

## Podstawowe operacje

### 1. Edycja instrukcji

Edytuj plik `docs/INSTRUKCJA_OBSLUGI.md` w dowolnym edytorze Markdown.

**Formatowanie:**
- Nagłówki: `##` (sekcja), `###` (podsekcja), `####` (punkt)
- Obrazy: `![Opis](images/nazwa_pliku.png)`
- Listy: `-` dla punktów, `1.` dla numerowanych
- Kod: `` `kod` `` dla inline, ` ``` ` dla bloków

### 2. Dodawanie zrzutów ekranu

1. Wykonaj zrzut ekranu z aplikacji
2. Zapisz w folderze `docs/images/` z opisową nazwą (np. `nowa_funkcja_1.png`)
3. Dodaj referencję w Markdown: `![Opis obrazu](images/nowa_funkcja_1.png)`

**Uwaga:** Obrazy są wykluczone z Git (zobacz `.gitignore`).

### 3. Generowanie dokumentu Word

**Sposób 1: Skrypt PowerShell (zalecany)**
```powershell
cd docs
.\convert-to-word.ps1
```

**Sposób 2: Ręcznie przez Pandoc**
```powershell
cd docs
pandoc INSTRUKCJA_OBSLUGI.md -o INSTRUKCJA_OBSLUGI.docx --toc --toc-depth=3
```

**Co robi skrypt:**
- Konwertuje Markdown → Word
- Automatycznie skaluje obrazy do 50%
- Wyśrodkowuje obrazy
- Blokuje proporcje obrazów
- Dodaje spis treści
- Otwiera dokument Word

**Wymagania:**
- Pandoc (zainstalowany przez winget/choco)
- Microsoft Word (dla modyfikacji obrazów)

## Dodawanie nowych modułów/sekcji

### Krok 1: Dodaj sekcję w Markdown

W pliku `INSTRUKCJA_OBSLUGI.md` dodaj nową sekcję:

```markdown
## 4. Nowa funkcja

### Opis ekranu
Opis nowej funkcji...

![Zrzut ekranu](images/nowa_funkcja.png)

### Pola wprowadzania danych
...
```

### Krok 2: Dodaj zrzuty ekranu

1. Wykonaj zrzuty ekranu
2. Zapisz w `docs/images/`
3. Dodaj referencje w Markdown

### Krok 3: Wygeneruj Word

Uruchom skrypt konwersji (patrz wyżej).

## Aktualizacja istniejącej instrukcji

1. **Edytuj** `INSTRUKCJA_OBSLUGI.md`
2. **Dodaj/zmień** zrzuty ekranu w `docs/images/` (jeśli potrzeba)
3. **Uruchom** `convert-to-word.ps1` - nadpisze istniejący plik Word

**Uwaga:** Jeśli plik Word jest otwarty, skrypt poinformuje Cię o tym. Zamknij plik i uruchom ponownie.

## Rozwiązywanie problemów

### Pandoc nie jest zainstalowany
```powershell
winget install --id JohnMacFarlane.Pandoc
```

### Błąd przy modyfikacji obrazów
- Zamknij plik Word, jeśli jest otwarty
- Uruchom skrypt ponownie

### Obrazy nie są widoczne w Word
- Sprawdź, czy pliki są w `docs/images/`
- Sprawdź ścieżki w Markdown (relatywne: `images/nazwa.png`)

## Ustawienia skryptu

W pliku `convert-to-word.ps1` można zmienić:

- **Skala obrazów:** Zmień `0.5` na inną wartość (np. `0.3` dla 30%, `0.7` dla 70%)
- **Głębokość spisu treści:** Zmień `--toc-depth=3` na inną wartość

## Najczęstsze komendy

```powershell
# Przejdź do folderu docs
cd docs

# Wygeneruj Word
.\convert-to-word.ps1

# Sprawdź wersję Pandoc
pandoc --version

# Konwersja ręczna (bez modyfikacji obrazów)
pandoc INSTRUKCJA_OBSLUGI.md -o INSTRUKCJA_OBSLUGI.docx --toc
```

## Wskazówki

- **Nazwy plików obrazów:** Używaj opisowych nazw z podkreślnikami (np. `login_page_1.png`)
- **Organizacja:** Grupuj obrazy tematycznie w nazwach (np. `settings_*`, `login_*`)
- **Wersjonowanie:** Jeśli potrzebujesz zachować stare wersje, skopiuj plik `.docx` przed nadpisaniem
- **Backup:** Regularnie commituj zmiany w `INSTRUKCJA_OBSLUGI.md` do Git

