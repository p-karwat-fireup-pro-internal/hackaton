# BABOK + automatyzacja: od pierwszego spotkania do wyceny

Pokażę to jako pipeline — dla każdego etapu wskazuję **technikę BABOK** + **co konkretnie agent może zautomatyzować**. To, co BABOK robi dobrze, to dyscyplina i artefakty — a artefakty doskonale nadają się do generowania przez LLM.

## Etap 0 — Przygotowanie przed pierwszym spotkaniem

| BABOK technique | Automatyzacja |
|---|---|
| **Stakeholder Analysis** (onion diagram, RACI) | Agent z dostępem do LinkedIn/strony klienta buduje wstępną mapę interesariuszy |
| **Document Analysis** | Agent czyta materiały od klienta (RFP, stronę, raport roczny) i wyciąga: domena, język branżowy, pain points |
| **Brainstorming** (przygotowanie pytań) | Agent generuje dopasowany skrypt wywiadu na bazie domeny + Twojego szablonu |

**Praktyka kluczowa:** zacznij **glosariusz** (BABOK §10.22) już teraz — z analizy strony klienta. Każde nieoczywiste słowo (np. "polisa", "ryzyko", "proces wniosku") trafia do glosariusza z definicją. To podstawa wspólnego języka i potem zaoszczędzi godziny nieporozumień.

## Etap 1 — Pierwsze spotkanie zapoznawcze (discovery call)

| BABOK technique | Automatyzacja |
|---|---|
| **Interviews** (structured) | Live transcript + agent podpowiada follow-up pytania w czasie rzeczywistym albo po spotkaniu |
| **Business Model Canvas** | Po spotkaniu agent generuje wstępny BMC klienta — szybko widać gdzie są luki w wiedzy |
| **SWOT / PESTLE** | Agent generuje pierwszą wersję na bazie transkryptu i researchu |

**Cel etapu wg BABOK:** zrozumieć **business need** (§6.1), nie wymagania funkcjonalne. Najczęstszy błąd: skok do "co ma być w aplikacji" zanim wiesz "po co".

## Etap 2 — Strategy Analysis (definicja problemu i celu)

To jest **najważniejszy etap, którego najczęściej brakuje**. BABOK §6 (Strategy Analysis) mówi: zdefiniuj current state, future state, gap, risk — **zanim** zaczniesz projektować rozwiązanie.

| BABOK technique | Artefakt do wygenerowania przez agenta |
|---|---|
| **Business Case** (§10.7) | Dokument: problem, opcje, koszty, korzyści, rekomendacja |
| **Scope Modeling** (§10.41) | Diagram kontekstu: co jest w zakresie, co poza |
| **Decision Analysis** (§10.16) | Macierz opcji rozwiązania |
| **Risk Analysis** (§10.38) | Risk register z prawdopodobieństwem × wpływem |

**Kluczowa praktyka:** **assumptions log**. Każde założenie agent zapisuje jawnie (np. "klient ma już SSO", "integracja z SAP możliwa przez REST"). To później wpływa na wycenę i kontrakt.

## Etap 3 — Warsztat wymagań (elicitation workshop)

| BABOK technique | Automatyzacja |
|---|---|
| **Requirements Workshop** (§10.36) | Agent moderator: agenda, parking lot, zapis decyzji |
| **Process Modeling — BPMN** (§10.35) | Agent generuje BPMN z opisu procesu (np. tekst → diagram via Mermaid/PlantUML) |
| **Use Cases / Scenarios** (§10.45, §10.47) | Z transkryptu → use case'y w standardowym formacie |
| **User Stories** (§10.49) | Generowanie stories w formacie "As a … I want … so that …" + INVEST validation |
| **Data Modeling** (§10.13) | Wstępny ERD z opisu encji biznesowych |

**Praktyka:** **rule of thumb od BABOK** — każde wymaganie ma mieć źródło (kto powiedział, na jakim spotkaniu). To **traceability** (§5) i daje się trywialnie zautomatyzować — agent tagguje każdą wyciągniętą rzecz źródłem.

## Etap 4 — Klasyfikacja i priorytetyzacja wymagań

BABOK rozróżnia 4 typy wymagań (§1.3) — w wycenie traktujesz je inaczej:

1. **Business requirements** — cele, KPI
2. **Stakeholder requirements** — co konkretni użytkownicy potrzebują
3. **Solution requirements**
   - **Functional** (FR) — co system robi
   - **Non-functional** (NFR) — jak działa: performance, security, compliance
