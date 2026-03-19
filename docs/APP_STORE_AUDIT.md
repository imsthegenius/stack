# App Store Review Audit — STACK

**Date:** 2026-03-19
**Auditor:** Pre-submission self-review against Apple App Store Review Guidelines (Feb 2026 edition)
**App:** Stack - Daily Pledge (`com.twohundred.stack`)
**Version:** 1.0.0

---

## Summary

The relay system code is complete and builds clean. However, the app is **NOT ready for App Store submission**. There are 11 blocking issues that would result in immediate rejection, plus 8 high-priority items that need attention. This document tracks every issue, its guideline reference, and the fix status.

---

## BLOCKERS — Will be rejected

### B1. Privacy policy has placeholder email
- **Guideline:** 5.1.1(i), 2.1 (completeness)
- **File:** `privacy-policy.html` line 128
- **Issue:** `[CONTACT_EMAIL]` placeholder text. Apple reviewers check privacy policies. Placeholder = instant rejection.
- **Fix:** Replace with real email (e.g., `stack@twohundred.co` or similar).
- **Status:** ☐ Open

### B2. Privacy policy not hosted at a live URL
- **Guideline:** 5.1.1(i)
- **Issue:** Required in TWO places: (1) App Store Connect metadata "Privacy Policy URL" field, (2) accessible within the app. Currently just a local HTML file in repo root.
- **Fix:** Host on GitHub Pages, Vercel, or your own domain. The URL must be live and loading when the reviewer checks it.
- **Status:** ☐ Open

### B3. No privacy policy link inside the app
- **Guideline:** 5.1.1(i)
- **File:** `ios/STACK/Views/Settings/SettingsView.swift`
- **Issue:** SettingsView has version info and "No notifications" text but no link to the privacy policy. Must be tappable and open in Safari/SFSafariViewController.
- **Fix:** Add a "Privacy Policy" row in the ABOUT section of SettingsView that opens the hosted URL.
- **Status:** ☐ Open

### B4. No report button on relay messages
- **Guideline:** 1.2 (User-Generated Content)
- **Files:** `MilestoneMomentView.swift`, `TodayView.swift`
- **Issue:** The backend `reportRelayMessage()` exists in SupabaseService but ZERO UI surfaces it. No swipe-to-report, no context menu, no button. Apple requires "a mechanism to report offensive content" for any UGC feature.
- **Fix:** Add a report action on relay messages. Options: (a) long-press context menu with "Report Message", (b) small flag icon, (c) swipe action. Should call `SupabaseService.shared.reportRelayMessage(id:)`.
- **Status:** ☐ Open

### B5. No blocking/hiding mechanism for relay messages
- **Guideline:** 1.2 (User-Generated Content)
- **Issue:** Apple requires "the ability to block abusive users." Without user accounts, this must be implemented at the message level. Users need a way to never see a reported message again.
- **Fix:** Add a `blockedRelayMessageIDs: [String]` array to StackStore (persisted in UserDefaults). When a user reports a message, add its ID to this list. Filter fetched messages against this list before display.
- **Status:** ☐ Open

### B6. No content filtering on relay submissions
- **Guideline:** 1.2 (User-Generated Content)
- **Issue:** No client-side or server-side word filter. A user could submit anything — profanity, slurs, harmful content — and it goes straight to other users' screens.
- **Fix:** Add a client-side blocklist filter in RelayWriteView before submission. Check the trimmed message against a list of blocked words/patterns. Show an error if flagged. This is the minimum viable content moderation. Server-side moderation (Supabase Edge Function) is ideal for Phase 2.
- **Status:** ☐ Open

### B7. No contact/support info in the app
- **Guideline:** 1.5, 1.2
- **File:** `ios/STACK/Views/Settings/SettingsView.swift`
- **Issue:** No email, no support link, no way to reach the developer from within the app. Required for all apps, doubly required for apps with UGC.
- **Fix:** Add a "Contact" or "Support" row in SettingsView that opens a `mailto:` link or a support URL.
- **Status:** ☐ Open

