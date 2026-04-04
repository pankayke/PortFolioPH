# PortFolioPH Admin Dashboard - Design System

## 🎨 Design Philosophy

**Principles:**
- **Clarity First**: Information hierarchy that scannable in <3 seconds
- **Minimal Polish**: Professional without unnecessary ornamentation
- **Accessibility**: WCAG AA compliant, clear contrast ratios
- **Performance**: Smooth 60fps animations, lightweight markup
- **Consistency**: Single source of truth for all UI patterns

**Inspiration**: Stripe Dashboard, Vercel, Linear, Notion Admin Panels

---

## 📐 Color Palette

### Primary Colors
```
Blue (Primary Action)
  50:  #EFF6FF
  100: #DBEAFE
  200: #BFDBFE
  400: #60A5FA
  500: #3B82F6  ← Button base
  600: #2563EB  ← Hover
  700: #1D4ED8  ← Active
  900: #111E3D

Neutral (UI Foundation)
  50:  #F9FAFB
  100: #F3F4F6
  200: #E5E7EB
  300: #D1D5DB
  400: #9CA3AF
  500: #6B7280
  600: #4B5563
  700: #374151
  900: #111827
```

### Semantic Colors
```
Success:    #10B981 (Emerald 500) - Approved, Active, Accept
Warning:    #F59E0B (Amber 500)   - Pending, Review, Caution
Danger:     #EF4444 (Red 500)     - Rejected, Delete, Error
Info:       #3B82F6 (Blue 500)    - Information
```

### Status Badge System
```
Pending:       bg-amber-50   text-amber-700   border-amber-200
Approved:      bg-emerald-50 text-emerald-700 border-emerald-200
Rejected:      bg-red-50     text-red-700     border-red-200
Reviewed:      bg-blue-50    text-blue-700    border-blue-200
Shortlisted:   bg-purple-50  text-purple-700  border-purple-200
Active:        bg-emerald-50 text-emerald-700 border-emerald-200
Closed:        bg-gray-50    text-gray-700    border-gray-200
```

---

## 🔤 Typography Scale

### Font Family
```
Primary:   "Inter" or system sans-serif (-apple-system, BlinkMacSystemFont)
Monospace: "Fira Code" or "Monaco"
```

### Type Scale
```
Hero          - 28px | 700 (font-black)   | tracking-tight
Title/H1      - 24px | 700 (font-bold)    | tracking-tight
Subtitle/H2   - 20px | 600 (font-semibold)| tracking-tight
Section/H3    - 16px | 600 (font-semibold)| tracking-normal
Label/H4      - 14px | 600 (font-semibold)| tracking-0.5px
Body Large    - 16px | 400 (font-normal)  | leading-6
Body Default  - 14px | 400 (font-normal)  | leading-5
Body Small    - 13px | 400 (font-normal)  | leading-5
Caption       - 12px | 500 (font-medium)  | leading-4
```

### Text Color Hierarchy
```
Primary Text:   text-gray-900  (Headlines, primary content)
Secondary Text: text-gray-700  (Supporting info)
Tertiary Text:  text-gray-500  (Metadata, timestamps)
Disabled Text:  text-gray-400  (Inactive elements)
Link Text:      text-blue-600  (Interactive elements)
```

---

## 📏 Spacing System

Base unit: **4px**

```
0:    0px
1:    4px
2:    8px
3:    12px
4:    16px   ← Standard padding/margin
5:    20px
6:    24px   ← Large sections
7:    28px
8:    32px
10:   40px   ← Hero sections
```

### Component Spacing Rules
```
Card padding:        px-6 py-5 (24px horizontal, 20px vertical)
Button padding:      px-4 py-2 (16px horizontal, 8px vertical)
Input padding:       px-3 py-2.5 (12px horizontal, 10px vertical)
Table cell padding:  px-6 py-4 (24px horizontal, 16px vertical)
Header padding:      px-6 py-5 (24px horizontal, 20px vertical)
Section gap:         gap-6 (24px between elements)
```

---

## 🎯 Shadow System

```
Elevation 0:  No shadow (borders only)
Elevation 1:  shadow-sm   [0 1px 2px 0 rgba(0,0,0,0.05)]
Elevation 2:  shadow     [0 1px 3px 0 rgba(0,0,0,0.1)]   ← Default card
Elevation 3:  shadow-lg  [0 10px 15px -3px rgba(0,0,0,0.1)]  ← Modal, hover
Elevation 4:  shadow-xl  [0 20px 25px -5px rgba(0,0,0,0.1)]  ← Dropdown, popover
```

