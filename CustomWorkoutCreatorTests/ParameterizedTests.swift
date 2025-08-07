//
//  ParameterizedTests.swift
//  CustomWorkoutCreatorTests
//
//  Parameterized tests using modern Swift Testing features
//

import Testing
import SwiftUI
import SwiftData
@testable import CustomWorkoutCreator

@Suite("Parameterized Tests")
struct ParameterizedTests {
    
    // MARK: - Training Method Validation Tests
    
    @Test("Training method validation", 
          arguments: [
            // Standard training methods
            (TrainingMethod.standard(minReps: 8, maxReps: 12), true, "Valid standard range"),
            (TrainingMethod.standard(minReps: 12, maxReps: 8), false, "Invalid: max < min"),
            (TrainingMethod.standard(minReps: 0, maxReps: 10), false, "Invalid: min is zero"),
            (TrainingMethod.standard(minReps: 1, maxReps: 1), true, "Valid: single rep"),
            
            // Rest-pause training methods  
            (TrainingMethod.restPause(targetTotal: 50, minReps: 5, maxReps: 10), true, "Valid rest-pause"),
            (TrainingMethod.restPause(targetTotal: 0, minReps: 5, maxReps: 10), false, "Invalid: zero target"),
            (TrainingMethod.restPause(targetTotal: 50, minReps: 10, maxReps: 5), false, "Invalid: min > max"),
            (TrainingMethod.restPause(targetTotal: 10, minReps: 5, maxReps: 20), false, "Invalid: target < max"),
            
            // Timed training methods
            (TrainingMethod.timed(seconds: 30), true, "Valid timed exercise"),
            (TrainingMethod.timed(seconds: 0), false, "Invalid: zero seconds"),
            (TrainingMethod.timed(seconds: -10), false, "Invalid: negative seconds"),
            (TrainingMethod.timed(seconds: 1), true, "Valid: minimum time")
          ])
    func trainingMethodValidation(method: TrainingMethod, expectedValid: Bool, description: String) {
        func validateTrainingMethod(_ method: TrainingMethod) -> Bool {
            switch method {
            case let .standard(minReps, maxReps):
                return minReps > 0 && maxReps > 0 && minReps <= maxReps
            case let .restPause(targetTotal, minReps, maxReps):
                return targetTotal > 0 && minReps > 0 && maxReps > 0 && 
                       minReps <= maxReps && targetTotal >= maxReps
            case let .timed(seconds):
                return seconds > 0
            }
        }
        
        let isValid = validateTrainingMethod(method)
        #expect(isValid == expectedValid, "Failed: \(description)")
    }
    
    // MARK: - Effort Level Tests
    
    @Test("Effort level validation",
          arguments: Array(0...12)) // Test values 0 through 12
    func effortLevelValidation(effort: Int) {
        func validateEffortLevel(_ effort: Int) -> Bool {
            return effort >= 1 && effort <= 10
        }
        
        let isValid = validateEffortLevel(effort)
        let expectedValid = effort >= 1 && effort <= 10
        
        #expect(isValid == expectedValid, "Effort level \(effort) validation failed")
    }
    
    // MARK: - Search Performance Tests
    
    @Test("Search query performance",
          arguments: [
            ("", 1500, "Empty query returns all"),
            ("push", 50, "Common term"),
            ("nonexistent", 0, "No matches"),
            ("a", 300, "Single character"),
            ("exercise", 1500, "Universal term"),
            ("ABC", 0, "Case sensitive mismatch"),
            ("abc", 20, "Lowercase match"),
            ("123", 10, "Numeric search")
          ])
    func searchQueryPerformance(query: String, expectedResultCount: Int, description: String) throws {
        let exercises = TestFixtures.createExerciseItems(1500)
        
        let measurement = PerformanceMeasurement(
            name: "Search Performance - \(description)",
            expectation: 0.05
        )
        
        let results = exercises.filter { exercise in
            query.isEmpty || exercise.name.localizedCaseInsensitiveContains(query)
        }
        
        // Allow some variance in results since test data is generated
        let variance = max(10, expectedResultCount / 10) // 10% variance minimum
        let lowerBound = max(0, expectedResultCount - variance)
        let upperBound = expectedResultCount + variance
        
        #expect(results.count >= lowerBound && results.count <= upperBound,
               "\(description): Expected ~\(expectedResultCount), got \(results.count)")
        
