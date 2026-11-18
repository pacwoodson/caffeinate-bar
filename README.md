# CaffeinateBar

Menu bar app (macOS 13+) that runs `caffeinate -dimst <seconds>` for 30 min, 1 h, 2 h, 4 h or 8 h,
shows the remaining time, can stop it, and can launch at login.

```bash
./build.sh   # builds, ad-hoc signs and installs ~/Applications/CaffeinateBar.app
```

- `main.swift` — the app (AppKit, no Xcode project).
- `make-icon.swift` — draws the app icon, called by `build.sh`.

<img width="386" height="245" alt="Capture d’écran 2026-11-18 à 09 11 32" src="https://github.com/user-attachments/assets/5f656e45-9cce-45a5-8cf2-7845bc0ded93" />
