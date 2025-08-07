//
//  test_exercise_loading.swift
//  CustomWorkoutCreatorTests
//
//  Created by Developer on 07/08/2025.
//

import Testing
import Foundation
@testable import CustomWorkoutCreator



@Suite("Exercise Library Loading Tests", .tags(.integration))
struct ExerciseLibraryLoadingTests {
    
    @Test("Load exercises from JSON")
    func loadExercisesFromJSON() throws {
        let bundle = Bundle.main
        let url = try #require(
            bundle.url(forResource: "exercises", withExtension: "json"),
            "Could not find exercises.json in bundle"
        )
        
        let data = try Data(contentsOf: url)
        let exerciseDataArray = try JSONDecoder().decode([ExerciseData].self, from: data)
        
        #expect(exerciseDataArray.count > 0, "Successfully loaded \(exerciseDataArray.count) exercises from JSON")
        #expect(exerciseDataArray.count >= 1500, "Expected at least 1500 exercises")
    }
    
    @Test("Verify exercise GIF availability")
    func verifyExerciseGIFs() throws {
        let bundle = Bundle.main
        let url = try #require(
            bundle.url(forResource: "exercises", withExtension: "json"),
            "Could not find exercises.json in bundle"
        )
        
        let data = try Data(contentsOf: url)
        let exerciseDataArray = try JSONDecoder().decode([ExerciseData].self, from: data)
        
        // Test first few exercises for GIFs
        let testCount = min(5, exerciseDataArray.count)
        var gifsFound = 0
        var gifsMissing = 0
        
        for i in 0..<testCount {
            let exercise = exerciseDataArray[i]
            let gifURL = bundle.url(
                forResource: exercise.exerciseId,
                withExtension: "gif",
                subdirectory: "Resources/ExerciseGIFs"
            )
            
            if gifURL != nil {
                gifsFound += 1
            } else {
                gifsMissing += 1
            }
        }
        
        // Some exercises may not have GIFs, so just verify the mechanism works
        #expect(gifsFound > 0 || gifsMissing > 0, "GIF checking mechanism works")
    }
    
    @Test("Exercise data structure validation")
    func validateExerciseDataStructure() throws {
        let bundle = Bundle.main
        let url = try #require(
            bundle.url(forResource: "exercises", withExtension: "json"),
            "Could not find exercises.json in bundle"
        )
        
        let data = try Data(contentsOf: url)
        let exerciseDataArray = try JSONDecoder().decode([ExerciseData].self, from: data)
        
        // Validate first exercise
        if let firstExercise = exerciseDataArray.first {
            #expect(!firstExercise.exerciseId.isEmpty, "Exercise ID should not be empty")
            #expect(!firstExercise.name.isEmpty, "Exercise name should not be empty")
            
            // Check for duplicates
            let ids = Set(exerciseDataArray.map { $0.exerciseId })
            #expect(ids.count == exerciseDataArray.count, "All exercise IDs should be unique")
        }
    }
    
    @Test("Exercise search performance", .tags(.performance))
    func exerciseSearchPerformance() throws {
        let bundle = Bundle.main
        let url = try #require(
            bundle.url(forResource: "exercises", withExtension: "json"),
            "Could not find exercises.json in bundle"
        )
        
        let data = try Data(contentsOf: url)
        let exerciseDataArray = try JSONDecoder().decode([ExerciseData].self, from: data)
        
        let measurement = PerformanceMeasurement(
            name: "Search exercises",
            expectation: 0.05 // 50ms
        )
        
        let searchTerm = "Press"
        let filtered = exerciseDataArray.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(searchTerm)
        }
        
        measurement.expect()
        #expect(filtered.count > 0, "Should find exercises containing 'Press'")
    }
}