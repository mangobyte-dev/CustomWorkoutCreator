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
import Giffy

struct GifImageView: View {
    let name: String
    
    init(_ name: String) {
        self.name = name
        print("🎬 GifImageView init with name: '\(name)'")
    }
    
    var body: some View {
        gifContent
    }
    
    // MARK: - ViewBuilders for Performance
    
    @ViewBuilder
    private var gifContent: some View {
        if let url = gifURL {
            let _ = print("✅ GIF URL found: \(url.path)")
            
            if name.contains("_custom_") || name.hasSuffix(".jpg") || name.hasSuffix(".jpeg") {
                // Custom photos are static images, not GIFs
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
            } else {
                // Bundle GIFs use Giffy
                Giffy(filePath: url)
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            let _ = print("❌ GIF URL not found for: '\(name)'")
            placeholderContent
        }
    }
    
    @ViewBuilder
    private var placeholderContent: some View {
        Image(systemName: "figure.strengthtraining.traditional")
            .font(.title2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
    }
    
    // Pre-compute URL once with debug logging
    private var gifURL: URL? {
        // Debug logging
        print("🔍 GifImageView looking for: '\(name)'")
        
        // Check for custom images first (stored in Documents directory)
        if name.contains("_custom_") || name.hasSuffix(".jpg") || name.hasSuffix(".jpeg") {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                         in: .userDomainMask).first!
            let customPath = documentsPath.appendingPathComponent("custom_exercises").appendingPathComponent(name)
            
            if FileManager.default.fileExists(atPath: customPath.path) {
                print("✅ Found custom image: \(customPath.path)")
                return customPath
            } else {
                print("❌ Custom image not found at: \(customPath.path)")
            }
        }
        
        // Try bundle GIFs
        // Approach 1: With ExerciseGIFs subdirectory
        if let url = Bundle.main.url(forResource: name, withExtension: "gif", subdirectory: "ExerciseGIFs") {
            print("📦 Found GIF in ExerciseGIFs subdirectory: \(url.path)")
            return url
        }
        
        // Approach 2: Direct bundle lookup with extension
        if let url = Bundle.main.url(forResource: name, withExtension: "gif") {
            print("📦 Found GIF in main bundle (no subdirectory): \(url.path)")
            return url
        }
        
        // Approach 3: With Resources/ExerciseGIFs subdirectory
        if let url = Bundle.main.url(forResource: name, withExtension: "gif", subdirectory: "Resources/ExerciseGIFs") {
            print("📦 Found GIF in Resources/ExerciseGIFs: \(url.path)")
            return url
        }
        
        print("❌ Not found: '\(name)'")
        
        return nil
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
