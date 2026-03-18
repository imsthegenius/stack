@~/Desktop/second-brain/rules/brain-sync-rule.md
# STACK — Repo Rules

## Bundle IDs
- Main app: `com.stack.app`
- Widget extension: `com.stack.app.widget`
- App Group: `group.com.stack.shared` — ALL UserDefaults must use this suite

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

## Design Tokens
```
Background:    #0C0B09  — Color(hex: "0C0B09") — everywhere, flat, no gradient
Primary text:  #F4F2EE  — StackTheme.primaryText
Secondary:     #8C8880  — StackTheme.secondaryText
Tertiary:      #4A4845  — StackTheme.tertiaryText
Ghost:         #2E2C2A  — StackTheme.ghost
Stack gold:    #C8A96E  — chip circles + earned chip borders ONLY
Milestone:     #FFFFFF  — Color.white — counter on milestone day ONLY
Separator:     #1C1B19  — StackTheme.separator
```

## Typography Rules (NO EXCEPTIONS)
- `SF Pro Thin` — hero counter (88pt) ONLY
- `SF Pro Light` — EVERYTHING ELSE
- `Georgia regular` — relay message text ONLY: `Font.custom("Georgia", size: 19)`
- FORBIDDEN: `.regular`, `.medium`, `.bold` anywhere in the app
- FORBIDDEN: `Text("...").fontWeight(.regular)` or `.fontWeight(.bold)`

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

### The Relay
- Supabase: `https://wfckqpnxnzzwbgbthtsb.supabase.co`
- Anon key: `REPLACE_WITH_SUPABASE_ANON_KEY` (see SupabaseService.swift TODO)
- Free tier: relay message is blurred with paywall overlay
- Paid tier: shows relay message in Georgia font
- After receiving: `store.receivedRelayMilestoneDays.append(days)` + `store.save()`
- Phase 2: user writes a message forward via RelayWriteView

### Widget Data Flow
- `StackStore.syncWidgetData()` writes to App Group UserDefaults and calls `WidgetCenter.shared.reloadAllTimelines()`
- Called on every `pledgeToday()`, `startNewChapter()`, and `save()`
- Widget reads: `widget_current_days`, `widget_chapter_number`, `widget_total_days`, `widget_is_milestone_today`, `widget_pledged_today`, `widget_milestone_label`
- Widget background: `.containerBackground(.clear, for: .widget)` — NEVER #0C0B09

## RevenueCat TODO Locations
- `Views/Paywall/PaywallView.swift` — currently uses StoreKit directly, TODO comments mark where to swap in RevenueCat
- `App/STACKApp.swift` — `Purchases.configure(withAPIKey:)` goes in `init()`
- Product ID: `com.stack.app.lifetime`

## Supabase
- URL: `https://wfckqpnxnzzwbgbthtsb.supabase.co`
- Anonymous key placeholder: `REPLACE_WITH_SUPABASE_ANON_KEY`
- Run `supabase/schema.sql` then `supabase/seed.sql` in the Supabase SQL editor before testing relay

## What NOT To Do
- No confetti, particle effects, or celebration animations
- No "You're amazing!" or wellness copy
- No push notifications of any kind
- No SF Pro Regular or Bold
- No gradients
- No #C8A96E gold on the counter number (only on chip circles)
- No rounded card backgrounds in lists
- No `.ultraThinMaterial` behind the hero counter number
- No warm black (#0C0B09) widget backgrounds — use `.containerBackground(.clear)`

## Global App Setup
- `.preferredColorScheme(.dark)` on WindowGroup — non-negotiable
- `UINavigationBar.appearance()` override in `STACKApp.init()` — sets light weight for all nav titles
- `.toolbarBackground(.ultraThinMaterial, for: .navigationBar)` + `.toolbarColorScheme(.dark, for: .navigationBar)` on every NavigationStack
