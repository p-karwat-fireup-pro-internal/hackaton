# Hackaton — Field Notebook

Prototyp aplikacji mobilnej dla techników utrzymania budynków. Repozytorium zawiera trzy części:

- `app/` — prototyp w Expo (TypeScript + React Native + NativeWind).
- `ios/` — natywny port w SwiftUI (projekt generowany przez XcodeGen).
- `backend/` — REST API w Bun + Hono + SQLite. Wdrożone na Coolify na RPi pod adresem https://backend.mirek-rpi.org.

`PRODUCT.md` to specyfikacja strategiczna, `DESIGN.md` opisuje system wizualny, a `CLAUDE.md` jest plikiem wprowadzającym dla agentów Claude Code.

## Uruchomienie aplikacji iOS lokalnie na macOS

Wymagany Mac z zainstalowanym Xcode (iOS Simulator jest jego częścią; same Command Line Tools nie wystarczą).

1. Zainstaluj **Xcode** z Mac App Store (~15 GB).
2. Zainstaluj **XcodeGen** — katalog `ios/` jest generowany z `ios/project.yml`:
   ```bash
   brew install xcodegen
   ```
3. Wygeneruj i otwórz projekt Xcode:
   ```bash
   cd ios
   xcodegen generate
   open FieldNotebook.xcodeproj
   ```
4. W Xcode wybierz dowolny iPhone simulator z paska schematów (np. „iPhone 16"), a następnie **⌘R**. Simulator wystartuje i zainstaluje aplikację.

Domyślna konfiguracja `Release` celuje w produkcyjny backend (`https://backend.mirek-rpi.org`). Zaloguj się jednym z kont z bazy testowej (patrz `backend/README.md` — np. `marek@firma.pl` / `test1234`).

### Łączenie z lokalnym backendem zamiast produkcji

1. W Xcode: **Product → Scheme → Edit Scheme → Run → Build Configuration → `Debug-Local`**. To ustawia `DEBUG_LOCAL` i kieruje `Config.swift` na `http://localhost:3000`.
2. W drugim terminalu:
   ```bash
   cd backend
   bun install        # tylko za pierwszym razem
   bun run migrate    # tworzy ./data/app.db
   bun run seed       # wstawia cztery konta testowe
   bun run dev
   ```
3. Ponownie ⌘R w Xcode — simulator komunikuje się teraz z laptopem zamiast z RPi.

### Artefakt CI

`.github/workflows/ios.yml` buduje `.app` dla iOS Simulatora i publikuje go jako artefakt GitHub Actions o nazwie `FieldNotebook-simulator` (retencja 14 dni). Instrukcja pobrania i instalacji znajduje się w `ios/README.md` → sekcja **CI**.
