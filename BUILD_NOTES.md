# STACK — Build Notes

## What was built overnight

### New files created
- `ios/STACK/Views/Today/TodayView.swift` — ring pledge + "Stacked." + MilestoneMomentView fullScreenCover
- `ios/STACK/Views/Stacks/StacksView.swift` — gold chip circles, sheet navigation, relay unread dot
- `ios/STACK/Views/Stacks/StackCardView.swift` — gold chip circle in sheet + StackExportView (ImageRenderer export)
- `ios/STACK/Views/MilestoneMoment/MilestoneMomentView.swift` — Georgia font relay, 4 states (loading/paid+message/paid+empty/free)
- `ios/STACK/Views/MilestoneMoment/RelayWriteView.swift` — Phase 2 write-forward with 500 char limit
- `ios/STACK/Services/SupabaseService.swift` — relay fetch/submit/report with 2s timeout
- `supabase/schema.sql` — relay_messages table + RLS policies + report RPC
- `supabase/seed.sql` — 40+ relay messages seeded across all 13 milestones
- `CLAUDE.md` — full repo rules and design system reference

### Existing files modified
- `ios/STACK/STACKApp.swift` — added `.preferredColorScheme(.dark)` to WindowGroup
- `ios/STACK/Views/Onboarding/OnboardingContainerView.swift` — fixed all `.medium` → `.light` weights, Screen 4 "already counting" background to #1C1B19

### Files confirmed correct (no changes needed)
- `ios/STACK/Models/Chapter.swift` — Codable, computed daysCount ✓
- `ios/STACK/Models/Milestone.swift` — all 13 thresholds ✓
- `ios/STACK/Models/RelayMessage.swift` — Codable with snake_case ✓
- `ios/STACK/Models/StackStore.swift` — @Observable, App Group suite, syncWidgetData ✓
- `ios/STACK/Utilities/Theme.swift` — all tokens, StackDateFormatter, Color hex ✓
- `ios/STACK/Views/Journey/JourneyView.swift` — confirmationDialog, correct copy ✓
- `ios/STACK/Views/Paywall/PaywallView.swift` — StoreKit, "One time. No subscription." ✓
- `ios/STACK/Views/Settings/SettingsView.swift` — minimal, correct ✓
- `ios/STACK/App/ContentView.swift` — text-only TabView, .preferredColorScheme ✓
- `ios/STACKWidget/STACKWidget.swift` — 4 types, .containerBackground(.clear), midnight refresh ✓

---

## Morning Action Items (in order)

### 1. Add new files to Xcode project
The following files were created on disk but must be added to the Xcode project:
- Open `STACK.xcodeproj` in Xcode
- Right-click each folder in Xcode → "Add Files to STACK"
- Add: `Views/MilestoneMoment/MilestoneMomentView.swift`
- Add: `Views/MilestoneMoment/RelayWriteView.swift`
- Add: `Services/SupabaseService.swift`
- Make sure "Add to targets: STACK" is checked for each

### 2. Apple Developer Account
- Register bundle ID: `com.stack.app`
- Register widget bundle ID: `com.stack.app.widget`
- Enable **App Groups** capability on both targets → add `group.com.stack.shared`
- Create development provisioning profiles for both targets
- In Xcode: Signing & Capabilities → + Capability → App Groups

### 3. Supabase Setup
- Go to: https://app.supabase.com → select project `wfckqpnxnzzwbgbthtsb`
- SQL Editor → paste and run `supabase/schema.sql`
- SQL Editor → paste and run `supabase/seed.sql`
- Go to Settings → API → copy the **anon/public** key
- Open `ios/STACK/Services/SupabaseService.swift`
- Replace `REPLACE_WITH_SUPABASE_ANON_KEY` with your actual key

### 4. RevenueCat Integration (optional — can ship with StoreKit first)
PaywallView already works with native StoreKit. To switch to RevenueCat:
- Create RevenueCat project at app.revenuecat.com
- Add product: `com.stack.app.lifetime` ($4.99 one-time)
- In Xcode: File → Add Package → `https://github.com/RevenueCat/purchases-ios-spm`
- In `STACKApp.init()`: `Purchases.configure(withAPIKey: "YOUR_KEY")`
- In `PaywallView.swift`: replace `purchaseLifetime()` body with RevenueCat purchase call

### 5. Build and Test Checklist
- [ ] Xcode clean build → zero compile errors
- [ ] Run on iOS 26 simulator → onboarding completes → Today screen shows day count
- [ ] Set chapter startDate = 365 days ago → counter turns white → tap counter → MilestoneMomentView opens
- [ ] Tap ring area when not yet pledged → ring animates around number → "Stacked." appears
- [ ] Second tap same day → no state change
- [ ] Tap ring area when already pledged on milestone day → MilestoneMomentView opens
- [ ] Journey tab → "Start new chapter" → confirmationDialog appears → confirm → Chapter 1 visible in list
- [ ] Stacks tab → gold circle on earned rows → tap earned row → StackCardView sheet opens → Share button renders image
- [ ] MilestoneMomentView (free tier) → relay message is blurred → paywall overlay visible
- [ ] MilestoneMomentView (paid/test) → Georgia font message visible → tap → RelayWriteView opens → "Send forward" posts to Supabase
- [ ] Settings → "Add to lock screen" → instructions sheet appears
- [ ] Lock screen widget → transparent background, shows current day count

---

## Known Morning Issues to Watch
- Widget won't work until App Groups capability is provisioned — will show 0 days
- Relay fetch will timeout until Supabase anon key is set (shows loading state silently)
- `MilestoneMomentView` requires `SupabaseService.swift` to be in the Xcode target — verify this in Build Phases → Compile Sources
