# STACK Design Overhaul — Complete Implementation Plan

**Parent ticket:** TWO-345
**Child tickets:** TWO-346 through TWO-354
**Reason:** Apple rejected TWICE for Guideline 4 (typography/readability). Design audit scored 38/100.
**Reference:** Atoms app (James Clear) — card-based, clear hierarchy, micro-animations, visual depth.

---

## Design Principles (Extracted from Atoms Analysis)

1. **Card-based content grouping** — content lives in rounded-rect cards, not floating on void
2. **Typography hierarchy that POPS** — headlines use `.medium` weight, body `.regular`, hero `.light` (never `.thin`)
3. **Visual depth through layering** — background → card → content creates depth without gradients
4. **Prominent CTAs** — buttons look tappable with strong visual weight, gold accent for premium actions
5. **Micro-animations** — spring-based entrance, staggered reveals, satisfying feedback on interaction
6. **Generous internal spacing** — cards have 20-24pt padding, sections breathe

---

## CRITICAL: What CLAUDE.md Rules to Override

The existing CLAUDE.md typography rules CAUSED the rejection. Override these specifically:

| Old Rule (WRONG) | New Rule |
|---|---|
| SF Pro Thin for hero counter | SF Pro **Light** for hero counter |
| SF Pro Light for 18pt+ titles | SF Pro **Regular** for titles, **Medium** for headlines |
| No `.medium`, `.bold`, `.semibold` | `.medium` is allowed and REQUIRED for headlines and CTAs |
| No rounded card backgrounds | Cards with `RoundedRectangle` backgrounds are the PRIMARY layout pattern |

