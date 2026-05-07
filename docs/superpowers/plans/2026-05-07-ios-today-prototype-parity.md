# iOS Today Screen — wyrównanie do prototypu — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wyrównać natywny ekran `TodayView` w `ios/` do prototypu Expo z `app/`: stały tytuł „Mój dzień" + data zamiast nazwy użytkownika, kategoria + ikona + dzielnica + czas dojazdu w karcie spotlight, ikona/etykieta kategorii i etykieta statusu w wierszach pozostałych zleceń, nagłówek sekcji „Reszta dnia N", trwale widoczny dolny przycisk „Rozpocznij" / „Otwórz zlecenie".

**Architecture:** Pięć ogniskowych zmian w warstwie prezentacji `ios/FieldNotebook/Features/Today/` i `Shared/TopBar.swift`. Mapowanie `JobDTO.category` (String) → `IconName` + polska etykieta przez nowy plik `JobCategoryMapping.swift` (analog `categoryIcon` + `categoryLabel` z `app/src/components/Icon.tsx` + `app/src/data/mockJobs.ts`). Spotlight i bottom CTA dobierają etykietę zależnie od stanu (`pending` / `in_progress` / brak zakończonych) — ta sama logika co `pickSpotlight` / `spotlightLabel` / `ctaForSpotlight` w `app/src/screens/TodayScreen.tsx`. Bottom CTA montujemy przez `.safeAreaInset(edge: .bottom)` na `ScrollView` (zgodnie z istniejącym wzorcem z `JobDetailView`), żeby nie zasłaniał ostatniego wiersza listy.

**Tech Stack:** SwiftUI 5 (iOS 17+), `@Observable` AppStore, `IconView` z `Assets.xcassets` (template rendering). Brak nowych zależności.

**Walidacja:** Brak Xcode w kontenerze deweloperskim — kompilacja i podgląd uruchomione w CI (`.github/workflows/ios.yml`, runner macos-14). Każde zadanie kończ commitem; cały plan wypchnij i zweryfikuj wzrokowo build z Appetize w podsumowaniu uruchomienia workflow.

---

## File Structure

- **Tworzy:** `ios/FieldNotebook/Features/Today/JobCategoryMapping.swift`
  Wolne funkcje `categoryIcon(for:)` i `categoryLabel(for:)` mapujące surowy `JobDTO.category` (String) na `IconName` i polską etykietę. Jeden punkt prawdy dla obu wywołań w SpotlightCard i JobRow.

- **Modyfikuje:** `ios/FieldNotebook/Shared/TopBar.swift`
  Zmiana parametru `title: String` na `date: Date`. Renderuje stały tytuł „Mój dzień" w `Font.display`-podobnym kroju + sformatowaną datę („Wt, 7 maj") w `labelSmall` poniżej. Sync indicator zostaje po prawej, wyrównany do dolnej krawędzi nagłówka.

- **Modyfikuje:** `ios/FieldNotebook/Features/Today/TodayView.swift`
  Przekazuje `Date()` do `TopBar`. Dodaje sekcję `SectionHeader("Reszta dnia", count: …)` przed pętlą z `JobRow`. Wybór spotlight (`pickSpotlight`) preferuje `in_progress` przed `pending`. Dolny CTA „Rozpocznij" / „Otwórz zlecenie" montowany przez `.safeAreaInset(edge: .bottom)` — wykonuje `store.startJob` dla `pending` i nawiguje do `Route.jobDetail` w obu wypadkach.

- **Modyfikuje:** `ios/FieldNotebook/Features/Today/SpotlightCard.swift`
  Dodaje wiersz nagłówkowy „{spotlightLabel} · {kategoria}" z kółkiem ikony kategorii (24×24, tło `mistDeep`). Pod adresem dodaje dzielnicę (jeśli jest). W stopce dodaje ikonę i etykietę „~ {minuty} min jazdy" obok okna czasowego. Nowy parametr `spotlightLabel: String` (string, nie enum — etykietę składa wywołujący).

