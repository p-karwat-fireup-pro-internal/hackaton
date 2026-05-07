# Field Notebook — iOS

Natywny port w SwiftUI prototypu Expo z katalogu `app/`. Cel: iOS 17.

## Lokalny rozwój

```bash
cd ios
brew install xcodegen   # jednorazowo
xcodegen generate
open FieldNotebook.xcodeproj
```

Wybierz schemat **Debug-Local**, żeby kierować na `http://localhost:3000`. Domyślne schematy **Debug**/**Release** używają produkcyjnego adresu z `App/Config.swift`.

## Testy

```bash
xcodebuild test \
  -project FieldNotebook.xcodeproj \
  -scheme FieldNotebook \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## CI

`.github/workflows/ios.yml` buduje `.app` dla iOS Simulatora przy każdym pushu na `main` lub `ios` (oraz ręcznie z `workflow_dispatch`) i publikuje go jako artefakt GitHub Actions o nazwie `FieldNotebook-simulator` (retencja 14 dni). Bez zewnętrznych usług, bez sekretów.

### Pobranie i uruchomienie artefaktu na macOS

Wymagany zainstalowany Xcode (sam Simulator z Xcode wystarczy, żeby `xcrun simctl` działał).

```bash
# 1. Pobierz najnowszy artefakt (albo wskaż konkretny run przez --run <id>).
gh run download -R <owner>/<repo> -n FieldNotebook-simulator -D /tmp/fn
unzip /tmp/fn/FieldNotebook.zip -d /tmp/fn

# 2. Wybierz dowolny zainstalowany simulator i go wystartuj.
xcrun simctl list devices available | grep iPhone
xcrun simctl boot "iPhone 15"        # nazwa z listy powyżej
open -a Simulator

# 3. Zainstaluj i uruchom .app po bundle id.
xcrun simctl install booted /tmp/fn/FieldNotebook.app
xcrun simctl launch booted dev.zaniewicz.fieldnotebook
```

Domyślna konfiguracja `Release` celuje w produkcyjny backend (`https://backend.mirek-rpi.org`). Konta testowe wymienione są w `backend/README.md`.

## Lista kontrolna po instalacji artefaktu

- [ ] `xcrun simctl install booted` kończy się bez błędu, ikona aplikacji pojawia się w Simulatorze
- [ ] Login jako `marek@firma.pl` / `test1234` → lista pokazuje 8 zleceń (3 zamknięte, 5 otwartych)
- [ ] Otwórz otwarte zlecenie → Detail → Start → Capture → wybierz zdjęcie z biblioteki Simulatora → Finish
- [ ] Wyloguj → login jako `kasia@firma.pl` → widoczny pusty stan
- [ ] Wyloguj → login jako `anna@firma.pl` → SyncIndicator pokazuje offline; przejścia trafiają do kolejki oczekujących
- [ ] Wyloguj → login jako `piotr@firma.pl` → baner „New Job" widoczny u góry
- [ ] 5× błędne hasło dla `marek@firma.pl` → 423 lockout z odliczaniem
