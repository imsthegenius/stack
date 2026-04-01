---
name: stack-skill-reminder
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.swift$
action: warn
---

You are editing a Swift file in STACK. Before writing code, invoke the `stack-ios` skill via the Skill tool if you haven't already this session. It contains the exact design tokens, forbidden patterns, relay mechanics, and component rules for this app.

Quick reference: SF Pro Light everywhere (Thin for counter only), Georgia 19pt for relay only, no gradients, tab labels via UITabBarAppearance (SF Pro Light 10pt), no .regular/.medium/.bold weights.