- **Modyfikuje:** `ios/FieldNotebook/Features/Today/JobRow.swift`
  Dodaje wiersz kategorii nad adresem (ikona 12 pt + etykieta + ticketId po prawej w `mono`) i pasek z etykietą statusu („Pilne" / „Zaplanowane" / „W trakcie") + kropką + oknem czasowym. Skraca `description` do jednej linii (zamiast dwóch) — odpowiada prototypowi.

---

## Task 1: Mapowanie kategorii (JobCategoryMapping.swift)

**Files:**
- Create: `ios/FieldNotebook/Features/Today/JobCategoryMapping.swift`

- [ ] **Step 1: Utwórz nowy plik z funkcjami mapującymi**

```swift
import Foundation

/// Maps `JobDTO.category` (raw string from the backend) to the bounded
/// `IconName` set in `IconView.swift`. Mirrors `categoryIcon` from
/// `app/src/components/Icon.tsx`. Unknown categories fall back to `.wrench`
/// so we never crash on a backend-side typo.
func categoryIcon(for category: String) -> IconName {
    switch category {
    case "elektryka":    return .lightning
    case "hydraulika":   return .droplet
    case "klimatyzacja": return .snowflake
    case "stolarka":     return .hammer
    case "ogolne":       return .wrench
    default:             return .wrench
    }
}

/// Polish display label for a `JobDTO.category`. Mirrors `categoryLabel`
/// from `app/src/data/mockJobs.ts`. Unknown categories fall back to the
/// generic "Ogólne" so the UI never shows a raw slug.
func categoryLabel(for category: String) -> String {
    switch category {
    case "elektryka":    return "Elektryka"
    case "hydraulika":   return "Hydraulika"
    case "klimatyzacja": return "Klimatyzacja"
    case "stolarka":     return "Stolarka"
    case "ogolne":       return "Ogólne"
    default:             return "Ogólne"
    }
}
```

- [ ] **Step 2: Dodaj plik do `project.yml`, jeśli nie jest już objęty wzorcem `Features/**`**

Otwórz `ios/project.yml` i potwierdź, że `sources` dla targetu `FieldNotebook` zawiera ścieżkę obejmującą `FieldNotebook/Features/**` (lub równoważny glob). Jeśli plik nie jest objęty, dodaj go do listy. Większość konfiguracji XcodeGen używa już rekurencyjnego glob — w takim wypadku ten krok jest no-op.

- [ ] **Step 3: Commit**

```bash
git add ios/FieldNotebook/Features/Today/JobCategoryMapping.swift
git commit -m "Add JobDTO.category → IconName + label mapping for iOS"
```

---

## Task 2: TopBar pokazuje „Mój dzień" + datę

**Files:**
- Modify: `ios/FieldNotebook/Shared/TopBar.swift`
- Modify: `ios/FieldNotebook/Features/Today/TodayView.swift:13`

- [ ] **Step 1: Przepisz `TopBar` na układ tytuł + data + sync**

Nadpisz cały plik `ios/FieldNotebook/Shared/TopBar.swift` poniższym contentem:

```swift
import SwiftUI

struct TopBar: View {
    let date: Date
    let syncState: AppStore.SyncState

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Mój dzień")
                    .font(.sans(.bold, size: 28))
                    .foregroundStyle(Color.titleInk)
                    .accessibilityAddTraits(.isHeader)
                Text(Self.formatDate(date))
                    .font(.sans(.medium, size: 14))
                    .foregroundStyle(Color.muted)
            }
            Spacer()
            SyncIndicator(state: syncState)
                .padding(.bottom, 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.cream)
    }

    /// Mirrors `formatDate` in `app/src/components/TopBar.tsx`: short Polish
    /// weekday + day + short Polish month (e.g. "Wt, 7 maj"). Uses fixed
    /// arrays rather than `DateFormatter` so the abbreviations match the
    /// prototype byte-for-byte and don't depend on the device locale.
    private static let dayShort = ["Nd", "Pn", "Wt", "Śr", "Cz", "Pt", "Sb"]
    private static let monthShort = [
        "sty", "lut", "mar", "kwi", "maj", "cze",
        "lip", "sie", "wrz", "paź", "lis", "gru",
    ]

    private static func formatDate(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Sunday — matches JS `Date.getDay()`
        let components = calendar.dateComponents([.weekday, .day, .month], from: date)
        let weekdayIdx = (components.weekday ?? 1) - 1
        let monthIdx = (components.month ?? 1) - 1
        let day = components.day ?? 1
        return "\(dayShort[weekdayIdx]), \(day) \(monthShort[monthIdx])"
    }
}
```

Uwagi:
- Usuwamy ramkę o stałej wysokości `Spacing.topBarHeight` i dolną kreskę. Prototyp ich nie ma — chrom pasujący do projektu „Steel Field Notebook" (`DESIGN.md` §6: brak dekoracyjnych obramowań). Wysokość rośnie naturalnie z dwóch wierszy tekstu plus paddingu, co odpowiada prototypowi.
- `dayShort[0] = "Nd"` (niedziela) zgodne z `Date.getDay()` w JS, gdzie 0 = niedziela.

- [ ] **Step 2: Zaktualizuj wywołanie w `TodayView`**

W pliku `ios/FieldNotebook/Features/Today/TodayView.swift` zamień jedyne wywołanie:

```swift
TopBar(title: store.user?.displayName ?? "Field Notebook",
       syncState: store.syncState)
```

na:

```swift
TopBar(date: Date(), syncState: store.syncState)
```

(`Date()` celowo — to realny build z backendem, nie demo-fixture; data ma reagować na bieżący dzień.)

- [ ] **Step 3: Sprawdź, czy żadne inne miejsce nie używa `TopBar(title:syncState:)`**

Run: `rg "TopBar\(" ios/FieldNotebook`
Expected: jedyne dopasowanie to wywołanie zaktualizowane w kroku 2 (`TopBar(date:syncState:)`). Jeśli pojawi się inne — zaktualizuj je analogicznie.

- [ ] **Step 4: Commit**

```bash
git add ios/FieldNotebook/Shared/TopBar.swift ios/FieldNotebook/Features/Today/TodayView.swift
git commit -m "iOS: restore prototype top bar with 'Mój dzień' + date"
```

---

## Task 3: SpotlightCard z kategorią, dzielnicą i czasem dojazdu

**Files:**
- Modify: `ios/FieldNotebook/Features/Today/SpotlightCard.swift`

- [ ] **Step 1: Przepisz cały plik**

Nadpisz `ios/FieldNotebook/Features/Today/SpotlightCard.swift` poniższym contentem:

```swift
import SwiftUI

struct SpotlightCard: View {
    let job: JobDTO
    /// e.g. "Następne zlecenie", "Pierwsze zlecenie", "Ostatnie zlecenie",
    /// "Trwa zlecenie". Caller picks based on workday state.
    let spotlightLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            address
                .padding(.top, 16)
            if let district = job.district {
                Text(district)
                    .font(.sans(.medium, size: 14))
                    .foregroundStyle(Color.muted)
                    .padding(.top, 2)
            }
            Text(job.description)
                .font(.bodyText)
                .foregroundStyle(Color.bodyInk)
                .lineLimit(2)
                .padding(.top, 12)
            footer
                .padding(.top, 18)
        }
        .padding(Spacing.cardPad)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mist, in: RoundedRectangle(cornerRadius: Radius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.xl)
                .stroke(Color.borderSoft, lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(Color.mistDeep)
                IconView(name: categoryIcon(for: job.category), size: 13)
                    .foregroundStyle(Color.bodyInk)
            }
            .frame(width: 24, height: 24)

            Text("\(spotlightLabel) · \(categoryLabel(for: job.category))")
                .font(.sans(.semibold, size: 13))
                .foregroundStyle(Color.muted)

            Spacer()

            if job.priority == .urgent {
                PriorityTag(priority: .urgent)
            }
        }
    }

    private var address: some View {
        // Address + optional unit on the same line, unit lighter weight.
        // Matches prototype line-height: -0.5 letterSpacing, 28/34.
        let suffix = job.unit.map { " " + $0 } ?? ""
        return (
            Text(job.address)
                .font(.sans(.bold, size: 28))
                .foregroundStyle(Color.titleInk)
            + Text(suffix)
                .font(.sans(.medium, size: 28))
                .foregroundStyle(Color.bodyInk)
        )
        .lineSpacing(2)
    }

    private var footer: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                IconView(name: .clock, size: 15).foregroundStyle(Color.bodyInk)
                Text(job.scheduledWindow)
                    .font(.mono(.medium, size: 14))
                    .foregroundStyle(Color.bodyInk)
            }
            if let travel = job.travelTimeMin {
                HStack(spacing: 6) {
                    IconView(name: .mapPin, size: 15).foregroundStyle(Color.bodyInk)
                    Text("~ \(travel) min jazdy")
                        .font(.sans(.medium, size: 14))
                        .foregroundStyle(Color.bodyInk)
                }
            }
            Spacer()
            Text(job.ticketId)
                .font(.mono(.regular, size: 12))
                .foregroundStyle(Color.muted)
        }
    }
}
```

Uwagi:
- `categoryIcon(for:)` i `categoryLabel(for:)` pochodzą z Task 1 — nieprefiksowane wolne funkcje w tym samym module.
- `spotlightLabel` to gołe `String`, nie enum, bo wywołujący `TodayView` składa go warunkowo. Trzymamy się Swift 5.9 strict — bez bare `Encodable` (nie ma znaczenia tutaj).
- Tag „Pilne" przesuwamy do prawej krawędzi wiersza nagłówka (jak w prototypie — `flex-row items-center justify-between`).
- Border dodajemy przez `overlay(stroke)` — w `Color.borderSoft`, zgodnie z `app/src/components/SpotlightCard.tsx:36`.

- [ ] **Step 2: Commit**

```bash
git add ios/FieldNotebook/Features/Today/SpotlightCard.swift
git commit -m "iOS: add category, district, travel time to spotlight card"
```

---

## Task 4: JobRow z kategorią i etykietą statusu

**Files:**
- Modify: `ios/FieldNotebook/Features/Today/JobRow.swift`

- [ ] **Step 1: Przepisz cały plik**

Nadpisz `ios/FieldNotebook/Features/Today/JobRow.swift` poniższym contentem:

```swift
import SwiftUI

struct JobRow: View {
    let job: JobDTO

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            StatusDot(status: job.status)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                categoryRow
                    .padding(.bottom, 2)

                Text(addressWithUnit)
                    .font(.sans(.semibold, size: 17))
                    .foregroundStyle(isDone ? Color.bodyInk : Color.titleInk)
                    .strikethrough(isDone, color: Color.bodyInk)
                    .lineLimit(1)

                Text(job.description)
                    .font(.sans(.regular, size: 14))
                    .foregroundStyle(Color.bodyInk)
                    .lineLimit(1)
                    .padding(.top, 2)

                statusRow
                    .padding(.top, 8)
            }

            IconView(name: .chevronRight, size: 18)
                .foregroundStyle(Color.borderHair)
                .padding(.top, 18)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .opacity(isDone ? 0.55 : 1)
        .frame(minHeight: Spacing.rowHeight, alignment: .top)
    }

    private var categoryRow: some View {
        HStack(spacing: 6) {
            IconView(name: categoryIcon(for: job.category), size: 12)
                .foregroundStyle(Color.muted)
            Text(categoryLabel(for: job.category))
                .font(.sans(.semibold, size: 12))
                .foregroundStyle(Color.muted)
            Spacer()
            Text(job.ticketId)
                .font(.mono(.regular, size: 11))
                .foregroundStyle(Color.muted)
        }
    }

    private var statusRow: some View {
        HStack(spacing: 10) {
            Text(statusText)
                .font(.sans(.semibold, size: 13))
                .foregroundStyle(statusColor)
            Circle()
                .fill(Color.borderHair)
                .frame(width: 3, height: 3)
            Text(job.scheduledWindow)
                .font(.mono(.regular, size: 13))
                .foregroundStyle(Color.muted)
        }
    }

    private var addressWithUnit: String {
        if let unit = job.unit { return "\(job.address) \(unit)" }
        return job.address
    }

    private var isUrgent: Bool {
        job.priority == .urgent && job.status != .done
    }

    private var isDone: Bool { job.status == .done }

    private var statusText: String {
        if isUrgent { return "Pilne" }
        switch job.status {
        case .pending:     return "Zaplanowane"
        case .in_progress: return "W trakcie"
        case .done:        return "Ukończone"
        }
    }

    private var statusColor: Color {
        if isUrgent { return Color.statusUrgent }
        if isDone   { return Color.statusDone }
        return Color.muted
    }
}
```

Uwagi:
- Adres + unit łączymy w jednym `Text` (string concatenation), nie używamy `Text + Text` — w prototypie unit ma inną wagę, ale tu trzymamy się prostszej linii dla zachowania `lineLimit(1)` + ewentualnego `strikethrough`. Akceptowalna utrata szczegółu — różnica wagi unit jest subtelna i nie pojawia się w screenshotach z `app/screenshots/`.
- Etykieta statusu i kolor zgodne z `app/src/components/JobRow.tsx`: pilne → `status-urgent`, ukończone → `status-done`, reszta → `muted`.

- [ ] **Step 2: Commit**

```bash
git add ios/FieldNotebook/Features/Today/JobRow.swift
git commit -m "iOS: show category icon + label and status text in JobRow"
```

---

## Task 5: TodayView — sekcja „Reszta dnia", spotlight label, dolny CTA

**Files:**
- Modify: `ios/FieldNotebook/Features/Today/TodayView.swift`

- [ ] **Step 1: Przepisz cały plik `TodayView.swift`**

Nadpisz `ios/FieldNotebook/Features/Today/TodayView.swift` poniższym contentem:

```swift
import SwiftUI

struct TodayView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let pending  = store.jobs.filter { $0.status != .done }
        let done     = store.jobs.filter { $0.status == .done }
        let spotlight = pickSpotlight(in: pending)
        let restOfDay = spotlight.map { s in pending.filter { $0.id != s.id } } ?? pending

        VStack(spacing: 0) {
            TopBar(date: Date(), syncState: store.syncState)

            ScrollView {
                VStack(spacing: 16) {
                    if store.pendingNewJobBanner {
                        NewJobBanner(onAccept: store.acceptNewJob,
                                     onDismiss: store.dismissNewJobBanner)
                    }

                    if let spotlight {
                        NavigationLink(value: Route.jobDetail(jobId: spotlight.id)) {
                            SpotlightCard(
                                job: spotlight,
                                spotlightLabel: spotlightLabelText(
                                    for: spotlight,
                                    pendingCount: pending.count,
                                    doneCount: done.count
                                )
                            )
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)
                    } else {
                        emptyState
                    }

                    if !restOfDay.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            sectionHeader(title: "Reszta dnia", count: restOfDay.count)
                                .padding(.top, 12)

                            ForEach(Array(restOfDay.enumerated()), id: \.element.id) { idx, job in
                                if idx > 0 {
                                    Rectangle()
                                        .fill(Color.borderSoft)
                                        .frame(height: 1)
                                        .padding(.leading, 20)
                                }
                                NavigationLink(value: Route.jobDetail(jobId: job.id)) {
                                    JobRow(job: job)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if !done.isEmpty {
                        DoneAccordion(doneJobs: done)
                            .padding(.top, 8)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color.cream)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let spotlight {
                    bottomCta(for: spotlight)
                }
            }
        }
    }

    // MARK: - Spotlight selection

    /// Prefer an in-progress job; otherwise the first pending one. Mirrors
    /// `pickSpotlight` in `app/src/screens/TodayScreen.tsx`.
    private func pickSpotlight(in pending: [JobDTO]) -> JobDTO? {
        if let inProgress = pending.first(where: { $0.status == .in_progress }) {
            return inProgress
        }
        return pending.first
    }

    /// Mirrors `spotlightLabel` in `app/src/screens/TodayScreen.tsx`.
    private func spotlightLabelText(
        for spotlight: JobDTO,
        pendingCount: Int,
        doneCount: Int
    ) -> String {
        if spotlight.status == .in_progress { return "Trwa zlecenie" }
        if doneCount == 0                   { return "Pierwsze zlecenie" }
        if pendingCount == 1                { return "Ostatnie zlecenie" }
        return "Następne zlecenie"
    }

    // MARK: - Bottom CTA

    @ViewBuilder
    private func bottomCta(for spotlight: JobDTO) -> some View {
        let title = spotlight.status == .in_progress ? "Otwórz zlecenie" : "Rozpocznij"
        NavigationLink(value: Route.jobDetail(jobId: spotlight.id)) {
            Text(title)
                .font(.sans(.semibold, size: 17))
                .foregroundStyle(Color.inkOnSignal)
                .frame(maxWidth: .infinity, minHeight: Spacing.ctaHeight)
                .background(Color.signal, in: RoundedRectangle(cornerRadius: Radius.lg))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            if spotlight.status == .pending {
                Task { await store.startJob(spotlight.id) }
            }
        })
        .background(Color.cream)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.borderSoft).frame(height: 1)
        }
    }

    // MARK: - Section header

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.sans(.bold, size: 15))
                .foregroundStyle(Color.titleInk)
            Text("\(count)")
                .font(.sans(.medium, size: 13))
                .foregroundStyle(Color.muted)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 8) {
            IconView(name: .check, size: 32).foregroundStyle(Color.statusDone)
            Text("Wszystko zrobione na dziś")
                .font(.titleText)
                .foregroundStyle(Color.titleInk)
            Text("Wracaj jutro o 8:00.")
                .font(.bodyText)
                .foregroundStyle(Color.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}
```

Uwagi:
- `safeAreaInset(edge: .bottom)` zachowuje wzorzec z `JobDetailView.swift:30` — system zarządza paddingiem dla wskaźnika home, więc nie potrzebujemy ręcznych obliczeń jak w `TodayScreen.tsx` (`insets.bottom`).
- `NavigationLink + simultaneousGesture` zamiast `Button` daje nam jednoczesny `startJob` (efekt uboczny) i nawigację do detail. Alternatywą byłoby `Button` wywołujący `Task` i programowy push do `path` — wymagałoby przeniesienia `path` w dół. Wzorzec `simultaneousGesture` jest minimalnie bardziej idiomatyczny w SwiftUI.
- Brak wariantu „Pokaż następne" dla `allDone` — w obecnym backendzie nie istnieje akcja „pokaż następne", a w prototypie ten guzik jest wizualną zaślepką (`onPress` nieobsługiwany). Stan `allDone` po naszej zmianie pokazuje `emptyState` bez bottom CTA — równoważne wizualnie z `BottomCTA secondary` bez gestów.
- W kontekście wytycznych z CLAUDE.md (`No local builds`) nie odpalamy lokalnie `xcodebuild`. Pierwsza realna walidacja to runner w GitHub Actions.

- [ ] **Step 2: Commit i push**

```bash
git add ios/FieldNotebook/Features/Today/TodayView.swift
git commit -m "iOS: add 'Reszta dnia' section, spotlight label, persistent bottom CTA"
git push
```

- [ ] **Step 3: Sprawdź workflow `iOS` w GitHub Actions**

Otwórz `gh run list --workflow="iOS" --limit=1` i poczekaj, aż zakończy się sukcesem. Po zielonym build skopiuj link do Appetize z podsumowania run-u i wzrokowo porównaj ekran z `app/screenshots/today.png` oraz stanem opisanym w argumentach planu (paskowy „Mój dzień" + data, kategoria w spotlight, dzielnica + czas dojazdu, kategorie w wierszach, „Reszta dnia 3", dolne „Rozpocznij").

---

## Self-review summary

- **Pasek górny — „Mój dzień" + data** → Task 2 (TopBar przyjmuje `date: Date`, wywołanie w TodayView).
- **Kategoria + ikona w karcie spotlight** → Task 1 (`categoryIcon`/`categoryLabel`) + Task 3 (`header` w SpotlightCard).
- **Dzielnica i czas dojazdu w karcie spotlight** → Task 3 (`district` pod adresem, `travelTimeMin` w `footer`).
- **Ikona kategorii i etykieta kategorii w wierszach** → Task 1 + Task 4 (`categoryRow` w JobRow).
- **Etykieta statusu w wierszach** → Task 4 (`statusRow` z `Pilne`/`Zaplanowane`/`W trakcie`/`Ukończone`).
- **Sekcja „Reszta dnia N"** → Task 5 (`sectionHeader`, separatory między wierszami).
- **Bottom CTA „Rozpocznij" / „Otwórz zlecenie"** → Task 5 (`bottomCta(for:)` przez `safeAreaInset`).
- **Spójność typów** → `categoryIcon(for:)` / `categoryLabel(for:)` z Task 1 wołane w Task 3 i 4 z tej samej sygnatury. `Route.jobDetail(jobId:)` użyty zarówno w spotlight, jak i w bottom CTA — zgodnie z istniejącym `Routes.swift`. Zachowane przez cały plan: `JobDTO.priority`, `JobStatus`, `Color.*`, `Spacing.*`, `Radius.*`, `IconName.*`.
- **Brak placeholderów** — wszystkie kroki zawierają kompletny kod do wpisania.
