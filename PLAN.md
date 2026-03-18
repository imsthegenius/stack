# STACK — Core Build (Phase 1: Data, Today, Journey, Stacks, Widget)


## What we're building first

The core of STACK — a sobriety counter app with a warm near-black aesthetic, chapter-based counting (no resets ever), and a lock screen widget. This phase covers the data layer, three main tabs, settings, and widget extension.

---

### **Features**

- **Chapters, not streaks** — your count never resets to zero. Starting over creates a new chapter; all previous days are kept forever
- **Today screen** — large day counter front and center, daily pledge button ("Stack today" → "Stacked.")
- **Journey screen** — full chapter history with current + past chapters, total days stacked, and a "Start new chapter" flow with confirmation
- **Stacks screen** — all 13 milestone thresholds displayed; earned ones are interactive, locked ones show "In X days"
- **Stack Card** — tapping an earned milestone opens a detail card with a share button (exports a clean image)
- **Settings screen** — widget instructions, unlock prompt (placeholder StoreKit shell), and about info
- **Lock screen widget** — 4 widget types (rectangular, circular, inline, small) that update at midnight using App Groups shared data
- **Milestone detection** — counter turns pure white on milestone days; tapping it will later open the Milestone Moment screen (Phase 2)
- **Daily pledge** — one per calendar day, persists across relaunches, resets at midnight

---

### **Design**

- **Background:** Warm near-black (#0C0B09) everywhere — no cards, no gradients
- **Typography:** SF Pro Thin for hero numbers, SF Pro Light for everything else — never Regular, never Bold
- **Colours:** Warm off-white (#F4F2EE) primary text, warm grey (#8C8880) secondary, dark grey (#4A4845) tertiary, ghost (#2E2C2A) for locked items
- **Milestone white:** Pure #FFFFFF appears only on milestone days — counter number and Stack circle stroke
- **Glass effects:** Pledge button, navigation bars, and earned Stack circles use ultra-thin material. iOS 26 `.glassEffect()` where specified (with fallback)
- **Dividers:** 0.5pt barely-visible (#1C1B19) separators — no card backgrounds
- **Layout:** 28pt horizontal padding consistently, left-aligned text
- **Dark mode only:** `.preferredColorScheme(.dark)` app-wide
- **No confetti, no celebrations, no "You're amazing!"** — quiet, earned moments only

---

### **Screens**

1. **Today (Tab 1)** — Chapter label at top, massive day counter in upper-center, "DAYS" label below, total stacked line (if multiple chapters), pledge button near bottom
2. **Stacks (Tab 2)** — Navigation list of all 13 milestones. Earned rows have glass circles with white stroke + milestone label + earned date. Locked rows are ghosted with "In X days"
3. **Stack Card (Sheet)** — Large glass circle with day number, milestone label, share button that exports a clean card image
4. **Journey (Tab 3)** — Current chapter (large), past chapters (muted), total days stacked, "Start new chapter" text button with confirmation dialog
5. **Settings (Tab 4)** — Widget setup instructions, unlock STACK row (StoreKit shell ready for real product ID), about section with privacy info

---

### **Widget**

- 4 types in one extension: Lock Screen rectangular, circular, inline, and Home Screen small
- All read from shared App Group UserDefaults — no network calls
- Timeline refreshes at midnight automatically
- Shows current days, chapter number, milestone status, and pledge state

---

### **App Icon**

- Minimal, dark icon matching the app's warm near-black aesthetic — a subtle stacked layers motif in warm off-white on the dark background

---

### **Phase 2 (next session)**

- Onboarding flow (6 screens with two paths)
- Milestone Moment screen (Relay receive + write forward)
- Supabase Relay service integration
- Paywall with StoreKit purchase flow
