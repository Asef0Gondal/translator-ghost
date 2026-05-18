import SwiftUI

struct MainHUDView: View {
    @ObservedObject var appDelegate: AppDelegate
    @ObservedObject var translationEngine: TranslationEngine
    @ObservedObject var captureEngine: CaptureEngine
    
    @State private var showRawText: Bool = false
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        self.translationEngine = appDelegate.translationEngine
        self.captureEngine = appDelegate.captureEngine
    }
    
    var body: some View {
        ZStack {
            // Elegant dark glassmorphism card background
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1.5)
                )
            
            HStack(spacing: 16) {
                // Control Buttons Panel
                VStack(spacing: 8) {
                    // Lock Toggle (Ghost Mode)
                    Button(action: {
                        appDelegate.toggleGhostMode()
                    }) {
                        Image(systemName: appDelegate.isGhostMode ? "lock.fill" : "lock.open.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(appDelegate.isGhostMode ? Color.cyan.opacity(0.85) : Color.white.opacity(0.12))
                            .cornerRadius(10)
                            .shadow(color: appDelegate.isGhostMode ? Color.cyan.opacity(0.3) : Color.clear, radius: 4)
                    }
                    .buttonStyle(.plain)
                    .help(appDelegate.isGhostMode ? "Unlock Selection Area (Drag Mode)" : "Lock Selection Area (Ghost Mode - Click-Through)")
                    
                    // Raw/Translation Toggle
                    Button(action: {
                        showRawText.toggle()
                    }) {
                        Image(systemName: "character.bubble.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(showRawText ? Color.purple.opacity(0.85) : Color.white.opacity(0.12))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .help(showRawText ? "Show English Translation" : "Show Raw OCR Japanese/Chinese Text")
                }
                .padding(.leading, 14)
                
                // Display Area
                VStack(alignment: .leading, spacing: 4) {
                    if !appDelegate.isScanning {
                        // Pause State / Safety Stop UI
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("SCANNING IS PAUSED")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.red)
                                
                                Text(captureEngine.isPermissionDenied ? 
                                     "Screen Recording permission required. Toggle switch in Settings." :
                                     "Scanner paused manually.")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                captureEngine.isPermissionDenied = false
                                appDelegate.startScanning()
                            }) {
                                Text("RESUME SCAN")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.green.opacity(0.85))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.trailing, 16)
                    } else {
                        // Scanning Active State
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            
                            Text(showRawText ? "RAW TEXT" : "TRANSLATION")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                            
                            if translationEngine.isTranslating {
                                ProgressView()
                                    .controlSize(.small)
                                    .scaleEffect(0.6)
                                    .frame(width: 12, height: 12)
                            }
                        }
                        
                        ScrollView {
                            Text(showRawText ? captureEngine.recognizedText : translationEngine.translatedText)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(3)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(height: 70)
                    }
                }
                .padding(.vertical, 12)
                .padding(.trailing, 16)
            }
        }
        .frame(height: 120)
    }
}

// SwiftUI Helper for native macOS Glassmorphism visual effect backing
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
