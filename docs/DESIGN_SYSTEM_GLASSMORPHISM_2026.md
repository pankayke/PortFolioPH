# PortFolioPH Design System (Glassmorphism 2026)

This document is the single source of truth for PortFolioPH visual language across all screens.

## 1) Brand Direction

- Dark mode first, premium glass layers, soft depth, and modern trust-forward UI.
- Visual blend: professional (LinkedIn), creative (Behance), calm information hierarchy (Notion), and Filipino warmth.
- Signature motif: subtle talent-network lines, faint bokeh, and micro Philippine accents.

## 2) Color Tokens

- **Base dark:** `#0F172A`, `#0A0F1A`, `#111827`
- **Base light:** `#F8FAFC`
- **Primary:** `#0A66C2`
- **Primary bright:** `#3B82F6`
- **Secondary:** `#8B5CF6`
- **Success/progress:** `#14B8A6`
- **Philippine warm accents:** `#EF4444`, `#DC2626`

Implementation source: `lib/core/styling/design_tokens.dart`

## 3) Glass Surface Specification

- Card fill (dark): `rgba(30,41,59,0.32-0.55)`
- Card fill (light): `rgba(255,255,255,0.65-0.85)`
- Blur: `24-36`
- Border: `1.5px`, white alpha `0.12-0.22`
- Radius: `24-36`
- Shadow: layered, soft, high-depth (`0 8px 32px` class)

Implementation source: `lib/presentation/widgets/glass/glass_container.dart`

## 4) Motion & Interactions

- Primary interaction scale: `1.04`
- Focus rim: primary blue glow
- Section entry: fade + slight translate
- Carousel indicators: animated width and color transitions

Token source: `lib/core/styling/design_tokens.dart` and `lib/core/styling/glass_constants.dart`

## 5) Global Components

- **App background:** immersive gradient + node lines + faint bokeh + sunrise hint.
  - `lib/presentation/widgets/premium_app_background.dart`
- **Glass container:** default wrapper for cards and elevated sections.
  - `lib/presentation/widgets/glass/glass_container.dart`
- **Bottom nav:** frosted glass shell, active glow, optional micro PH accent on Home.
  - `lib/presentation/screens/main_scaffold.dart`
- **Buttons / inputs / cards:** themed globally through `AppTheme`.
  - `lib/core/theme/app_theme.dart`

## 6) Screen-Level Rules

- **Home/Dashboard**
  - Welcome hero + PH tagline + stat pills
  - Jobs carousel with glass chips and apply CTA
  - Progress cards with teal/blue accents
- **Portfolio**
  - Glass cards in grid/masonry layout
  - Showcase strips keep same corner radius and border treatment
- **Resume**
  - Glass sections and card-based lists with consistent spacing rhythm
- **Skills**
  - Glass list tiles, proficiency indicators, and clear focus styles
- **Profile**
  - Hero profile card + glass section cards below

## 7) Accessibility Baseline

- Minimum touch target: `48x48`
- High contrast text in dark mode (`#E2E8F0` / `#F1F5F9` ranges)
- Visible focus state on all controls
- Text hierarchy: headings `18-28`, body `14-16`

## 8) Implementation Checklist for New Screens

- Use `PremiumAppBackground` as the root visual surface.
- Use `GlassContainer` for all key panels/cards.
- Keep radii in `24-32` band.
- Use primary/secondary accents from design tokens only.
- Match spacing rhythm from existing tabs (12/16/24).
- Keep one primary CTA per viewport section.

## 9) Screenshot Capture Protocol (for final design review)

Since render export is environment-dependent, use this capture setup:

1. Run app: `flutter run -d web-server --web-port 56557`
2. Open `http://localhost:56557`
3. DevTools device mode: **Samsung Galaxy S8+** (`360x740`)
4. Capture:
   - Home/Dashboard
   - Portfolio
   - Resume
   - Skills
   - Profile
5. Toggle light mode and capture small inset references per screen.

