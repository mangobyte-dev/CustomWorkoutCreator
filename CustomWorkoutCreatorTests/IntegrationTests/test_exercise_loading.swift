#!/usr/bin/env swift

import Foundation

struct ExerciseData: Codable {
    let exerciseId: String
    let name: String
}

// Test JSON loading
guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
    print("❌ Could not find exercises.json in bundle")
    exit(1)
}

do {
    let data = try Data(contentsOf: url)
    let exerciseDataArray = try JSONDecoder().decode([ExerciseData].self, from: data)
    
    print("✅ Successfully loaded \(exerciseDataArray.count) exercises from JSON")
    
    // Test first few exercises
    print("\nFirst 5 exercises:")
    for i in 0..<min(5, exerciseDataArray.count) {
        let exercise = exerciseDataArray[i]
        print("  \(exercise.exerciseId) - \(exercise.name)")
        
        // Check if corresponding GIF exists
        let gifURL = Bundle.main.url(forResource: exercise.exerciseId, withExtension: "gif", subdirectory: "Resources/ExerciseGIFs")
        if gifURL != nil {
            print("    ✅ GIF found")
        } else {
            print("    ❌ GIF not found")
        }
    }
    
} catch {
    print("❌ Error loading exercises: \(error)")
    exit(1)
}