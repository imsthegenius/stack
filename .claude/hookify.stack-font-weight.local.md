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
    pattern: weight:\s*\.(thin|bold|semibold|heavy|black)|\.fontWeight\(\.(thin|bold|semibold|heavy|black)\)
action: block
---

**BLOCKED — Forbidden font weight in STACK**

STACK v2 design system uses these font weights:
- `SF Pro Light` (`.light`) — hero counter (88pt) ONLY
- `SF Pro Regular` (`.regular`) — body text, labels (17pt and below)
- `SF Pro Medium` (`.medium`) — ALLOWED for headlines, CTAs, overlines, section labels

`.bold`, `.semibold`, `.heavy`, `.black` are forbidden. No exceptions.
NOTE: `.thin` is also now forbidden (counter changed from .thin to .light in design overhaul).
