# piesp_patrol

Aplikacja mobilna PIESP Patrol dla Flutter.

## Dokumentacja

- [Instrukcja obsługi](docs/INSTRUKCJA_OBSLUGI.md) - szczegółowa instrukcja obsługi aplikacji dla użytkowników końcowych

## Budowanie wersji web (offline)

Aby zbudować aplikację web **działającą w odciętym środowisku** (bez dostępu do internetu):

```bash
flutter build web --release --no-web-resources-cdn
```

Flaga `--no-web-resources-cdn` powoduje, że zasoby Flutter (np. CanvasKit) są **wbudowane w build** zamiast pobierane z CDN w czasie działania aplikacji.

**Dodatkowo:**
- Czcionki: aplikacja używa lokalnych fontów (Roboto z assets) – brak pobierania z Google Fonts.
- API backendu: adres serwera ustawiasz w Ustawieniach w aplikacji – w środowisku odciętym wskaż adres wewnętrzny (np. `https://api.local.int`).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
