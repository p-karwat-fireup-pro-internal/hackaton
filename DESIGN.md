<!-- SEED: re-run /impeccable document once there's code to capture the actual tokens and components. -->

---
name: Field Service Technician App
description: A mobile work-day console for service technicians dispatched by a building-maintenance company.
---

# Design System: Field Service Technician App

## 1. Overview

**Creative North Star: "The Steel Field Notebook"**

Imagine a precision-stitched leather field notebook — the kind a senior site engineer carries from one job to the next. Cool tinted-grey paper, a single ink color, a calm typographic spine, and not one decorative flourish. The notebook is unmistakably *for working* — never for reading on the couch, never for impressing investors, never for selling something to its owner. The app is the digital incarnation of that object: a personal, tactile, daily log of jobs that turns the technician's day from a noisy queue of dispatcher messages into one quiet sequence of "next job → do it → done".

The aesthetic carries Linear's typographic precision, Things 3's calm rhythm and breathing room, and Stripe Dashboard's confidence with neutral surfaces and a single voice of color. None of those references are visible in their literal form, but the underlying craft posture is the same: design for an expert, not a novice. Show the next concrete action; hide everything that does not earn its place. Use color as signal, not as marketing. Let typography carry the hierarchy and let whitespace do the seating arrangement.

This system explicitly rejects the corporate-ERP visual vocabulary (dense tables, dispatcher-first hierarchy, SAP Fiori / Oracle Field Service / Salesforce Lightning). It also rejects consumer-delivery-app energy (Uber Driver / Glovo / Wolt — bright CTAs, gamification, ratings, tip prompts), generic SaaS-dashboard blandness (KPI cards, violet/indigo gradients, the "modern minimal" template), and the legacy CMMS pattern of paper-process-translated-to-mobile (30-point checklists, signature pads, PDF generators). The app is none of those things — it is a quiet, durable tool, on the technician's side.

**Key Characteristics:**
- Restrained color strategy: tinted-grey neutrals carry the surface; one signal-blue accent appears on ≤5% of any screen, reserved for primary action and critical state.
- Field-grade contrast and density: WCAG AAA on body text, generous whitespace, type weight that survives direct sunlight.
- Calm, not exciting: the app should feel inevitable, not novel. Surprise is a failure mode.
- Tool-grade typography: a single humanist sans across the whole product, hierarchy through size and weight contrast.
- Motion is restrained: only state-change feedback, never decoration. Animation never blocks the next action.
- One right way: defaults are committed and not configurable. No theme picker, no density modes, no "advanced settings" page.

## 2. Colors

The palette is a tinted-grey field with a single signal-blue accent. The greys are not pure neutrals — they are subtly cool-tinted toward the same hue as the accent, so the whole interface reads as one material under the same light. Color is used as signal: where the eye should go next, what state something is in. It is never used as decoration.

**Strategy:** Restrained. Tinted neutrals carry ≥95% of every screen; the signal-blue accent never exceeds 5%. This is non-negotiable.

### Primary
- **Signal Steel Blue** `[to be resolved during implementation]`: the single brand accent. Used for the primary CTA on the bottom bar, the active state of the current ticket, and *only* for unambiguously primary action. Anchor target: `oklch(~50% 0.18 240)` — saturated enough to read as intent, not so vivid it becomes decoration. Final hex/OKLCH lands when the first prototype renders on a phone in actual sunlight, not in design tools.

### Neutral (the "paper" of the notebook)
- **Cool Cream Surface** `[to be resolved]`: the dominant page background. A barely-there tint toward the accent hue (chroma ~0.005). Anchor: `oklch(~97% 0.005 240)`. Higher than pure white, never `#fff`.
- **Cool Mist Surface** `[to be resolved]`: secondary surface for grouped content (cards, sheets, the current-job container). Anchor: `oklch(~94% 0.006 240)`.
- **Steel Mid Border** `[to be resolved]`: dividers, hairlines, input borders. Anchor: `oklch(~85% 0.008 240)`.
- **Graphite Body** `[to be resolved]`: body text and high-contrast labels. Anchor: `oklch(~25% 0.015 240)`. Never pure black; reads softer in sunlight without losing contrast.
- **Charcoal Title** `[to be resolved]`: titles, screen headers, the technician's name. Anchor: `oklch(~18% 0.02 240)`.