### Apply Rules
- Cards at rest:        shadow
- Cards on hover:       shadow-lg + transition
- Elevated panels:      shadow-lg
- Dropdowns/popovers:   shadow-xl
- Modals:               shadow-xl

---

## 🎪 Border Radius

```
None:    rounded-none (0px)
Small:   rounded-md   (6px)   ← Buttons, inputs, small components
Default: rounded-lg   (8px)   ← Cards, tables, standard components
Large:   rounded-xl   (12px)  ← Modals, large containers
Full:    rounded-full (9999px) ← Badges, avatars
```

### Border Color System
```
Default:    border-gray-200
Focus:      border-blue-500
Error:      border-red-500
Success:    border-green-500
```

---

## 🎬 Animation & Transitions

### Standard Motion Curves
```
Fast:      150ms  (cubic-bezier(0.4, 0, 0.2, 1))  - Small interactions
Base:      200ms  (cubic-bezier(0.4, 0, 0.2, 1))  - Standard transitions
Slow:      300ms  (cubic-bezier(0.4, 0, 0.2, 1))  - Large panels
```

### Common Animations
```
Hover elevation:     shadow transition + transform translate-y-0.5
Button press:        scale-95 duration-75
Card entrance:       fade-in + slide-up duration-200
Tooltip appear:      fade-in duration-100
Loading spinner:     rotate animation duration-1000
```

### Tailwind Config
```
transition: 'all 200ms cubic-bezier(0.4, 0, 0.2, 1)'
hover:shadow-lg + hover:scale-105 (for interactive cards)
active:scale-95 (for buttons)
```

---

## 📦 Component Specifications

### Stat Card (New Design)
```
┌─────────────────────────────────┐
│  [Icon]  Title                  │
│                                 │
│  42  ↑ 12% from last week       │
│                                 │
│  Subtitle or CTA link           │
└─────────────────────────────────┘

Structure:
- Header with icon (48x48, secondary color)
- Large number (32px, bold)
- Metric line (12px, gray-600)
- Footer action (link or small text)
- Padding: 24px (p-6)
- Border: 1px gray-200
- Shadow: shadow (default)
- Hover: shadow-lg + translate-y -0.5
```

### Status Badge
```
─────────────────────────────────
│ ● Pending  │ ● Approved │ ● Rejected │
─────────────────────────────────

Rules:
- Padding: px-3 py-1 (inline-flex items-center gap-1)
- Border: 1px + 50 alpha background
- Text: 12px font-medium
- Gap: 4px (icon to text)
- Border-radius: rounded-full
```

### Button System
```
Primary (CTA):     bg-blue-600 text-white hover:bg-blue-700 active:scale-95
Secondary:         bg-gray-100 text-gray-700 hover:bg-gray-200
Tertiary:          text-blue-600 hover:bg-blue-50
Danger:            bg-red-50 text-red-600 hover:bg-red-100

Sizing:
- Small:   px-3 py-1.5 text-sm
- Medium:  px-4 py-2.5 text-base  ← Default
- Large:   px-6 py-3 text-base

Icon + Text: gap-2 items-center (icon on left)
```

### Input Field
```
Border:     1px border-gray-300
Padding:    px-3 py-2.5 (12px h, 10px v)
Focus:      border-blue-500 ring-2 ring-blue-100
Rounded:    rounded-md
Transition: transition-all 150ms

Label:      text-sm font-medium text-gray-700 (above input)
Helper Text: text-xs text-gray-500 (below input)
Error:      border-red-500 ring-2 ring-red-100
```

### Empty State
```
┌──────────────────────────────────────┐
│                                      │
│        [Illustration or Icon]        │
│                                      │
│      No data yet                     │
│   Get started with a helpful action  │
│                                      │
│     [ Primary Action Button ]        │
│                                      │
└──────────────────────────────────────┘

Structure:
- Centered layout on full page or large card
- Icon: 64px, gray-300
- Title: 18px, bold, gray-900
- Description: 14px, gray-600, max-w-sm
- Button: Primary, below description
- Padding: py-12 (page) or p-8 (card)
```

---

## 🎨 Tailwind Configuration (tailwind.config.js)

