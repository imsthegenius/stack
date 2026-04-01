# STACK — Full Redesign Plan

**Status:** Working document — plan phase before implementation
**Purpose:** Pass Apple Review (Guideline 4 typography, readability) on first try, while preserving the core aesthetic and voice
**Date:** 2026-03-31

---

## Why We're Here — The Rejection Analysis

Apple rejected twice for **Guideline 4 (Hard to read type or typography)** and **Guideline 1.1 (Objectionable content in description)**.

The Guideline 1.1 issue is an App Store Connect problem (copy, category, keywords) — already fixed outside code. This plan focuses entirely on the design and typography issues that cause Guideline 4 failures.

### What Apple's reviewers actually see

Apple review runs on a physical device under standard lighting. They tap through the app manually. What triggers Guideline 4 is not just low-contrast text — it's the overall impression of the typography system. Thin weights on small sizes. Low-contrast labels. Screens where the intent of text is unclear. The reviewer's subjective read: "Is this legible? Does it feel designed or broken?"

The current STACK design has three compounding problems:
1. **Thin-weight SF Pro is being used at sizes where it becomes illegible.** The 88pt Thin counter is fine. But any occurrence of `.thin` or `.light` below ~18pt on a dark background reads as "unfinished" to a reviewer.
2. **The warm dark background (#0C0B09) reduces perceptual contrast.** Pure white (#FFFFFF) is 4.5:1+ against it, which is fine. But #F4F2EE (primaryText) at 4:1 is borderline, and #8C8880 (secondaryText) is currently ~3:1 — which falls below the WCAG 4.5:1 requirement for text ≤17pt. The tertiaryText fix (to #8A857F) still measures at ~3.7:1 — borderline.
3. **Small labels scattered throughout.** 12pt tracking labels (CHAPTER 1, DAYS, section headers) are legal under Apple's HIG minimum (11pt), but when combined with a thin/light weight and low contrast, they compound the readability problem.

### What this plan fixes

This is not a full aesthetic overhaul. STACK's core visual identity — warm near-black background, ultra-light typography, gold chip accents, no celebration, no wellness copy — is preserved and worth keeping. What changes is precision: every text element gets an explicit contrast ratio check, every small label gets enough contrast to stand clearly, and the animation and interaction model gets systematically specified so the app feels complete rather than sparse.

---

## 1. Color System

### Current palette (with contrast ratios against #0C0B09)

| Token | Hex | Approx contrast | WCAG status for 17pt Regular |
|-------|-----|-----------------|-------------------------------|
| Background | #0C0B09 | — | — |
| primaryText | #F4F2EE | ~17.8:1 | PASS |
| secondaryText | #8C8880 | ~3.2:1 | FAIL (need 4.5:1) |
| tertiaryText | #8A857F | ~3.7:1 | FAIL (need 4.5:1) |
| ghost | #2E2C2A | ~1.4:1 | Not used for text |
| gold | #C8A96E | ~5.2:1 | PASS |
| milestoneWhite | #FFFFFF | ~19.1:1 | PASS |
| separator | #1C1B19 | ~1.2:1 | Not used for text |

**The core failure:** secondaryText (#8C8880) is used extensively for body-level labels — relay attribution, button labels, chapter subtitles, "DAYS" label, onboarding body copy. At 17pt Regular, it needs 4.5:1. At ~3.2:1 it fails.

### Revised palette

The palette philosophy stays: warm near-black, single warm neutral scale, gold accent only on chips. What changes is the floor on text contrast.

```
Background:      #0C0B09   (unchanged — the signature dark)
Primary text:    #F0EDE8   (slightly warmed down from #F4F2EE — still ~17:1, avoids clinical white)
Secondary text:  #A09890   (brightened from #8C8880 — achieves ~4.8:1 — PASS for 17pt)
Tertiary text:   #7A756F   (darkened from #8A857F — wait, see note below)
Ghost:           #2E2C2A   (unchanged — not used for text)
Gold:            #C8A96E   (unchanged — chip circles only)
Milestone white: #FFFFFF   (unchanged)
Separator:       #1C1B19   (unchanged)
```

**Note on tertiary text:** Tertiary text is used for inactive tabs, hints, dates, legal text, and timestamps. These are supplementary — never the only way to convey information. Under WCAG, "incidental" text (decorative, inactive) is exempt from contrast requirements. However, Apple's reviewer doesn't know that. The fix: use tertiaryText only for truly secondary metadata (timestamps, "Chapter 1", date ranges) where the context makes it readable. Never use it for interactive labels or instructional copy. Set tertiaryText to `#7A756F` (~3.2:1) and use secondaryText `#A09890` for anything the user needs to act on.

**Wait — contradiction caught.** If tertiary is `#7A756F` that is darker than the old value and has lower contrast. That is wrong. Let me recalculate.

Contrast formula against #0C0B09 (luminance ~0.004):
- #7A756F: luminance ~0.185 → ratio ~(0.185+0.05)/(0.004+0.05) = ~4.3:1
- #8A857F: luminance ~0.247 → ratio ~(0.247+0.05)/(0.004+0.05) = ~5.5:1

So the existing tertiaryText #8A857F is actually ~5.5:1 — which passes. The problem was the old value #4A4845, which is now fixed. The secondary text #8C8880 is the real failure.

### Revised palette (corrected)

```swift
// Theme.swift — revised values
Background:      #0C0B09   → unchanged
primaryText:     #F4F2EE   → unchanged (good contrast, good warmth)
secondaryText:   #A09890   → CHANGE from #8C8880 (gains contrast, passes 4.5:1)
tertiaryText:    #8A857F   → unchanged (already fixed, ~5.5:1 — passes)
ghost:           #2E2C2A   → unchanged
gold:            #C8A96E   → unchanged
milestoneWhite:  #FFFFFF   → unchanged
separator:       #1C1B19   → unchanged
```

**One color change only.** secondaryText goes from #8C8880 to #A09890. This is surgical. It brightens secondary labels — relay attribution, button labels, chapter subtitles, "DAYS" — to pass contrast without touching anything else.

### Color use rules (reinforced)

| Color | Must be used for | Never use for |
|-------|-----------------|----------------|
| primaryText | Counter number, headlines, body copy that conveys action | Labels that repeat nearby primary text |
| secondaryText | Relay body text, chapter subtitles, button labels, "DAYS" | Pure decorative metadata |
| tertiaryText | Dates, timestamps, legal links, "CHAPTER 1" header labels, "swipe" hint, tracking labels | Any interactive element, any instructional copy |
| ghost | Unpledged ring stroke, locked chip circles, text editor background | Text of any kind |
| gold | Chip circle stroke + number in StacksView | Counter number, any other element |

---

## 2. Typography System

### Design philosophy

The typography voice is: "carving notches into a wall." Sparse. Factual. The counter number is the one moment of scale. Everything else exists to support it without competing.

The Apple failure was not about the system concept — it was about execution at small sizes. A reviewer looking at a 12pt Thin label in warm gray on near-black will mark it "hard to read" even if it technically passes WCAG. The fix is to ensure every label reads as *intentionally minimal* rather than *accidentally illegible*.

### Typography scale — complete

| Role | Size | Weight | Color | Tracking | Notes |
|------|------|--------|-------|----------|-------|
| Hero counter | 88pt | Thin | primaryText or milestoneWhite | 0 | Never change |
| Page title | 34pt | Light | primaryText | 0 | "Journey", "Stacks", "Settings" |
| Onboarding headline | 42pt | Light | primaryText | 0 | Screen 1–3 |
| Date confirmation headline | 34pt | Light | primaryText | 0 | Screen 5A confirmation |
| Date picker headline | 28–34pt | Light | primaryText | 0 | "When did your current chapter begin?" |
| Journey day count (current) | 40pt | Light | primaryText | 0 | The hero of Journey |
| Journey day count (past) | 28pt | Light | secondaryText | 0 | Receded — it's history |
| Section overline | 12pt | Regular | secondaryText | +1.5 | "WIDGET", "ACCOUNT", "DAYS" — increase color to secondaryText |
| Body copy | 17pt | Regular | secondaryText | 0 | Onboarding paragraphs, relay attribution |
| Body copy (primary) | 17pt | Regular | primaryText | 0 | Where the user needs to act |
| Relay message | 19pt | Georgia Regular | primaryText | 0 | Unchanged — Georgia is the one serif moment |
| Button primary label | 15pt | Regular | background (on primaryText bg) | 0 | High contrast inverted |
| Button secondary label | 15pt | Regular | secondaryText | 0 | |
| Button ghost label | 13pt | Regular | tertiaryText | 0 | "Later", "Change date" |
| Settings row | 16pt | Regular | primaryText | 0 | |
| Settings row trailing | 14pt | Regular | tertiaryText | 0 | |
| Metadata / timestamps | 12pt | Regular | tertiaryText | +1.5 | Dates, chapter refs, milestone earned dates |
| Chapter overline | 12pt | Regular | secondaryText | +1.5 | "CHAPTER 1" — promote from tertiaryText |
| "Stacked." confirmation | 14pt | Regular | secondaryText | 0 | After pledge |
| Relay attribution "— from day X" | 12pt | Regular | tertiaryText | 0 | |
| Count down / countdown | 12pt | Regular | tertiaryText | 0 | "3 days until next relay" |
| Legal copy | 12pt | Regular | tertiaryText | 0 | Terms, Privacy links |
| Tab bar labels | 10pt | Regular (via UIFont) | primaryText / tertiaryText | 0 | System via UITabBarAppearance |

### Critical changes from current state

1. **"CHAPTER X" label on TodayView:** Currently uses `StackTheme.secondaryText`. This is correct and stays. The size (12pt) is fine at Regular weight.

2. **"DAYS" label below counter:** Currently 12pt Regular in `StackTheme.secondaryText`. With the secondaryText brightening to #A09890, this improves. Stays at 12pt. Add `tracking(2.0)` for air.

3. **Onboarding body copy (screen 2, 3):** Currently 17pt Regular in `StackTheme.secondaryText`. With the secondaryText fix, this passes. No size change needed.

4. **Section headers in Settings/Journey/Stacks (e.g., "WIDGET", "ACCOUNT"):** Currently 12pt Regular in `StackTheme.secondaryText`. With the color fix, these are fine. The tracking (1.5) is good.

5. **The big fix — 16pt Regular for settings rows in primaryText:** Already correct. No change.

6. **RelayWriteView write prompt (16pt Regular secondaryText):** With color fix, passes. No size change.

7. **Onboarding Page Indicator dots (5pt circles):** Not text — exempt from contrast rules. Keep.

8. **`Font.custom("Georgia", size: 18)` in RelayWriteView placeholder:** The placeholder uses `StackTheme.ghost` (#2E2C2A) for color. Against the ghost background (#2E2C2A background of the TextEditor), this is ~1:1 — invisible. Fix: placeholder text should use `StackTheme.tertiaryText` (#8A857F), not ghost. This is a legibility bug.

### What does NOT change

- SF Pro Thin for the 88pt counter. This is the core visual identity and at 88pt is perfectly legible.
- SF Pro Light for 18pt+ titles and headers.
- SF Pro Regular for 17pt and below.
- Georgia Regular (19pt) for relay messages. This is a deliberate serif moment — distinctive, warm, different register.
- No Bold, Semibold, Medium, Heavy, Black anywhere.

### Dynamic Type

Every view must support Dynamic Type. The current implementation uses fixed `font(.system(size: N, weight: W))` which does NOT scale with Dynamic Type. This needs to be addressed carefully — we cannot just swap to `.body` style names because our weight constraints wouldn't apply.

**Approach:** Use `font(.system(size: N, weight: W, design: .default))` combined with `.dynamicTypeSize(.xSmall ... .accessibility3)` to allow scaling within a capped range. For the hero counter, set `.dynamicTypeSize(.large ... .accessibility1)` to allow modest scaling without breaking layout.

**Exception:** The 88pt hero counter should NOT scale with Dynamic Type — it's a graphic element. Use `.dynamicTypeSize(.large)` to fix it.

---

## 3. Microanimation Spec

The app voice is spare and factual. Animations must serve meaning — not decoration. Every animation in this spec has a reason.

### Animation principles for STACK

1. **One high-impact moment per screen transition.** Not a cascade of animated elements.
2. **Duration ceiling: 0.5s.** Anything longer feels slow for a utility app.
3. **Spring over easing.** Spring physics feel more alive than cubic ease curves.
4. **Haptics paired with every meaningful state change.** The pledge tap, the ring completing, sending a relay forward — each gets a haptic.
5. **Reduce Motion respected.** When `@Environment(\.accessibilityReduceMotion)` is true, replace all positional animations with opacity fades only.

### TodayView — Pledge sequence

This is the most important interaction in the app. It must feel earned without feeling celebratory.

**Current state:** Ring animates with `.easeInOut(duration: 0.6)`. Number transitions with `.contentTransition(.numericText())`. "Stacked." appears. Light haptic.

**Proposed sequence:**

```
T+0.0s  User taps counter
         → .impactOccurred(style: .light) — immediate, before animation
         → pledgedToday = true
         → Ring begins filling: Circle().trim animated with .spring(duration: 0.5, bounce: 0.15)
           from 0 to 1.0, rotating from -90°

T+0.2s  "Stacked." fades in: .opacity transition with .easeIn(duration: 0.25)
         (delayed by 0.2s to not compete with ring)

T+0.5s  If relay day: "Loading relay message..." fades in with .opacity

T+2.0s  Relay message appears: .asymmetric(
           insertion: .opacity.combined(with: .offset(y: 8)),
           removal: .opacity
         ) — message slides up 8pt while fading in
```

**On Reduce Motion:** Ring fills instantly (no animation). "Stacked." appears instantly. Relay message fades in only (no offset).

**Haptic on milestone day:** When `store.isMilestoneDay` and user pledges, use `.impactOccurred(style: .medium)` — slightly heavier to mark the milestone.

### TodayView — Counter number

The `.contentTransition(.numericText())` is already specified. Keep it. It applies when the day count changes (e.g., at midnight, or after debug day picker). This is the correct iOS-native transition.

**Enhancement:** When the view appears for the first time in a session, the counter number fades in over 0.3s with a very subtle scale from 0.97 to 1.0. This uses `@State private var counterDidAppear = false` + `.scaleEffect(counterDidAppear ? 1.0 : 0.97)` + `.opacity(counterDidAppear ? 1.0 : 0.0)`. Triggered in `.onAppear` with a 0.1s delay.

### TodayView — Relay message reveal (inline)

After the relay fetch completes, the Georgia-font message must feel significant — not just a text appearing.

```swift
// The transition already defined: .opacity.combined(with: .move(edge: .bottom))
// Enhance to: asymmetric with offset-up entrance
.transition(.asymmetric(
    insertion: .opacity.combined(with: .offset(y: 12)),
    removal: .opacity
))
// Duration: 0.35s
// Delay: 0.1s after relayLoading goes false
```

### Onboarding — Page transitions

**Current state:** Swipe gesture calls `withAnimation(.smooth)` which is a system default. This is fine but generic.

**Proposed:** Replace `.smooth` with `.interactiveSpring(response: 0.38, dampingFraction: 0.82)` for the page transition. The pages slide rather than just switching — this requires converting the page switch from a conditional `Group` to a `TabView` with `.tabViewStyle(.page(indexDisplayMode: .never))` for proper gesture tracking.

**Alternative if TabView creates layout issues:** Keep the current gesture approach but use `matchedGeometryEffect` on the page content to create a cross-fade with a slight rightward shift on advance, leftward on retreat.

**Page indicator:** The 5pt circles are correct. They should animate when the active index changes:
- Active dot: 6pt width (slight scale-up), primaryText color
- Inactive dot: 5pt, ghost color
- Transition: `.spring(duration: 0.25, bounce: 0.3)`

### Onboarding — CTA button

The primary CTA button ("Starting today", "Let's go", "Start stacking") should have a subtle press state:

```swift
.scaleEffect(isPressed ? 0.98 : 1.0)
.animation(.spring(duration: 0.2, bounce: 0), value: isPressed)
```

Use a `ButtonStyle` that tracks the press state. This is a standard interaction pattern that makes the UI feel responsive.

### Stacks — Earned milestone reveal

When a user earns a new milestone (the day count crosses a milestone day), the newly-earned row should briefly pulse:

**Current state:** No animation on earn.

**Proposed:** When a row transitions from locked to earned state, use:
```swift
.symbolEffect(.bounce, value: isNewlyEarned)
```
On the gold circle, a single `.bounce` effect. This is subtle — one beat, no repetition.

The detection: track `@AppStorage("lastSeenEarnedMilestone")` and compare to `store.currentDays`. If a new milestone was earned since last app launch, flag it. Clear on view appear.

### Journey — Chapter row

No animation proposed for the Journey list. Static is correct here — this is a record, not an action space.

**Exception:** The "Start new chapter" button press should use the same `ButtonStyle` press scale as onboarding CTAs.

### MilestoneMoment — Relay message entrance

This is the highest-stakes screen. The relay message arriving needs to feel earned and momentous without resorting to particle effects.

**Sequence:**

```
Screen appears (fullscreen cover transition — system default)

T+0.0s  Header label ("CHAPTER 1 · 30 DAYS") fades in: .opacity, 0.3s
T+0.5s  Loading indicator shows: "·  ·  ·" — animate opacity with
          .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
          (already implemented — good)

When fetch completes (typically 0.5–1.5s):
T+X     Message block fades in:
          .opacity combined with .offset(y: 10)
          duration 0.4s, spring with slight bounce

T+X+0.2s "Tap to leave one for the next person →" fades in: .opacity 0.3s
T+X+0.5s "Take your time." fades in at bottom: .opacity 0.3s
```

**The "·  ·  ·" loading state:** The current animation pulsates indefinitely. Add a slow brightness animation to the dots rather than just opacity — this feels more alive without being distracting. Use `PhaseAnimator([0.3, 1.0, 0.3], content: { opacity in ... })` with 0.9s phases.

### RelayWriteView — Sent forward

After submit, "Sent forward." replaces the button text. Currently there's a `.easeInOut(duration: 0.4)` animation.

**Enhancement:** Add a `.sensoryFeedback(.success, trigger: sentForward)` for a success haptic pattern. The "Sent forward." state change currently animates the button label. Also animate the TextEditor fading to reduced opacity (0.3) to signal it's frozen.

### Tab bar transitions

The system tab bar switches are instant by default. No custom tab transition animation. The floating glass capsule in iOS 26 handles this naturally. Do not fight the system.

---

## 4. Screen-by-Screen Design Direction

### TodayView

**Current state:** Functionally complete and well-designed. The counter, ring, pledge confirmation, relay message, and multi-chapter footer all work.

**Problems:**
- "Loading relay message..." (13pt secondaryText) is used for loading state text — with the color fix this is fine.
- "Relay message available." (13pt tertiaryText) — this is the locked relay label. With tertiaryText at #8A857F (~5.5:1), fine.
- The "Unlock STACK" button (13pt secondaryText + lock icon) inside the locked relay state — this needs the secondaryText color fix. After fix: passes.
- "CHAPTER 1" tap target: Currently a small text button. It needs minimum 44pt height. Currently has only the text height plus 16pt padding. Add explicit `.frame(minHeight: 44)` to the button's content shape.

**Proposed changes:**
1. Brighten secondaryText (color fix propagates everywhere)
2. Ensure "CHAPTER X" button has 44pt minimum touch target
3. Apply counter appear animation (scale + fade on first appear)
4. Relay message entrance animation (offset + fade)
5. Remove the countdown "X days until next relay" — this is noise on an already spare screen. The user doesn't need to know. If kept, make it tertiaryText at 11pt with tracking.

**Layout stays:** VStack with Spacer above and below the counter block. Counter centered. Information below. Nothing moves.

**What does NOT change:** The counter circle size (200pt diameter), the ring thickness (1pt stroke), the counter number size and weight, the "Stacked." confirmation copy, the Georgia relay message, the chapter tap-to-Journey link.

### Onboarding — Full Screen Direction

The onboarding is 5 screens + an optional sign-in screen after setup. The flow is:

```
Screen 1: "Every day counts." — hook
Screen 2: "No resets. Ever." — differentiator
Screen 3: "Messages at milestones." — relay explanation
Screen 4: "Where are you?" — path split (new vs existing)
Screen 5A: Date picker (new users)
Screen 5B: History import (existing users)
```

**Voice corrections needed:**

Screen 1 body copy (17pt secondaryText):
- Current: "Whether this is Day 1 or Day 847 — nothing disappears."
- Current: "Nothing resets. It all stacks."
- Keep. This is good. Behavior-agnostic. The writing is right.
- "I already have an account" button: 13pt tertiaryText. With color fix, fine. Touch target: needs `.frame(minHeight: 44)`.

Screen 2 (the example block):
- "Chapter 1  ·  127 days  ·  Mar 2023 – Jul 2023" — 13pt tertiaryText
- "Chapter 2  ·  currently at Day 847" — 13pt tertiaryText
- "974 days stacked" — 13pt tertiaryText
- With the tertiaryText fix, these are fine. They're supplementary data.

Screen 3:
- Current: "At certain days, a short anonymous message appears."
- Current: "Written by someone who reached that number before you."
- Current: "When you're ready, you leave one for the next person."
- All good. Behavior-agnostic. Honest about the relay.
- "Your first week of messages is free. After that, one payment unlocks the relay forever." — 15pt tertiaryText. This works. It's factual.

Screen 4 ("Where are you?"):
- CTA buttons: "Starting today" (primaryText inverted) and "I'm already counting" (secondaryText on separator bg)
- The separator background (#1C1B19) on the "I'm already counting" button: text color secondaryText (#A09890 after fix). Contrast of #A09890 against #1C1B19: luminance ratio ~4.1:1. Borderline. Fix: use ghost (#2E2C2A) as the button background for better contrast, or use secondaryText text against ghost background — ratio ~3.9:1. Still marginal. **Better fix:** use primaryText (#F4F2EE) text on ghost background (#2E2C2A). Ratio ~12:1. Clear legibility. This maintains the visual hierarchy (primary CTA = inverted, secondary CTA = ghost).

Screen 5A — date picker:
- Headline: "When did your current chapter begin?" — 34pt Light primaryText. Correct. (Already fixed from the old "When did you last drink?")
- Subtitle: "Or tap below if today is Day 1." — 16pt Regular secondaryText. With color fix, passes.
- DatePicker wheel in dark mode. System component — Apple controls legibility here.
- "Sign in after setup to back up your progress." — 12pt tertiaryText. With fix, fine. This is supplementary.

Screen 5B — history import:
- "Let's bring it all." — 34pt Light primaryText. Good.
- "CURRENT CHAPTER" section header — 12pt Regular tertiaryText. This is a label, not body copy — fine.
- DatePicker row — system component. Good.
- Toggle "I have previous chapters" — 15pt Regular secondaryText. With fix, fine.

**New onboarding element to add:** A subtle progress indicator replacement. The current 5pt dot page indicator is fine. Consider upgrading to a 1pt horizontal line that extends from left-to-right as the user advances — more editorial, more "notch on a wall." Implementation:

```swift
GeometryReader { geo in
    Rectangle()
        .fill(StackTheme.ghost)
        .frame(height: 1)
    Rectangle()
        .fill(StackTheme.primaryText)
        .frame(width: geo.size.width * CGFloat(currentPage + 1) / 4.0, height: 1)
        .animation(.spring(duration: 0.4, bounce: 0.1), value: currentPage)
}
.frame(height: 1)
.padding(.horizontal, 28)
```

This replaces the 5pt dot array with a single continuous progress line — much more "notch" than dots.

**Alternatively:** Keep dots, they're understated enough. The line is optional and may cause confusion about whether the bar means "time remaining" or "progress." Decision: keep dots but animate them more crisply (scale + color, spring physics).

### Stacks

**Current state:** Clean list of milestones — earned (gold circle + label) vs locked (ghost circle + countdown).

**Problems:**
- Earned row: label is 16pt Regular primaryText. Good.
- Earned row subtitle (date + chapter): 12pt Regular tertiaryText. With fix, good.
- Locked row: label is 16pt Regular tertiaryText. This is an issue — at 16pt, it's fine contrast-wise (#8A857F is ~5.5:1) but feels underpowered compared to earned rows. **Proposal:** keep locked labels at tertiaryText but add `opacity(0.7)` to the entire locked row to visually fade it without changing color tokens.
- The gold circle stroke (1.5pt) contains the milestone shortlabel at 15pt Regular gold. #C8A96E against #0C0B09: ~5.2:1. Passes. Good.
- Separator padding: `.padding(.leading, 80)` creates an indent that aligns with the text. This is correct and stays.

**New direction for StacksView:**
- Remove the NavigationStack's navigation title — it's already empty. Good.
- The "Stacks" heading at top (34pt Light) is inside a ScrollView. On scroll, it disappears behind the ultra-thin nav bar. This is fine — the title context is clear.
- Consider: the "In X days" countdown text on locked rows could be removed. It's information the user didn't ask for — they can count. Alternatively, keep it but only show it for milestones within 30 days of the user's current count (nearby milestones only), hiding far-future ones. This reduces visual noise without losing utility.

**StackCardView (the sheet on tapping an earned milestone):** Not read in detail — but the same color and typography rules apply. Ensure any text uses the updated secondaryText color.

### Journey

**Current state:** Vertical list of chapters. Current chapter has larger day count (40pt Light) and a "Since" date. Past chapters show 28pt Light secondaryText.

**Analysis:** This is the best-executed screen in the app. The visual hierarchy (current chapter = large, past = receded) is exactly right. The "Start new chapter" button at bottom uses tertiaryText — correct, it's a destructive-adjacent action that shouldn't be prominent.

**Problems:**
- "Since {date}" is 12pt Regular tertiaryText — with fix, passes.
- The total "X days stacked" at bottom is 15pt Regular secondaryText — with fix, passes.
- "Across X chapters" is 12pt Regular tertiaryText — fine.

**What changes:**
- Nothing structural. The screen is correct.
- Apply the secondaryText color fix.
- Ensure "Start new chapter" has a `.frame(minHeight: 44)` on its content shape.

**One addition:** When `store.totalDays` is a significant number (e.g., 365+), consider a moment of acknowledgment in the Journey footer. Not "You're amazing!" — something factual: "All of it counts." or simply the number displayed larger. Spec: if `store.totalDays >= 365`, display the total days at 28pt Light primaryText with "days total" at 14pt Regular tertiaryText, replacing the current 15pt secondaryText layout. This is a reading moment, not a celebration.

### Settings

**Current state:** Section list with headers, rows, toggles. Clean.

**Problems:**
- Section headers ("WIDGET", "STACK", "ACCOUNT") are 12pt Regular secondaryText with tracking 1.5. With color fix, fine. These are labels — they guide rather than instruct.
- Settings row titles (16pt Regular primaryText) are correct.
- Settings row trailing items (12–14pt Regular tertiaryText) are correct.
- "No notifications. No streaks. No social." — 13pt Regular secondaryText. This is the app's ethos in three phrases. With color fix, it's readable. It could go to primaryText to give it more presence — but that may feel like bragging. Keep secondaryText. It's a quiet statement.

**What changes:**
- secondaryText color fix propagates.
- The About section "Version X" + "No notifications..." block: consider adding a small `StackTheme.separator` line before the About section content begins, to visually ground the section.

**Debug section:** Invisible in release. Fine.

### PaywallView

**Current state:** Clean. "The relay." headline, body description, price, unlock button, restore, legal.

**Problems:**
- "The relay." — 34pt Light primaryText. Correct.
- Body copy — 17pt Regular secondaryText. With fix, passes.
- Price line — 15pt Regular tertiaryText. With fix, fine.
- "Unlock STACK" button — 15pt Regular background-colored on primaryText background. Inverted — always passes.
- "Restore purchases" — 13pt Regular tertiaryText. With fix, passes. Needs `.frame(minHeight: 44)` touch target.
- Legal links — 12pt Regular tertiaryText. These are exempt from contrast as incidental/decorative. But the underline makes them interactive — at 12pt, they need 4.5:1. With tertiaryText fix (#8A857F, ~5.5:1): passes.

**What changes:**
- secondaryText color fix.
- Ensure restore button has `.frame(minHeight: 44)`.
- Consider: the paywall has no visual element beyond text. For a screen that needs to convert, it should feel confident — not empty. Proposal: add a very subtle decorative element above "The relay." — a single horizontal line at full width, 0.5pt, in ghost color. This anchors the headline visually. It's one mark on the wall.

**Copy note:** "The relay." as a heading is good. "Anonymous messages from people who reached the same milestones." is correct. The paywall has previously flagged tension — it must convert but can't be gimmicky. The current copy is factual and respects the app voice. Keep it exactly as-is.

### MilestoneMomentView (fullscreen relay)

**Current state:** Fullscreen dark cover. Header label, loading dots, Georgia message block, footer "Take your time."

**The message block:** Uses `StackTheme.separator` (#1C1B19) as background of the inner VStack. Georgia text (19pt Regular primaryText) on this near-black surface. Contrast: #F4F2EE against #1C1B19 is ~15:1. Passes easily.

**Problems:**
- The `clipShape(RoundedRectangle(cornerRadius: 8))` creates a subtle card — it's the only "card" in the app. This is intentional here as the relay message is a distinct object. The rounded rect at 8pt is fine. But it may conflict with the "no rounded card backgrounds in lists" rule. **Ruling:** This is not a list — it's a fullscreen cover with a single content block. The rounded rect at 8pt serves as a message container, not a list card. Keep it, but consider whether the background at separator color provides enough distinction from the background. #1C1B19 against #0C0B09: luminance contrast ~1.2:1 — almost invisible. The card effectively disappears. **Fix:** Increase the block background to ghost (#2E2C2A) for better definition. Contrast of primaryText (#F4F2EE) against ghost (#2E2C2A) is ~12.5:1. The card is visible and legible.
- The "truncatedText" in freetierView uses `StackTheme.tertiaryText` (#8A857F) for a blurred/locked relay message. Against separator background (#1C1B19 — proposed to become ghost #2E2C2A): contrast ~4.2:1. Borderline at 19pt Georgia. At 19pt it qualifies as "large text" (18pt threshold) so the requirement is 3:1. Passes.
- The freetierView "Unlock STACK" button inside the separator/ghost block: standard inverted button. Fine.

**Proposed changes:**
- Change message block background from separator (#1C1B19) to ghost (#2E2C2A) for better card definition
- Apply the relay entrance animation (offset + fade sequence)
- Add `.sensoryFeedback(.impact, trigger: isLoading)` — subtle haptic when the message reveals (when isLoading goes from true to false)

### RelayWriteView

**Current state:** TextEditor with Georgia placeholder, character counter, send button.

**Problems:**
- Placeholder text uses `StackTheme.ghost` (#2E2C2A) as the text color, against the TextEditor background of ghost (#2E2C2A). This is 1:1 contrast — invisible. **This is a bug.** The placeholder is invisible against the editor background.
- **Fix:** Change placeholder text color to `StackTheme.tertiaryText` (#8A857F). Against ghost background (#2E2C2A): ~4.1:1. Fine at 18pt Georgia.
- The "Send forward" button uses separator (#1C1B19) as background with primaryText text. This is very low contrast. Contrast of primaryText against separator: ~15:1 text-to-bg — but the button itself is nearly invisible (separator on background is invisible). **Fix:** Change the send button background to ghost (#2E2C2A). This makes the button visible as a distinct surface.
- The character counter "500" → "482" (counting down) at 12pt Regular tertiaryText: with fix, passes.

**Proposed changes:**
- Placeholder color: ghost → tertiaryText
- "Send forward" button background: separator → ghost
- Add `.sensoryFeedback(.success, trigger: sentForward)`
- When `sentForward` is true, fade TextEditor to 0.3 opacity

### SignInView (Auth)

Not read in detail but the same rules apply. Sign in with Apple button should use the system `SignInWithAppleButton` style, which is Apple-managed and passes review by default.

---

## 5. Component Patterns

### Button primary (inverted)

```swift
struct StackPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            ZStack {
                StackTheme.primaryText
                Group {
                    if isLoading {
                        ProgressView().tint(StackTheme.background)
                    } else {
                        Text(title)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(StackTheme.background)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)  // 52pt for comfortable touch target
            .clipShape(.rect(cornerRadius: 12))
            .opacity(isDisabled ? 0.4 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(StackPressButtonStyle())
    }
}

struct StackPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(duration: 0.2, bounce: 0), value: configuration.isPressed)
    }
}
```

Current buttons use 16pt padding around 15pt text = 46pt minimum height. This passes (44pt minimum). Keep current approach — no need to create a new component for this pass. Add `.frame(minHeight: 52)` where missing.

### Button secondary (ghost)

```swift
// Ghost background, primaryText foreground
.background(StackTheme.ghost)
.foregroundStyle(StackTheme.primaryText)
```

This replaces the current pattern of separator background for secondary buttons (which is nearly invisible).

### List row

Pattern: `HStack { content; Spacer(); trailing }` at 28pt horizontal padding, 16pt vertical padding. Separator is 0.5pt separator color, full width with 28pt horizontal padding. This pattern is correct and consistent. Keep.

### Section header (overline)

```swift
Text("SECTION NAME")
    .font(.system(size: 12, weight: .regular))
    .tracking(1.5)
    .foregroundStyle(StackTheme.secondaryText)  // promoted from tertiaryText
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 28)
    .padding(.top, 16)
    .padding(.bottom, 8)
```

**Change:** Section headers were tertiaryText. Promote to secondaryText. At 12pt Regular, the contrast was always fine, but this makes section structure more readable at a glance — important for Apple's reviewer scanning the Settings screen.

### Tab bar

The tab bar uses custom labels via `UITabBarAppearance`. The current label setup is `UIFont.systemFont(ofSize: 10, weight: .regular)`. The icons should use `.light` symbol weight to match typography.

For iOS 26 (Liquid Glass): The floating glass capsule tab bar will adopt automatically. Do not set a custom tab bar background. Let the system handle the glass material. This is correct for the aesthetic — the dark glass tab bar against #0C0B09 will be subtle and appropriate.

**Tab icons:** Use `.light` font weight for all SF Symbol tab icons:
```swift
Image(systemName: "circle.dotted")
    .environment(\.symbolRenderingMode, .monochrome)
    .font(.system(size: 24, weight: .light))
```

### Loading state

The `ProgressView()` with `.tint(StackTheme.background)` (for inverted loading) and `.tint(StackTheme.tertiaryText)` (for muted loading) is correct. The relay "·  ·  ·" loading text is the bespoke STACK loading pattern — keep it for the MilestoneMomentView where it fits the wait moment.

### Empty state

Use `ContentUnavailableView` (iOS 17+) for truly empty states. STACK doesn't have many true empty states — the Journey always has at least one chapter, StacksView always shows milestones. The only real empty state is the relay pool ("You're the first to reach X in STACK.") which is already handled in `emptyPoolView`. Keep as-is.

---

## 6. Accessibility — Apple Review Pass Checklist

This section is the direct answer to "what ensures we pass Guideline 4."

### Contrast ratios (after color fix)

| Element | Text color | Background | Ratio | WCAG req (17pt Regular) | Status |
|---------|-----------|------------|-------|------------------------|--------|
| Counter number | #F4F2EE | #0C0B09 | ~17.8:1 | 4.5:1 | PASS |
| Onboarding headline | #F4F2EE | #0C0B09 | ~17.8:1 | 3:1 (large) | PASS |
| Page title 34pt | #F4F2EE | #0C0B09 | ~17.8:1 | 3:1 (large) | PASS |
| Body copy 17pt | #A09890 | #0C0B09 | ~4.8:1 | 4.5:1 | PASS |
| Settings row 16pt | #F4F2EE | #0C0B09 | ~17.8:1 | 4.5:1 | PASS |
| Settings trailing 14pt | #8A857F | #0C0B09 | ~5.5:1 | 4.5:1 | PASS |
| Section headers 12pt | #A09890 | #0C0B09 | ~4.8:1 | 4.5:1 | PASS |
| Journey day count | #F4F2EE | #0C0B09 | ~17.8:1 | 3:1 (large) | PASS |
| Journey day past | #A09890 | #0C0B09 | ~4.8:1 | 3:1 (large) | PASS |
| Timestamps / dates | #8A857F | #0C0B09 | ~5.5:1 | 4.5:1 | PASS |
| "Stacked." | #A09890 | #0C0B09 | ~4.8:1 | 4.5:1 | PASS |
| Georgia relay 19pt | #F4F2EE | #2E2C2A | ~12.5:1 | 3:1 (large) | PASS |
| Relay attribution 12pt | #8A857F | #0C0B09 | ~5.5:1 | 4.5:1 | PASS |
| Relay placeholder 18pt | #8A857F | #2E2C2A | ~4.1:1 | 3:1 (large) | PASS |
| Gold chip label 15pt | #C8A96E | #0C0B09 | ~5.2:1 | 4.5:1 | PASS |
| Legal links 12pt | #8A857F | #0C0B09 | ~5.5:1 | 4.5:1 | PASS |
| Paywall body 17pt | #A09890 | #0C0B09 | ~4.8:1 | 4.5:1 | PASS |
| "Unlock STACK" button | #0C0B09 | #F4F2EE | ~17.8:1 | 4.5:1 | PASS |

**All elements pass with the single secondaryText change (#8C8880 → #A09890).**

### Touch targets

Minimum 44x44pt. Elements to audit:

| Element | Current height | Fix needed? |
|---------|---------------|-------------|
| "CHAPTER X" button (TodayView) | ~28pt text | Add `.frame(minHeight: 44)` |
| "I already have an account" (Onboarding) | ~28pt text | Add `.frame(minHeight: 44)` |
| "Start new chapter" (Journey) | `padding(.vertical, 14)` + 14pt text = 42pt | Add `.frame(minHeight: 44)` |
| "Restore purchases" (Settings/Paywall) | `padding(.vertical, 12)` + 13pt text = 38pt | Add `.frame(minHeight: 44)` |
| "Later" (RelayWriteView) | `padding(.vertical, 12)` + 13pt text = 38pt | Add `.frame(minHeight: 44)` |
| Counter ZStack (200pt circle) | 200pt | PASS |
| Primary CTA buttons | `padding(.vertical, 16)` + 15pt text = 47pt | PASS |
| Settings rows | `padding(.vertical, 16)` + 16pt text = 48pt | PASS |

### VoiceOver

The counter already has `.accessibilityLabel("Day X, pledged")` / `"Day X, tap to pledge"` and `.accessibilityAddTraits(.isButton)`. This is correct.

Additional VoiceOver labels needed:
- Onboarding page indicator dots: `.accessibilityLabel("Page X of 4")`
- Earned milestone rows: `.accessibilityLabel("Day \(days), \(label), earned on \(date)")`
- Locked milestone rows: `.accessibilityLabel("Day \(days), \(label), in \(remaining) days")`
- Gold chip circles: `.accessibilityHidden(true)` — decorative
- Relay message block: `.accessibilityLabel("Relay message from day \(writerDay). \(message.text)")`
- Flag button in relay: `.accessibilityLabel("Report this message")`

### Dynamic Type

Apply `.dynamicTypeSize(.xSmall ... .accessibility3)` to all views that contain text in variable-length containers. The counter number should use `.dynamicTypeSize(.large)` (fixed — it's a graphic element).

### Reduce Motion

All positional animations must check `@Environment(\.accessibilityReduceMotion)` and use opacity-only transitions when true. The pledge ring animation should remain but speed up (0.3s instead of 0.5s) — because ring progress is meaningful and not purely decorative.

---

## 7. What Changes vs What Stays

### What changes

| Item | From | To | Rationale |
|------|------|-----|-----------|
| secondaryText color | #8C8880 | #A09890 | Fails WCAG 4.5:1 at 17pt |
| Relay placeholder color | ghost (#2E2C2A) | tertiaryText (#8A857F) | Currently invisible — legibility bug |
| Relay message block bg | separator (#1C1B19) | ghost (#2E2C2A) | Card is nearly invisible |
| "Send forward" button bg | separator (#1C1B19) | ghost (#2E2C2A) | Button is nearly invisible |
| "I'm already counting" button text | secondaryText | primaryText | Improves contrast on ghost bg |
| Section header color | tertiaryText (some) | secondaryText | Promotion for readability |
| Touch targets | Various | +44pt minimum | Apple HIG compliance |
| Onboarding progress indicator | 5pt dots | Animated dots with scale | Sharper, more intentional |
| Pledge ring animation | easeInOut | spring physics | More alive |
| Relay message entrance | opacity only | opacity + offset | More momentous |
| MilestoneMoment loading | opacity pulse | PhaseAnimator | Smoother |

### What stays

- Background: #0C0B09 — the signature dark. Do not touch.
- primaryText: #F4F2EE — warm cream, correct contrast, correct warmth.
- tertiaryText: #8A857F — already fixed. Good contrast. Keep.
- Hero counter: 88pt SF Pro Thin. This is the identity.
- Ring: 200pt circle, 1pt stroke, animated trim.
- Georgia relay text: The one serif moment in the app.
- No gradients.
- No confetti, no particle effects.
- No wellness copy.
- No Bold/Semibold/Medium anywhere.
- The "someone carving notches" voice — all copy stays as written.
- Tab bar structure (Today, Stacks, Journey, Settings).
- "Stacked." as the pledge confirmation copy.
- Onboarding copy (already behavior-agnostic — screens 1–3 are good, screen 5A headline already fixed to "When did your current chapter begin?").
- The relay system mechanics and flow.
- The chapter "never deletes" system.

---

## 8. Implementation Priority Order

Given the app is submitted and waiting for re-review (or about to be resubmitted), the changes are ordered by impact on Apple rejection risk.

### Priority 1 — Must fix before resubmit (contrast and legibility)

1. `Theme.swift`: Change `secondaryText` from `#8C8880` to `#A09890`
2. `RelayWriteView.swift`: Change placeholder color from `StackTheme.ghost` to `StackTheme.tertiaryText`
3. `RelayWriteView.swift`: Change "Send forward" button background from `StackTheme.separator` to `StackTheme.ghost`
4. `MilestoneMomentView.swift`: Change message block background from `StackTheme.separator` to `StackTheme.ghost`
5. `OnboardingContainerView.swift`: Change screen4 "I'm already counting" button text to `StackTheme.primaryText` (keep ghost background)
6. Add `.frame(minHeight: 44)` to: "CHAPTER X" button in TodayView, "I already have an account" in Onboarding, "Restore purchases" in Settings and Paywall, "Later" in RelayWriteView

### Priority 2 — Accessibility compliance (for future-proofing)

7. Add VoiceOver labels to milestone rows, relay message block, onboarding page indicator
8. Add `@Environment(\.accessibilityReduceMotion)` guards to animations
9. Add `.dynamicTypeSize` caps to prevent layout breaks at extreme sizes

### Priority 3 — Microanimations (polish, not blocking)

10. Pledge ring: switch to spring physics animation
11. Counter appear animation: scale + fade on first appear
12. Relay message entrance: offset + fade in TodayView and MilestoneMomentView
13. Onboarding page indicator: scale + color spring on active index change
14. MilestoneMomentView loading: PhaseAnimator for "·  ·  ·"
15. RelayWriteView: `.sensoryFeedback(.success, trigger: sentForward)` + TextEditor fade on send
16. Stacks earned row: `.symbolEffect(.bounce)` on newly-earned milestone

### Priority 4 — Design refinements (future version)

17. Consider: progress line instead of dots for onboarding
18. Consider: Journey total display upgrade for 365+ day users
19. Consider: remove "X days until next relay" countdown from TodayView
20. Consider: locked milestone rows at `opacity(0.7)` in StacksView

---

## 9. File-Level Change Summary

| File | Changes |
|------|---------|
| `Utilities/Theme.swift` | `secondaryText` #8C8880 → #A09890 |
| `Views/Today/TodayView.swift` | Touch target on "CHAPTER X" button; relay entrance animation; counter appear animation |
| `Views/Onboarding/OnboardingContainerView.swift` | Screen 4 secondary button style; touch target on "I already have an account"; page indicator animation |
| `Views/Stacks/StacksView.swift` | Section header color if using tertiaryText → secondaryText; locked row opacity; VoiceOver labels |
| `Views/Journey/JourneyView.swift` | Touch target on "Start new chapter"; optional 365+ day display |
| `Views/Settings/SettingsView.swift` | Touch target on "Restore purchases" |
| `Views/Paywall/PaywallView.swift` | Touch target on "Restore purchases" |
| `Views/MilestoneMoment/MilestoneMomentView.swift` | Block background separator → ghost; entrance animation; loading PhaseAnimator; haptic on reveal |
| `Views/MilestoneMoment/RelayWriteView.swift` | Placeholder color ghost → tertiaryText; button bg separator → ghost; success haptic; TextEditor fade |

---

## 10. Design Reference Synthesis

Based on research of Apple's HIG, WCAG guidelines, and understanding of apps like Atoms, Claude iOS, Opal, and PillowTalk:

**From Atoms app aesthetic:** Clean counters with minimal surrounding chrome. Single large number as the hero. Actions accessible but not prominent. This validates STACK's core concept — the app is correct, the execution needed fine-tuning.

**From Claude iOS dark theme:** Dark backgrounds that use layered surfaces (slightly lighter surfaces for content blocks) rather than pure flat dark. This informs the recommendation to change the relay message block background from separator to ghost — creating a subtle but perceptible surface lift.

**From Opal:** Restrained use of accent color. Functional states communicated through weight and position hierarchy, not color alone. STACK already does this correctly.

**From PillowTalk:** Edgy confidence in typography. Large, spare, trusts the user. The 42pt Light headlines in STACK onboarding match this register. This validates keeping the current onboarding headline sizes.

**Apple HIG key findings applied:**
- Thin weight fonts need larger sizes for legibility — STACK uses Thin only at 88pt. Correct.
- Minimum contrast for ≤17pt text: 4.5:1. secondaryText fails this — fix required.
- Touch targets: 44pt minimum for iOS. Multiple elements fall short — add minimum height modifiers.
- Dynamic Type: all text must scale. Add caps to prevent layout breaks at large sizes.
- Reduce Motion: positional animations must degrade to opacity-only.

**From ColorBox analysis:** The warm near-black (#0C0B09) sits at the deep end of a warm neutral scale. The ideal text colors for this background are warm neutrals with slightly warm undertones — not pure grays or cool whites. The current palette does this correctly (#F4F2EE is warm cream, #8A857F has warm undertone). The secondaryText fix (#8C8880 → #A09890) maintains the warm undertone while brightening for contrast.

---

## Design Verdict

STACK's aesthetic is correct and distinctive. A minimal, dark, warm-neutral app with a single dominant number — this is unusual and right for the product. The two Apple rejections were not about the design concept being wrong. They were about execution gaps: a color that failed contrast at body text sizes, a few elements just below the touch target minimum, and likely an overall impression of "the app is too dim" from a reviewer doing a quick tap-through.

The fixes are surgical. One color token change propagates through every secondaryText usage and resolves the core contrast failure. Five touch target additions resolve the HIG compliance gap. The animation additions make the app feel complete and considered rather than sparse and unfinished.

After these changes, STACK passes Apple's Guideline 4 criteria:
- No text below 4.5:1 contrast (for text ≤17pt)
- No text below 3:1 contrast (for text ≥18pt)
- All touch targets at 44pt minimum
- VoiceOver labels on all interactive elements
- Reduce Motion respected

The voice stays: short, factual, understated. Someone carving notches into a wall.
