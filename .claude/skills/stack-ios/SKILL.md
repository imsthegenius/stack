---
name: stack-ios
description: MANDATORY skill for ANY work on the STACK iOS app (~/Desktop/stack-app). Enforces design tokens, typography rules, relay system mechanics, chapter/counter behavior, widget data flow, and forbidden patterns. Trigger whenever editing Swift/SwiftUI files in stack-app, discussing STACK features, or reviewing STACK code. Also trigger for "stack app", "STACK", "pledge", "relay", "chapter", "milestone", "counter", "widget" in the context of this project.
---

# STACK iOS Development Rules

You are working on STACK — a minimal, dark, understated day-counting app for people changing habits. The app's voice is short, factual, no mystery, no sell. Think: someone carving notches into a wall, not a wellness coach.

## Design Tokens — Use These Exactly

| Token | Hex | SwiftUI | Use |
|-------|-----|---------|-----|
| Background | #0C0B09 | `StackTheme.background` | Everywhere. Flat. No gradients. |
| Primary text | #F4F2EE | `StackTheme.primaryText` | Main text, active tab icons |
| Secondary | #A09890 | `StackTheme.secondaryText` | Relay attribution, button labels |
| Tertiary | #8A857F | `StackTheme.tertiaryText` | Inactive tabs, hints, dates |
| Ghost | #2E2C2A | `StackTheme.ghost` | Unpledged ring, locked circles |
| Gold | #C8A96E | `Color(hex: "C8A96E")` | Chip circles + earned chip borders ONLY |
| Milestone white | #FFFFFF | `StackTheme.milestoneWhite` | Counter on milestone day ONLY |
| Separator | #1C1B19 | `StackTheme.separator` | List dividers |

Gold (#C8A96E) goes on chip circles in StacksView ONLY. Never on the counter number.

## Typography — No Exceptions

| Font | Where | Example |
|------|-------|---------|
| SF Pro Thin (88pt) | Hero counter number ONLY | `.font(.system(size: 88, weight: .thin))` |
| SF Pro Light | 18pt and above — titles, headers, display text | `.font(.system(size: N, weight: .light))` |
| SF Pro Regular | 17pt and below — body text, labels, buttons, legal, section headers | `.font(.system(size: N, weight: .regular))` |
| Georgia regular (19pt) | Relay message text ONLY | `Font.custom("Georgia", size: 19)` |

**FORBIDDEN**: `.medium`, `.bold`, `.semibold`, `.heavy`, `.black` anywhere in the codebase. No `.fontWeight(.bold)` or any weight heavier than `.regular`. Use `.light` for 18pt+ and `.regular` for 17pt and below (`.thin` for the counter only).

Tab bar labels must use `UIFont.systemFont(ofSize: 10, weight: .regular)` via UITabBarAppearance.

## Counter Mechanics

- Counter is ALWAYS computed: `Calendar.current.dateComponents([.day], from: startOfDay(startDate), to: startOfDay(now)).day`
- NEVER store a counter variable. NEVER increment a counter.
- On milestone day: counter color = `StackTheme.milestoneWhite` (#FFFFFF)
- On non-milestone day: counter color = `StackTheme.primaryText` (#F4F2EE)
- `Chapter.startDate` is `let` (immutable). To change it, create a new Chapter struct.

## Pledge Mechanics

- Ring: `Circle().trim(from: 0, to: pledgedToday ? 1.0 : 0.0)` overlaid on counter
- One pledge per day. Cannot undo. If already pledged, tap does nothing (except on milestone/fullscreen relay day → opens MilestoneMomentView)
- Confirmation text appears below counter after pledge (currently "Locked in.")
- `todayPledgeDate` is local-only (per-device-per-day)

## Chapter Rules

- A new chapter = old chapter gets `endDate = today`, new Chapter created
- Old chapters are NEVER deleted — always visible in Journey
- `totalDays` = sum of all chapter `daysCount`

## Relay System

Two parallel systems that MUST stay aligned:
- `RelayPoint.allRelayPoints` in Milestone.swift — client-side relay cadence
- `relay_points` table in Supabase — server-side relay cadence
- `Milestone.allDays` — the subset of relay points that are milestones (used in StacksView)

These must always be in sync. If you add a relay point, add it in all three places.

### Relay flow
1. Pre-pledge on relay day: nothing shown (no teasing what doesn't exist)
2. User pledges → `relayLoading = true` → 1.5s delay
3. During delay: "Someone left you something." shows (loading state)
4. `showInlineRelayMessage()` fetches from Supabase → message appears in Georgia font
5. If fetch returns nil: nothing shows. Don't tease what doesn't exist.
6. Fullscreen relay days: MilestoneMomentView opens instead of inline

### Relay voice
Messages are behavior-agnostic. STACK serves a spectrum from heavy addiction to casual habit change. No medical language. The common thread is "the fragility of a new commitment."

## Widget Data Flow

- `StackStore.syncWidgetData()` writes to App Group UserDefaults (`group.com.twohundred.stack`)
- Called on every `pledgeToday()`, `startNewChapter()`, and `save()`
- Widget background: `.containerBackground(.clear, for: .widget)` — NEVER #0C0B09

## Auth

- Sign in with Apple is MANDATORY. No skip option in production.
- `#if DEBUG` blocks can add skip functionality for simulator testing
- Data loss is unacceptable — Day 847 user switching phones must not lose history

## Absolutely Forbidden

- No confetti, particle effects, or celebration animations
- No "You're amazing!" or wellness copy
- No push notifications
- No SF Pro Medium, Bold, Semibold, Heavy, or Black (anywhere, ever)
- No gradients
- No gold on the counter number
- No rounded card backgrounds in lists
- No `.ultraThinMaterial` behind the hero counter number
- No warm black widget backgrounds
- No gimmicky taglines or mystery language ("Someone left something here for you" = rejected)

## App Voice Examples

Good: "Locked in.", "One at a time.", "Take your time.", "No notifications. No streaks. No social."
Bad: "You're amazing!", "Keep going champ!", "Someone left something here for you."

## Before Making Changes

1. Check which file you're editing and verify you're using the right design tokens
2. Verify all text uses `.light` (16pt+) or `.regular` (15pt and below), `.thin` for counter only
3. If touching relay code, ensure client and server cadence stay aligned
4. If touching chapters, remember `startDate` is `let`
5. Test on a relay day (use debug day picker in Settings) to verify relay flow
