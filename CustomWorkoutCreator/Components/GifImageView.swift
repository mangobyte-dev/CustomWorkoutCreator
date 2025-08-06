// IMPORTANT: For GIFs to work, you must add the Resources folder to Xcode:
// 1. In Xcode, right-click on CustomWorkoutCreator folder
// 2. Select "Add Files to CustomWorkoutCreator..."
// 3. Navigate to the Resources folder
// 4. SELECT "Create folder references" (blue folder icon, NOT yellow)
// 5. Ensure "Add to targets: CustomWorkoutCreator" is checked
// 6. Click "Add"
//
// This will make the ExerciseGIFs directory available in the app bundle

import SwiftUI
import WebKit

struct GifImageView: UIViewRepresentable {
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        
        // Try multiple paths to find the GIF
        if let url = Bundle.main.url(forResource: name, withExtension: "gif") {
            // GIF is in main bundle
            let data = try! Data(contentsOf: url)
            webview.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        } else if let url = Bundle.main.url(forResource: name, withExtension: "gif", subdirectory: "ExerciseGIFs") {
            // GIF is in subdirectory
            let data = try! Data(contentsOf: url)
            webview.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        } else {
            // Show placeholder
            let html = "<html><body style='background-color: #f0f0f0; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0;'><div style='text-align: center; color: #888;'>GIF not found</div></body></html>"
            webview.loadHTMLString(html, baseURL: nil)
        }
        
        webview.scrollView.isScrollEnabled = false
        webview.backgroundColor = .clear
        return webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Don't reload - causes performance issues
    }
}

/// Convenience initializer for optional GIF names
extension GifImageView {
    /// Initialize with an optional GIF filename
    /// - Parameter name: Optional name of the GIF file. If nil, shows placeholder.
    init?(_ name: String?) {
        guard let name = name, !name.isEmpty else {
            return nil
        }
        self.name = name
    }
}

#Preview("GIF Display") {
    VStack(spacing: 16) {
        // Test with actual GIF that exists in Resources
        GifImageView("01qpYSe")
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        
        // Test placeholder for missing GIF
        GifImageView("nonexistent")
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}