# EV Charging App — Mobile Design System

**Status:** Finalized — UI Implementation Reference  
**Scope:** Flutter Mobile Application (MVP)  
**Last Updated:** 2026-06-11  
**Supported locales:** English (LTR), Persian/Farsi (RTL)

This document is the authoritative specification for the visual design and interaction patterns of the EV Charging mobile application. Every UI decision made during implementation must be consistent with this baseline. No design pattern may be introduced at implementation time without updating this document.

---

## Table of Contents

1. [Color System](#1-color-system)
2. [Typography System](#2-typography-system)
3. [Spacing Scale](#3-spacing-scale)
4. [Elevation System](#4-elevation-system)
5. [Border Radius System](#5-border-radius-system)
6. [Button Variants](#6-button-variants)
7. [Input Variants](#7-input-variants)
8. [Card Variants](#8-card-variants)
9. [Bottom Navigation Design](#9-bottom-navigation-design)
10. [Map-Specific UI Components](#10-map-specific-ui-components)
11. [Station Card Design](#11-station-card-design)
12. [Reservation Card Design](#12-reservation-card-design)
13. [Charging Session Widgets](#13-charging-session-widgets)
14. [Wallet Widgets](#14-wallet-widgets)
15. [Notification Widgets](#15-notification-widgets)
16. [Loading States](#16-loading-states)
17. [Empty States](#17-empty-states)
18. [Error States](#18-error-states)
19. [RTL Support](#19-rtl-support)
20. [Accessibility Requirements](#20-accessibility-requirements)

---

## 1. Color System

### Design intent

The palette communicates three brand values simultaneously: **Energy** (the electric accent, vibrant and kinetic), **Trust** (the primary blue, stable and reliable), and **Clarity** (generous neutral tones that never compete with functional color signals). The charger status system has its own semantic palette — these five colors are never used decoratively.

### Brand palette

| Token | Hex | HSL | Role |
|-------|-----|-----|------|
| `brand.electric` | `#0F5EFF` | 222° 100% 53% | Primary actions, key CTAs, links |
| `brand.electricDark` | `#0044CC` | 218° 100% 40% | Pressed/active state of primary |
| `brand.electricLight` | `#4D8FFF` | 218° 100% 65% | Light-mode tinted surfaces, focus rings |
| `brand.energy` | `#00D68F` | 161° 100% 42% | Charging active, success, available |
| `brand.energyDark` | `#00A86E` | 161° 100% 33% | Pressed energy state |

### Semantic color tokens

Semantic tokens are what widgets consume. Never use brand palette values directly in components — always reference semantic tokens. This enables future dark-mode and theme switching.

**Light mode:**

| Token | Value | Usage |
|-------|-------|-------|
| `color.primary` | `#0F5EFF` | Primary buttons, active tab indicator, selected state |
| `color.primaryContainer` | `#E8F0FF` | Tinted surface behind primary elements |
| `color.onPrimary` | `#FFFFFF` | Text/icon on primary-colored backgrounds |
| `color.secondary` | `#00D68F` | Charging state, success, available badge |
| `color.secondaryContainer` | `#E0FBF3` | Tinted surface for success/charging states |
| `color.onSecondary` | `#FFFFFF` | Text/icon on secondary-colored backgrounds |
| `color.tertiary` | `#6B4EFF` | Reservation state, wallet accent |
| `color.tertiaryContainer` | `#EDE8FF` | Reserved badge background |
| `color.onTertiary` | `#FFFFFF` | Text/icon on tertiary backgrounds |
| `color.error` | `#E53935` | Error states, destructive actions, faulted |
| `color.errorContainer` | `#FFEBEE` | Error message background |
| `color.onError` | `#FFFFFF` | Text/icon on error backgrounds |
| `color.warning` | `#F59E0B` | Occupied/busy, pending states, caution |
| `color.warningContainer` | `#FFFBEB` | Warning message background |
| `color.onWarning` | `#FFFFFF` | Text/icon on warning backgrounds |
| `color.background` | `#F4F7FF` | App-wide background (subtle blue tint) |
| `color.surface` | `#FFFFFF` | Card, bottom sheet, dialog surfaces |
| `color.surfaceVariant` | `#EEF2FF` | Chips, selected item backgrounds, input fills |
| `color.surfaceElevated` | `#FFFFFF` | Same as surface; elevation adds shadow |
| `color.outline` | `#DDE3F0` | Input borders, card outlines, dividers |
| `color.outlineVariant` | `#EEF1FB` | Subtle dividers, disabled borders |
| `color.scrim` | `#000000` at 50% opacity | Modal overlay, bottom sheet backdrop |

**Text tokens (light mode):**

| Token | Value | Usage |
|-------|-------|-------|
| `color.text.primary` | `#111827` | Body text, card titles, labels |
| `color.text.secondary` | `#6B7280` | Subtitles, helper text, timestamps |
| `color.text.tertiary` | `#9CA3AF` | Placeholder text, disabled labels |
| `color.text.disabled` | `#D1D5DB` | Disabled control text |
| `color.text.inverse` | `#FFFFFF` | Text on dark/colored surfaces |
| `color.text.link` | `#0F5EFF` | Inline links |
| `color.text.success` | `#059669` | Confirmation text, available status text |
| `color.text.error` | `#DC2626` | Inline error messages |
| `color.text.warning` | `#D97706` | Warning messages |

### Dark mode tokens

Dark mode uses a deep navy background — not pure black. Pure black on OLED creates harsh contrast that makes prolonged use fatiguing, particularly at night when the charging app is most needed.

| Token | Light value | Dark value |
|-------|-------------|------------|
| `color.primary` | `#0F5EFF` | `#4D8FFF` (lighter for dark bg contrast) |
| `color.primaryContainer` | `#E8F0FF` | `#1A2A55` |
| `color.secondary` | `#00D68F` | `#00E89A` |
| `color.secondaryContainer` | `#E0FBF3` | `#00341E` |
| `color.tertiary` | `#6B4EFF` | `#9B80FF` |
| `color.tertiaryContainer` | `#EDE8FF` | `#1E164A` |
| `color.error` | `#E53935` | `#FF6B6B` |
| `color.errorContainer` | `#FFEBEE` | `#3B1010` |
| `color.warning` | `#F59E0B` | `#FBB83F` |
| `color.warningContainer` | `#FFFBEB` | `#3B2800` |
| `color.background` | `#F4F7FF` | `#0A0F1E` |
| `color.surface` | `#FFFFFF` | `#141B2D` |
| `color.surfaceVariant` | `#EEF2FF` | `#1C2540` |
| `color.surfaceElevated` | `#FFFFFF` | `#1E2A3D` |
| `color.outline` | `#DDE3F0` | `#2A3A55` |
| `color.outlineVariant` | `#EEF1FB` | `#1F2D45` |
| `color.text.primary` | `#111827` | `#F0F4FF` |
| `color.text.secondary` | `#6B7280` | `#8FA3C8` |
| `color.text.tertiary` | `#9CA3AF` | `#5D7090` |
| `color.text.disabled` | `#D1D5DB` | `#3D506B` |

### Charger status color system

These five colors are a closed semantic set. They carry critical operational meaning and are never repurposed for decorative use.

| Status | Color token | Hex (light) | Hex (dark) | On-status text |
|--------|------------|-------------|------------|----------------|
| Available | `status.available` | `#059669` | `#34D399` | `#FFFFFF` |
| Charging | `status.charging` | `#0F5EFF` | `#4D8FFF` | `#FFFFFF` |
| Occupied | `status.occupied` | `#D97706` | `#FBB83F` | `#FFFFFF` |
| Reserved | `status.reserved` | `#7C3AED` | `#A78BFA` | `#FFFFFF` |
| Unavailable | `status.unavailable` | `#6B7280` | `#64748B` | `#FFFFFF` |
| Faulted | `status.faulted` | `#DC2626` | `#FF6B6B` | `#FFFFFF` |

### Color usage rules

- The primary (`#0F5EFF`) is used for one primary CTA per screen maximum. Secondary and tertiary actions use outlined or text variants.
- Status colors are only used in contexts that reference charger/session/reservation state. Never use `status.available` to mean "form is complete" or `status.faulted` to mean "generic error" — use semantic `color.success`/`color.error` for those.
- The map surface is exempt from the standard surface token. Map tiles carry their own visual weight; UI elements overlaid on the map use elevated surfaces with stronger shadow to lift them visually.
- Gradient usage is restricted to: the charging session ring animation track, and the branded splash/onboarding screen. No decorative gradients elsewhere.

---

## 2. Typography System

### Font families

| Script | Family | Weight range | Source |
|--------|--------|-------------|--------|
| Latin (English) | Inter | 400, 500, 600, 700 | Google Fonts |
| Persian / Farsi | Vazirmatn | 400, 500, 600, 700 | Google Fonts |

**Fallback chain:** The active locale's font is the primary family. The other script's font is in the fallback list. Mixed-script text (e.g., a Persian sentence containing "OCPP" or a model number) renders correctly without manual intervention.

**Why Inter:** Excellent Latin legibility at small sizes, large weight variety, wide Unicode coverage for Latin-adjacent scripts.

**Why Vazirmatn:** The standard open-source Persian font for digital products. Designed specifically for screen legibility at small sizes. Contains its own high-quality Latin subset, eliminating awkward cross-family mixing for Latin characters within Persian text.

### Type scale

All sizes in logical pixels (sp). Line heights are minimum values; text can expand beyond for long content.

| Token | Size | Weight | Line height | Letter spacing | Usage |
|-------|------|--------|-------------|---------------|-------|
| `type.display.large` | 40sp | 700 Bold | 48sp | −0.5px | Splash headline, large empty state |
| `type.display.medium` | 32sp | 700 Bold | 40sp | −0.3px | Major marketing moments |
| `type.headline.large` | 28sp | 600 SemiBold | 36sp | −0.2px | Screen titles (auth, KYC) |
| `type.headline.medium` | 24sp | 600 SemiBold | 32sp | −0.1px | Section headers, dialog titles |
| `type.headline.small` | 20sp | 600 SemiBold | 28sp | 0 | Card hero text, list screen titles |
| `type.title.large` | 18sp | 600 SemiBold | 26sp | 0 | Navigation title, prominent labels |
| `type.title.medium` | 16sp | 600 SemiBold | 24sp | 0.1px | Card titles, form section headers |
| `type.title.small` | 14sp | 600 SemiBold | 20sp | 0.1px | Sub-section labels, tab labels |
| `type.body.large` | 16sp | 400 Regular | 24sp | 0.15px | Primary reading text |
| `type.body.medium` | 14sp | 400 Regular | 22sp | 0.15px | Secondary body, descriptions |
| `type.body.small` | 12sp | 400 Regular | 18sp | 0.2px | Captions, help text, timestamps |
| `type.label.large` | 14sp | 500 Medium | 20sp | 0.1px | Button labels, prominent chips |
| `type.label.medium` | 12sp | 500 Medium | 16sp | 0.3px | Badge text, small chips |
| `type.label.small` | 11sp | 500 Medium | 16sp | 0.5px | Micro labels, connector type tags |
| `type.numeric.display` | 48sp | 700 Bold | 56sp | −1px | Balance, large session metrics |
| `type.numeric.large` | 32sp | 700 Bold | 40sp | −0.5px | kWh delivered, session cost |
| `type.numeric.medium` | 24sp | 600 SemiBold | 30sp | −0.2px | Duration, live power reading |
| `type.numeric.small` | 18sp | 500 Medium | 24sp | 0 | Transaction amounts, estimates |

`type.numeric.*` tokens use `fontFeatures: [FontFeature.tabularFigures()]` — all digits are the same width, preventing layout shifts as numbers update in real time.

### Persian (fa) typography adjustments

When locale is `fa`, the following adjustments apply globally:

| Property | Latin default | Persian override | Reason |
|----------|-------------|-----------------|--------|
| Font family | Inter | Vazirmatn | Script coverage |
| Line height | As specified | +25% across all tokens | Persian script needs more vertical space |
| Letter spacing | As specified | 0 across all tokens | Vazirmatn is optimized; manual tracking is harmful |
| Text direction | LTR | RTL | Writing system |
| body.large line height | 24sp | 30sp | Readability |
| body.medium line height | 22sp | 28sp | Readability |

**Always-LTR exceptions regardless of locale:**
- Phone numbers
- OTP codes
- Station IDs, session IDs, transaction IDs
- Technical codes (connector IDs, version strings)
- These elements are wrapped in an explicit LTR container; `type.body.*` tokens apply but font is always Inter

### Typography usage rules

- Never mix weights within a single label or short text element. Use a single token per text span.
- For emphasis within body text (e.g., a highlighted amount inside a description), use `type.body.large` with weight 600 — not a different size.
- Truncation: all list item titles truncate at one line with ellipsis. Multi-line body text wraps fully. Never clip text without an ellipsis.
- Minimum legible size: 11sp (`type.label.small`). Nothing smaller appears in any component.

---

## 3. Spacing Scale

The entire layout is built on an **8dp grid**. Every margin, padding, gap, and size either falls on the 8dp grid or on the 4dp half-grid (for fine adjustments).

| Token | Value | Common uses |
|-------|-------|-------------|
| `space.1` | 4dp | Icon internal padding, hairline gaps, chip icon gap |
| `space.2` | 8dp | Compact item spacing, icon-to-label gap, chip horizontal padding |
| `space.3` | 12dp | Card internal section gap, small button vertical padding |
| `space.4` | 16dp | Standard screen edge margin, section header vertical padding, list item padding |
| `space.5` | 20dp | Between related element groups, input vertical padding |
| `space.6` | 24dp | Between unrelated sections within a screen |
| `space.7` | 32dp | Major section separation, dialog content padding |
| `space.8` | 40dp | Large decorative gap, onboarding vertical spacing |
| `space.9` | 48dp | Top/bottom padding on tall cards |
| `space.10` | 64dp | Splash screen vertical rhythm, empty state illustration margin |

### Specific layout rules

**Screen edge margin:** `space.4` (16dp) on all sides. The map screen is exempt — the map extends edge-to-edge and floating UI overlays use their own internal padding.

**Bottom safe area:** All scrollable content and CTAs add a `space.4` (16dp) bottom clearance below the bottom navigation bar's safe area inset.

**List item anatomy:** Horizontal padding `space.4` | Leading content | `space.3` gap | Text content | `space.3` gap | Trailing content | Horizontal padding `space.4`. Vertical: minimum 56dp touch target height with `space.3` top + bottom internal padding.

**Card internal padding:** `space.4` (16dp) standard. Compact card variant uses `space.3` (12dp).

**Bottom sheet internal padding:** `space.5` (20dp) top below the handle. `space.4` (16dp) left/right. `space.6` (24dp) bottom above safe area inset.

---

## 4. Elevation System

Elevation communicates layer depth. Higher elevation means closer to the user, therefore more important or more temporary. Shadows in light mode are desaturated blue-gray (not neutral gray) to harmonize with the blue-tinted background.

| Level | dp | Shadow spec (light mode) | Shadow spec (dark mode) | Component |
|-------|-----|--------------------------|------------------------|-----------|
| 0 | 0 | None | None | Background, flat dividers |
| 1 | 2 | `0 1px 3px rgba(15,94,255,0.08)` | `0 1px 3px rgba(0,0,0,0.3)` | Subtle cards, contained sections |
| 2 | 4 | `0 2px 8px rgba(15,94,255,0.10)` | `0 2px 8px rgba(0,0,0,0.4)` | Standard cards, list items |
| 3 | 8 | `0 4px 16px rgba(15,94,255,0.12)` | `0 4px 16px rgba(0,0,0,0.5)` | Map overlay elements, FABs |
| 4 | 12 | `0 6px 20px rgba(15,94,255,0.14)` | `0 6px 20px rgba(0,0,0,0.55)` | Bottom navigation bar |
| 5 | 16 | `0 8px 28px rgba(15,94,255,0.16)` | `0 8px 28px rgba(0,0,0,0.6)` | Bottom sheet (partially open) |
| 6 | 24 | `0 12px 40px rgba(15,94,255,0.18)` | `0 12px 40px rgba(0,0,0,0.65)` | Dialogs, full-height bottom sheet |
| 7 | 32 | `0 16px 56px rgba(15,94,255,0.22)` | `0 16px 56px rgba(0,0,0,0.7)` | Modals over full-screen content |

**Elevation + tint in dark mode:** At elevation levels 1–7 in dark mode, surfaces receive an additive white tint overlay proportional to elevation level. Level 1: `#FFFFFF` at 5% opacity on surface. Level 6: `#FFFFFF` at 15% opacity. This is standard Material You dark-mode behavior and provides depth without shadows becoming invisible.

**Map surface rule:** UI panels floating above the map (search bar, station detail sheet, session mini-card) use elevation 3 minimum. The map itself is elevation 0. Nothing sits between 0 and 3 on the map surface — the visual jump must be immediately apparent.

---

## 5. Border Radius System

| Token | Value | Usage |
|-------|-------|-------|
| `radius.none` | 0dp | Full-width banners, horizontal dividers, image fills |
| `radius.xs` | 4dp | Status dots, small tags, micro badges |
| `radius.sm` | 8dp | Input fields, small buttons, inline chips |
| `radius.md` | 12dp | Standard cards, dialog surface corners |
| `radius.lg` | 16dp | Large cards, connector type selection items, map overlay panels |
| `radius.xl` | 20dp | Bottom sheet top corners, session ring card |
| `radius.2xl` | 28dp | Bottom navigation bar top corners, large modal surfaces |
| `radius.full` | 9999dp | Circular avatars, pill buttons, status indicator dots, FABs |

**Consistency rule:** All cards in the same list use the same radius token. Never mix `radius.md` and `radius.lg` cards in the same list view.

**Bottom sheet top corners:** Always `radius.xl` (20dp) on the two top corners. Bottom corners are always 0 (extend edge-to-edge).

**Sheet handle:** A 32dp wide × 4dp tall pill shape, `radius.full`, `color.outline` fill, centered at 12dp from the top edge of the sheet.

---

## 6. Button Variants

### Size specifications

| Size | Height | Horizontal padding | Label token | Icon size |
|------|--------|-------------------|-------------|-----------|
| Large | 56dp | `space.6` (24dp) | `type.label.large` | 20dp |
| Medium | 44dp | `space.5` (20dp) | `type.label.large` | 18dp |
| Small | 32dp | `space.3` (12dp) | `type.label.medium` | 16dp |

All buttons use `radius.sm` (8dp) by default. Pill variant uses `radius.full`.

Minimum touch target: 44×44dp regardless of visual size. Small buttons that appear visually smaller use invisible padding to meet the minimum.

### Variant catalog

**1. Primary (Filled)**
- Background: `color.primary`
- Label: `color.onPrimary` (white)
- Icon (optional): same as label
- Pressed: background `color.primaryDark`; scale 0.98
- Loading: replace label with 20dp circular indicator, same white color; width maintained
- Disabled: background `color.outline`; label `color.text.disabled`; no interaction

**2. Secondary (Outlined)**
- Background: transparent
- Border: 1.5dp `color.primary`
- Label: `color.primary`
- Pressed: background `color.primaryContainer`; border darkens
- Loading: circular indicator in `color.primary`
- Disabled: border `color.outline`; label `color.text.disabled`

**3. Tertiary (Text / Ghost)**
- Background: transparent; no border
- Label: `color.primary`
- Pressed: background `color.primaryContainer` at 60% opacity
- Disabled: label `color.text.disabled`
- Used for: low-priority secondary actions, inline cancel, "Learn more"

**4. Destructive (Filled)**
- Background: `color.error`
- Label: `color.onError` (white)
- Pressed: background darkened 15%
- Loading: white circular indicator
- Disabled: same rule as Primary
- Used for: stop session, cancel reservation, revoke session

**5. Destructive Outlined**
- Background: transparent
- Border: 1.5dp `color.error`
- Label: `color.error`
- Pressed: background `color.errorContainer`
- Used for: secondary destructive confirmation ("I want to cancel" alongside "Keep reservation")

**6. Icon Button**
- Shape: `radius.full` (circular)
- Sizes: 40dp (standard), 48dp (map FAB variant), 56dp (floating action)
- Background: `color.surface` at elevation 3
- Icon: `color.text.primary`
- Active/selected icon: `color.primary`
- Pressed: background `color.surfaceVariant`
- Tooltip on long-press (accessibility)

**7. Chip / Filter Button**
- Height: 32dp
- Shape: `radius.full` pill
- Unselected: border 1dp `color.outline`; background transparent; label `color.text.secondary`
- Selected: background `color.primaryContainer`; border `color.primary`; label `color.primary`; leading check icon appears on selection
- Used for: connector type filters, power level filters, reservation status filters

### Button group rules

- A screen has at most one Large Primary button, always anchored to the bottom of the screen content area (above safe area inset).
- Stacked button pairs (Primary + Secondary): 12dp gap between them; Secondary button first visually if destructive.
- Never place two filled buttons adjacent to each other.
- Icon-only buttons always have an accessible label for screen readers.

---

## 7. Input Variants

### Anatomy (common to all text inputs)

Label (above field, always visible — not inside field) → Input container → Helper / error text (below field)

- Label: `type.body.small`, `color.text.secondary`; moves to above the container (never floats Material-style)
- Container height: 52dp standard, 48dp compact
- Internal padding: 16dp horizontal, 14dp vertical
- Helper text: `type.body.small`, `color.text.tertiary`; always reserved space even when empty to prevent layout shift on error appearance
- Error text: replaces helper text in same space; `color.text.error`; leading error icon 14dp

### States

| State | Border | Background | Label color | Icon color |
|-------|--------|-----------|-------------|-----------|
| Default | 1dp `color.outline` | `color.surface` | `color.text.secondary` | `color.text.tertiary` |
| Focused | 2dp `color.primary` | `color.surface` | `color.primary` | `color.primary` |
| Filled (has value) | 1dp `color.outline` | `color.surface` | `color.text.secondary` | `color.text.secondary` |
| Error | 2dp `color.error` | `color.errorContainer` | `color.text.error` | `color.error` |
| Disabled | 1dp `color.outlineVariant` | `color.surfaceVariant` | `color.text.disabled` | `color.text.disabled` |
| Read-only | None | `color.surfaceVariant` | `color.text.secondary` | — |

### Variant catalog

**1. Standard Text Input**
- Shape: `radius.sm` (8dp)
- Trailing clear (×) icon appears when field has content and is focused

**2. Search Input**
- Leading search icon: 20dp, `color.text.tertiary`; transitions to `color.primary` on focus
- Trailing clear (×) icon: animated in when content present
- Shape: `radius.full` (pill) — distinguishes search from form inputs
- Background: `color.surfaceVariant` in default state (no border); border appears on focus

**3. Phone Number Input**
- Leading: country flag (16dp) + dialing code (`type.label.large`, `color.text.primary`) in a tappable container separated by a 1dp vertical divider
- Input area: always `TextDirection.ltr`; font always Inter
- Keyboard type: numeric (phone)
- Format: auto-inserts spaces as user types per country format

**4. OTP Code Input**
- 6 individual boxes in a horizontal row; always LTR regardless of locale
- Box size: 48×56dp
- Shape: `radius.sm`
- Gap between boxes: 8dp
- Active box: 2dp `color.primary` border with subtle pulse animation
- Filled box: `color.primaryContainer` background; digit centered in `type.headline.small`, `color.primary`
- Error state: all boxes turn `color.error` border + `color.errorContainer` background simultaneously; shake animation (horizontal, 4dp amplitude, 300ms, ease-out)
- Cursor: blinking 2dp line inside active empty box
- On correct OTP: brief success pulse (green border flash, 200ms)

**5. Amount Input**
- Leading currency label or symbol: `type.title.medium`, `color.text.secondary`; vertically centered; separated by divider
- Number input: right-aligned; `type.numeric.medium`; comma-formatted as user types
- Maximum width for the numeric portion: fits the expected maximum value
- Keyboard: numeric with decimal (if currency has decimals)
- Font: always Inter for numbers; locale-specific font for labels around it

**6. Date/Time Picker (bottom sheet)**
- Trigger: a read-only text input showing the selected value; tap opens a bottom sheet
- Bottom sheet contains:
  - Calendar grid for date selection (Gregorian in `en`, Shamsi in `fa`)
  - Time picker wheel below the calendar (hour / minute columns)
  - Confirm and Cancel buttons at the bottom
- Selected date cell: `radius.full` circle fill, `color.primary`, white text
- Today marker: `color.primary` dot below the date number (when not selected)
- Header: month/year navigation with back/forward arrows (mirrored in RTL)

**7. Selection Input (bottom sheet list)**
- Trigger: same as date picker — read-only input, tap opens bottom sheet
- Bottom sheet: scrollable list of options
- Selected option: checkmark trailing icon, label in `color.primary`
- Each option: 56dp height, `type.body.large`, full-width tap area

**8. Multi-line Text Area**
- Min height: 96dp (4 lines)
- Max height: 160dp (scrolls beyond)
- Character count: bottom-right corner, `type.body.small`, `color.text.tertiary`; turns `color.error` within 10 characters of limit
- Same border/state rules as Standard Text Input

### Input group rules

- All form inputs on a screen use the same container height and shape variant. Never mix pill search inputs with standard inputs in the same form.
- Required fields: asterisk suffix (*) on the label, `color.error`. Never use placeholder text as the only indicator of required status.
- Labels are always visible above the field — never rely on placeholder text to communicate what the field is.

---

## 8. Card Variants

Cards are elevated surfaces grouping related information. They are never nested (no card inside a card).

### Variant catalog

**1. Standard Card**
- Surface: `color.surface`, elevation 2
- Shape: `radius.md` (12dp)
- Padding: `space.4` (16dp) all sides
- No interactivity (no ripple, no chevron)
- Used for: info sections, static content, KYC status display

**2. Interactive Card**
- Surface: `color.surface`, elevation 2
- Shape: `radius.md`
- Padding: `space.4`
- Trailing: chevron icon 16dp, `color.text.tertiary`
- Ripple on tap: `color.primary` at 8% opacity
- Hover/press: background `color.surfaceVariant`
- Used for: list items that navigate somewhere, settings items, vehicle list items

**3. Status Card (left-accent)**
- Surface: `color.surface`, elevation 2
- Shape: `radius.md` with left-side `radius.sm` override only on left corners
- Left accent bar: 4dp width, full card height, `radius.none`; color is the status semantic color
- Content padding: 16dp on all sides except left where there is 20dp (to clear the accent bar with a gap)
- Used for: reservation cards in the list, notification history items, any card that carries a status value

**4. Hero Card**
- Surface: `color.surface`, elevation 2
- Shape: `radius.lg` (16dp)
- Top section: full-width image or illustration area, 160dp tall, `radius.lg` on top corners only, `radius.none` on bottom
- Content section: `space.4` padding
- Bottom section: action row with a primary button
- Used for: featured station, onboarding feature highlights

**5. Compact List Card**
- Surface: `color.surface`, elevation 1
- Shape: `radius.sm` (8dp)
- Height: 64dp (fixed, single-line info layout)
- Internal padding: 12dp vertical, `space.4` horizontal
- No separator lines between items; rely on card spacing (`space.2` vertical gap between items)
- Used for: transaction list, vehicle list, session list

**6. Map Station Detail Card (bottom sheet)**
- This is a bottom sheet surfaced as a card — see Section 10 for full specification.

### Card group rules

- Vertical spacing between cards in a list: `space.2` (8dp)
- Cards in a horizontal scroll row: `space.3` (12dp) gap; first card has `space.4` left inset; last card has `space.4` right inset (so edge cards align with screen margin)
- The shadow of a card must be visible against the background — never place cards on `color.surface` (white on white). Always ensure the background is `color.background` or a tinted surface.

---

## 9. Bottom Navigation Design

### Layout

- Height: 64dp + bottom safe area inset
- Background: `color.surface`, elevation 4
- Top border: 1dp `color.outlineVariant`
- Top corners: `radius.2xl` (28dp) when the navigation bar appears over content (map screen); square top corners when the content ends flush above the bar

### Tab item anatomy

Each tab occupies equal width. 5 tabs on a standard 390dp screen width = 78dp per tab.

- Touch target: 56dp × 56dp minimum, centered within the tab column
- Icon size: 24dp
- Label: `type.label.small` (11sp), always visible (never icon-only)
- Vertical layout: icon (24dp) → 4dp gap → label
- Inactive: icon `color.text.tertiary`; label `color.text.tertiary`
- Active: icon `color.primary`; label `color.primary`; active indicator pill behind icon

**Active indicator pill:**
- Width: 56dp
- Height: 28dp
- Shape: `radius.full`
- Background: `color.primaryContainer`
- The pill is behind the icon only, not extending down to the label

### Badge specifications

| Tab | Badge type | Trigger |
|-----|-----------|---------|
| Map | None | — |
| Reservations | Count badge | Reservations active within the next 24 hours |
| Charging | Pulse dot | Session is active |
| Wallet | None | — |
| Profile | Alert dot | kycStatus is pending or rejected |

**Count badge:** 18dp minimum diameter, `radius.full`, `color.error` background, `type.label.small` white text. Positioned at top-right of icon, overlapping 6dp into the icon. Shows max "99+" after 99.

**Pulse dot (charging active):** 8dp diameter circle, `color.secondary` (charging green). Animated: 2-second repeating scale pulse from 1.0→1.3→1.0, opacity 1.0→0.6→1.0. Positioned at top-right of the charging bolt icon.

**Alert dot:** 8dp diameter circle, `color.warning`. No animation. Top-right of profile icon.

### Session mini-card

The session mini-card appears above the bottom navigation bar whenever a charging session is active. It persists across all 5 tabs.

- Height: 56dp
- Width: screen width − `space.8` (40dp) total horizontal margin
- Background: `color.surface`, elevation 3
- Shape: `radius.md` (12dp)
- Position: floating 8dp above the top edge of the bottom navigation bar
- Left: animated charging bolt icon (18dp, `color.secondary`) + station name (`type.title.small`, `color.text.primary`, max 1 line truncated)
- Center: live kWh in `type.numeric.small`, `color.secondary` + "kWh" label in `type.label.small`, `color.text.secondary`
- Right: live duration in `type.label.medium`, `color.text.secondary` + "Stop" pill button (Small Destructive variant)
- Tap anywhere on the card (except Stop button): navigate to `/charging/:sessionId`
- Animation in: slide up from bottom (200ms ease-out) simultaneous with content shifting up
- Animation out: slide down (150ms ease-in) when session ends

### RTL behavior

In RTL (Persian), the visual order of the 5 tabs is reversed: Profile | Wallet | Charging | Reservations | Map (right-to-left). Tab indices remain unchanged — only screen position mirrors. The session mini-card layout also mirrors: Stop button on the left, station name on the right, metrics in the center.

---

## 10. Map-Specific UI Components

The map screen is the app's home and the most visually complex surface. All UI components float over the native map tile layer.

### Map surface layers (bottom to top)

| Layer | Z-order | Component |
|-------|---------|-----------|
| 0 | Map tiles | Native map SDK background |
| 1 | Station clusters | Server-rendered cluster aggregates |
| 2 | Station pins | Individual station markers |
| 3 | Selected station ring | Expanded selection indicator |
| 4 | Map controls | My location FAB, zoom controls, layer toggle |
| 5 | Search + filter bar | Top overlay |
| 6 | Station detail sheet | Bottom sheet (expands over map) |
| 7 | Session mini-card | Persistent above nav bar |

### Search bar

- Position: 16dp from top safe area, 16dp left/right margin
- Height: 52dp
- Shape: `radius.full` (pill)
- Background: `color.surface`, elevation 3
- Leading: magnifier icon 20dp, `color.text.tertiary`; transitions to `color.primary` on focus
- Placeholder: `type.body.large`, `color.text.tertiary`
- Active search: trailing ×  clear button
- When focused: bottom search results panel animates up (bottom sheet at half height), map dims (scrim 30%)
- Voice search icon (trailing, unfocused state): 20dp microphone icon, `color.text.tertiary`

### Filter chips row

- Position: directly below search bar, 8dp gap
- Horizontal scroll, no snap, fades at right edge
- Chip variants: 32dp height, `radius.full`, as defined in Button Variants section
- Filter groups: Connector type (Type 2, CCS, CHAdeMO, GB/T), Power (AC/DC, ≥50kW, ≥150kW), Status (Available now), Price (Low to high)
- Active filter count badge: small count dot on the filter toggle icon when any filter is active

### Station pin (map marker)

Pins are the primary navigation signal on the map. They must be legible at every zoom level where individual stations appear.

**Pin anatomy (zoomed-in view):**
- Shape: 36×44dp total (36dp square body + 8dp triangle bottom pointer)
- Body: `radius.md` (12dp) on all corners of the square portion
- Icon: 18dp centered in the 36dp square body; connector type icon or bolt icon
- Shadow: elevation 3 equivalent
- Border: 1.5dp white outline on body and pointer

**Pin states:**

| State | Body background | Icon color | Size |
|-------|----------------|-----------|------|
| Available | `status.available` | White | 36×44dp |
| Occupied | `status.occupied` | White | 36×44dp |
| Reserved | `status.reserved` | White | 36×44dp |
| Unavailable | `status.unavailable` | White | 36×44dp |
| Faulted | `status.faulted` | White | 36×44dp |
| Selected | `color.primary` | White | 44×54dp (enlarged) |
| Current session | `color.secondary` | White | 44×54dp + pulse ring |

**Selection pulse ring:** When a pin is selected, a 44dp circle appears behind the pin at 40% opacity in the pin's status color, animating from 44dp to 64dp diameter over 800ms, repeating. This draws the eye and confirms selection.

**Cluster bubble:**
- Shape: `radius.full` circle
- Minimum size: 40dp diameter
- Scales logarithmically with station count: 40dp (2–9), 48dp (10–49), 56dp (50+)
- Background: `color.primary` with a white ring outline (2dp)
- Count label: `type.label.large` white, centered
- Subtext (optional at large size): "stations", `type.label.small` white, 80% opacity
- Tap: map zooms into cluster bounds; animation 300ms ease-in-out

### Map control buttons

**My Location FAB:**
- Position: bottom-right, 16dp from right edge, 16dp above session mini-card (or nav bar if no session)
- Size: 48dp, `radius.full`
- Background: `color.surface`, elevation 3
- Icon: 22dp location icon
- States: inactive (hollow circle icon), active/following (filled circle + current location dot on map)
- Pressed: scale 0.95, 100ms

**Layer/Settings button:**
- Position: 16dp above My Location button
- Size: 40dp, `radius.full`
- Background: `color.surface`, elevation 3
- Icon: 20dp layers icon

### Station detail bottom sheet

The station detail sheet appears when a map pin is tapped. It starts at a "peek" height and can be dragged to full expansion.

**Peek state (236dp):**
- Sheet handle at top (always visible)
- Station name: `type.title.large`, 1 line, truncated
- Address: `type.body.medium`, `color.text.secondary`, 1 line
- Distance: `type.label.large`, `color.text.secondary` (e.g., "1.2 km")
- Connector row: horizontal scroll of connector type chips showing type + count + status dot
- Primary CTA: full-width "View Station" primary button

**Expanded state (full height, ~60% screen):**
All peek content +
- Connector list: each connector card shows: connector type icon, power (kW), status badge, tariff estimate, "Reserve" / "Start" buttons
- Operator info: logo (24dp) + name
- Amenities: small icon chips (parking, restroom, coffee, 24h)
- Last updated timestamp: `type.body.small`, `color.text.tertiary`

**Connector status badge in list:**
- Shape: `radius.full` pill, 24dp height
- Background: status semantic color at 15% opacity
- Text: status label in `type.label.medium`, status semantic color (full opacity)
- Leading 6dp dot: full status color

---

## 11. Station Card Design

### Station list card (in search results)

Height: 88dp, `radius.md`, elevation 2.

```
[ Status indicator 4dp bar left side ]
[ Station icon 40dp ] | [ Name (type.title.medium, 1 line)      ] | [ Distance (type.label.large, color.secondary) ]
                      | [ Address (type.body.small, secondary)  ]
                      | [ Connector chips row (max 3 visible)   ] | [ Available count (type.label.medium) ]
```

- Status indicator bar (4dp left edge): highest-priority status color across all connectors
- Station icon: operator logo if available; fallback to electric bolt icon in `color.primaryContainer` background circle
- Connector chips: 20dp × 20dp, `radius.xs`, background `color.surfaceVariant`, connector type icon 12dp
- Available count: "3 / 5 available" format, `color.text.secondary`

### Station detail screen header

Full-width header (not a card) at the top of the station detail screen:

- Hero background: operator brand color or map satellite image at 30% opacity; height 200dp
- Gradient overlay bottom-to-top: `color.surface` at 100% to transparent (covers bottom 80dp)
- Station name: `type.headline.medium` pinned at bottom-left, `color.text.primary`
- Address: `type.body.medium`, `color.text.secondary`
- Distance + navigation icon: bottom-right, `type.label.large`

---

## 12. Reservation Card Design

### Reservation list item

Uses the Status Card (left-accent) variant with a 4dp left accent bar.

Height: 96dp.

```
[ Status accent bar ] | [ Status badge (pill) + Station name (type.title.medium)    ] | [ Start time (type.label.large) ]
                      | [ Connector type chip + Connector label                     ]
                      | [ Tariff estimate (type.body.small, secondary)              ] | [ Date (type.body.small, secondary) ]
```

**Status badge (pill):** 24dp height, `radius.full`, background is status semantic color at 15%, text is status semantic color.

| Reservation status | Badge color | Accent bar color |
|-------------------|------------|-----------------|
| Confirmed | `status.reserved` (purple) | `status.reserved` |
| Active (session started) | `status.charging` (blue) | `status.charging` |
| Completed | `color.text.tertiary` (gray) | `color.outlineVariant` |
| Cancelled | `color.text.tertiary` | `color.outlineVariant` |
| Expired | `color.warning` | `color.warning` |
| NoShow | `color.error` | `color.error` |

### Reservation detail screen

Organized in content sections (Standard Card variant) separated by `space.3` gaps:

**Section 1 — Station card:** Station name, address, map thumbnail (80×80dp, `radius.sm`, right-aligned), directions button.

**Section 2 — Time slot card:** Start + end time displayed as two rows. Persian locale uses Shamsi date. If reservation is today: "Today" instead of the date. Countdown timer shown when within 30 minutes: `type.numeric.medium` in `color.warning`.

**Section 3 — Connector card:** Connector type icon (32dp), power (kW), tariff snapshot preview.

**Section 4 — Pricing card:** Component breakdown from TariffSnapshot. Each line: component type label + rate. Total estimate at bottom with heavier weight. Currency formatted per locale.

**Actions (bottom anchored):**
- Active/Confirmed status: "Start Session" (Primary Large) + "Cancel" (Tertiary, `color.error`)
- Cancellation window expired: "Start Session" only; Cancel button replaced with "Cancellation window closed" helper text
- Completed/Cancelled: "View Receipt" or no actions

### Countdown timer (within 30 minutes of start)

- Displayed inside the time slot card
- Format: MM:SS remaining
- Color: `color.warning` at 30min, transitions to `color.error` at 5min
- Font: `type.numeric.medium`
- Pulsing at 1-minute intervals: brief scale pulse 1.0→1.05→1.0

---

## 13. Charging Session Widgets

The active charging screen is the most critical UI in the application. A user entrusts the app with real money and physical hardware. Every element communicates clarity and control.

### Session status screen layout

Full-screen with four main zones (top to bottom):

1. Status header (40dp) — station name, connection status indicator
2. Session ring (280dp circle) — the primary visual focus
3. Metrics grid (140dp) — secondary data
4. Stop action zone (120dp + safe area) — the primary action

### Session ring

**Anatomy:**
- Background track ring: 12dp stroke width, `color.outlineVariant`, `radius.full`
- Progress arc: 12dp stroke width, gradient from `color.primary` (0°) to `color.secondary` (120°) — arc starts at top center and fills clockwise
- Center content area: 220dp diameter circle within the ring

**Progress metric:** The arc represents energy delivered as a fraction of estimated total. If no estimate is available, the arc completes one full rotation every 60 minutes (representing time elapsed).

**Center content — three-state:**

*State 1 — Energy mode (default):*
- Large number: kWh delivered, `type.numeric.large` (32sp), `color.text.primary`
- Unit: "kWh", `type.label.large`, `color.text.secondary`, below number
- Subtext: live power "at 50 kW", `type.body.small`, `color.text.tertiary`

*State 2 — Cost mode (tap to toggle):*
- Large number: current cost, `type.numeric.large`, `color.text.primary`; currency formatted per locale
- Unit: currency code, `type.label.large`, `color.text.secondary`
- Subtext: estimated final cost, `type.body.small`, `color.text.tertiary`

*State 3 — Time mode (tap again):*
- Large number: elapsed duration in MM:SS or HH:MM, `type.numeric.large`, `color.text.primary`
- Subtext: "elapsed", `type.body.small`, `color.text.tertiary`

Tapping the center cycles through the three modes. The mode indicator is three small dots below the ring (like a page indicator), current mode dot filled in `color.primary`.

**Ring animation while charging:**
- The gradient arc update is smooth (not stepped); re-renders at 1-second intervals with eased interpolation
- Outer glow: 4dp blurred halo in `color.secondary` at 20% opacity; pulses from 20% to 35% opacity over 2 seconds, repeating

**Ring animation when degraded (WS disconnected):**
- Progress arc becomes dashed (8dp dash, 8dp gap)
- Center overlay: ⚡️icon replaced by a wave-strike icon, `color.warning`; "Connection lost" text in `type.body.small`, `color.warning`
- All numbers frozen; timestamp of last update shown in `type.body.small`, `color.text.tertiary`

### Metrics grid

Below the ring: a 2×2 grid of metric tiles.

| Tile | Metric | Format | Token |
|------|--------|--------|-------|
| Top-left | Energy delivered | 12.5 kWh | `type.numeric.medium` |
| Top-right | Elapsed time | 00:45:22 | `type.numeric.medium` |
| Bottom-left | Current power | 50 kW | `type.numeric.medium` |
| Bottom-right | Estimated cost | ¥1,200 (or ۱٬۲۰۰ ریال) | `type.numeric.medium` |

Each tile:
- Background: `color.surfaceVariant`
- Shape: `radius.md`
- Label: `type.label.small`, `color.text.tertiary`
- Value: `type.numeric.medium`, `color.text.primary`
- Live update: number transitions with a brief fade-swap animation (150ms), preventing jarring number jumps

### Stop session button

- Size: Large (56dp)
- Variant: Destructive (Filled)
- Label: "Stop Charging"
- Position: center-horizontal, anchored 24dp above safe area inset
- Below button: estimated final cost preview in `type.body.small`, `color.text.secondary`

**Stop confirmation screen** (`/charging/:id/stop`):

A full-screen overlay (not a dialog):
- Title: "Stop your session?" — `type.headline.medium`
- Current session metrics summary: small compact grid (energy, time, cost so far)
- Warning: if session is still building charge, a note showing "Stopping now costs ¥X"
- Confirm stop: Destructive Large button, "Confirm Stop"
- Cancel: Tertiary button, "Continue Charging" — placed above the destructive button (preventing accidental double-tap)
- While OCPP command in flight: both buttons disabled; a progress indicator replaces the Confirm Stop button label; "Sending stop command…" helper text

### Session completed / receipt screen

- Checkmark animation: large circle draws from 0 to full, `color.secondary`, 600ms ease-out
- Station name + session ID: below checkmark
- Final metrics card: energy, duration, final cost in a Standard Card
- Tariff breakdown: expandable section (collapsed by default), showing each billing component
- "Done" button (Primary Large): navigates back to map
- "Share Receipt" button (Secondary): system share sheet

---

## 14. Wallet Widgets

### Balance display

Positioned at the top of the Wallet tab:

- Background card: `radius.xl`, `color.primaryContainer`, padding `space.5`
- Label: "Current Balance", `type.label.large`, `color.primary` at 80% opacity
- Balance value: `type.numeric.display` (48sp), `color.primary`; tabular figures
- Currency code: `type.title.medium`, `color.primary` at 70% opacity, inline after value
- Last refreshed: `type.body.small`, `color.primary` at 60% opacity
- "Top Up" button (Medium, white background, `color.primary` label): bottom-right of card

**Persian locale balance display:** Amount in `type.numeric.display` with Vazirmatn font; value uses Persian-Indic digits; currency unit (ریال or تومان) follows the number.

### Top-up flow

**Amount selection screen:**
- Preset amount chips: 4 chips in a 2×2 grid. Each chip: `radius.md`, 64dp height, amount in `type.numeric.small`, currency label below in `type.label.small`, status card left border in `color.primary` when selected
- Custom amount input: Amount Input variant, full width, below presets
- "Review" primary CTA anchored at bottom

**Confirmation screen:**
- Summary card: amount, currency, payment method icon + last 4 digits
- Fine print: processing time note, `type.body.small`, `color.text.tertiary`
- "Confirm Top-Up" Destructive variant? No — Primary Large: "Confirm ¥X Top-Up" (amount in label for clarity)

### Transaction list item

Uses the Compact List Card variant. Height: 64dp.

```
[ Transaction icon 36dp ] | [ Description (type.body.medium, primary)   ] | [ Amount (type.numeric.small, right-aligned) ]
                          | [ Date (type.body.small, tertiary)           ] | [ Status (type.label.small, tertiary)       ]
```

**Transaction icon (36dp circle, `radius.full`):**

| Transaction type | Icon | Background |
|----------------|------|-----------|
| TopUp | Arrow-down | `color.secondaryContainer` |
| SessionCharge | Bolt | `color.primaryContainer` |
| ReservationHold | Lock | `color.tertiaryContainer` |
| HoldRelease | Unlock | `color.tertiaryContainer` |
| Refund | Arrow-return | `color.secondaryContainer` |
| Adjustment | Settings | `color.surfaceVariant` |

**Amount color:**
- TopUp, HoldRelease, Refund: `color.secondary` (green — money coming in)
- SessionCharge, ReservationHold: `color.text.primary` (neutral — money going out)
- Adjustment: `color.text.secondary`

**Amount format:** Leading "+" for credits (TopUp, Refund, HoldRelease); no symbol for debits. Currency formatted per locale.

### Transaction detail screen

Standard Card containing:
- Transaction ID: `type.body.small` mono-spaced for the ID value, `color.text.tertiary`; copy-to-clipboard tap
- Type and description
- Amount (large, `type.numeric.large`)
- Date + time (formatted per locale including Shamsi for `fa`)
- Reference: session ID if `SessionCharge`; link to charging record

---

## 15. Notification Widgets

### In-app banner

Appears from the top of the screen (below the status bar), overlapping the current screen content. Maximum 3 banners queued; each auto-dismisses after 5 seconds.

**Anatomy (height 64dp + top safe area padding):**
- Background: `color.surface`, elevation 6
- Leading: notification type icon (20dp) in a 36dp circle with `color.primaryContainer` background
- Title: `type.title.small`, `color.text.primary`, 1 line
- Body: `type.body.small`, `color.text.secondary`, 2 lines maximum
- Trailing: dismiss × button (24dp touch target, `color.text.tertiary` icon)
- Left edge accent bar: 3dp, color matches notification semantic type (session = `color.primary`; reservation = `status.reserved`; wallet = `color.secondary`; security = `color.error`)

**Entry animation:** Slide down from fully above screen, 250ms ease-out.
**Exit animation:** Slide up back above screen, 200ms ease-in. Also triggered by swipe-up gesture.
**Progress bar:** Thin 2dp bar at bottom of banner showing remaining display time. Uses notification type accent color. Pauses on long-press.

**Tap behavior:** Navigates to the notification target route (via `NotificationRouter`), dismisses the banner.

**Security alert variant:** Full-width, height 80dp, `color.error` left border 4dp, red accent icon. Does not auto-dismiss. Requires explicit user interaction. Sits above all other banners and cannot be swiped away — only the "View" button dismisses it.

### Notification history list item

Uses the Status Card (left-accent) variant.

- Unread: left accent bar is solid type-color; background `color.surfaceVariant`
- Read: left accent bar is type-color at 30% opacity; background `color.surface`
- Title: `type.title.small`, `color.text.primary` (unread) or `color.text.secondary` (read)
- Body: `type.body.small`, `color.text.secondary`, 2 lines, ellipsis
- Timestamp: `type.body.small`, `color.text.tertiary`; relative format ("5 min ago") for last 24h; absolute date beyond that
- "Mark all read" action: in section header, `type.label.large`, `color.primary`; tap marks all above read

---

## 16. Loading States

### Principle

Skeleton loaders are used for all content that loads from the network. A skeleton shows the layout of the real content at its actual dimensions. No spinner is used for full-screen initial loads. Spinners are used only for inline actions (button loading state, pull-to-refresh indicator).

### Skeleton anatomy

- Skeleton blocks use `color.surfaceVariant` as the base
- Shimmer animation: a lighter highlight (`color.surface` at 80% opacity) sweeps left-to-right over 1.5 seconds, infinite, eased
- In dark mode: base `color.surfaceVariant`; shimmer `color.outline` at 50% opacity
- Persian locale: shimmer direction reverses (sweeps right-to-left)

### Skeleton patterns per screen

**Station list (search results):**
Three skeleton station list cards, each 88dp height:
- Left: 40dp circle skeleton
- Middle: two rectangle skeletons (120dp×14dp title, 80dp×12dp subtitle)
- Right: 40dp×14dp rectangle skeleton
- Bottom row: three 60dp×20dp pill skeletons (connector chips)

**Reservation list:**
Three skeleton status cards with left accent, 96dp height each.

**Active charging screen:**
- Ring skeleton: `color.outlineVariant` track ring only; no progress arc; no center content
- Center: 64dp×20dp rectangle (kWh label), 32dp×14dp rectangle (unit) stacked, centered
- Metrics grid: four `color.surfaceVariant` rectangles in the 2×2 grid

**Wallet screen:**
- Balance card skeleton: full-width, 100dp, with two rectangle skeletons
- Transaction list: five 64dp skeleton compact cards

**Station detail (expanded bottom sheet):**
- Header: 100% width × 48dp rectangle (name), 60% width × 16dp rectangle (address)
- Connector list: three 72dp skeleton cards

### Inline loading (pull-to-refresh)

Standard platform pull-to-refresh indicator using `color.primary` for the spinner color. Minimum 1-second display to prevent a visual flash.

### Page transition loading

Between route navigations where data is fetched on load: the new screen mounts immediately (preventing blank flashes) and its skeleton renders at the correct final layout dimensions.

---

## 17. Empty States

### Design approach

Empty states are moments to reinforce the brand and guide the user forward. Each has:
1. An illustration (vector, 160dp × 120dp, non-decorative but friendly)
2. A headline (`type.headline.small`, `color.text.primary`, centered)
3. A support paragraph (`type.body.medium`, `color.text.secondary`, centered, max 2 lines)
4. An optional primary CTA

All empty states are vertically centered in their container (list area), not at the top.

### Empty state catalog

**Reservations — no active reservations:**
- Illustration: A simplified calendar with a charging connector overlay
- Headline: "No reservations yet"
- Body: "Book a charging slot at your favorite station"
- CTA: "Find a Station" (Primary Medium, navigates to /map)

**Reservations — all past:**
- Headline: "No upcoming reservations"
- Body: "Your past sessions are in your wallet history"
- CTA: "View History" (Secondary Medium)

**Charging tab — no active session:**
- Illustration: A charging connector with a subtle electric arc motif
- Headline: "Ready to charge"
- Body: "Find an available station on the map to start a session"
- CTA: "Find a Station" (Primary Medium)

**Wallet — no transactions:**
- Illustration: A wallet with an electric coin/bolt
- Headline: "No transactions yet"
- Body: "Your charging sessions and top-ups will appear here"
- No CTA (user will transact naturally)

**Map — no results in search:**
- Shown in the search results bottom sheet
- Illustration: A map pin with a question mark
- Headline: "No stations found"
- Body: "Try a different search term or expand your area"
- CTA: "Clear filters" (Tertiary Medium) if filters are active

**Notification history — no notifications:**
- Illustration: Bell with "zzz" motif
- Headline: "All quiet"
- Body: "You'll see charging, reservation, and wallet updates here"

**Profile — no vehicles:**
- Illustration: A simplified EV silhouette
- Headline: "No vehicles added"
- Body: "Add your vehicle for personalized charging recommendations"
- CTA: "Add Vehicle" (Primary Medium)

---

## 18. Error States

### Hierarchy

Errors are surfaced at the most local scope possible. Field-level errors stay at the field. Network errors affecting a whole screen surface as a screen-level state. Only truly unrecoverable situations warrant a blocking error route.

### 1. Field-level (inline)

- Error text: `type.body.small`, `color.text.error`, below the input container
- Leading error icon: 14dp × 14dp, `color.error`, aligned with text
- Input container: 2dp `color.error` border, `color.errorContainer` background
- Appears immediately on blur (not on keystroke)
- Disappears when the value becomes valid (real-time)

### 2. Toast / snackbar (transient action feedback)

For non-blocking operation failures (e.g., failed to save preferences):
- Position: bottom of screen, 16dp above safe area; 16dp horizontal margin
- Height: 52dp minimum
- Background: `color.text.primary` (dark)
- Text: `type.body.medium`, white
- Shape: `radius.sm`
- Optional action: `type.label.large`, `color.brand.energy` (green)
- Auto-dismiss: 4 seconds
- Maximum 1 toasts at a time; new toasts replace the current one

### 3. Inline screen error (content failed to load)

Replaces the skeleton or list content within the screen. Used when data fetch fails but the user can retry.

**Anatomy:**
- Icon: 48dp warning or cloud-offline icon, `color.text.tertiary`
- Title: `type.title.medium`, `color.text.primary`
- Body: `type.body.medium`, `color.text.secondary`
- Retry button: Secondary Medium, centered

**Variants by error type:**

| AppError variant | Icon | Title | Body |
|----------------|------|-------|------|
| NetworkError | Cloud-offline | "No connection" | "Check your internet connection and try again" |
| ApiError (5xx) | Server icon | "Something went wrong" | Server-returned `detail` field if present |
| ApiError (4xx) | Document-warning | "Couldn't load this" | Server-returned `detail` field |
| OcppTimeoutError | Clock-alert | "Charger not responding" | "The charger didn't respond in time. Your session was not started." |

### 4. Blocking error screen

Used only for conditions that prevent the app from functioning:

**Maintenance mode** (`/error/maintenance`):
- Full-screen, `color.background`
- Large illustration: construction cone motif
- Title: "Scheduled maintenance", `type.headline.large`
- Body: expected return time if known
- "Check status" text link (tertiary, opens status page)
- No retry button — the app will resume automatically

**Account suspended** (`/error/forbidden`):
- Title: "Account restricted"
- Body: reason if server-provided
- Support contact link

**Security alert (post-DeviceIdMismatch logout):**
- Full-screen overlay with `color.errorContainer` tinted background
- Icon: 64dp shield with exclamation, `color.error`
- Title: "Security alert", `type.headline.medium`, `color.error`
- Body: "Unusual activity was detected on your account. You have been signed out for your safety."
- CTA: "Sign in again" (Primary)
- Secondary link: "Contact support"

### 5. OCPP command error (in-session)

Not a route-level error. Surfaces within the charging session screen:

- Error banner slides down from top of the charging session screen content area
- Background: `color.errorContainer`
- Left 4dp bar: `color.error`
- Message: server-returned detail or mapped OCPP error message
- Dismiss × button
- Does not block the session view or stop button

---

## 19. RTL Support

### Directionality scope

The active `Locale('fa')` sets `TextDirection.rtl` at the `MaterialApp` level. This cascades through the entire widget tree. All layout widgets that honor directionality (all standard Flutter widgets) automatically mirror.

**What mirrors automatically:**
- `Row` children order
- `EdgeInsetsDirectional` start/end → becomes right/left in RTL
- `AlignmentDirectional` → mirrors
- `TextAlign.start/end` → aligns to right in RTL
- `Icons.arrow_back/forward` and all direction-implying Material icons
- `BottomNavigationBar` tab order
- `ListView` scroll direction (still vertical — only horizontal order within rows mirrors)
- `Slider` fill direction
- `LinearProgressIndicator` fill direction

**What does NOT mirror automatically (requires explicit handling):**

| Element | Required treatment |
|---------|-------------------|
| Custom SVG icons implying direction (custom back arrow, custom chevron) | Provide RTL SVG variant OR apply `Transform.scale(scaleX: -1)` conditionally |
| Page slide transition direction | Query `Directionality.of(context)` — slide from left (RTL) vs right (LTR) |
| Session ring arc direction | Ring progress fills counter-clockwise in RTL (matches reading direction) |
| Map controls position | My Location FAB: bottom-left in RTL (mirrors from bottom-right) |
| Search bar: leading/trailing icons | Leading search icon → trailing in RTL (handled via `InputDecoration` start/end properties) |
| Shimmer animation direction | Right-to-left in RTL |
| Session mini-card layout | Fully mirrors: metrics on left, station name on right |

### Typography differences in RTL

**Always LTR regardless of locale setting:**
These elements are wrapped in an explicit `Directionality(textDirection: TextDirection.ltr)` widget and use Inter font:

- Phone number display and input
- OTP input boxes
- Station ID, connector ID, session ID, transaction ID
- All 6-digit and alphanumeric codes
- Energy values in kWh (the unit "kWh" is not translated — international standard)

**Mixed-direction text (e.g., Persian sentence with a number):**
Flutter's bidirectional text algorithm handles this automatically. Arabic/Persian characters flow RTL; numeric and Latin characters flow LTR within the RTL context. No manual intervention needed.

**Punctuation:**
ARB strings for `fa` use Persian punctuation marks where required: ، (Arabic comma), ؟ (Arabic question mark), ؛ (Arabic semicolon). The `intl` package handles these in formatted strings.

### Layout-specific RTL rules

**Cards:** The Status Card left-accent bar appears on the right side in RTL. Trailing chevrons appear on the left. All internal padding uses `EdgeInsetsDirectional`.

**Bottom sheets:** Content alignment mirrors. The sheet handle is always centered (no directionality). The primary action button (full width) is not affected.

**Bottom navigation session mini-card:**
- LTR: [Bolt icon + Station name] ──── [kWh metric] ──── [Duration + Stop button]
- RTL: [Stop button + Duration] ──── [kWh metric] ──── [Station name + Bolt icon]

**Station detail bottom sheet:**
- Connector list items: connector icon → connector type label → power label → status badge → CTA button; this entire row mirrors in RTL

**OTP screen:** OTP boxes remain LTR, centered. The surrounding UI (labels, countdown timer) is RTL. This creates a visually mixed screen — the OTP row is explicitly wrapped in an LTR container.

---

## 20. Accessibility Requirements

### Contrast ratios (WCAG 2.1)

All text/background pairings must meet the following minimums. No exception during implementation.

| Requirement | Ratio | Applied to |
|------------|-------|-----------|
| AA Normal text | 4.5:1 | `type.body.*` on any background |
| AA Large text | 3:1 | `type.headline.*`, `type.display.*` on any background |
| AA UI components | 3:1 | Input borders, button outlines, status badges |
| AAA Normal text | 7:1 | Critical information (error messages, financial values) |

**Known passing pairs (verify during implementation):**

| Foreground | Background | Ratio |
|-----------|-----------|-------|
| `#0F5EFF` (primary) | `#FFFFFF` (surface) | 5.8:1 ✓ AA |
| `#111827` (text.primary) | `#FFFFFF` (surface) | 17.6:1 ✓ AAA |
| `#111827` | `#F4F7FF` (background) | 15.2:1 ✓ AAA |
| `#FFFFFF` | `#0F5EFF` (primary button) | 5.8:1 ✓ AA |
| `#FFFFFF` | `#E53935` (error) | 4.6:1 ✓ AA |
| `#6B7280` (text.secondary) | `#FFFFFF` | 4.6:1 ✓ AA |
| `#FFFFFF` | `#059669` (status.available) | 4.5:1 ✓ AA (boundary) |

**Dark mode:** All light-mode pairs have dark-mode equivalents that must be independently verified. The lighter versions of colors used in dark mode (`#4D8FFF` for primary on `#141B2D` surface) must re-pass contrast.

### Touch target sizes

Every interactive element maintains a minimum 44×44dp touch target. Visual size may be smaller; the hit area is extended via invisible padding.

| Component | Visual size | Minimum hit area |
|-----------|------------|-----------------|
| Buttons (Large) | 56dp height | 56dp+ ✓ |
| Buttons (Medium) | 44dp height | 44dp ✓ |
| Buttons (Small) | 32dp height | 44dp (extended) |
| Tab bar items | ~48dp height | 56dp height |
| Dismiss × on banner | 24dp icon | 44×44dp area |
| Close button in sheets | 24dp icon | 44×44dp area |
| Map pin | 36×44dp | 44×44dp |
| Connector chip in filter | 32dp height | 44dp height (extended) |
| Icon buttons (40dp) | 40dp | 44dp area (extended) |

### Screen reader (TalkBack / VoiceOver)

Every interactive element must have a semantic label. Rules:

- **Icon-only buttons:** Mandatory `Semantics.label` describing the action ("My location", "Close", "Toggle map layers")
- **Station pins:** Label: "[Station name], [available count] connectors available, [distance]"
- **Session ring:** Label: "[X] kilowatt-hours delivered, [Y] minutes elapsed, [Z] cost so far. Double-tap to cycle display mode."
- **Balance display:** Label: "Current balance: [amount] [currency]"
- **Transaction items:** Label: "[Type]: [description], [amount], [date]"
- **Status badges:** Announced as part of the parent element; e.g., "Reservation confirmed, Elm Street Station, June 21 at 2pm"
- **OTP boxes:** Group labeled "Verification code, enter 6 digits"; each box labeled "Digit [N] of 6"
- **Loading skeletons:** `Semantics.label = "Loading"` on the skeleton container; individual skeleton blocks are excluded from the accessibility tree

### Motion and animation

All animations respect the system's reduced-motion preference:

| Animation | Default | Reduced motion alternative |
|-----------|---------|--------------------------|
| Session ring arc fill | Smooth continuous update | Instant update, no interpolation |
| Session ring outer glow pulse | 2s repeating pulse | Static glow, no pulse |
| Banner slide in/out | 250ms slide | Instant appear/disappear |
| Map pin selection pulse ring | 800ms expand | Static ring, no animation |
| Charging tab pulse dot | Continuous pulse | Static filled dot |
| Page transitions | Directional slide 250ms | Fade 150ms |
| Skeleton shimmer | Continuous sweep | Static flat skeleton |
| Success checkmark draw | 600ms draw animation | Instant checkmark |

All durations under 200ms are exempt from reduced-motion (below the perception threshold for motion sickness).

### Focus management

- On screen navigation: focus is set to the screen's primary heading or the first interactive element
- On bottom sheet open: focus moves to the sheet's handle or first interactive element
- On bottom sheet close: focus returns to the triggering element
- On banner appearance: a brief announcement is made to screen readers without stealing visual focus
- On error appearance: focus moves to the error message if it appears as a result of a user action (form submission)
- Modal dialogs and blocking error screens trap focus within the modal

### Language and locale

- `Semantics.attributedLabel` with the correct locale set for mixed-language content
- Number values read as numbers, not individual digits (e.g., "twelve point five kilowatt-hours")
- Currency values read with currency name ("twelve hundred yen", not "twelve zero zero")
- Date values read in the locale's natural order (day-month-year for Persian calendar)

---

*This document is the complete design system specification. No UI pattern may be introduced at implementation time that is not described here. Design deviations require an explicit update to this document before implementation proceeds.*