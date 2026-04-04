# Admin Dashboard - Visual Style Guide (Quick Reference)

## 🎨 Color Quick Reference

### Semantic Status Colors
```
🟡 AMBER-500 (#F59E0B) - Pending, Needs Review, Caution
🟢 EMERALD-500 (#10B981) - Approved, Active, Success
🔴 RED-500 (#EF4444) - Rejected, Error, Attention
🔵 BLUE-500 (#3B82F6) - Primary, Admin, Info
🟣 PURPLE-500 (#A855F7) - Secondary, Shortlisted
⚫ GRAY-500 (#6B7280) - Closed, Archived, Inactive
```

### For Backgrounds (50 or 100 variant)
```
Badge Pending: bg-amber-50 text-amber-700 border-amber-100
Badge Approved: bg-emerald-50 text-emerald-700 border-emerald-100
Badge Rejected: bg-red-50 text-red-700 border-red-100
Badge Info: bg-blue-50 text-blue-700 border-blue-100
Badge Secondary: bg-purple-50 text-purple-700 border-purple-100
Badge Neutral: bg-gray-50 text-gray-700 border-gray-100
```

---

## 📐 Spacing Cheat Sheet

```
Standard Card Padding:      p-6 (24px)
Standard Button Padding:    px-4 py-2.5
Standard Input Padding:     px-3 py-2.5
Standard Table Cell:        px-6 py-4
Between Grid Items:         gap-6
Between Sections:           mb-8
Header/Footer Inside:       px-6 py-5
```

---

## 🔤 Typography Quick Ref

```
Hero (Dashboard title):           text-2xl font-bold text-gray-900
Section Title (Card header):      text-base font-semibold text-gray-900
Body Text (Primary):              text-sm font-normal text-gray-900
Body Text (Secondary):            text-sm font-normal text-gray-600
Helper Text/Meta:                 text-xs font-normal text-gray-500
Badge Text:                       text-xs font-medium
Button Text:                      text-sm font-medium
Link Text:                        text-sm font-medium text-blue-600
```

---

## 🎪 Component Patterns

### Cards
```
<div class="bg-white rounded-lg border border-gray-200 shadow hover:shadow-lg 
            transition-shadow duration-200">
    <div class="p-6">
        <!-- Your content -->
    </div>
</div>
```

### Buttons
```
Primary:    bg-blue-600 text-white hover:bg-blue-700 px-4 py-2.5 rounded-lg
Secondary:  bg-gray-100 text-gray-700 hover:bg-gray-200 px-4 py-2.5 rounded-lg
Tertiary:   text-blue-600 hover:bg-blue-50 px-3 py-2 rounded-md
Link:       text-blue-600 hover:underline
```

### Status Badges
```
<span class="inline-flex items-center gap-1 px-3 py-1 rounded-full 
            text-xs font-medium bg-amber-50 text-amber-700 border border-amber-100">
    <span class="w-1.5 h-1.5 bg-amber-500 rounded-full"></span>
    Pending
</span>
```

### Tables
```
Header:     bg-gray-50 border-b border-gray-200 px-6 py-3
Rows:       hover:bg-blue-50 transition-colors duration-100 border-b border-gray-100
Cells:      px-6 py-4
```

---

## 🎯 Icon + Color Combinations

```
Users        👥  + Blue    (Admin management)
Jobs         💼  + Emerald (Active postings)
Applications 📄  + Amber   (Review needed)
Actions      ⚡  + Blue    (Quick access)
Status       ●   + Semantic Color
```

---

## 🚫 What NOT to Do

```
❌ Don't use more than 2 font sizes in a card
❌ Don't mix shadow and border inconsistently
❌ Don't use color alone to communicate status
❌ Don't forget padding around icons
❌ Don't make buttons smaller than 44px (touch target)
❌ Don't use more than 5 unique colors per view
❌ Don't forget hover states on clickables
❌ Don't use generic "data" or "information" labels
```

---

## ✅ Copy-Paste Templates

