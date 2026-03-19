# App Store Fix Plan — STACK

**Ref:** `docs/APP_STORE_AUDIT.md`
**Goal:** Fix all 27 audit items so the app passes App Store review on first submission.

---

## Phase A: Privacy & Legal (Fixes B1, B2, B3, B7, B8, B9, H1)

These are document/content fixes. No complex code changes.

### A1. Fix privacy policy content
- **File:** `privacy-policy.html`
- Replace `[CONTACT_EMAIL]` with real email
- Update Section 3: disclose relay message WRITING (not just fetching)
- Add new Section: RevenueCat SDK disclosure (collects IDFV, purchase history, sends to RevenueCat servers)
- Update the "no third-party tracking" claim to be accurate
- Link RevenueCat privacy policy: `https://www.revenuecat.com/privacy`

### A2. Create Terms of Use
- **New file:** `terms-of-use.html`
- Cover: acceptable use for relay messages, content ownership, moderation rights (we can remove messages), no liability for UGC, no medical claims

### A3. Host both documents
- Push `privacy-policy.html` and `terms-of-use.html` to GitHub Pages OR deploy to a simple Vercel/Netlify site
- Result: two live URLs (e.g., `https://stack-app.twohundred.co/privacy` and `/terms`)

### A4. Add links in SettingsView
- **File:** `ios/STACK/Views/Settings/SettingsView.swift`
- Add LEGAL section with:
  - "Privacy Policy" row → opens hosted URL in `Link` or `SFSafariViewController`
  - "Terms of Use" row → opens hosted URL
  - "Contact Support" row → `mailto:stack@twohundred.co` (or whatever email)

---

## Phase B: UGC Compliance (Fixes B4, B5, B6)

Apple requires four things for user-generated content: filter, report, block, contact info.

### B1. Report button on relay messages
- **Files:** `MilestoneMomentView.swift`, `TodayView.swift`
- On the paid message view (MilestoneMomentView): add a small "Report" button or long-press context menu below the attribution line
- On inline relay (TodayView): add a long-press gesture that shows a confirmation alert → calls `reportRelayMessage(id:)`
- After reporting, show brief confirmation ("Reported. Thank you.") and hide the message

### B2. Block/hide reported messages locally
- **File:** `ios/STACK/Models/StackStore.swift`
- Add `blockedRelayMessageIDs: [String]` persisted in UserDefaults
- When a user reports a message, add its ID to this list
- In TodayView and MilestoneMomentView: after fetching a relay, check if `blockedRelayMessageIDs.contains(message.id)` — if so, fetch another or show empty state

### B3. Client-side content filter on relay submissions
- **New file:** `ios/STACK/Utilities/ContentFilter.swift`
- Simple blocklist of ~50 words (slurs, explicit terms, hate speech)
- Check relay text before submission in RelayWriteView
- If flagged: show error "Your message couldn't be sent. Please revise it."
- This is minimum viable moderation. Server-side filtering can come later.

---

## Phase C: Privacy Manifest (Fix B10)

### C1. Create PrivacyInfo.xcprivacy
- **New file:** `ios/STACK/PrivacyInfo.xcprivacy`
- Declare accessed API types:
  - `NSPrivacyAccessedAPICategoryUserDefaults` — reason `CA92.1` (app functionality)
  - `NSPrivacyAccessedAPICategoryDiskSpace` — reason `E174.1` (if RevenueCat accesses this)
  - `NSPrivacyAccessedAPICategorySystemBootTime` — reason `35F9.1` (if RevenueCat accesses this)
- Declare: `NSPrivacyTracking` = false
- Declare: `NSPrivacyTrackingDomains` = empty array
- Declare: `NSPrivacyCollectedDataTypes` = appropriate entries for RevenueCat + relay writes
- Add to STACK target in Xcode project

---

## Phase D: Widget + Build Fixes (Fixes H8, M8)

### D1. Remove widget paywall gating
- **File:** `ios/STACKWidget/STACKWidget.swift`
- All widget views currently show lock icon for free users
- Change: show the counter for ALL users, free and paid
- The widget is a counter — it shouldn't be gated. The relay is the paid feature.
- Remove all `if entry.lifetimePurchased` branches in widget views
- Remove `widget_lifetime_purchased` from StackStore.syncWidgetData() and widget provider

