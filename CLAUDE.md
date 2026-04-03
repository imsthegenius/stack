@~/Desktop/second-brain/rules/brain-sync-rule.md

## Linear Project
LINEAR_PROJECT: ""
When fetching or creating Linear tickets, ALWAYS filter by this project. Never pull tickets from other projects.
@~/Desktop/second-brain/rules/linear-workflow-rule.md
# STACK — Repo Rules

## Bundle IDs
- Main app: `com.twohundred.stack`
- Widget extension: `com.twohundred.stack.widget`
- App Group: `group.com.twohundred.stack` — ALL UserDefaults must use this suite
- App Store name: `Stack - Daily Pledge`
- iCloud container: default (uses `NSUbiquitousKeyValueStore` — no container ID needed)

## Project Structure
```
ios/STACK/
  App/             STACKApp.swift, ContentView.swift
  Models/          Chapter, Milestone, RelayMessage, StackStore
  Views/Today/     TodayView
  Views/Journey/   JourneyView
  Views/Onboarding/ OnboardingContainerView + Screen views
  Views/Stacks/    StacksView, StackCardView (+ StackExportView)
  Views/MilestoneMoment/  MilestoneMomentView, RelayWriteView
  Views/Paywall/   PaywallView
  Views/Settings/  SettingsView
  Services/        SupabaseService
  Utilities/       Theme.swift (StackTheme, StackDateFormatter, Color hex extension)
ios/STACKWidget/
  STACKWidget.swift  (all 4 widget types + TimelineProvider)
supabase/
  schema.sql       Run once in Supabase SQL editor
  seed.sql         Run once after schema
```

## Design Tokens (V4 — "Marks on Dark Stone")
```
Background:    #0C0B09  — StackTheme.background — everywhere, flat, no gradient
Surface 1:     #14120F  — StackTheme.surface1
Surface 2:     #1C1916  — StackTheme.surface2 — cards, elevated content
Surface 3:     #252220  — StackTheme.surface3 — secondary buttons, skeleton loaders
Primary text:  #FFFFFF  — StackTheme.primaryText (true white)
Secondary:     #A09890  — StackTheme.secondaryText
Ghost:         #2E2C2A  — StackTheme.ghost
Ember:         #CB6040  — StackTheme.ember — pledge ring, relay accent, active states
Milestone:     #FFFFFF  — Color.white — counter on milestone day ONLY
Separator:     #1C1B19  — StackTheme.separator
```

## Typography Rules (NO EXCEPTIONS)
- `Instrument Serif Regular` — display (38pt), title (28pt), subhead (22pt) headings ONLY
- `SF Pro Thin` — hero counter (88pt) ONLY
- `SF Pro Light` — headline (20pt)
- `SF Pro Regular` — 17pt and below (body text, labels, buttons, legal, section headers)
- `Georgia regular` — relay message text ONLY: `Font.custom("Georgia", size: 19)`
- FORBIDDEN: `.medium`, `.bold`, `.semibold`, `.heavy`, `.black` anywhere in the app
- FORBIDDEN: `Text("...").fontWeight(.bold)` or any weight heavier than `.regular`
- FORBIDDEN: Text under 13pt anywhere in the app

## Key Mechanics

### Counter
- Always computed: `Calendar.current.dateComponents([.day], from: chapter.startDate, to: Date()).day`
- NEVER stored — never increment a counter variable
- On milestone day: color turns `#FFFFFF` (pure white via `StackTheme.milestoneWhite`)
- On non-milestone day: color is `#F4F2EE` (primary text)

### Ring Pledge
- `Circle().trim(from: 0, to: pledgedToday ? 1.0 : 0.0)` overlaid on counter
- Tap anywhere in counter ZStack → `store.pledgeToday()`
- One pledge per day. Cannot undo. If already pledged, tap does nothing (except on milestone day → opens MilestoneMomentView)
- "Stacked." appears below counter after pledge

### Chapters (Never Reset)
- A new chapter = old chapter gets `endDate = today`, new Chapter created
- Old chapters are NEVER deleted — always visible in Journey
- `totalDays` = sum of all chapter daysCount