### B8. Privacy policy doesn't mention RevenueCat
- **Guideline:** 5.1.1(i)
- **File:** `privacy-policy.html`
- **Issue:** The policy says "We do not use analytics, crash-reporting SDKs, advertising networks, or any third-party tracking tools." This is **false**. RevenueCat SDK collects: device identifiers (IDFV), purchase history, app version, OS version, and sends it to RevenueCat servers for entitlement management. This must be disclosed.
- **Fix:** Add a section about RevenueCat (purchase management SDK). Disclose what it collects and link to RevenueCat's privacy policy (https://www.revenuecat.com/privacy).
- **Status:** ☐ Open

### B9. Privacy policy doesn't mention relay message writing
- **Guideline:** 5.1.1(i)
- **File:** `privacy-policy.html`
- **Issue:** Section 3 says "one-way content request" — that was true before the relay write feature. Now users SUBMIT text content to Supabase. The policy must disclose that user-written text is stored on Supabase servers and displayed to other users anonymously.
- **Fix:** Update Section 3 to cover both fetching and writing relay messages. Explain that submitted text is anonymous (no user identifier attached), stored on Supabase, and shown to other users. Mention that messages can be reported and auto-removed.
- **Status:** ☐ Open

### B10. No PrivacyInfo.xcprivacy manifest
- **Guideline:** 5.1.1 (Apple's Privacy Manifest requirement, enforced since Spring 2024)
- **Issue:** Required for all apps using third-party SDKs that access "required reason APIs." RevenueCat's SDK accesses `UserDefaults`, disk space, and system boot time — all require declared reasons in a privacy manifest. Without this, App Store Connect will reject the binary during processing (before human review even starts).
- **Fix:** Create `ios/STACK/PrivacyInfo.xcprivacy` declaring:
  - `NSPrivacyAccessedAPITypes` for UserDefaults (reason: `CA92.1` — app functionality)
  - `NSPrivacyAccessedAPITypes` for disk space (reason: `E174.1`)
  - `NSPrivacyAccessedAPITypes` for system boot time (reason: `35F9.1`)
  - `NSPrivacyCollectedDataTypes` — empty (we don't collect linked data)
  - `NSPrivacyTracking` — false
  - `NSPrivacyTrackingDomains` — empty
- **Status:** ☐ Open

### B11. No App Store screenshots
- **Guideline:** 2.3.3
- **Issue:** App Store Connect requires screenshots for 6.7" (iPhone 15 Pro Max / 16 Pro Max) and 6.1" (iPhone 15 Pro / 16 Pro) at minimum. These must show the actual app, not mockups of features that don't exist.
- **Fix:** Take screenshots on simulator or device showing: (1) TodayView with counter, (2) pledged state with "Stacked.", (3) relay message (inline or fullscreen), (4) Stacks tab, (5) Journey tab. 5-6 screenshots per size.
- **Status:** ☐ Open (requires manual capture or automation)

---

## HIGH PRIORITY — Likely rejection or delayed review

### H1. No Terms of Use
- **Guideline:** Not explicitly numbered but frequently cited in rejections, especially for apps with UGC
- **Issue:** No Terms of Use / Terms of Service document exists. For an app where users submit content that other users see, ToU should cover: acceptable use, content ownership, moderation rights, liability limitations.
- **Fix:** Create a Terms of Use HTML page (can be on same host as privacy policy). Link in SettingsView and App Store description.
- **Status:** ☐ Open

### H2. Age rating needs careful selection
- **Guideline:** 2.3.6
- **Issue:** The app deals with sobriety/substance abstinence themes and has UGC. Answer the age rating questionnaire honestly. "Mature/Suggestive Themes" → "Infrequent" or "Frequent" depending on relay content. UGC presence may push to 17+.
- **Fix:** In App Store Connect, answer the age rating questions. If relay messages could reference substance use, select "Infrequent/Mild" for mature themes. With UGC, Apple may require 17+. Consider: if you implement content filtering (B6), the rating may stay at 12+.
- **Status:** ☐ Requires App Store Connect action

### H3. App Store category selection
- **Guideline:** 2.3.5
- **Issue:** "Health & Fitness" invites medical-claim scrutiny under Guideline 1.4.1. The app is NOT a medical app and must not make medical claims. "Lifestyle" is safer and equally appropriate for a daily pledge/counter tool.
- **Recommendation:** Primary category: **Lifestyle**. Secondary: **Health & Fitness** (if desired).
- **Status:** ☐ Requires App Store Connect action

### H4. IAP product must exist in App Store Connect
- **Guideline:** 3.1.1
- **Issue:** `com.twohundred.stack.lifetime` must be created in App Store Connect with status "Ready to Submit" and included with the app binary submission. If the reviewer can't purchase, rejection under 2.1. The product needs: reference name, product ID, pricing, description, screenshot.
- **Fix:** Create the Non-Consumable IAP in ASC. Set price. Add a review screenshot (the PaywallView). Set status to "Ready to Submit."
- **Status:** ☐ Requires App Store Connect action

### H5. RevenueCat is using a test API key
- **Guideline:** 2.1 (completeness)
- **File:** `ios/STACK/STACKApp.swift` line 8
- **Issue:** `Purchases.configure(withAPIKey: "test_HUKGKJUpyCSWrvkxSdPOVUrKSyy")` — test keys load sandbox data and may not resolve offerings in production. The PaywallView CTA button is disabled when `offering == nil`. If offerings don't load, the reviewer sees a broken paywall.
- **Fix:** Create a production app in RevenueCat dashboard. Get the production API key (`appl_xxxxx`). Replace the test key. Ensure the IAP product is configured in RevenueCat with the correct product ID and entitlement ("Stack Forever").
- **Status:** ☐ Open

### H6. App Privacy nutrition labels in App Store Connect
- **Guideline:** Mandatory submission requirement
- **Issue:** Must accurately declare data collection. Currently undeclared.
- **Fix:** In App Store Connect → App Privacy, declare:
  - **Purchases**: "Purchase History" — collected by RevenueCat, linked to device, used for App Functionality
  - **Identifiers**: "Device ID" (IDFV) — collected by RevenueCat, not linked to user identity
  - **User Content**: "Other User Content" — relay messages written by users, NOT linked to identity, used for App Functionality
  - **Diagnostics**: RevenueCat may collect crash/performance data
  - **Tracking**: No
- **Status:** ☐ Requires App Store Connect action

### H7. App Review notes needed
- **Guideline:** 2.1
- **Issue:** Without clear notes, the reviewer may not understand how to trigger the paywall, what the relay is, or why the app looks "empty" on Day 0.
- **Fix:** Write detailed App Review notes covering:
  - "To test the paywall: Open the app → set a start date in the past (e.g., 7+ days ago) → pledge → the MilestoneMomentView will appear with the relay message and paywall for free users."
  - "The relay feature shows anonymous messages from people who've reached the same milestone. Days 1-6 are free. Day 7+ requires the lifetime unlock."
  - "The app is behavior-agnostic — it's a daily pledge counter, not specific to any substance or habit."
  - "Relay messages are submitted anonymously to Supabase. There is no user account system."
- **Status:** ☐ Requires App Store Connect action

### H8. Widget shows lock for free users — reconsider
- **Guideline:** 4.10 (monetizing built-in capabilities)
- **File:** `ios/STACKWidget/STACKWidget.swift`
- **Issue:** Free users see a lock icon on circular/rectangular/small widgets and "Unlock STACK" on the inline widget. This could be interpreted as gating a built-in OS capability (widgets). The PAID feature is the relay — not the counter or the widget.
- **Fix:** Show the counter on ALL widgets for ALL users (free and paid). The widget is a counter — it should always show the number. The relay is the paid feature, and it doesn't appear in widgets anyway.
- **Status:** ☐ Open

---

## MEDIUM — Could cause issues

### M1. No app description written
- **Guideline:** 2.3
- **Status:** ☐ Requires App Store Connect action

### M2. No keywords selected
- **Guideline:** 2.3
- **Status:** ☐ Requires App Store Connect action

### M3. IPv6-only network not tested
- **Guideline:** 2.5.5
- **Issue:** App must work on IPv6-only networks. The Supabase URL is a hostname so DNS resolution handles it, but this should be verified.
- **Status:** ☐ Open

### M4. Supabase RLS allows unrestricted INSERT
- **Guideline:** 1.6 (data security)
- **File:** `supabase/schema.sql`
- **Issue:** `CREATE POLICY "anon_insert" ON relay_messages FOR INSERT WITH CHECK (true)` means anyone with the anon key (extractable from the binary) can INSERT arbitrary messages via the REST API, bypassing client-side filters.
- **Fix:** Add server-side constraints: (a) text length check already exists, (b) add a rate-limit via Supabase Edge Function or RLS policy with a timestamp check, (c) consider adding a basic profanity check as a Postgres function.
- **Status:** ☐ Open

### M5. No rate limiting on relay submissions
- **Guideline:** 1.6, 1.2
- **Issue:** A malicious user could flood the relay_messages table. No per-device or per-IP rate limiting exists.
- **Fix:** Add a Supabase Edge Function as a proxy for inserts, with IP-based rate limiting. Or add a client-side cooldown (e.g., one write per relay point per session).
- **Status:** ☐ Open

### M6. App description must not make medical claims
- **Guideline:** 1.4.1
- **Issue:** When writing the App Store description, avoid language like "helps you recover from addiction," "sobriety tool," "treatment." Use language like "daily pledge counter," "track your commitment," "anonymous peer messages."
- **Status:** ☐ Guidance — apply when writing description

### M7. `RevenueCatUI` still imported in SettingsView
- **Issue:** `import RevenueCatUI` is only needed for `CustomerCenterView()`. If RevenueCat doesn't have Customer Center configured, this will show a blank/error view. Verify it works or remove it.
- **Status:** ☐ Not verified

### M8. Bundle version mismatch warning
- **Issue:** Build warning: "The CFBundleShortVersionString of an app extension ('1.0') must match that of its containing parent app ('1.0.0')." Widget extension version must match the app version.
- **Fix:** Set widget's `MARKETING_VERSION` to `1.0.0` to match the app.
- **Status:** ☐ Open

---

## NOT AN ISSUE

### User accounts / signup
STACK intentionally has NO user accounts. All data is local (UserDefaults in App Group). Guideline 5.1.1(v) explicitly says "If your app doesn't include significant account-based features, let people use it without a login." No accounts = no account deletion requirement = no Sign in with Apple requirement.

### Supabase anon key in source code
Supabase anon keys are designed to be public. They are equivalent to a "public API key." Row-Level Security (RLS) policies on the table control what operations are allowed. The key being in the binary is by design.

### Dark mode only
Forcing `.preferredColorScheme(.dark)` is fine. Many apps do this. Not a review concern.

### App icon
1024x1024 PNG exists in the asset catalog. Compliant.

---

## Checklist Summary (updated 2026-03-20)

| Category | Total | Fixed | Remaining |
|----------|-------|-------|-----------|
| Blockers | 11 | 10 | 1 (B11 — screenshots) |
| High Priority | 8 | 1 | 7 (all require ASC / RevenueCat dashboard) |
| Medium | 8 | 0 | 8 |
| **Total** | **27** | **11** | **16** |

### Fixed (code + hosting)
- ✅ B1 — Privacy policy email fixed (`hello@twohundred.co`)
- ✅ B2 — Privacy policy hosted at https://imsthegenius.github.io/stack/privacy.html
- ✅ B3 — Privacy policy linked in SettingsView
- ✅ B4 — Report button on relay messages (flag icon + confirmation dialog)
- ✅ B5 — Blocked message IDs stored locally, reported messages hidden
- ✅ B6 — Client-side content filter on relay submissions
- ✅ B7 — Contact support link in SettingsView (mailto:hello@twohundred.co)
- ✅ B8 — Privacy policy now discloses RevenueCat SDK
- ✅ B9 — Privacy policy now covers relay message writing
- ✅ B10 — PrivacyInfo.xcprivacy manifest created
- ✅ H1 — Terms of Use created + hosted at https://imsthegenius.github.io/stack/terms.html
- ✅ H8 — Widget counter visible for all users (removed paywall gating)

### Remaining (requires manual action)
- ☐ B11 — Screenshots (must capture on simulator or device)
- ☐ H2 — Age rating (App Store Connect questionnaire)
- ☐ H3 — Category selection (Lifestyle primary, Health & Fitness secondary)
- ☐ H4 — IAP product creation in App Store Connect
- ☐ H5 — RevenueCat production API key (replace test key in STACKApp.swift)
- ☐ H6 — App Privacy nutrition labels in App Store Connect
- ☐ H7 — App Review notes
- ☐ M1-M2 — App description + keywords
- ☐ M4-M5 — Server-side rate limiting (nice-to-have, not a blocker)
- ☐ M7 — Verify CustomerCenterView works
- ☐ M8 — Widget bundle version alignment