### Status palette (functional, narrowly scoped)
A small status family used only for ticket-state badges. Each state combines color + icon + label — color alone is never the signal.

- **Status: Pending / Next** — neutral graphite (no chroma).
- **Status: In Progress** — the signal-blue accent at full saturation.
- **Status: Done** — a muted forest green `[to be resolved]`, anchor `oklch(~50% 0.10 145)`.
- **Status: Blocked / Needs attention** — a deep amber `[to be resolved]`, anchor `oklch(~62% 0.16 70)`. Reserved for genuine action-required states; never for soft "warnings" the technician can ignore.

### Named Rules

**The 5% Rule.** The signal-blue accent never exceeds 5% of any rendered screen. If you are tempted to color a third element blue, color none of them.

**The No-Dashboard-Color Rule.** No purple, no indigo gradients, no rainbow-tagged metrics, no fluorescent yellow highlights. The corporate-ERP and SaaS-dashboard color vocabularies are forbidden by name.

**The Same-Light Rule.** Every neutral has a trace of the accent's hue (chroma 0.005–0.02). Pure neutrals are not used. The whole interface must read as one material under one light source.

## 3. Typography

**Display & Body Font:** A single humanist sans-serif across the whole product. `[Specific font pairing to be chosen at implementation]` — candidates include Inter, Public Sans, and Source Sans 3, evaluated for legibility at 16 pt on a 5-inch phone in direct sunlight. The chosen face must offer at least four weights (400 / 500 / 600 / 700) and full Polish diacritics with no kerning issues on common pairs (ą, ę, ć, ł, ń, ś, ź, ż).

**Mono accent (optional, recommended):** A single monospaced face `[to be resolved]` reserved for technical data — ticket IDs, dispatch timestamps, addresses with unit numbers. Never used for body copy, never for headings. Its purpose is to typographically signal "this is data, not narrative".

**Character:** Quiet, confident, expert-grade. The type does not announce itself; it simply works. No display-only weights, no condensed variants, no italics for decoration.

### Hierarchy

- **Display** (700, ~32 pt, line-height 1.1): ticket title on a focused job screen. One per screen, never decorative.
- **Headline** (600, ~24 pt, line-height 1.2): screen titles, day-section headers ("Dziś — 6 zleceń"). Full-width, never ranged-right.
- **Title** (600, ~18 pt, line-height 1.3): list item primary line (job title, address). The first line of a ticket card.
- **Body** (400, 16 pt floor, line-height 1.5): all running text and secondary list lines. 16 pt is the minimum at default scale; never below. Max line length is irrelevant on mobile (one column), but body text never exceeds ~36 characters per line on a 5-inch phone.
- **Label** (500, 13 pt, letter-spacing +0.04em, sentence case): metadata under list items, status badges, inline timestamps. Sentence case only — uppercase labels are forbidden (they read as corporate badge clutter).

### Named Rules

**The Sentence-Case Rule.** All labels and chip text are sentence case. UPPERCASE labels are forbidden — they belong to enterprise software and the app must never look like that.

**The 16 pt Floor Rule.** Body text is never smaller than 16 pt at default OS scale. Anything smaller fails the sun-and-gloves test.

**The Single-Voice Rule.** One sans across the whole app. No serif accents, no display-only families, no per-section font swaps. If a section feels like it needs a different font, the section's hierarchy is wrong.

## 4. Elevation

The system is **flat by default**. Surfaces are differentiated by tonal shifts (Cool Cream → Cool Mist → faint divider lines), not by drop shadows. Depth is conveyed structurally — through grouping, whitespace, and tone — not optically. This matches the restrained motion energy: a quiet surface that doesn't "pop" or "lift" decoratively.

Shadows are reserved for two contexts only:
- **Active sheet over content** (a sheet sliding up from the bottom for capture-photo, mark-complete confirmation, etc.) — a soft ambient shadow indicating "the sheet is detached from the page beneath".
- **Floating action / sticky bottom bar** when scrolled content passes underneath — a hairline shadow telling the technician "you have scrolled past the start; this bar is sitting on top".

