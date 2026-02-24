# AGENTS.md

## Cursor Cloud specific instructions

### Overview

PIESP Patrol is a Flutter/Dart mobile app for Polish law-enforcement patrol officers. It is a **client-only** application — no backend code lives in this repo. All API calls go to an external backend at `https://api.trentum.pl`.

### Flutter SDK

- Requires Dart SDK `>=3.9.0 <4.0.0` (see `pubspec.yaml`). Flutter 3.41+ (stable) ships Dart 3.11 which satisfies this.
- Flutter is installed at `/opt/flutter/bin` and added to PATH via `~/.bashrc`.

### Common commands

| Task | Command |
|------|---------|
| Install deps | `flutter pub get` |
| Lint / analyze | `flutter analyze` |
| Run tests | `flutter test` |
| Run web (dev) | `flutter run -d chrome --web-port=8080 --web-hostname=0.0.0.0` |
| Build web | `flutter build web` |
| Build Linux | `flutter build linux` |

### Gotchas

- The existing `test/widget_test.dart` is a leftover Flutter counter template test and **always fails**. It does not test the actual app.
- Linux desktop builds require `libgtk-3-dev`, `ninja-build`, `libstdc++-14-dev` (for clang 18 C++ header resolution), and a symlink `libstdc++.so` in `/usr/lib/x86_64-linux-gnu/`.
- The app works **offline** (no Google Fonts, no external runtime requests except to the configured API backend).
- The app connects to `https://api.trentum.pl` by default. The API URL is configurable via the in-app Settings page.
- Per workspace rules: avoid `Color.withOpacity()` — use `Color.withValues(alpha: ...)` instead.
