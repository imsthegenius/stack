---
name: stack-no-material-counter
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.swift$
  - field: new_text
    operator: regex_match
    pattern: \.ultraThinMaterial|\.thinMaterial|\.thickMaterial|\.regularMaterial
action: block
---

**BLOCKED — No material backgrounds in STACK**

STACK does not use `.ultraThinMaterial` or any material modifier — especially not behind the hero counter number.

Use flat colors from StackTheme (background: `Color(hex: "0C0B09")`).