### Stat Card Template
```blade
<div class="bg-white rounded-lg border border-gray-200 shadow hover:shadow-lg transition-shadow duration-200">
    <div class="p-6">
        <div class="flex items-center justify-between mb-4">
            <p class="text-sm font-medium text-gray-600">Total Users</p>
            <div class="w-12 h-12 bg-blue-50 rounded-lg flex items-center justify-center">
                <i class="fas fa-users text-blue-600 text-lg"></i>
            </div>
        </div>
        <div class="mb-4">
            <div class="text-3xl font-bold text-gray-900">42</div>
        </div>
        <div class="grid grid-cols-3 gap-2 pt-4 border-t border-gray-100">
            <div>
                <p class="text-xs text-gray-500">Admins</p>
                <p class="text-sm font-semibold text-gray-900">5</p>
            </div>
        </div>
    </div>
</div>
```

### Empty State Template
```blade
<div class="px-6 py-12 text-center">
    <i class="fas fa-inbox text-gray-300 text-4xl mb-3 block"></i>
    <h3 class="text-gray-900 font-semibold mb-1">No data found</h3>
    <p class="text-gray-500 text-sm">Helpful message here.</p>
</div>
```

### Table Row Template
```blade
<tr class="hover:bg-blue-50 transition-colors duration-100">
    <td class="px-6 py-4">
        <div class="flex items-center gap-3">
            <div class="w-9 h-9 bg-gradient-to-br from-blue-400 to-blue-600 rounded-full 
                        flex items-center justify-center">
                <span class="text-xs font-semibold text-white">U</span>
            </div>
            <p class="font-medium text-gray-900">Name</p>
        </div>
    </td>
    <td class="px-6 py-4 text-sm text-gray-600">Email</td>
    <td class="px-6 py-4">
        <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full 
                    text-xs font-medium bg-blue-50 text-blue-700 border border-blue-100">
            <span class="w-1.5 h-1.5 rounded-full bg-blue-500"></span>
            Badge
        </span>
    </td>
</tr>
```

---

## 🔍 Common Tailwind Classes (Copy)

**Cards:**
```
bg-white rounded-lg border border-gray-200 shadow hover:shadow-lg transition-shadow duration-200 p-6
```

**Status Badges:**
```
inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-medium
```

**Table Headers:**
```
bg-gray-50 border-b border-gray-200 px-6 py-3 text-xs font-semibold text-gray-700 uppercase tracking-wider
```

**Hover Effects:**
```
hover:bg-blue-50 transition-colors duration-100
hover:shadow-lg transition-shadow duration-200
```

**Avatars:**
```
w-9 h-9 bg-gradient-to-br from-blue-400 to-blue-600 rounded-full flex items-center justify-center
```

---

## 📊 Breakpoint Reference

```
sm:  640px  (tablets + up)
md:  768px  (large tablets + up)
lg:  1024px (laptops + up)
xl:  1280px (large laptops + up)
2xl: 1536px (4K monitors)

Usage:
grid-cols-1 md:grid-cols-2 lg:grid-cols-4
px-4 md:px-6  (tighter on mobile, standard on desktop)
text-sm md:text-base  (smaller on mobile)
```

---

## 🎬 Animation Classes

```
transition-shadow duration-200   (Card hover)
transition-colors duration-100   (Row hover)
transition-all duration-200      (Generic transitions)
hover:scale-105                  (Slight zoom on hover)
active:scale-95                  (Button press)
animate-pulse                    (Pulsing indicator)
```

---

## 🧪 Testing Checklist

- [ ] Hover states work on desktop
- [ ] Touch targets are 44px+ on mobile
- [ ] Colors contrast 4.5:1 for text
- [ ] Icons and labels align vertically
- [ ] Spacing is consistent (multiples of 4px)
- [ ] Font sizes don't go below 14px
- [ ] No text without semantic meaning relies on color
- [ ] All interactive elements have focus outline
- [ ] Empty states display properly
- [ ] Tables don't overflow on mobile

---

## 🚀 Performance Notes

- Use Tailwind's built-in utilities (not custom CSS)
- Keep component complexity low
- Use `transition-[property] duration-[time]` for animations
- Shadow transitions are GPU-accelerated
- Border radius doesn't impact performance

---

## 📞 Support / Questions

See documentation files:
- `docs/DESIGN_SYSTEM_ADMIN.md` - Complete spec
- `docs/IMPLEMENTATION_GUIDE_ADMIN_DASHBOARD.md` - Code examples
- `docs/UX_REASONING_QUICK_REFERENCE.md` - Detailed reasoning