**Keep these rules unchanged:**
- Georgia for relay messages
- No confetti/particles/celebration animations
- No gradients
- No push notifications
- `.preferredColorScheme(.dark)` on WindowGroup
- Gold (#C8A96E) only on chip circles + earned chip borders (EXTEND to CTA buttons too)

---

## Task 1: Theme Foundation (TWO-346)

**File:** `ios/STACK/Utilities/Theme.swift`
**Blocks:** ALL other tasks

### 1.1 Color Token Updates

```swift
enum StackTheme {
    // Backgrounds
    static let background = Color(hex: "0C0B09")         // unchanged
    static let cardBackground = Color(hex: "1E1C19")      // NEW — card surfaces (≈1.3:1 vs background — visible)
    static let cardBorder = Color(hex: "3A3836")          // NEW — card border (visible against both bg and card)

    // Text
    static let primaryText = Color(hex: "F4F2EE")         // unchanged
    static let secondaryText = Color(hex: "A09890")       // unchanged
    static let tertiaryText = Color(hex: "9B958E")        // BUMPED from #8A857F — better WCAG AA
    static let ghost = Color(hex: "2E2C2A")               // unchanged
    static let milestoneWhite = Color.white               // unchanged
    static let separator = Color(hex: "1C1B19")           // unchanged

    // Accent
    static let gold = Color(hex: "C8A96E")                // NEW token (was inline)

    // Destructive
    static let destructive = Color.red.opacity(0.8)       // unchanged
    static let destructiveMuted = Color.red.opacity(0.5)  // unchanged

    // Layout constants
    static let cardRadius: CGFloat = 16
    static let cardRadiusSmall: CGFloat = 12
}
```

### 1.2 Typography Scale Updates

```swift
enum StackTypography {
    // Hero — CHANGED from .thin to .light
    static let heroCounter = Font.system(size: 88, weight: .light)

    // Display — for onboarding hero text
    static let display = Font.system(size: 42, weight: .regular)

    // Titles — CHANGED from .light to .regular
    static let title = Font.system(size: 34, weight: .regular)

    // Headlines — NEW weight .medium for visual hierarchy
    static let headline = Font.system(size: 22, weight: .medium)

    // Subheadline — size 18pt matches old `headline` slot; CHANGED weight from .light to .regular
    // NOTE: The old StackTypography.subheadline was 14pt. No code in the app currently references
    // StackTypography.subheadline directly (all views use inline .font() calls), so this size
    // change has zero impact outside this plan's scope. The 14pt slot is now `footnote`.
    static let subheadline = Font.system(size: 18, weight: .regular)

    // Body — unchanged
    static let body = Font.system(size: 16, weight: .regular)

    // Callout — unchanged
    static let callout = Font.system(size: 15, weight: .regular)

    // Footnote — unchanged
    static let footnote = Font.system(size: 14, weight: .regular)

    // Caption — unchanged
    static let caption = Font.system(size: 12, weight: .regular)

    // Overline — NEW .medium weight for section labels
    static let overline = Font.system(size: 12, weight: .medium)

    // CTA text — NEW .medium for button labels
    static let cta = Font.system(size: 15, weight: .medium)

    // Label — unchanged
    static let label = Font.system(size: 10, weight: .regular)
}
```

### 1.3 Animation Presets Updates

```swift
enum StackAnimation {
    // Pledge ring — slightly bouncier for more satisfaction
    static let pledgeRing = Animation.spring(duration: 0.6, bounce: 0.2)

    // Card/content entrance — used for fade-in-up pattern
    static let cardEntrance = Animation.spring(duration: 0.45, bounce: 0.12)

    // Generic entrance — quick fade
    static let entrance = Animation.easeOut(duration: 0.35)

    // Button press — unchanged
    static let press = Animation.easeInOut(duration: 0.15)

    // Stagger delay between list items
    static let stagger: Double = 0.06
}
```

### 1.4 NEW: Reusable StackCard Component

Add to Theme.swift:

```swift
struct StackCard<Content: View>: View {
    let content: Content
    var padding: CGFloat
    var radius: CGFloat

    init(
        padding: CGFloat = 20,
        radius: CGFloat = StackTheme.cardRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.radius = radius
    }

    var body: some View {
        content
            .padding(padding)
            .background(StackTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(StackTheme.cardBorder, lineWidth: 1.0)
            )
    }
}
```

> **Contrast note:** cardBackground #1E1C19 vs background #0C0B09 yields ≈1.3:1 contrast ratio — cards are clearly distinguishable. Border at #3A3836 with 1.0pt lineWidth provides definitive card edges. The previous #161513 at 0.5pt was invisible.

### 1.5 NEW: Gold CTA Button Style

```swift
struct GoldCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(StackTypography.cta)
            .foregroundStyle(StackTheme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(StackTheme.gold)
            .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(StackAnimation.press, value: configuration.isPressed)
    }
}
```

### 1.6 Consolidate Duplicate Button Styles

**Problem:** OnboardingContainerView defines `StackPressButtonStyle` (scale 0.98, spring 0.2) while Theme.swift has `PressScaleButtonStyle` (scale 0.97, spring 0.15). Two near-identical styles.

**Fix:** DELETE `StackPressButtonStyle` from OnboardingContainerView. Update `PressScaleButtonStyle` in Theme.swift to use the slightly gentler values:

```swift
struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(duration: 0.2, bounce: 0), value: configuration.isPressed)
    }
}
```

Then in OnboardingContainerView, replace all `.buttonStyle(StackPressButtonStyle())` with `.buttonStyle(PressScaleButtonStyle())`.

> Note: The 0.98/0.2 values from StackPressButtonStyle are slightly more natural than 0.97/0.15. Using the gentler version everywhere.

### 1.7 Entrance Animation Modifier

Move this from OnboardingContainerView into Theme.swift so ALL views can use it:

```swift
extension View {
    func entranceAnimation(visible: Bool, offset: CGFloat = 10) -> some View {
        self
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : offset)
    }
}
```

### Acceptance Criteria
- [ ] All new color tokens compile and render correctly
- [ ] `cardBackground` is #1E1C19 (visibly distinct from #0C0B09 background)
- [ ] `cardBorder` is #3A3836 with 1.0pt lineWidth in StackCard
- [ ] `goldCTA` token does NOT exist (removed — only `gold` is used)
- [ ] `StackCard` renders a rounded-rect card with border on any content
- [ ] `GoldCTAButtonStyle` renders gold background with dark text
- [ ] `PressScaleButtonStyle` uses scale 0.98 and spring duration 0.2 (consolidated)
- [ ] Typography scale uses correct weights (.light for hero, .regular for titles, .medium for headlines)
- [ ] `tertiaryText` is #9B958E (verify hex)
- [ ] App builds with zero errors

---

## Task 2: Today View Redesign (TWO-348)

**File:** `ios/STACK/Views/Today/TodayView.swift`
**Depends on:** Task 1

### 2.1 Chapter Badge (top of screen)

**Current:**
```swift
Text("CHAPTER \(chapter.chapterNumber)")
    .font(.system(size: 12, weight: .regular))
    .tracking(1.5)
    .foregroundStyle(StackTheme.secondaryText)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 28)
    .padding(.top, 16)
```

**New:**
```swift
Text("CHAPTER \(chapter.chapterNumber)")
    .font(StackTypography.overline)  // 12pt .medium
    .tracking(1.5)
    .foregroundStyle(StackTheme.secondaryText)
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(StackTheme.cardBackground)
    .clipShape(Capsule())
    .overlay(Capsule().stroke(StackTheme.cardBorder, lineWidth: 1.0))
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 28)
    .padding(.top, 16)
```

### 2.2 Counter Block Updates

**Counter number:**
```swift
// CHANGE: .thin → .light
Text("\(store.currentDays)")
    .font(StackTypography.heroCounter)  // 88pt .light (was .thin)
    .foregroundStyle(store.isMilestoneDay ? StackTheme.milestoneWhite : StackTheme.primaryText)
    .contentTransition(.numericText())
```

**Ring strokes — increase visibility:**
```swift
// Ghost ring: lineWidth 1 → 1.5
Circle()
    .stroke(StackTheme.ghost, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
    .frame(width: 200, height: 200)

// Pledge ring: lineWidth 1 → 1.5
Circle()
    .trim(from: 0, to: pledgedToday ? 1.0 : 0.0)
    .stroke(StackTheme.primaryText, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
    .rotationEffect(.degrees(-90))
    .frame(width: 200, height: 200)
    .animation(
        reduceMotion ? .none : StackAnimation.pledgeRing,  // Updated animation preset
        value: pledgedToday
    )
```

**"DAYS" label:**
```swift
Text("DAYS")
    .font(StackTypography.overline)  // 12pt .medium (was .regular)
    .tracking(1.5)
    .foregroundStyle(StackTheme.secondaryText)
```

**Milestone label below DAYS:**
```swift
Text(label.uppercased())
    .font(StackTypography.overline)  // 12pt .medium (was .regular)
    .tracking(3)
    .foregroundStyle(StackTheme.milestoneWhite)
```

### 2.3 "Stacked." Confirmation — More Satisfying

**Current:** 14pt regular, secondaryText
**New:**
```swift
if pledgedToday && stackedTextVisible {
    HStack(spacing: 6) {
        Image(systemName: "checkmark")
            .font(.system(size: 13, weight: .medium))
        Text("Stacked.")
            .font(.system(size: 15, weight: .medium))
    }
    .foregroundStyle(StackTheme.primaryText)
    .padding(.top, 20)
    .transition(.opacity)
}
```

### 2.4 Inline Relay Message — Card Treatment

**Current:** Plain VStack with text
**New:** Wrap in StackCard
```swift
if showInlineRelay, let message = inlineRelayMessage {
    if inlineRelayReported {
        // Keep as-is (simple text)
        Text("Reported. Thank you.")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(StackTheme.tertiaryText)
            .padding(.top, 24)
            .transition(.opacity)
    } else {
        StackCard(padding: 20, radius: StackTheme.cardRadiusSmall) {
            VStack(alignment: .leading, spacing: 8) {
                Text(message.text)
                    .font(Font.custom("Georgia", size: 19))
                    .foregroundStyle(StackTheme.secondaryText)
                    .lineSpacing(5)

                Text("— from \(writerLabel(for: message))")
                    .font(StackTypography.caption)
                    .foregroundStyle(StackTheme.tertiaryText)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .transition(reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 12)).combined(with: .scale(scale: 0.98)),
                removal: .opacity
            )
        )
        .onLongPressGesture {
            showReportConfirmation = true
        }
    }
}
```

### 2.5 Locked Relay CTA — Proper Card with Gold Button

**Current:** Plain text + small link
**New:**

> **Intentional copy change:** "Relay message available." → "A relay message is waiting." This is a deliberate UX improvement — the new copy creates anticipation and invites action, not just states a fact.

```swift
if showLockedRelay {
    StackCard(padding: 20, radius: StackTheme.cardRadiusSmall) {
        VStack(spacing: 14) {
            Text("A relay message is waiting.")
                .font(StackTypography.callout)
                .foregroundStyle(StackTheme.secondaryText)

            Button {
                showPaywallSheet = true
            } label: {
                Text("Unlock STACK")
            }
            .buttonStyle(GoldCTAButtonStyle())
        }
    }
    .padding(.horizontal, 28)
    .padding(.top, 20)
    .transition(reduceMotion
        ? .opacity
        : .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 12)),
            removal: .opacity
        )
    )
}
```

### 2.6 Multi-Chapter Total Footer

**Current:** Plain text
**New:** Wrap in card
```swift
if store.chapters.count > 1 {
    HStack(spacing: 4) {
        Text("\(store.totalDays)")
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(StackTheme.secondaryText)
        Text("days total across \(store.chapters.count) chapters")
            .font(StackTypography.caption)
            .foregroundStyle(StackTheme.tertiaryText)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(StackTheme.cardBackground)
    .clipShape(Capsule())
    .overlay(Capsule().stroke(StackTheme.cardBorder, lineWidth: 1.0))
    .padding(.top, 20)
}
```

### 2.7 "Loading relay message..." Text

**Current (TodayView lines 58-64):**
```swift
if pledgedToday && relayLoading {
    Text("Loading relay message...")
        .font(.system(size: 13, weight: .regular))
        .foregroundStyle(StackTheme.tertiaryText)
        .padding(.top, 12)
        .transition(.opacity)
}
```

**New:**
```swift
if pledgedToday && relayLoading {
    Text("Loading relay message...")
        .font(StackTypography.caption)  // 12pt .regular — uses token
        .foregroundStyle(StackTheme.tertiaryText)
        .padding(.top, 12)
        .transition(.opacity)
}
```

### 2.8 Countdown to Next Relay

```swift
// CHANGE: font uses token
Text("\(daysLeft) day\(daysLeft == 1 ? "" : "s") until next relay")
    .font(StackTypography.caption)  // unchanged size but uses token
    .foregroundStyle(StackTheme.tertiaryText)
    .padding(.top, 12)
```

### Acceptance Criteria
- [ ] Chapter badge renders as a pill/capsule with card background
- [ ] Counter uses .light weight (not .thin)
- [ ] Ring strokes are 1.5pt wide
- [ ] "Stacked." shows checkmark icon, 15pt medium, primaryText color
- [ ] Inline relay appears in a StackCard
- [ ] Locked relay shows gold CTA button in a card
- [ ] Multi-chapter total appears in a capsule pill
- [ ] "Loading relay message..." uses StackTypography.caption token
- [ ] All animations still work with reduceMotion respected

---

## Task 3: Onboarding Redesign (TWO-347)

**File:** `ios/STACK/Views/Onboarding/OnboardingContainerView.swift`
**Depends on:** Task 1

### 3.1 Global Changes Across All Screens

All onboarding titles:
```swift
// CHANGE: .light → .regular for all 42pt titles
.font(.system(size: 42, weight: .regular))  // was .light
```

All 19pt body text:
```swift
// CHANGE: .light → .regular for all body text
.font(.system(size: 19, weight: .regular))  // was .light
```

All CTA buttons:
```swift
// CHANGE: .regular → .medium for all CTA button labels
.font(StackTypography.cta)  // 15pt .medium
```

### 3.2 Screen 1 ("Every day counts") — Add Counter Preview

After the two body text lines and before `Spacer()`, add a visual preview:

```swift
// Mini counter preview — shows what the app looks like
ZStack {
    Circle()
        .stroke(StackTheme.primaryText, lineWidth: 1.5)
        .frame(width: 80, height: 80)
    Text("14")
        .font(.system(size: 36, weight: .light))
        .foregroundStyle(StackTheme.primaryText)
}
.padding(.top, 48)
.entranceAnimation(visible: visibleElements >= 3)
```

### 3.3 Screen 2 ("No resets.") — Card for Chapter Preview

Replace the current plain VStack chapter preview with a StackCard:

**Current:**
```swift
VStack(alignment: .leading, spacing: 4) {
    Text("Chapter 1  ·  127 days  ·  Mar 2023 – Jul 2023")
    Text("Chapter 2  ·  currently at Day 847")
    StackTheme.separator.frame(height: 0.5).padding(.vertical, 4)
    Text("974 days stacked")
}
.font(.system(size: 13, weight: .regular))
.foregroundStyle(StackTheme.tertiaryText)
.padding(.top, 32)
```

**New:**
```swift
StackCard(padding: 16, radius: StackTheme.cardRadiusSmall) {
    VStack(alignment: .leading, spacing: 6) {
        Text("Chapter 1  ·  127 days  ·  Mar–Jul 2023")
            .font(StackTypography.footnote)
            .foregroundStyle(StackTheme.tertiaryText)
        Text("Chapter 2  ·  currently at Day 847")
            .font(StackTypography.footnote)
            .foregroundStyle(StackTheme.secondaryText)
        StackTheme.separator.frame(height: 0.5).padding(.vertical, 2)
        Text("974 days stacked")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(StackTheme.secondaryText)
    }
}
.padding(.top, 32)
```

Note: The StackCard already handles its own padding, and since screen2 has `.padding(.horizontal, 28)` on the parent, we do NOT add horizontal padding to the card — it inherits the parent padding.

### 3.4 Screen 3 ("Messages at milestones.") — Relay Preview Card

After the body text paragraphs, before the pricing line, add a relay message preview:

```swift
// Relay message preview card
StackCard(padding: 20, radius: StackTheme.cardRadiusSmall) {
    VStack(alignment: .leading, spacing: 8) {
        Text("The first month is a wall. The second is a door.")
            .font(Font.custom("Georgia", size: 17))
            .foregroundStyle(StackTheme.primaryText)
            .lineSpacing(5)
        Text("— from day 47")
            .font(StackTypography.caption)
            .foregroundStyle(StackTheme.tertiaryText)
    }
}
.padding(.top, 24)
.entranceAnimation(visible: visibleElements >= 3)
```

Move the pricing line AFTER this card:
```swift
Text("Your first week of messages is free. After that, one payment unlocks the relay forever.")
    .font(StackTypography.callout)
    .foregroundStyle(StackTheme.tertiaryText)
    .padding(.top, 16)
    .entranceAnimation(visible: visibleElements >= 3)
```

### 3.5 Screen 4 ("Where are you?") — Button Weight Updates

Primary CTA:
```swift
Text("Starting today")
    .font(StackTypography.cta)  // 15pt .medium (was .regular)
    .foregroundStyle(StackTheme.background)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(StackTheme.primaryText)
    .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
```

Secondary CTA:
```swift
Text("I'm already counting")
    .font(StackTypography.callout)  // stays 15pt .regular
    .foregroundStyle(StackTheme.secondaryText)
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(StackTheme.cardBackground)  // CHANGED from separator
    .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
    .overlay(
        RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall)
            .stroke(StackTheme.cardBorder, lineWidth: 1.0)
    )
```

### 3.6 Screen 5A (Date Picker) — Weight Updates

Title:
```swift
// Both "When did your current chapter begin?" and confirmation title
.font(.system(size: 34, weight: .regular))  // was .light
```

CTA buttons: use `StackTypography.cta` (15pt .medium)

### 3.7 Screen 5B (History Import) — Card Treatment

**History preview:** Wrap in StackCard
```swift
StackCard(padding: 16, radius: StackTheme.cardRadiusSmall) {
    VStack(alignment: .leading, spacing: 4) {
        // ... chapter lines (keep existing content)
    }
}
```

**Section headers:**
```swift
Text("CURRENT CHAPTER")
    .font(StackTypography.overline)  // 12pt .medium (was .regular)
    .tracking(1.5)
    .foregroundStyle(StackTheme.tertiaryText)
```

**"Start stacking" CTA:** Use `.font(StackTypography.cta)`

### 3.8 Delete StackPressButtonStyle + Replace References

DELETE the `StackPressButtonStyle` struct at the top of OnboardingContainerView.swift (lines 5-11).
Replace all `.buttonStyle(StackPressButtonStyle())` with `.buttonStyle(PressScaleButtonStyle())`.

This consolidation is specified in Task 1 section 1.6. The updated `PressScaleButtonStyle` in Theme.swift uses the same 0.98/0.2 values.

### 3.9 Skip Button Weight

```swift
Text("Skip")
    .font(StackTypography.body)  // 16pt .regular (unchanged)
    .foregroundStyle(StackTheme.secondaryText)
```

### 3.9 Back Chevron Update

```swift
Image(systemName: "chevron.left")
    .font(.system(size: 17, weight: .regular))  // unchanged
    .foregroundStyle(StackTheme.secondaryText)  // CHANGED from tertiaryText for better visibility
```

### Acceptance Criteria
- [ ] All onboarding titles use .regular weight (not .light)
- [ ] All body text uses .regular weight (not .light)
- [ ] Screen 2 shows chapter preview in a StackCard
- [ ] Screen 3 shows a relay message preview in a StackCard
- [ ] Screen 4 buttons use .medium weight for primary CTA
- [ ] Screen 4 secondary button uses cardBackground (not separator)
- [ ] Screen 5B history preview is in a StackCard
- [ ] Mini counter preview appears on screen 1
- [ ] `StackPressButtonStyle` deleted, all references replaced with `PressScaleButtonStyle`
- [ ] Entrance animations still work correctly

---

## Task 4: Stacks View & Stack Card Redesign (TWO-349)

**Files:** `ios/STACK/Views/Stacks/StacksView.swift`, `ios/STACK/Views/Stacks/StackCardView.swift`
**Depends on:** Task 1

### 4.1 StacksView — Card-Based Rows

**Page title:**
```swift
Text("Stacks")
    .font(StackTypography.title)  // 34pt .regular (was .light)
    .foregroundStyle(StackTheme.primaryText)
```

**Layout restructure:** Change from flat list to card-based items.

Replace the `LazyVStack(spacing: 0)` + separator pattern:
```swift
LazyVStack(spacing: 12) {
    ForEach(Array(Milestone.allDays.enumerated()), id: \.element) { index, days in
        let earned = store.currentDays >= days
        if earned {
            Button {
                selectedMilestone = days
            } label: {
                earnedRow(days: days, index: index)
            }
        } else {
            lockedRow(days: days, index: index)
        }
        // DELETE: Remove all separator lines between rows
    }
}
.padding(.horizontal, 20)
.padding(.vertical, 8)
```

**Earned row — card style:**
```swift
private func earnedRow(days: Int, index: Int) -> some View {
    HStack(spacing: 16) {
        ZStack {
            Circle()
                .fill(StackTheme.gold.opacity(0.1))  // NEW: subtle gold fill
            Circle()
                .stroke(StackTheme.gold, lineWidth: 1.5)
            Text(Milestone.shortLabel(for: days))
                .font(StackTypography.callout)  // 15pt .regular
                .foregroundStyle(StackTheme.gold)
        }
        .frame(width: 40, height: 40)
        .scaleEffect(newlyEarnedMilestone == days ? 1.12 : 1.0)
        .animation(
            newlyEarnedMilestone == days
                ? .spring(duration: 0.3, bounce: 0.5).repeatCount(2, autoreverses: true)
                : .default,
            value: newlyEarnedMilestone
        )

        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(Milestone.label(for: days) ?? "")
                    .font(.system(size: 16, weight: .medium))  // CHANGED from .regular
                    .foregroundStyle(StackTheme.primaryText)

                if !store.receivedRelayDays.contains(days) {
                    Circle()
                        .fill(StackTheme.gold)
                        .frame(width: 5, height: 5)  // slightly larger dot
                }
            }

            if let info = store.earnedDate(for: days) {
                Text("\(StackDateFormatter.string(from: info.date)) · Chapter \(info.chapter.chapterNumber)")
                    .font(StackTypography.caption)
                    .foregroundStyle(StackTheme.tertiaryText)
            }
        }

        Spacer()

        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(StackTheme.tertiaryText)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(StackTheme.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
            .stroke(StackTheme.cardBorder, lineWidth: 1.0)
    )
    .contentShape(Rectangle())
    .opacity(listAppeared ? 1.0 : 0.0)
    .offset(y: listAppeared ? 0 : 6)
    .animation(
        reduceMotion ? nil : StackAnimation.cardEntrance.delay(Double(index) * StackAnimation.stagger),
        value: listAppeared
    )
}
```

**Locked row — dimmed card:**
```swift
private func lockedRow(days: Int, index: Int) -> some View {
    HStack(spacing: 16) {
        Circle()
            .stroke(StackTheme.ghost, lineWidth: 1.5)
            .frame(width: 40, height: 40)

        VStack(alignment: .leading, spacing: 2) {
            Text(Milestone.label(for: days) ?? "")
                .font(StackTypography.body)
                .foregroundStyle(StackTheme.tertiaryText)

            let remaining = Milestone.daysUntil(from: store.currentDays, to: days)
            Text("In \(remaining) days")
                .font(StackTypography.caption)
                .foregroundStyle(StackTheme.tertiaryText)
        }

        Spacer()
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(StackTheme.ghost.opacity(0.3))  // Very subtle background
    .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
    .allowsHitTesting(false)
    .opacity(listAppeared ? 0.7 : 0.0)  // Slightly dimmed even when visible
    .offset(y: listAppeared ? 0 : 6)
    .animation(
        reduceMotion ? nil : StackAnimation.cardEntrance.delay(Double(index) * StackAnimation.stagger),
        value: listAppeared
    )
}
```

### 4.2 StackCardView (Detail Sheet) — Card-Wrapped Content

**Circle badge:**
```swift
private var stackCircle: some View {
    ZStack {
        Circle()
            .stroke(StackTheme.primaryText, lineWidth: 2)  // CHANGED from 1.5

        Text(Milestone.shortLabel(for: milestoneDays))
            .font(.system(size: 54, weight: .regular))  // CHANGED from .light
            .foregroundStyle(StackTheme.primaryText)
    }
}
```

**Milestone label:**
```swift
Text(milestoneLabel.uppercased())
    .font(StackTypography.headline)  // 22pt .medium (was 22pt .light)
    .tracking(2)
    .foregroundStyle(StackTheme.primaryText)
    .padding(.top, 28)
```

**Tagline:**
```swift
Text("One at a time.")
    .font(StackTypography.callout)  // 15pt .regular (unchanged)
    .foregroundStyle(StackTheme.secondaryText)
    .padding(.top, 12)
```

**Action buttons — more prominent:**
```swift
VStack(spacing: 16) {
    if RelayPoint.relayPoint(for: milestoneDays) != nil {
        Button {
            showRelay = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "envelope")
                    .font(.system(size: 14, weight: .regular))
                Text("Read the relay")
                    .font(StackTypography.footnote)
            }
            .foregroundStyle(StackTheme.primaryText)  // CHANGED from secondaryText
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(StackTheme.cardBackground)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(StackTheme.cardBorder, lineWidth: 1.0))
        }
    }

    Button {
        renderAndShare()
    } label: {
        HStack(spacing: 6) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 14, weight: .regular))
            Text("Share")
                .font(StackTypography.footnote)
        }
        .foregroundStyle(StackTheme.secondaryText)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(StackTheme.cardBackground)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(StackTheme.cardBorder, lineWidth: 1.0))
    }
}
.padding(.bottom, 32)
```

### 4.3 StackExportView (Share Image) — Full Update

This is the image users post to social media. It must match the new typography.

**Current StackExportView body:**
```swift
var body: some View {
    VStack(spacing: 0) {
        Spacer()

        ZStack {
            Circle()
                .stroke(StackTheme.primaryText, lineWidth: 1.5)
                .frame(width: 128, height: 128)

            Text(Milestone.shortLabel(for: milestoneDays))
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(StackTheme.primaryText)
        }

        Text((Milestone.label(for: milestoneDays) ?? "").uppercased())
            .font(.system(size: 22, weight: .light))
            .tracking(2)
            .foregroundStyle(StackTheme.primaryText)
            .padding(.top, 28)

        Text("One at a time.")
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(StackTheme.secondaryText)
            .padding(.top, 12)

        Spacer()

        Text("STACK")
            .font(.system(size: 12, weight: .regular))
            .tracking(2)
            .foregroundStyle(StackTheme.tertiaryText)
            .padding(.bottom, 24)
    }
    .frame(width: 390, height: 500)
    .background(StackTheme.background)
}
```

**New StackExportView body:**
```swift
var body: some View {
    VStack(spacing: 0) {
        Spacer()

        ZStack {
            Circle()
                .stroke(StackTheme.primaryText, lineWidth: 2)  // CHANGED from 1.5
                .frame(width: 128, height: 128)

            Text(Milestone.shortLabel(for: milestoneDays))
                .font(.system(size: 54, weight: .regular))  // CHANGED from .light
                .foregroundStyle(StackTheme.primaryText)
        }

        Text((Milestone.label(for: milestoneDays) ?? "").uppercased())
            .font(StackTypography.headline)  // 22pt .medium (CHANGED from 22pt .light)
            .tracking(2)
            .foregroundStyle(StackTheme.primaryText)
            .padding(.top, 28)

        Text("One at a time.")
            .font(StackTypography.callout)  // 15pt .regular (unchanged)
            .foregroundStyle(StackTheme.secondaryText)
            .padding(.top, 12)

        Spacer()

        Text("STACK")
            .font(StackTypography.overline)  // 12pt .medium (CHANGED from .regular)
            .tracking(2)
            .foregroundStyle(StackTheme.tertiaryText)
            .padding(.bottom, 24)
    }
    .frame(width: 390, height: 500)  // Size unchanged — critical for share image
    .background(StackTheme.background)
}
```

**Changes summary:** Circle stroke 1.5→2, number weight .light→.regular, milestone label .light→.medium, "STACK" watermark .regular→.medium. Frame size preserved.

### Acceptance Criteria
- [ ] Milestone list uses card-based rows with spacing (no thin separators)
- [ ] Earned rows have gold-tinted circle fill
- [ ] Earned milestone labels use .medium weight
- [ ] Locked rows have subtle ghost background at reduced opacity
- [ ] StackCardView circle uses lineWidth 2, number weight .regular
- [ ] Action buttons (relay/share) are pill-shaped with card backgrounds
- [ ] StackExportView matches new typography weights
- [ ] Stagger animations work correctly with new spacing

---

## Task 5: Journey View Redesign (TWO-350)

**File:** `ios/STACK/Views/Journey/JourneyView.swift`
**Depends on:** Task 1

### 5.1 Page Title
```swift
Text("Journey")
    .font(StackTypography.title)  // 34pt .regular (was .light)
```

### 5.2 Timeline Column — Bolder

```swift
private func timelineColumn(isCurrentChapter: Bool, isLast: Bool) -> some View {
    VStack(alignment: .center, spacing: 0) {
        Spacer().frame(height: 14)  // was 12
        Circle()
            .fill(isCurrentChapter ? StackTheme.gold : StackTheme.ghost)  // CHANGED: gold for current
            .frame(width: 7, height: 7)  // CHANGED from 5
        if !isLast {
            Rectangle()
                .fill(StackTheme.ghost)  // CHANGED from separator (slightly brighter)
                .frame(width: 2)  // CHANGED from 1
                .frame(maxHeight: .infinity)
        }
    }
    .frame(width: 28)
}
```

### 5.3 Current Chapter — Card Treatment

```swift
private func currentChapterContent(_ chapter: Chapter) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text("CHAPTER \(chapter.chapterNumber)")
            .font(StackTypography.overline)  // 12pt .medium (was .regular)
            .tracking(1.5)
            .foregroundStyle(StackTheme.secondaryText)

        HStack(alignment: .lastTextBaseline, spacing: 4) {
            Text("\(chapter.daysCount)")
                .font(.system(size: 40, weight: .regular))  // CHANGED from .light
                .foregroundStyle(StackTheme.primaryText)

            Text("days")
                .font(StackTypography.footnote)
                .foregroundStyle(StackTheme.secondaryText)
        }

        Text("Since \(StackDateFormatter.string(from: chapter.startDate))")
            .font(StackTypography.caption)
            .foregroundStyle(StackTheme.tertiaryText)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(StackTheme.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
            .stroke(StackTheme.cardBorder, lineWidth: 1.0)
    )
    .padding(.trailing, 20)  // was 28 — tighter to compensate for card padding
    .padding(.vertical, 12)  // was 20
}
```

### 5.4 Past Chapter — Subtle Card

```swift
private func pastChapterContent(_ chapter: Chapter) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text("CHAPTER \(chapter.chapterNumber)")
            .font(StackTypography.overline)  // 12pt .medium (was .regular)
            .tracking(1.5)
            .foregroundStyle(StackTheme.secondaryText)

        HStack(alignment: .lastTextBaseline, spacing: 4) {
            Text("\(chapter.daysCount)")
                .font(.system(size: 28, weight: .regular))  // CHANGED from .light
                .foregroundStyle(StackTheme.secondaryText)

            Text("days")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(StackTheme.tertiaryText)
        }

        let startFormatted = StackDateFormatter.string(from: chapter.startDate)
        let endFormatted = chapter.endDate.map { StackDateFormatter.string(from: $0) } ?? ""
        Text("\(startFormatted) – \(endFormatted)")
            .font(StackTypography.caption)
            .foregroundStyle(StackTheme.tertiaryText)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(StackTheme.ghost.opacity(0.4))  // Subtle, dimmer than current chapter
    .clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
    .padding(.trailing, 20)
    .padding(.vertical, 8)
}
```

### 5.5 Total Days Summary — Card

```swift
VStack(spacing: 4) {
    Text("\(store.totalDays) days stacked")
        .font(.system(size: 15, weight: .medium))  // CHANGED: added .medium
        .foregroundStyle(StackTheme.secondaryText)

    if store.chapters.count > 1 {
        Text("Across \(store.chapters.count) chapters")
            .font(StackTypography.caption)
            .foregroundStyle(StackTheme.tertiaryText)
    }
}
.frame(maxWidth: .infinity, alignment: .center)
.padding(16)
.background(StackTheme.cardBackground)
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 20)
.padding(.top, 32)
```

### 5.6 "Start New Chapter" Button

```swift
Button { ... } label: {
    Text("Start new chapter")
        .font(StackTypography.cta)  // 15pt .medium (was .regular)
        .foregroundStyle(StackTheme.primaryText)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(StackTheme.cardBackground)  // CHANGED from ghost
        .clipShape(.rect(cornerRadius: StackTheme.cardRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall)
                .stroke(StackTheme.cardBorder, lineWidth: 1.0)
        )
}
.buttonStyle(PressScaleButtonStyle())
.padding(.horizontal, 20)
.padding(.top, 20)
.padding(.bottom, 32)
```

### Acceptance Criteria
- [ ] Timeline dots are 7pt (not 5pt), line is 2pt wide (not 1pt)
- [ ] Current chapter dot is gold
- [ ] Current chapter content is in a card with border
- [ ] Past chapter content is in a subtle ghost-tinted card
- [ ] Day count numbers use .regular weight (not .light)
- [ ] Total days summary is in a card
- [ ] "Start new chapter" uses .medium weight and card-style background
- [ ] Section headers use .medium weight

---

## Task 6: Settings View Redesign (TWO-351)

**File:** `ios/STACK/Views/Settings/SettingsView.swift`
**Depends on:** Task 1

### 6.1 Page Title
```swift
Text("Settings")
    .font(StackTypography.title)  // 34pt .regular (was .light)
```

### 6.2 Section Headers — Medium Weight
```swift
private func sectionHeader(_ title: String) -> some View {
    Text(title)
        .font(StackTypography.overline)  // 12pt .medium (was .regular)
        .tracking(1.5)
        .foregroundStyle(StackTheme.secondaryText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 8)
}
```

### 6.3 Grouped Card Sections

Wrap each settings group in a card. The card wraps the rows with internal separators.

**Example — WIDGET section:**
```swift
sectionHeader("WIDGET")

VStack(spacing: 0) {
    Button { showWidgetInstructions = true } label: {
        settingsRow(title: "Add to lock screen", trailing: { chevron })
    }
}
.background(StackTheme.cardBackground)
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 20)
```

**STACK section (multi-row card):**
```swift
sectionHeader("STACK")
    .padding(.top, 24)

VStack(spacing: 0) {
    if store.lifetimePurchased {
        settingsRow(title: "Lifetime · Unlocked", trailing: { EmptyView() })
    } else {
        Button { showPaywall = true } label: {
            settingsRow(title: "Unlock STACK", trailing: {
                if !priceString.isEmpty {
                    Text("· \(priceString)")
                        .font(StackTypography.footnote)
                        .foregroundStyle(StackTheme.gold)  // CHANGED: gold for price
                }
            })
        }

        StackTheme.separator.frame(height: 0.5).padding(.horizontal, 20)

        Button { Task { await restoreSettingsPurchases() } } label: {
            // restore row...
        }
    }

    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 20)

    Button { showNewChapterConfirmation = true } label: {
        settingsRow(title: "Start New Chapter", trailing: { chevron })
    }
}
.background(StackTheme.cardBackground)
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 20)
```

**ACCOUNT section (signed-in variant):**
```swift
sectionHeader("ACCOUNT")
    .padding(.top, 24)

VStack(spacing: 0) {
    if let email = auth.userEmail {
        settingsRow(title: email, trailing: { EmptyView() })
        StackTheme.separator.frame(height: 0.5).padding(.horizontal, 20)
    }

    Button { auth.signOut() } label: {
        settingsRow(title: "Sign Out", trailing: { EmptyView() })
    }
}
.background(StackTheme.cardBackground)
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 20)

// Delete Account — separate card, visually isolated for safety
Button { showDeleteConfirmation = true } label: {
    HStack {
        Text("Delete Account")
            .font(StackTypography.body)
            .foregroundStyle(StackTheme.destructive)
        Spacer()
        if isDeletingAccount {
            ProgressView()
                .tint(StackTheme.destructiveMuted)
                .scaleEffect(0.75)
        }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .contentShape(Rectangle())
}
.disabled(isDeletingAccount)
.background(StackTheme.cardBackground)
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
        .stroke(StackTheme.destructive.opacity(0.3), lineWidth: 1.0)  // Red-tinted border for danger
)
.padding(.horizontal, 20)
.padding(.top, 12)
```

**ACCOUNT section (signed-out variant):**
```swift
sectionHeader("ACCOUNT")
    .padding(.top, 24)

VStack(spacing: 0) {
    Button { showSignInSheet = true } label: {
        settingsRow(title: "Sign in with Apple", trailing: {
            Image(systemName: "apple.logo")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(StackTheme.secondaryText)
        })
    }
}
.background(StackTheme.cardBackground)
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 20)
```

**LEGAL section (3 link rows):**
```swift
sectionHeader("LEGAL")
    .padding(.top, 24)

VStack(spacing: 0) {
    Link(destination: URL(string: "https://stack.twohundred.ai/privacy.html")!) {
        settingsRow(title: "Privacy Policy", trailing: {
            Image(systemName: "arrow.up.right")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(StackTheme.tertiaryText)
        })
    }

    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 20)

    Link(destination: URL(string: "https://stack.twohundred.ai/terms.html")!) {
        settingsRow(title: "Terms of Use", trailing: {
            Image(systemName: "arrow.up.right")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(StackTheme.tertiaryText)
        })
    }

    StackTheme.separator.frame(height: 0.5).padding(.horizontal, 20)

    Link(destination: URL(string: "mailto:hello@twohundred.ai")!) {
        settingsRow(title: "Contact Support", trailing: {
            Image(systemName: "envelope")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(StackTheme.tertiaryText)
        })
    }
}
.background(StackTheme.cardBackground)
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 20)
```

**ABOUT section (info VStack):**
```swift
sectionHeader("ABOUT")
    .padding(.top, 24)

VStack(alignment: .leading, spacing: 12) {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        Text("Version \(version)")
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(StackTheme.secondaryText)
    }

    Text("No notifications. No streaks. No social.")
        .font(.system(size: 13, weight: .regular))
        .foregroundStyle(StackTheme.secondaryText)

    Text(auth.isSignedIn
         ? "Your data is backed up when signed in."
         : "Sign in to back up your progress across devices.")
        .font(StackTypography.caption)
        .foregroundStyle(StackTheme.tertiaryText)
}
.frame(maxWidth: .infinity, alignment: .leading)
.padding(20)
.background(StackTheme.cardBackground)
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadiusSmall, style: .continuous)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 20)
```

### 6.4 Settings Row Padding Update

Rows inside cards need slightly adjusted padding:
```swift
private func settingsRow<Trailing: View>(title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
    HStack {
        Text(title)
            .font(StackTypography.body)
            .foregroundStyle(StackTheme.primaryText)
        Spacer()
        trailing()
    }
    .padding(.horizontal, 20)  // CHANGED from 28 (inside card now)
    .padding(.vertical, 16)
    .contentShape(Rectangle())
}
```

### 6.5 Widget Instructions Sheet — Cards

Update `WidgetInstructionsSheet` instruction steps to use card backgrounds:
```swift
private func instructionStep(number: Int, icon: String, text: String) -> some View {
    HStack(spacing: 16) {
        ZStack {
            Circle()
                .fill(StackTheme.cardBackground)  // ADD: fill background
                .frame(width: 36, height: 36)
            Circle()
                .stroke(StackTheme.cardBorder, lineWidth: 1)  // CHANGED from ghost
                .frame(width: 36, height: 36)
            Image(systemName: icon)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(StackTheme.secondaryText)
        }

        Text(text)
            .font(StackTypography.callout)
            .foregroundStyle(StackTheme.primaryText)
    }
}
```

### Acceptance Criteria
- [ ] Each settings group (WIDGET, STACK, ACCOUNT, LEGAL, ABOUT) is wrapped in a card
- [ ] Internal separators only appear within cards (not full-width)
- [ ] Section headers use .medium weight
- [ ] Price text shows in gold color
- [ ] Settings rows have adjusted padding (20pt inside cards)
- [ ] Widget instructions have filled circle backgrounds
- [ ] Delete Account row is in its own card area

---

## Task 7: Milestone Moment & Relay Write Redesign (TWO-352)

**Files:** `ios/STACK/Views/MilestoneMoment/MilestoneMomentView.swift`, `ios/STACK/Views/MilestoneMoment/RelayWriteView.swift`
**Depends on:** Task 1

### 7.1 MilestoneMomentView — Header

```swift
Text("CHAPTER \(chapterNumber) · \(headerLabel)")
    .font(StackTypography.overline)  // 12pt .medium (was .regular)
    .tracking(1.5)
    .foregroundStyle(StackTheme.tertiaryText)
```

### 7.2 Loading State — Animated Dots

Replace the plain text loading indicator:

**Current:**
```swift
Text("·  ·  ·")
    .font(.system(size: 17, weight: .regular))
    .foregroundStyle(StackTheme.tertiaryText)
    .opacity(0.3)
    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isLoading)
```

**New (add a @State var loadingDotPhase: Bool = false):**
```swift
private var loadingView: some View {
    HStack(spacing: 8) {
        ForEach(0..<3, id: \.self) { i in
            Circle()
                .fill(StackTheme.tertiaryText)
                .frame(width: 6, height: 6)
                .opacity(loadingDotPhase ? 1.0 : 0.3)
                .animation(
                    .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.2),
                    value: loadingDotPhase
                )
        }
    }
    .onAppear { loadingDotPhase = true }
}
```

Add `@State private var loadingDotPhase: Bool = false` to the view's state.

### 7.3 Message Card — Improved Styling

**paidMessageView card:**
```swift
.padding(24)
.background(StackTheme.cardBackground)  // CHANGED from separator
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadius))  // 16pt (was 8pt)
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadius)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 28)
```

**"Tap to leave one" prompt — more CTA-like:**
```swift
HStack(spacing: 4) {
    Text("Write one for the next person")
        .font(.system(size: 13, weight: .medium))  // CHANGED from 12pt .regular
    Image(systemName: "chevron.right")
        .font(.system(size: 10, weight: .medium))
}
.foregroundStyle(StackTheme.secondaryText)
.padding(.top, 14)
```

### 7.4 emptyPoolView — Same Card Update

```swift
.padding(24)
.background(StackTheme.cardBackground)  // CHANGED from separator
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadius))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadius)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 28)
```

### 7.5 freetierView — Gold CTA

```swift
// Unlock button inside card
Button {
    showPaywall = true
} label: {
    Text("Unlock STACK")
}
.buttonStyle(GoldCTAButtonStyle())  // NEW: gold CTA
.padding(.top, 20)
```

Card background:
```swift
.padding(24)
.background(StackTheme.cardBackground)  // CHANGED from separator
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadius))
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadius)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 28)
```

### 7.6 Footer

```swift
Text("Take your time.")
    .font(StackTypography.footnote)  // 14pt (was 13pt)
    .foregroundStyle(StackTheme.tertiaryText)
    .padding(.bottom, 48)
```

### 7.7 Entrance Timing — More Dramatic Stagger

In `.onChange(of: isLoading)`:
```swift
if !loading {
    // Message animates in
    withAnimation(reduceMotion ? .none : StackAnimation.cardEntrance) {
        messageVisible = true
    }
    // Footer fades in 500ms after message (was 200ms — give more time to read)
    let skipMotion = reduceMotion
    Task {
        if !skipMotion {
            try? await Task.sleep(nanoseconds: 500_000_000)  // CHANGED from 200ms
        }
        withAnimation(skipMotion ? .none : .easeOut(duration: 0.3)) {
            footerVisible = true
        }
    }
}
```

### 7.8 RelayWriteView — Text Editor Card

**Write prompt:**
```swift
Text(writePrompt)
    .font(StackTypography.body)  // 16pt .regular (unchanged size, uses token)
    .foregroundStyle(StackTheme.secondaryText)
```

**Text editor container:**
```swift
ZStack(alignment: .topLeading) {
    if messageText.isEmpty {
        Text(writePlaceholder)
            .font(Font.custom("Georgia", size: 18))
            .foregroundStyle(StackTheme.tertiaryText)
            .padding(.top, 8)
            .allowsHitTesting(false)
    }
    TextEditor(text: $messageText)
        .font(Font.custom("Georgia", size: 18))
        .foregroundStyle(StackTheme.primaryText)
        .scrollContentBackground(.hidden)
        .onChange(of: messageText) { _, new in
            if new.count > maxLength {
                messageText = String(new.prefix(maxLength))
            }
        }
}
.padding(16)  // CHANGED from 12
.background(StackTheme.cardBackground)  // CHANGED from ghost
.clipShape(RoundedRectangle(cornerRadius: StackTheme.cardRadius))  // 16pt (was 8pt)
.overlay(
    RoundedRectangle(cornerRadius: StackTheme.cardRadius)
        .stroke(StackTheme.cardBorder, lineWidth: 1.0)
)
.padding(.horizontal, 28)
.padding(.top, 24)
.frame(minHeight: 200)
```

**Character count — color changes near limit:**
```swift
Text("\(maxLength - messageText.count)")
    .font(StackTypography.caption)
    .foregroundStyle(
        (maxLength - messageText.count) < 50
            ? StackTheme.gold  // Gold warning when under 50
            : StackTheme.tertiaryText
    )
    .frame(maxWidth: .infinity, alignment: .trailing)
    .padding(.horizontal, 28)
    .padding(.top, 8)
```

**"Send forward" button — Gold CTA:**
```swift
Button {
    Task { await submit() }
} label: {
    Group {
        if sentForward {
            HStack(spacing: 6) {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .medium))
                Text("Sent forward.")
            }
        } else if isSubmitting {
            ProgressView()
                .tint(StackTheme.background)
        } else {
            Text("Send forward")
        }
    }
}
.buttonStyle(GoldCTAButtonStyle())
.disabled(
    isSubmitting ||
    messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
    sentForward
)
.opacity(
    (isSubmitting || messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || sentForward)
    ? 0.5 : 1.0
)
.padding(.horizontal, 28)
```

### Acceptance Criteria
- [ ] Loading state shows 3 animated pulsing dots (not plain text)
- [ ] All message cards use cardBackground (not separator), 16pt radius (not 8pt)
- [ ] Cards have 0.5pt border overlay
- [ ] Free-tier unlock button uses GoldCTAButtonStyle
- [ ] "Send forward" button uses GoldCTAButtonStyle
- [ ] Character count turns gold when < 50 remaining
- [ ] "Sent forward" shows checkmark icon
- [ ] Text editor uses cardBackground (not ghost), 16pt radius
- [ ] Footer stagger delay is 500ms (not 200ms)
- [ ] loadingDotPhase state variable added

---

## Task 8: Paywall & Sign In Redesign (TWO-354)

**Files:** `ios/STACK/Views/Paywall/PaywallView.swift`, `ios/STACK/Views/Auth/SignInView.swift`
**Depends on:** Task 1

### 8.1 PaywallView — Feature List + Gold CTA

**Title:**
```swift
Text("The relay.")
    .font(StackTypography.title)  // 34pt .regular (was .light)
    .foregroundStyle(StackTheme.primaryText)
```

**Description** — center-aligned:
```swift
Text("Anonymous messages from people who reached the same milestones. Read theirs. Leave one for the next person.")
    .font(.system(size: 17, weight: .regular))
    .foregroundStyle(StackTheme.secondaryText)
    .lineSpacing(4)
    .multilineTextAlignment(.center)  // NEW
    .padding(.top, 16)
```

**NEW: Feature list** — add between description and price:
```swift
VStack(spacing: 16) {
    featureRow(icon: "envelope.open", text: "Read every relay message")
    featureRow(icon: "pencil.line", text: "Write messages forward")
    featureRow(icon: "infinity", text: "Unlimited, forever")
}
.padding(.top, 32)
```

Add helper method:
```swift
private func featureRow(icon: String, text: String) -> some View {
    HStack(spacing: 14) {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(StackTheme.gold)
            .frame(width: 24)
        Text(text)
            .font(StackTypography.body)
            .foregroundStyle(StackTheme.primaryText)
        Spacer()
    }
}
```

**Price:**
```swift
if !priceString.isEmpty {
    Text("\(priceString) · one time · forever")
        .font(.system(size: 15, weight: .medium))  // CHANGED: .medium
        .foregroundStyle(StackTheme.gold)  // CHANGED: gold color
        .padding(.top, 24)
}
```

**Center the content block:**
```swift
// Wrap the title + description + features + price in a centered VStack
VStack(spacing: 0) {
    // ... all content centered
}
.padding(.horizontal, 28)
.multilineTextAlignment(.center)
```

**CTA button — Gold:**
```swift
Button {
    if loadFailed {
        Task { await loadOffering() }
    } else {
        Task { await purchase() }
    }
} label: {
    Group {
        if isLoadingOffering || isPurchasing {
            ProgressView()
                .tint(StackTheme.background)
        } else if loadFailed {
            Text("Retry")
        } else {
            Text("Unlock STACK")
        }
    }
}
.buttonStyle(GoldCTAButtonStyle())
.disabled(buttonDisabled && !loadFailed)
.opacity(buttonDisabled && !loadFailed ? 0.5 : 1.0)
```

**Restore purchases — slight contrast bump:**
```swift
Text("Restore purchases")
    .font(.system(size: 13, weight: .regular))
    .foregroundStyle(StackTheme.secondaryText)  // CHANGED from tertiaryText
```

### 8.2 SignInView — Feature Card + Title Weight

**Title:**
```swift
Text("Keep your\nprogress safe.")
    .font(.system(size: 42, weight: .regular))  // CHANGED from .light
    .foregroundStyle(StackTheme.primaryText)
```

**NEW: Value prop card** — add between description and Apple button:
```swift
StackCard(padding: 20, radius: StackTheme.cardRadiusSmall) {
    VStack(alignment: .leading, spacing: 16) {
        signInFeatureLine(icon: "icloud", text: "Syncs across all your devices")
        signInFeatureLine(icon: "arrow.clockwise", text: "Survives reinstalls and upgrades")
        signInFeatureLine(icon: "lock.shield", text: "Private and secure")
    }
}
.padding(.horizontal, 28)
.padding(.top, 32)
```

Add helper:
```swift
private func signInFeatureLine(icon: String, text: String) -> some View {
    HStack(spacing: 12) {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(StackTheme.secondaryText)
            .frame(width: 20)
        Text(text)
            .font(StackTypography.callout)
            .foregroundStyle(StackTheme.primaryText)
    }
}
```

### Acceptance Criteria
- [ ] PaywallView title uses .regular weight (not .light)
- [ ] Feature list with 3 gold-icon rows appears between description and price
- [ ] Price text uses .medium weight and gold color
- [ ] "Unlock STACK" button uses GoldCTAButtonStyle
- [ ] PaywallView content is center-aligned
- [ ] SignInView title uses .regular weight (not .light)
- [ ] SignInView shows a feature card with 3 icon rows
- [ ] "Restore purchases" uses secondaryText (not tertiaryText)

---

## Task 9: ContentView & Tab Bar Polish (TWO-353)

**File:** `ios/STACK/ContentView.swift`
**Depends on:** Tasks 2-8 (final polish after all screens are done)

### 9.1 Tab Bar Tint — Keep

```swift
.tint(StackTheme.primaryText)  // unchanged — this works
```

### 9.2 Consider Tab Bar Background

If the default tab bar background doesn't match the new card aesthetic, add:
```swift
.toolbarBackground(StackTheme.cardBackground, for: .tabBar)
.toolbarBackgroundVisibility(.visible, for: .tabBar)
```

Only apply this if the default translucent tab bar looks off against the new card-based layouts. The executor should verify visually and only add if needed.

### Acceptance Criteria
- [ ] Tab bar looks correct against new card-based screens
- [ ] No visual glitches when switching between tabs
- [ ] Onboarding → SignIn → Main flow transition is smooth

---

## Dependency Graph

```
Task 1 (Theme Foundation)
    ├── Task 2 (Today View)
    ├── Task 3 (Onboarding)
    ├── Task 4 (Stacks & Card Views)
    ├── Task 5 (Journey View)
    ├── Task 6 (Settings View)
    ├── Task 7 (Milestone Moment & Relay Write)
    └── Task 8 (Paywall & Sign In)
            └── Task 9 (ContentView & Tab Bar Polish)
```

Tasks 2-8 can ALL run in parallel after Task 1 completes.
Task 9 should run last as a final integration check.

---

## What to DELETE (across all files)

1. All `.font(.system(size: X, weight: .thin))` — replace with `.light` minimum
2. All `.font(.system(size: X, weight: .light))` for sizes 22pt+ — replace with `.regular` or `.medium`
3. Full-width separator lines between list items — replaced by card spacing
4. In StacksView: `StackTheme.separator.frame(height: 0.5).padding(.leading, 80)` — DELETE all instances
5. In SettingsView: Full-width `StackTheme.separator` between sections — keep only within-card separators
6. The `entranceAnimation` extension from OnboardingContainerView (moved to Theme.swift)
7. `StackPressButtonStyle` from OnboardingContainerView (consolidated into `PressScaleButtonStyle` in Theme.swift)

## What NOT to Change

1. Georgia font for relay messages — keep exactly as-is
2. Gold (#C8A96E) on chip circles in StacksView — keep (but extend to CTAs)
3. Dark background #0C0B09 — keep
4. `.preferredColorScheme(.dark)` — keep
5. All functional logic (pledging, relay loading, purchases) — ZERO behavior changes
6. RevenueCat integration — no changes
7. Supabase service calls — no changes
8. Widget data flow — no changes
9. `StackExportView` size (390x500) — keep for share image
