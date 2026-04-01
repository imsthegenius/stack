---
name: stack-no-celebrations
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.swift$
  - field: new_text
    operator: regex_match
    pattern: confetti|particle|Confetti|ParticleEffect|CAEmitterLayer|CAEmitterCell|UNUserNotificationCenter|UNNotification|requestAuthorization.*\.alert|\.badge|"You're amazing|"Great job|"Well done|"Keep it up
action: block
---

**BLOCKED — Forbidden patterns in STACK**

STACK does not use:
- Confetti or particle effects
- Push notifications of any kind
- Motivational/wellness copy ("You're amazing!", "Great job!", etc.)

The app's tone is restrained and dignified. No celebration animations. No push notifications. No cheerleading.
