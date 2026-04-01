---
name: stack-font-weight
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.swift$
  - field: new_text
    operator: regex_match
    pattern: weight:\s*\.(medium|bold|semibold|heavy|black)|\.fontWeight\(\.(medium|bold|semibold|heavy|black)\)
action: block
---

**BLOCKED — Forbidden font weight in STACK**

STACK uses three font weights:
- `SF Pro Thin` (`.thin`) — for the 88pt hero counter ONLY
- `SF Pro Light` (`.light`) — for 18pt and above (titles, headers, display text)
- `SF Pro Regular` (`.regular`) — for 17pt and below (body, labels, buttons, legal)

`.medium`, `.bold`, `.semibold`, `.heavy`, `.black` are ALL forbidden. No exceptions.
