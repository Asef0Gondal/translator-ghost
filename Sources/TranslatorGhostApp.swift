import SwiftUI
import Cocoa

@main
struct TranslatorGhostApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // We handle custom window management programmatically in AppDelegate
        // to have absolute control over transparency, floating levels, and click-through (Ghost Mode)
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var mainWindow: NSWindow!
    var selectionWindow: NSWindow!
    
    let captureEngine = CaptureEngine()
    let translationEngine = TranslationEngine()
    
    @Published var isGhostMode: Bool = false
    @Published var isScanning: Bool = true
    @Published var selectionRect: NSRect = NSRect(x: 200, y: 200, width: 600, height: 150)
    
    private var scanTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure main floating panel
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        
        // 1. Create selection overlay window
        selectionWindow = NSWindow(
            contentRect: selectionRect,
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )
        selectionWindow.isOpaque = false
        selectionWindow.backgroundColor = NSColor.clear
        selectionWindow.level = .floating
        selectionWindow.title = "Translator Selection Box"
        selectionWindow.hasShadow = false
        selectionWindow.isMovableByWindowBackground = true
        
        let overlayView = NSHostingView(rootView: SelectionOverlayView(appDelegate: self))
        selectionWindow.contentView = overlayView
        selectionWindow.makeKeyAndOrderFront(nil)
        
        // 2. Create translation display window (Main HUD)
        let mainHUDFrame = NSRect(
            x: selectionRect.origin.x,
            y: selectionRect.origin.y - 140,
            width: selectionRect.size.width,
            height: 120
        )
        
        mainWindow = NSWindow(
            contentRect: mainHUDFrame,
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )
        mainWindow.isOpaque = false
        mainWindow.backgroundColor = NSColor.clear
        mainWindow.level = .floating
        mainWindow.title = "Translator Ghost HUD"
        mainWindow.isMovableByWindowBackground = true
        mainWindow.hasShadow = true
        
        let mainView = NSHostingView(rootView: MainHUDView(appDelegate: self))
        mainWindow.contentView = mainView
        mainWindow.makeKeyAndOrderFront(nil)
        
        // Bind selection window moves to move HUD window with it
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectionWindowDidMove),
            name: NSWindow.didMoveNotification,
            object: selectionWindow
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(selectionWindowDidResize),
            name: NSWindow.didResizeNotification,
            object: selectionWindow
        )
        
        startScanning()
    }
    
    @objc private func selectionWindowDidMove() {
        guard let selectWin = selectionWindow, let mainWin = mainWindow else { return }
        let currentSelectRect = selectWin.frame
        let currentMainRect = mainWin.frame
        mainWin.setFrame(
            NSRect(
                x: currentSelectRect.origin.x,
                y: currentSelectRect.origin.y - currentMainRect.height - 10,
                width: currentSelectRect.width,
                height: currentMainRect.height
            ),
            display: true
        )
        self.selectionRect = currentSelectRect
    }
    
    @objc private func selectionWindowDidResize() {
        selectionWindowDidMove()
    }
    
    func startScanning() {
        isScanning = true
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickScan()
        }
    }
    
    func stopScanning() {
        isScanning = false
        scanTimer?.invalidate()
        scanTimer = nil
    }
    
    private func tickScan() {
        guard isScanning else { return }
        
        captureEngine.captureRegion(rect: selectionRect) { [weak self] rawText in
            guard let self = self else { return }
            
            if self.captureEngine.isPermissionDenied {
                self.stopScanning()
                return
            }
            
            let cleaned = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleaned.isEmpty else { return }
            
            self.translationEngine.translate(text: cleaned) { translated in
                DispatchQueue.main.async {
                    self.translationEngine.translatedText = translated
                    self.captureEngine.recognizedText = cleaned
                }
            }
        }
    }
    
    func toggleGhostMode() {
        isGhostMode.toggle()
        if isGhostMode {
            // Lock mode: Ignored by mouse clicks so user can click game behind it
            selectionWindow.ignoresMouseEvents = true
            selectionWindow.alphaValue = 0.5
        } else {
            // Unlock mode: Interactive window to resize and drag
            selectionWindow.ignoresMouseEvents = false
            selectionWindow.alphaValue = 1.0
        }
    }
}