```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: colors.blue,
        success: colors.emerald,
        warning: colors.amber,
        danger: colors.red,
      },
      spacing: {
        18: '4.5rem',
        22: '5.5rem',
      },
      fontSize: {
        xs: ['12px', { lineHeight: '16px' }],
        sm: ['13px', { lineHeight: '20px' }],
        base: ['14px', { lineHeight: '20px' }],
        lg: ['16px', { lineHeight: '24px' }],
        xl: ['20px', { lineHeight: '28px' }],
        '2xl': ['24px', { lineHeight: '32px' }],
      },
      transitionDuration: {
        250: '250ms',
      },
      animation: {
        fadeIn: 'fadeIn 200ms ease-in-out',
        slideUp: 'slideUp 200ms ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(8px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
}
```

---

## 🏗️ Layout Grid System

### Desktop (1280px+)
```
┌──────────────────────────────────────────┐
│        HEADER (full width)               │
├──────────────────────────────────────────┤
│  Sidebar (optional)  │  Main Content    │
│    280px             │    Remaining      │
│                      │  (responsive)     │
├──────────────────────────────────────────┤
│        FOOTER (full width)               │
└──────────────────────────────────────────┘

Main Container: max-w-7xl (1280px) mx-auto
Padding: px-6 (horizontal) py-8 (vertical)
```

### Tablet (768px - 1279px)
```
- Full width container
- Reduce padding to px-4
- Stack 2-column grids to 1 column
- Reduce card padding to p-4
```

### Mobile (< 768px)
```
- Full width, no max-width
- Padding: px-4
- All grids single column
- Smaller font sizes (-1 step)
```

---

## ✨ Visual Hierarchy Implementation

### Information Density
```
High Priority → Large + Bold + Color (Blue)
Medium        → Normal + Medium + Gray-700
Low           → Small + Light + Gray-500
```

### Scanning Patterns
```
Z-Pattern (for cards):
  1. Top-left:    Icon + Title
  2. Center:      Main metric
  3. Bottom:      Action/meta

F-Pattern (for lists):
  1. Column 1:    Primary info
  2. Other cols:  Supporting info
  3. Actions:     Far right
```

---

## 🎯 Quick Action Priority

**Primary Actions** (Immediate CTA):
- Blue-600, text-white
- Icon on left
- Padding: 10px 16px
- Example: "Create Job", "Review Application"

**Secondary Actions** (Optional, clear):
- Gray-100 background
- Gray-700 text
- Same size as primary
- Example: "Cancel", "Save Draft"

**Tertiary Actions** (Context menu):
- Blue-600 text only
- Hover: bg-blue-50
- Example: "View", "Edit", "Delete"

---

## 📊 Data Visualization

### Table Design
```
Header Row:
  - bg-gray-50
  - border-b border-gray-200
  - text-gray-900 font-medium
  - px-6 py-3 (table-like padding)

Data Row:
  - hover:bg-gray-50
  - border-b border-gray-100
  - px-6 py-4
  - Alternating rows: no stripe (cleaner)

Pagination:
  - Centered at bottom
  - Primary blue link color
  - Gray disabled state
```

---

## 🔔 Notifications

### Alert Positioning
```
Top-right corner
OR
Top banner (if critical)
```

### Alert Types
```
Success (Emerald):
  bg-emerald-50 border-emerald-200 text-emerald-800

Error (Red):
  bg-red-50 border-red-200 text-red-800

Warning (Amber):
  bg-amber-50 border-amber-200 text-amber-800

Info (Blue):
  bg-blue-50 border-blue-200 text-blue-800
```

---

## ♿ Accessibility Checklist

- [ ] Color contrast >= 4.5:1 for text
- [ ] Font sizes >= 14px for body text
- [ ] Button min height: 44px (touch target)
- [ ] Focus rings visible (blue-500, 2px)
- [ ] Semantic HTML (button, a, form, table)
- [ ] ARIA labels for icons
- [ ] Tab order logical and visible
- [ ] Error messages clear and associated with inputs

---

## 📋 Implementation Checklist

### Phase 1: Design System (Current)
- [x] Color palette defined
- [x] Typography scale established
- [x] Spacing system documented
- [x] Shadow system defined
- [x] Component specs created

### Phase 2: Dashboard Redesign (Next)
- [ ] Header with breadcrumbs
- [ ] Stat cards with icons
- [ ] Quick actions panel
- [ ] Recent activity sections
- [ ] Empty states

### Phase 3: Management Pages (Following)
- [ ] Users table redesign
- [ ] Jobs table redesign
- [ ] Applications table redesign
- [ ] Consistent filtering UI

### Phase 4: Component Library (Final)
- [ ] Reusable card component
- [ ] Status badge system
- [ ] Button variants
- [ ] Form components
- [ ] Empty state template

