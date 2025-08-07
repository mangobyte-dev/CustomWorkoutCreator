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
            Giffy(filePath: url)
                .aspectRatio(contentMode: .fit)
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
        // Debug: Try multiple approaches
        
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
        
        // Debug: List what's actually in the bundle
        print("🔍 Searching for: '\(name).gif'")
        print("🔍 Main bundle path: \(Bundle.main.bundlePath)")
        
        // Try to find any GIF files to understand the structure
        if let resourcePath = Bundle.main.resourcePath {
            let fileManager = FileManager.default
            do {
                let items = try fileManager.contentsOfDirectory(atPath: resourcePath)
                let gifFiles = items.filter { $0.hasSuffix(".gif") }
                if !gifFiles.isEmpty {
                    print("🔍 Found \(gifFiles.count) GIF files in main bundle")
                    print("🔍 First few GIFs: \(gifFiles.prefix(3))")
                } else {
                    // Check subdirectories
                    let subdirs = items.filter { item in
                        var isDirectory: ObjCBool = false
                        let fullPath = (resourcePath as NSString).appendingPathComponent(item)
                        return fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) && isDirectory.boolValue
                    }
                    print("🔍 Found subdirectories: \(subdirs)")
                    
                    // Check ExerciseGIFs subdirectory specifically
                    let exerciseGIFsPath = (resourcePath as NSString).appendingPathComponent("ExerciseGIFs")
                    if fileManager.fileExists(atPath: exerciseGIFsPath) {
                        let exerciseGIFs = try fileManager.contentsOfDirectory(atPath: exerciseGIFsPath)
                        let gifCount = exerciseGIFs.filter { $0.hasSuffix(".gif") }.count
                        print("🔍 ExerciseGIFs directory contains \(gifCount) GIF files")
                    } else {
                        print("🔍 ExerciseGIFs directory not found at: \(exerciseGIFsPath)")
                    }
                }
            } catch {
                print("🔍 Error listing bundle contents: \(error)")
            }
        }
        
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