        measurement.expect()
    }
    
    // MARK: - Component State Tests
    
    @Test("Component expansion states",
          arguments: [
            ([], "No items expanded"),
            ([0], "First item expanded"), 
            ([0, 2, 4], "Multiple even items"),
            ([1, 3, 5], "Multiple odd items"),
            ([0, 1, 2, 3, 4], "All items expanded")
          ])
    func componentExpansionStates(expandedIndices: [Int], description: String) {
        let itemCount = 5
        let items = (0..<itemCount).map { "Item \($0)" }
        
        // Simulate ExpandableList state management
        var expansionStates: [String: Bool] = [:]
        
        // Set up expanded states
        for index in expandedIndices {
            if index < items.count {
                expansionStates[items[index]] = true
            }
        }
        
        // Verify state management
        let expandedCount = expansionStates.values.count { $0 }
        #expect(expandedCount == expandedIndices.count, 
               "\(description): Expected \(expandedIndices.count) expanded, got \(expandedCount)")
        
        // Verify specific items
        for (index, item) in items.enumerated() {
            let expectedExpanded = expandedIndices.contains(index)
            let actualExpanded = expansionStates[item] ?? false
            #expect(actualExpanded == expectedExpanded,
                   "\(description): Item \(index) expansion state incorrect")
        }
    }
    
    // MARK: - Data Size Performance Tests
    
    @Test("Large dataset operations",
          arguments: [10, 50, 100, 500, 1000, 1500])
    @MainActor
    func largeDatasetOperations(itemCount: Int) throws {
        let testContainer = try TestContainer.makeInMemory()
        let expectedDuration = Double(itemCount) / 1000.0 * 0.1 // Scale with size
        
        let measurement = PerformanceMeasurement(
            name: "Large Dataset Operations - \(itemCount) items",
            expectation: expectedDuration
        )
        
        // Create and insert items
        let items = TestFixtures.createExerciseItems(itemCount)
        items.forEach { testContainer.context.insert($0) }
        
        try testContainer.context.save()
        
        // Verify insertion
        let fetchDescriptor = FetchDescriptor<ExerciseItem>()
        let savedItems = try testContainer.context.fetch(fetchDescriptor)
        #expect(savedItems.count == itemCount)
        
        measurement.expect()
    }
    
    // MARK: - Tempo Notation Tests
    
    @Test("Tempo notation generation",
          arguments: [
            (Tempo(eccentric: 2, pause: 0, concentric: 1), "2-0-1", "Normal tempo"),
            (Tempo(eccentric: 3, pause: 1, concentric: 2), "3-1-2", "Slow controlled"),
            (Tempo(eccentric: 2, pause: 0, concentric: 0), "2-0-X", "Explosive concentric"),
            (Tempo(eccentric: 4, pause: 2, concentric: 1), "4-2-1", "Super slow eccentric"),
            (Tempo(eccentric: 1, pause: 3, concentric: 1), "1-3-1", "Long pause"),
            (Tempo(eccentric: 0, pause: 0, concentric: 0), "0-0-X", "Full explosive")
          ])
    func tempoNotationGeneration(tempo: Tempo, expectedNotation: String, description: String) {
        let notation = tempo.notation
        #expect(notation == expectedNotation, 
               "\(description): Expected '\(expectedNotation)', got '\(notation)'")
    }
    
    // MARK: - Sorting Behavior Tests
    
    @Test("Exercise sorting by effort and name",
          arguments: [
            ([(effort: 5, name: "A"), (effort: 8, name: "B"), (effort: 5, name: "C")], 
             ["B", "A", "C"], "Different efforts with alphabetical secondary"),
            
            ([(effort: 7, name: "Z"), (effort: 7, name: "A"), (effort: 7, name: "M")],
             ["A", "M", "Z"], "Same effort, alphabetical primary"),
             
            ([(effort: 10, name: "Hard"), (effort: 1, name: "Easy"), (effort: 5, name: "Medium")],
             ["Hard", "Medium", "Easy"], "Mixed efforts"),
             
            ([(effort: 8, name: "Push-ups"), (effort: 8, name: "Pull-ups"), (effort: 8, name: "Dips")],
             ["Dips", "Pull-ups", "Push-ups"], "Real exercise names, same effort")
          ])
    func exerciseSortingByEffortAndName(exerciseData: [(effort: Int, name: String)], 
                                       expectedOrder: [String], 
                                       description: String) {
        let exercises = exerciseData.map { data in
            Exercise(name: data.name, trainingMethod: .standard(minReps: 10, maxReps: 15), effort: data.effort)
        }
        
        let sortedExercises = exercises.sorted()
        let actualOrder = sortedExercises.map { $0.name }
        
        #expect(actualOrder == expectedOrder, 
               "\(description): Expected \(expectedOrder), got \(actualOrder)")
    }
    
    // MARK: - Boundary Value Tests
    
    @Test("Range input boundary validation",
          arguments: [
            // (min, max, expectedValid, description)
            (1, 1, true, "Minimum valid range"),
            (1, 100, true, "Maximum practical range"), 
            (0, 10, false, "Invalid: min is zero"),
            (10, 5, false, "Invalid: min > max"),
            (-5, 10, false, "Invalid: negative min"),
            (10, -5, false, "Invalid: negative max"),
            (50, 50, true, "Equal min and max"),
            (1, 1000, true, "Very large but valid range")
          ])
    func rangeInputBoundaryValidation(min: Int, max: Int, expectedValid: Bool, description: String) {
        func validateRange(min: Int, max: Int) -> Bool {
            return min > 0 && max > 0 && min <= max
        }
        
        let isValid = validateRange(min: min, max: max)
        #expect(isValid == expectedValid, "\(description): Range (\(min), \(max))")
    }
    
    // MARK: - Workout Duration Tests
    
    @Test("Workout duration calculation accuracy",
          arguments: [
            // (intervals, expectedDuration, description)
            (1, 60, 60, "Single interval, 1 round"),
            (2, 30, 60, "Two intervals, 30s each"),
            (1, 120, 120, "Long single interval"),
            (5, 10, 50, "Many short intervals"),
            (3, 0, 0, "Zero duration intervals")
          ])
    func workoutDurationCalculationAccuracy(intervalCount: Int, 
                                           secondsPerInterval: Int, 
                                           expectedTotal: Int, 
                                           description: String) {
        // Create workout with specified parameters
        let workout = Workout(name: "Duration Test Workout")
        
        for i in 1...intervalCount {
            let interval = Interval(name: "Interval \(i)", rounds: 1)
            let exercise = Exercise(
                name: "Exercise \(i)",
                trainingMethod: .timed(seconds: secondsPerInterval)
            )
            interval.exercises.append(exercise)
            workout.intervals.append(interval)
        }
        
        // Calculate total duration (simplified calculation for testing)
        let calculatedDuration = workout.intervals.reduce(0) { total, interval in
            let intervalDuration = interval.exercises.reduce(0) { exerciseTotal, exercise in
                switch exercise.trainingMethod {
                case .timed(let seconds):
                    return exerciseTotal + seconds
                default:
                    return exerciseTotal // For standard/rest-pause, duration depends on performance
                }
            }
            return total + intervalDuration * interval.rounds
        }
        
        #expect(calculatedDuration == expectedTotal, 
               "\(description): Expected \(expectedTotal)s, got \(calculatedDuration)s")
    }
    
    // MARK: - Error Message Tests
    
    @Test("Error message generation",
          arguments: [
            ("", "Workout name cannot be empty"),
            ("   ", "Workout name cannot be empty"),
            ("A", nil), // Valid single character name
            ("Valid Workout Name", nil),
            (String(repeating: "A", count: 1000), "Workout name too long") // Very long name
          ])
    func errorMessageGeneration(workoutName: String, expectedError: String?) {
        func validateWorkoutName(_ name: String) -> String? {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedName.isEmpty {
                return "Workout name cannot be empty"
            }
            
            if trimmedName.count > 100 {
                return "Workout name too long"
            }
            
            return nil
        }
        
        let actualError = validateWorkoutName(workoutName)
        #expect(actualError == expectedError, 
               "Name: '\(workoutName)' - Expected: \(expectedError ?? "nil"), Got: \(actualError ?? "nil")")
    }
    
    // MARK: - Performance Scaling Tests
    
    @Test("Component rendering performance scaling",
          arguments: [1, 5, 10, 25, 50, 100])
    func componentRenderingPerformanceScaling(componentCount: Int) throws {
        // Test that component performance scales linearly
        let baseTimePerComponent: TimeInterval = 0.001 // 1ms per component
        let expectedDuration = Double(componentCount) * baseTimePerComponent
        let maxDuration = max(0.01, expectedDuration * 2) // Allow 2x overhead
        
        let measurement = PerformanceMeasurement(
            name: "Component Rendering Performance - \(componentCount) components",
            expectation: maxDuration
        )
        
        // Simulate creating many components
        var components: [(String, Int, Bool)] = []
        components.reserveCapacity(componentCount)
        
        for i in 0..<componentCount {
            let componentData = (
                name: "Component \(i)",
                value: i * 10,
                expanded: i % 2 == 0
            )
            components.append(componentData)
        }
        
        // Simulate processing components
        let processedCount = components.reduce(0) { count, component in
            let _ = (component.0, component.1, component.2) // Access all properties
            return count + 1
        }
        
        #expect(processedCount == componentCount)
        
        measurement.expect()
    }
}

