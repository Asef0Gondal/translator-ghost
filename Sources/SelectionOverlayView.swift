import SwiftUI

struct SelectionOverlayView: View {
    @ObservedObject var appDelegate: AppDelegate
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Outer glowing border
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        appDelegate.isGhostMode ? 
                            Color(red: 0.1, green: 0.8, blue: 0.9) : 
                            Color(red: 0.55, green: 0.2, blue: 0.95),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: appDelegate.isGhostMode ? [8, 4] : [])
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(appDelegate.isGhostMode ? Color.clear : Color.black.opacity(0.03))
                    )
                    .shadow(color: appDelegate.isGhostMode ? 
                        Color(red: 0.1, green: 0.8, blue: 0.9).opacity(0.3) : 
                        Color(red: 0.55, green: 0.2, blue: 0.95).opacity(0.3), radius: 6)
                
                // Floating status badge inside the frame
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(appDelegate.isGhostMode ? Color(red: 0.1, green: 0.8, blue: 0.9) : Color(red: 0.55, green: 0.2, blue: 0.95))
                                .frame(width: 8, height: 8)
                            
                            Text(appDelegate.isGhostMode ? "GHOST ACTIVE (CLICK-THROUGH)" : "DRAG & RESIZE SELECTION AREA")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.75))
                        .cornerRadius(6)
                        .padding([.top, .trailing], 8)
                    }
                    Spacer()
                }
            }
        }
    }
}