### D2. Fix bundle version mismatch
- In Xcode project settings: set STACKWidget target `MARKETING_VERSION` to `1.0.0` (matching the app target)

---

## Phase E: RevenueCat Production (Fix H5)

### E1. Switch to production API key
- **File:** `ios/STACK/STACKApp.swift`
- Replace `test_HUKGKJUpyCSWrvkxSdPOVUrKSyy` with production key from RevenueCat dashboard
- **Prerequisite:** Create production app in RevenueCat → add `com.twohundred.stack.lifetime` product → map to "Stack Forever" entitlement → get production API key

### E2. Verify CustomerCenterView
- **File:** `ios/STACK/Views/Settings/SettingsView.swift`
- Test that `CustomerCenterView()` from RevenueCatUI works in production. If not configured, remove the "Manage" row or replace with a simpler "Manage Subscription" link to Apple's subscription management URL.

---

## Phase F: App Store Connect Setup (Fixes H2-H4, H6-H7, M1-M2, B11)

These are NOT code changes — they're App Store Connect configuration. Documenting here for completeness.

### F1. Create IAP product
- App Store Connect → In-App Purchases → + Non-Consumable
- Reference Name: "Stack Forever - Lifetime Unlock"
- Product ID: `com.twohundred.stack.lifetime`
- Price: $6.99 (Tier 5)
- Description: "Unlock the relay. Read anonymous messages from people who've been where you are. Write one forward."
- Review screenshot: screenshot of PaywallView
- Status: "Ready to Submit"

### F2. App Privacy labels
- Declare:
  - Purchase History (RevenueCat) — linked to device, app functionality
  - Device ID / IDFV (RevenueCat) — not linked to identity, app functionality
  - Other User Content (relay writes) — not linked to identity, app functionality
  - Tracking: No

### F3. Age rating
- Answer questionnaire honestly:
  - Mature/Suggestive Themes: Infrequent/Mild
  - Unrestricted Web Access: No
  - Gambling: No
  - User-Generated Content: Yes (relay messages)
- Expected result: 12+ or 17+ depending on Apple's assessment of UGC + sobriety themes

### F4. Category
- Primary: **Lifestyle**
- Secondary: **Health & Fitness**

### F5. App description
- Write description (no medical claims)
- Include keywords

### F6. App Review notes
- Explain how to test:
  - "Set start date to 7+ days ago during onboarding to reach milestone day"
  - "Pledge by tapping the counter ring"
  - "Free users see Days 1-6 relay messages. Day 7+ shows the paywall"
  - "The relay is an anonymous peer messaging system — no user accounts"
- Explain the app is behavior-agnostic (not just alcohol)

### F7. Screenshots
- Capture on iPhone 16 Pro Max (6.7") and iPhone 16 Pro (6.1") simulators
- Screens: TodayView (Day 0), pledged state, relay message, MilestoneMomentView, Stacks tab, Journey tab
- 5-6 screenshots per size

### F8. Support URL
- Set to same domain as privacy policy (e.g., `https://stack-app.twohundred.co/support`)
- Can be a simple page with contact email

---

## Phase Order & Dependencies

```
Phase A (Privacy/Legal docs) — no code dependencies, do first
Phase B (UGC compliance) — code changes, can parallel with A
Phase C (Privacy manifest) — standalone, can parallel with A+B
Phase D (Widget + build) — standalone, can parallel
Phase E (RevenueCat prod) — needs RevenueCat dashboard setup first
Phase F (ASC setup) — needs A complete (hosted URLs), E complete (IAP product)
```

**Recommended order:** A + B + C + D in parallel → E → F → Final build + submit

---

## Estimated Effort

| Phase | Type | Effort |
|-------|------|--------|
| A | Content + simple code | ~1 hour |
| B | Code (Swift) | ~1.5 hours |
| C | Config file | ~20 minutes |
| D | Code (Swift) | ~30 minutes |
| E | Dashboard config | ~30 minutes (manual) |
| F | App Store Connect | ~2 hours (manual, includes screenshots) |

**Total code work:** ~3.5 hours
**Total manual work:** ~2.5 hours (RevenueCat dashboard, ASC setup, screenshots)
