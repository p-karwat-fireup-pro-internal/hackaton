# Product

## Register

product

## Users

**Service technicians** working as employees (or long-term contractors) of a building-maintenance service company. Electricians, plumbers, locksmiths, HVAC techs, general handymen ("złota rączka") who service residential and commercial buildings under contract with property administrators.

**Their context when using the app:**
- In the field, on a phone, between jobs or on-site mid-job.
- Hands are often occupied: holding tools, gloves on, dirty.
- Lighting is uncontrolled: bright sun outdoors, dark basements and electrical rooms, fluorescent stairwells.
- Connectivity is unreliable: weak signal in basements, elevators, behind concrete walls.
- Operating one-handed is the default, not the exception.
- They are not power users of mobile apps. Friction translates directly to lost wage minutes and frustration.

**The job they are trying to get done:** Receive the next assigned ticket, navigate to the address, do the physical work, document what was done with a photo and a short note, mark complete, move to the next one. Full stop.

## Product Purpose

A mobile-only operational tool that walks a service technician through their assigned workday — one job at a time, with the lowest possible cognitive and physical friction.

Tickets are dispatched by the service company's coordination system (out of scope for this app); the technician does not browse, bid on, or compete for them. The app is a closed workflow:

1. See what is assigned to me today, in order.
2. Start the next job.
3. Capture proof of work (photo + short description) at meaningful steps.
4. Mark complete.
5. Repeat.

**Success looks like:** A technician finishes a 6–10 ticket day without ever opening any other app, without losing a single photo to bad signal, and without having to think about the tool itself — only about the work.

**This is explicitly NOT:** a marketplace, a gig-economy app, a ratings/tipping platform, or a sales/upsell surface. The technician is not a customer being marketed to; they are a professional being equipped.

## Brand Personality

**Three words:** tool-grade, frictionless, field-honest.

**Voice and tone:**
- Direct and operational. "Start job", "Mark complete", "Photo required" — not "Ready to crush your next task?".
- No gamification. No streaks, no points, no ratings, no encouragement copy.
- No corporate dispatcher tone. The app does not lecture, scold, or report performance back at the technician ("punctuality dropped 12%"). It is on the technician's side.
- Respectful of the user's expertise. The technician knows their trade better than the app — instructions describe the workflow, never the craft.
- Plain language, short sentences. The reading level assumes someone reading on a 5-inch screen with sun glare and gloves on.

**Emotional goal:** the app should feel like a well-balanced hand tool — invisible when it works, satisfying when it clicks, never in the way.

## Anti-references

This product must not look like or behave like any of the following:

- **Corporate ERP / SAP / Oracle Field Service.** Dense tables, dozens of tabs, 50-field forms, terminology from 1995, dispatcher-first hierarchy. Every UX decision must serve the technician on the phone, not the office workflow that produced the ticket.
- **Consumer delivery apps (Uber / Glovo / Wolt).** Big food photos, aggressive CTAs, gamification, ratings, tip prompts, animated promotions. This is a tool for paid work, not entertainment or impulse engagement. Even though the user described the concept as "Uber for handyman", the resemblance ends at "mobile work assignments" — visual and interaction language must not borrow from rideshare/delivery.
- **Generic SaaS dashboards.** Metric cards, KPI charts, violet/indigo gradients, Inter on white, the "modern minimal" template that makes every B2B startup look identical. There are no metrics to glance at on this surface — only the next job.
- **Legacy CMMS / helpdesk software.** Screen after screen of form fields, 30-point checklists, signature pads, PDF generators, paper-process-translated-to-mobile. The app captures only what genuinely matters as proof of work; everything else is dispatcher-side and out of scope.
- **The literal "Uber for X" template.** Big map taking 60% of the screen, ETA banners, star ratings, driver-style status pills. We are not chasing that visual vocabulary.

## Design Principles

1. **Workflow over decoration.** The app has one job: walk a technician through assigned tickets from arrival to completion. Anything on screen that does not serve the next concrete action gets cut. No metric cards, no engagement copy, no decorative illustrations.

2. **Field-grade by default.** Touch targets, contrast, type weight, and synchronization behavior assume the worst-case scene: gloves on, sun overhead, basement signal, one hand free. This is not "accessibility on top" — it is the baseline ergonomic spec. A design that only works in a quiet office under good lighting has failed.

3. **The technician is the protagonist.** Every UX choice — what's shown, what's hidden, how things are named, what's celebrated, what's silenced — sides with the worker, not the dispatching organization. The app reports facts the technician needs; it does not surface KPIs, scoring, or surveillance back at them.

4. **State is always visible, never inferred.** Sync status, photo upload queue, current step in the job, where I am in the day. The technician should never wonder "did that send?", "what now?", or "where am I in this ticket?". Make the state of the world legible at a glance, especially when offline.

5. **One right way, not ten options.** Defaults are picked deliberately and not configurable. If a workflow needs more than 90 seconds to learn from cold, the design has failed. Settings exist only for things that genuinely vary by person (font size, language, dark mode), never as escape hatches for bad defaults.

## Accessibility & Inclusion

**Target standard:** WCAG 2.2 AA across the app, with WCAG AAA contrast (7:1 for body text, 4.5:1 for large text) on all primary content surfaces — driven by direct-sunlight legibility, not just compliance.

**Specific requirements derived from the user context:**

- **Touch targets:** minimum 56×56 pt for any actionable element (gloves spec). 64+ pt for primary CTAs. Generous spacing between adjacent targets (≥12 pt) to prevent mis-taps.
- **No precision-only gestures.** Long-press, fine swipe, pinch, and multi-touch may exist as accelerators, but never as the only path to an action. Every accelerator has a tappable equivalent.
- **Thumb zone first.** All primary actions sit in the bottom 60% of the screen, reachable one-handed. Top bar carries title and status only — never destructive or primary actions.
- **Color is never the only signal.** Status, priority, and progress always combine color + icon + text label. Designed to work for protanopia/deuteranopia and on washed-out screens in sunlight.
- **Light mode is the default surface.** Sunlight is the dominant ambient condition; light mode with high contrast wins outdoors. Dark mode is an opt-in for night/indoor work, not the assumed mode.
- **Type:** supports OS-level dynamic type / font scaling up to 200% without breaking layout. Body text never below 16 pt at default scale.
- **Motion:** respects `prefers-reduced-motion`. No essential information conveyed only through animation. Transitions ease out, never bounce.
- **Offline-first as accessibility.** Every screen explicitly shows whether data is local or synced. Photos and notes captured offline queue visibly and survive app restart.
- **Haptics + visual confirmation** for every state change. Audio cues are never required (loud worksites, headphones in use).
- **Language:** Polish primary, with copy short and direct enough to translate cleanly to other CEE languages later. Avoid idioms.