### User Accounts & Data Persistence
- Users MUST create an account. Data loss is unacceptable — someone at Day 847 switching phones must not lose their history.
- **Auth method:** Sign in with Apple (required by Apple if any third-party login is offered; use as the ONLY login method for simplicity)
- **Backend:** Supabase Auth — stores user profile (Apple ID token, anonymous display). No email/name collected unless Apple shares it.
- **Server-side storage:** Chapters, relay history, pledge history synced to Supabase `user_data` table keyed by Supabase auth user ID
- **Account deletion:** REQUIRED by Apple Guideline 5.1.1(v). Must be in-app (Settings), not "email us to delete."
- **Privacy policy:** Must be updated to reflect account creation + server-side data storage
- **When:** Account creation screen shown after onboarding, before first use. Existing iCloud KVS sync kept as fallback/supplement.
- Local: `UserDefaults(suiteName: "group.com.twohundred.stack")` — for widget access + immediate reads
- Cloud backup: `NSUbiquitousKeyValueStore.default` — kept as secondary sync layer
- `todayPledgeDate` is local-only (pledge is per-device-per-day)
- `lifetimePurchased` is local-only (RevenueCat handles cross-device purchase restoration)

### The Relay
- Supabase: `https://wfckqpnxnzzwbgbthtsb.supabase.co`
- Anon key: `REPLACE_WITH_SUPABASE_ANON_KEY` (see SupabaseService.swift TODO)
- Free tier: relay message is truncated to 15 words with paywall overlay
- Paid tier: shows relay message in Georgia font
- After receiving: `store.receivedRelayMilestoneDays.append(days)` + `store.save()`
- Phase 2: user writes a message forward via RelayWriteView

### Widget Data Flow
- `StackStore.syncWidgetData()` writes to App Group UserDefaults and calls `WidgetCenter.shared.reloadAllTimelines()`
- Called on every `pledgeToday()`, `startNewChapter()`, and `save()`
- Widget reads: `widget_current_days`, `widget_chapter_number`, `widget_total_days`, `widget_is_milestone_today`, `widget_pledged_today`, `widget_milestone_label`
- Widget background: `.containerBackground(.clear, for: .widget)` — NEVER #0C0B09

## RevenueCat
- Production API key in `STACKApp.swift`: `appl_GZCLVMbDdSbNaXDsuIJFpjafBRp`
- Product ID: `com.twohundred.stack.lifetime`
- Entitlement: `Stack Forever`

## Supabase
- URL: `https://wfckqpnxnzzwbgbthtsb.supabase.co`
- Anon key is in `SupabaseService.swift` (hardcoded, public by design — RLS controls access)
- Run `supabase/migrate-v1-to-v2.sql` then `supabase/seed.sql` before testing relay
- Auth: Supabase Auth with Sign in with Apple provider (TODO: configure in Supabase dashboard)
- User data table: `user_data` keyed by auth user ID (TODO: create schema)

## What NOT To Do
- No confetti, particle effects, or celebration animations
- No "You're amazing!" or wellness copy
- No push notifications of any kind
- No SF Pro Medium, Bold, Semibold, Heavy, or Black
- No decorative gradients (functional shimmer/glow via opacity permitted)
- No gold (#C8A96E) — use ember (#CB6040) via StackTheme.ember
- No cards-everywhere — cards only for relay messages and self-contained tappable units
- No `.ultraThinMaterial` behind the hero counter number
- No warm black (#0C0B09) widget backgrounds — use `.containerBackground(.clear)`
- No text under 13pt anywhere in the app
- No tertiaryText color — use secondaryText or primaryText

## Build Command
```bash
xcodebuild -project ios/STACK.xcodeproj -scheme STACK -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' build
```

## Global App Setup
- `.preferredColorScheme(.dark)` on WindowGroup — non-negotiable
- `UINavigationBar.appearance()` override in `STACKApp.init()` — sets light weight for all nav titles
- `.toolbarBackground(.ultraThinMaterial, for: .navigationBar)` + `.toolbarColorScheme(.dark, for: .navigationBar)` on every NavigationStack
