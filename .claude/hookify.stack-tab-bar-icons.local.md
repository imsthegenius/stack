---
name: stack-tab-bar-icons
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.swift$
  - field: new_text
    operator: regex_match
    pattern: \.tabItem\s*\{[^}]*systemImage|\.tabItem\s*\{[^}]*Label\(
action: block
---

**BLOCKED — No SF Symbols in tab bar**

STACK's tab bar is TEXT-ONLY. No icons. No SF Symbols.

The correct pattern is:
```swift
.tabItem { Text("Today") }
.tabItem { Text("Stacks") }
.tabItem { Text("Journey") }
.tabItem { Text("Settings") }
```

Never use `Label("...", systemImage: "...")` or `Image(systemName:)` in `.tabItem`.
