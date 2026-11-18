import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let statusLine = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let stopItem = NSMenuItem(title: "Arrêter", action: #selector(stop), keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Lancer au démarrage", action: #selector(toggleLogin), keyEquivalent: "")

    private var process: Process?
    private var endDate: Date?
    private var ticker: Timer?

    private let durations: [(label: String, seconds: Int)] = [
        ("30 minutes", 30 * 60), ("1 h", 3600), ("2 h", 2 * 3600), ("4 h", 4 * 3600), ("8 h", 8 * 3600),
    ]

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusLine.isEnabled = false
        stopItem.target = self
        loginItem.target = self

        let launchMenu = NSMenu()
        for (i, d) in durations.enumerated() {
            let item = NSMenuItem(title: d.label, action: #selector(startFromMenu(_:)), keyEquivalent: "")
            item.target = self
            item.tag = i
            launchMenu.addItem(item)
        }
        let launchItem = NSMenuItem(title: "Lancer pour", action: nil, keyEquivalent: "")
        launchItem.submenu = launchMenu

        let quitItem = NSMenuItem(title: "Quitter", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self

        menu.delegate = self
        [statusLine, stopItem, .separator(), launchItem, loginItem, .separator(), quitItem].forEach(menu.addItem)
        statusItem.menu = menu
        refresh()
    }

    func applicationWillTerminate(_ notification: Notification) { stop() }

    // MARK: caffeinate

    private func start(seconds: Int) {
        stop()
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        p.arguments = ["-dimst", String(seconds)]
        // caffeinate exits by itself at the end of the delay: reset the state then.
        p.terminationHandler = { [weak self] proc in
            DispatchQueue.main.async {
                guard let self, self.process === proc else { return }
                self.process = nil
                self.endDate = nil
                self.refresh()
            }
        }
        do {
            try p.run()
        } catch {
            alert("Impossible de lancer caffeinate", error.localizedDescription)
            return
        }
        process = p
        endDate = Date().addingTimeInterval(TimeInterval(seconds))
        refresh()
    }

    @objc private func stop() {
        let p = process
        process = nil
        endDate = nil
        p?.terminationHandler = nil
        p?.terminate()
        refresh()
    }

    // MARK: UI

    private func refresh() {
        let active = process != nil && endDate != nil
        statusItem.button?.image = NSImage(
            systemSymbolName: active ? "cup.and.saucer.fill" : "cup.and.saucer",
            accessibilityDescription: "Caffeinate")
        statusLine.title = active ? "Activé — \(format(endDate!.timeIntervalSinceNow)) restant" : "Désactivé"
        stopItem.isHidden = !active

        if active, ticker == nil {
            let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in self?.refresh() }
            RunLoop.main.add(t, forMode: .common)  // keeps ticking while the menu is open
            ticker = t
        } else if !active {
            ticker?.invalidate()
            ticker = nil
        }
    }

    private func format(_ interval: TimeInterval) -> String {
        let s = max(0, Int(interval.rounded(.up)))
        let h = s / 3600, m = (s % 3600) / 60, sec = s % 60
        if h > 0 { return String(format: "%d h %02d min", h, m) }
        if m > 0 { return String(format: "%d min %02d s", m, sec) }
        return "\(sec) s"
    }

    func menuWillOpen(_ menu: NSMenu) {
        refresh()
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    @objc private func startFromMenu(_ sender: NSMenuItem) {
        start(seconds: durations[sender.tag].seconds)
    }

    @objc private func toggleLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled { try service.unregister() } else { try service.register() }
            if service.status == .requiresApproval {
                alert("Approbation requise",
                      "Autorise CaffeinateBar dans Réglages Système › Général › Ouverture.")
            }
        } catch {
            alert("Lancement au démarrage impossible", error.localizedDescription)
        }
    }

    @objc private func quit() { NSApp.terminate(nil) }

    private func alert(_ title: String, _ text: String) {
        let a = NSAlert()
        a.messageText = title
        a.informativeText = text
        a.runModal()
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