4. **Transition requirements** — migracja danych, szkolenia, change management

| Technique | Automatyzacja |
|---|---|
| **MoSCoW** (§10.33 Prioritization) | Agent prowadzi sesję priorytetyzacji z klientem, generuje matrix |
| **Kano Model** | Klasyfikacja: must-have / performance / delighter |
| **Planguage** (NFR specification) | Agent przekuwa "ma być szybkie" → "TTI < 2s na 4G dla P95" |

**Najczęściej zapominane:** **transition requirements**. Migracja danych, szkolenie użytkowników, równoległe działanie systemów — to potrafi być 20–30% kosztu projektu, a nie ma tego w żadnej user story.

## Etap 5 — Solution Definition (high-level)

| BABOK technique | Automatyzacja |
|---|---|
| **Functional Decomposition** (§10.20) | Agent rozbija system na moduły/epiki |
| **Roles and Permissions Matrix** (§10.39) | Macierz ról × funkcji |
| **Vendor Assessment** (§10.46) | Agent rekomenduje stack/tools z uzasadnieniem |
| **Acceptance & Evaluation Criteria** (§10.1) | Per epik: jak zmierzymy że gotowe |

## Etap 6 — Estymacja i wycena

To etap, który **wszyscy robią najgorzej**, a BABOK ma dla niego osobną technikę (§10.18).

| Technique | Jak agent pomaga |
|---|---|
| **Estimation** (§10.18) — trzy metody | |
| ↳ **Top-down** (analogia, T-shirt) | Agent porównuje z poprzednimi projektami z bazy referencyjnej |
| ↳ **Bottom-up** (rozkład na story → punkty) | Agent generuje story i sugeruje rozmiar |
| ↳ **PERT** (optimistic + 4×most likely + pessimistic / 6) | Trzy estymaty per story, agent liczy ważoną i odchylenie |

**Kluczowe praktyki, które powinieneś zaszyć w agencie wyceny:**

1. **Reference Class Forecasting** — nie estymuj from scratch, tylko z bazy poprzednich projektów ("podobne projekty zajęły 4–7 mc, mediana 5,5"). Agent z dostępem do historii Twojej firmy = złoto.
2. **Risk-weighted estimate** — bazowa estymata × (1 + waga_ryzyka_z_risk_register). Agent linkuje wycenę do risk register z etapu 2.
3. **Assumptions-based pricing** — wycena ma listę założeń; jak któreś upadnie, klient wie że cena się zmienia. (Chroni przed "a myślałem, że to było wliczone".)
4. **Confidence intervals** — nie podawaj jednej liczby, podawaj zakres. PERT to daje matematycznie.
5. **Dekompozycja kosztu** — discovery / dev / QA / DevOps / PM / kontingencja — żeby klient widział co kupuje.

## Etap 7 — Dokument oferty / propozycji

Agent generuje dokument złożony z:
- Streszczenia menedżerskiego (z business case'u)
- Zrozumienia problemu (z etapu 1–2)
- Zakresu (scope diagram + lista epików MoSCoW)
- Architektury wysokopoziomowej
- Risk register (skrót)
- Assumptions log (jawnie!)
- Wyceny z zakresem (PERT)
- Harmonogramu kamieni milowych
- Następnych kroków

---

## Najważniejsze zasady "meta", które bym zaszył w agentach

1. **Traceability everywhere** — każdy artefakt zna swoje źródło. To jeden z filarów BABOK i daje się trywialnie zaimplementować jako pole `source_id` przy każdym requirement / story / risk.
2. **Glosariusz jako single source of truth** — agent nigdy nie używa terminu spoza glosariusza bez flagowania.
3. **Iteracyjne uszczegółowienie** — nie próbuj nail-ować wszystkiego w jednym spotkaniu. BABOK zakłada **progressive elaboration**: business need → stakeholder needs → solution requirements → design.
4. **Definition of Ready przed wyceną** — story do wyceny musi mieć: opis, kryteria akceptacji, NFR, zależności, ryzyka. Agent waliduje DoR i blokuje wycenę niedoprecyzowanych historyjek.
5. **Human-in-the-loop na granicach faz** — agent generuje, BA zatwierdza przed przejściem dalej. BABOK §3 (Requirements Life Cycle) wprost mówi o approve/baseline.
6. **Versioning artefaktów** — każdy artefakt ma wersję; gdy klient coś zmienia w sprintcie 3, widzisz co zatwierdził w sprintcie 1 (BABOK §5.3 Maintain Requirements).