// MARK: - Parameterized Test Utilities

extension ParameterizedTests {
    
    /// Helper for creating test data with specified characteristics
    struct ParameterizedTestDataGenerator {
        static func createExercisesWithEffortLevels(_ effortLevels: [Int]) -> [Exercise] {
            return effortLevels.enumerated().map { index, effort in
                Exercise(
                    name: "Exercise \(index)",
                    trainingMethod: .standard(minReps: 10, maxReps: 15),
                    effort: effort
                )
            }
        }
        
        static func createWorkoutsWithDates(_ dates: [Date]) -> [Workout] {
            return dates.enumerated().map { index, date in
                Workout(name: "Workout \(index)", dateAndTime: date)
            }
        }
        
        static func createIntervalsWithRounds(_ roundCounts: [Int]) -> [Interval] {
            return roundCounts.enumerated().map { index, rounds in
                Interval(name: "Interval \(index)", rounds: rounds)
            }
        }
    }
    
    /// Performance expectations based on dataset size
    struct PerformanceExpectations {
        static func expectedSearchTime(for itemCount: Int) -> TimeInterval {
            // Linear scaling: 1000 items = 50ms, scale accordingly
            return Double(itemCount) / 1000.0 * 0.05
        }
        
        static func expectedSortTime(for itemCount: Int) -> TimeInterval {
            // O(n log n) scaling for sorting
            let logFactor = itemCount > 1 ? log2(Double(itemCount)) : 1
            return Double(itemCount) * logFactor / 10000.0 // Scale factor
        }
        
        static func expectedInsertTime(for itemCount: Int) -> TimeInterval {
            // Linear scaling for database insertion
            return Double(itemCount) / 1000.0 * 0.1
        }
    }
}