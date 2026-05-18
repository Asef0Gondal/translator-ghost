import Foundation
import Cocoa
import Vision

class CaptureEngine: ObservableObject {
    @Published var recognizedText: String = ""
    @Published var isPermissionDenied: Bool = false
    
    private let tempImagePath = "/tmp/translator_ghost_capture.png"
    
    func captureRegion(rect: NSRect, completion: @escaping (String) -> Void) {
        // Clear any previous temp image
        try? FileManager.default.removeItem(atPath: tempImagePath)
        
        // Convert screen coordinates (SwiftUI/Cocoa window coordinates vs screen coordinates)
        // screencapture expects origin at top-left of primary screen.
        guard let mainScreen = NSScreen.screens.first else {
            completion("")
            return
        }
        
        let screenHeight = mainScreen.frame.height
        // Cocoa origin is bottom-left, screencapture origin is top-left
        let captureY = screenHeight - (rect.origin.y + rect.size.height)
        let captureX = rect.origin.x
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = [
            "-R\(Int(captureX)),\(Int(captureY)),\(Int(rect.size.width)),\(Int(rect.size.height))",
            "-x", // silent mode (no shutter sound)
            tempImagePath
        ]
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus != 0 {
                // If exit code is non-zero, permission is likely denied
                DispatchQueue.main.async {
                    self.isPermissionDenied = true
                }
                completion("")
                return
            }
            
            // Read captured image and run OCR
            if FileManager.default.fileExists(atPath: tempImagePath) {
                performOCR(on: tempImagePath) { text in
                    completion(text)
                }
            } else {
                completion("")
            }
        } catch {
            print("Failed to run screencapture process: \(error.localizedDescription)")
            completion("")
        }
    }
    
    private func performOCR(on path: String, completion: @escaping (String) -> Void) {
        guard let image = NSImage(contentsOfFile: path),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion("")
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }
            
            // Extract recognized strings
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            // Join strings with natural breaks
            let fullText = recognizedStrings.joined(separator: "\n")
            completion(fullText)
        }
        
        // Prioritize Japanese and Chinese languages
        request.recognitionLanguages = ["ja-JP", "zh-Hans", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Vision OCR failed: \(error.localizedDescription)")
            completion("")
        }
    }
}
