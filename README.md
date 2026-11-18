# CaffeinateBar

Menu bar app (macOS 13+) that runs `caffeinate -dimst <seconds>` for 30 min, 1 h, 2 h, 4 h or 8 h,
shows the remaining time, can stop it, and can launch at login.

```bash
./build.sh   # builds, ad-hoc signs and installs ~/Applications/CaffeinateBar.app
```

- `main.swift` — the app (AppKit, no Xcode project).
- `make-icon.swift` — draws the app icon, called by `build.sh`.