In every other situation — list items, cards, inputs, navigation, the current-job container — there are no shadows. The interface is one calm field.

### Shadow Vocabulary (sparse by design)

- **Sheet shadow** `box-shadow: [to be resolved]`: ~0 -8px 24px oklch(25% 0.015 240 / 0.08). Used only on bottom sheets above content.
- **Sticky bar separator** `box-shadow: [to be resolved]`: ~0 -1px 0 oklch(85% 0.008 240). Hairline, not glow.

### Named Rules

**The Flat-By-Default Rule.** Surfaces are flat at rest. Drop shadows appear only on detached layers (sheets, sticky bars over scrolled content). No card-stack shadows, no decorative elevation, no Material-style "z-axis storytelling".

**The No-Glassmorphism Rule.** No backdrop-filter blurs, no frosted overlays, no translucent cards. The app must be readable on a screen with a fingerprint, water droplet, or sun glare on it.

## 6. Do's and Don'ts

These are visual-system enforcements of PRODUCT.md's strategic line. Every anti-reference in PRODUCT.md is repeated here by name.

### Do:

- **Do** keep the signal-blue accent on ≤5% of any screen — and use it only for unambiguously primary action and critical state.
- **Do** anchor every neutral to the accent hue with chroma 0.005–0.02. The whole app must read as one material.
- **Do** use color + icon + text label for every status. Color alone is never the signal — it must work for protanopia/deuteranopia and on washed-out screens in sunlight.
- **Do** hold body text at 16 pt floor and primary CTA height at ≥64 pt. Touch targets ≥56 pt with ≥12 pt spacing between adjacent targets — gloves spec is non-negotiable.
- **Do** keep all primary actions in the bottom 60% of the screen. Top bar carries title and sync status only.
- **Do** make synchronization state visible on every screen (synced, queued, offline). The technician must never wonder "did that send?".
- **Do** use sentence case for every label, chip, and badge. Sentence case only.
- **Do** commit to one humanist sans across the whole product. One typeface, four weights.
- **Do** restrain motion to state-change feedback. Respect `prefers-reduced-motion` everywhere.
- **Do** light mode as the default surface. Dark mode is an opt-in, not the assumed mode.

### Don't:

- **Don't** look like a corporate ERP — no SAP Fiori, no Oracle Field Service, no Salesforce Lightning vocabulary. No dense tables, no dozens of tabs, no 50-field forms, no dispatcher-first hierarchy. (This is the app's named primary visual antagonist.)
- **Don't** look like a consumer delivery app — no Uber Driver / Glovo / Wolt visual language. No big food-style photos, no aggressive CTAs, no ratings, no tip prompts, no gamification, no streaks, no points.
- **Don't** look like a generic SaaS dashboard — no metric cards, no KPI charts, no violet/indigo gradients, no Inter-on-white "modern minimal" template.
- **Don't** look like a legacy CMMS or helpdesk — no 30-point checklists, no signature pads, no in-app PDF generators, no paper-process-translated-to-mobile screens.
- **Don't** chase the literal "Uber for X" template — no big map taking 60% of the screen, no ETA banners, no driver-style status pills, no star ratings.
- **Don't** use side-stripe colored borders (`border-left` / `border-right` >1px as a colored accent). Forbidden across the whole system.
- **Don't** use gradient text. `background-clip: text` with a gradient is forbidden. Single solid color, emphasis through weight.
- **Don't** use glassmorphism, backdrop blur, or frosted overlays. The screen will be smudged and sunlit; readability beats vibe.
- **Don't** use pure `#000` or `#fff`. Every neutral is hue-tinted toward the accent.
- **Don't** use uppercase labels or chip text. Forbidden — it is the calling card of the very enterprise software we are not.
- **Don't** add a settings page full of theme/density/font/layout toggles. One right way, committed defaults. Settings exist only for font scale, language, and dark-mode opt-in.
- **Don't** use decorative animation, entrance choreography, scroll-driven motion, or "celebration moments" on task completion. Motion is feedback, never decoration.
- **Don't** add metric cards, day-summary KPIs, performance charts, or any surveillance-style content surfaced back at the technician. The technician is the protagonist, not the subject.
