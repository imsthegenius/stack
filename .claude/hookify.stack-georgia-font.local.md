---
name: stack-georgia-font
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.swift$
  - field: new_text
    operator: regex_match
    pattern: Font\.custom\("Georgia",\s*size:\s*(?!19\b)\d+\)
action: warn
---

**Wrong Georgia font size**

Georgia is used ONLY for relay message text, and ONLY at size 19:
```swift
Font.custom("Georgia", size: 19)
```

If you're using Georgia at any other size, it's wrong. Check CLAUDE.md.
