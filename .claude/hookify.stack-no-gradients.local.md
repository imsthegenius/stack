---
name: stack-no-gradients
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.swift$
  - field: new_text
    operator: regex_match
    pattern: LinearGradient|RadialGradient|AngularGradient|\.gradient|EllipticalGradient
action: block
---

**BLOCKED — No gradients in STACK**

STACK uses flat colors ONLY. Background is always `Color(hex: "0C0B09")` — solid, no gradient.

Remove the gradient and use a flat color from StackTheme instead.
