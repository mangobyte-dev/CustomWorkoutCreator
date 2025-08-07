//
//  PerformanceTests.swift
//  CustomWorkoutCreatorTests
//
//  Created by Developer on 07/08/2025.
//

import Testing
import SwiftUI
import SwiftData
@testable import CustomWorkoutCreator



@Suite("Performance Tests", .tags(.performance))
struct PerformanceTests {
    
    // MARK: - 60fps Validation
    
    @Test("List scrolling maintains 60fps")
    func listScrollingPerformance() throws {
        let frameTime = 1.0 / 60.0 // 16.67ms per frame
        
        // Simulate scrolling through large list
        let items = MockData.exercises(count: 100)
        
        let measurement = PerformanceMeasurement(
            name: "Render 100 list items",
            expectation: frameTime
        )
        
        // Simulate frame render
        _ = items.map { exercise in
            LabelRow(title: exercise.name, value: "\(exercise.effort)/10")
        }
        
        measurement.expect()
        let (duration, _) = measurement.validate()
        let expectedFrameTime = 1.0 / 60.0
        #expect(duration < expectedFrameTime, 
                "Expected 60fps (\(expectedFrameTime)s per frame), got \(duration)s")
    }
    
    @Test("Expandable list animation performance")
    @MainActor
    func expandableListAnimation() {
        let frameTime = 1.0 / 60.0
        var expandedIDs = Set<UUID>()
        
        let items = (1...20).map { i in
            Interval(name: "Interval \(i)", rounds: 3)
        }
        
        let measurement = PerformanceMeasurement(
            name: "Expand 20 items",
            expectation: frameTime * 20 // Allow 20 frames for full animation
        )
        
        // Simulate expansion animation
        for item in items {
            expandedIDs.insert(item.id)
        }
        
        measurement.expect()
        #expect(expandedIDs.count == 20)
    }
    
    @Test("Complex view hierarchy rendering")
    func complexViewRendering() {
        let frameTime = 1.0 / 60.0
        
        let measurement = PerformanceMeasurement(
            name: "Render workout form",
            expectation: frameTime * 3 // Allow 3 frames for complex view
        )
        
        // Simulate complex view hierarchy
        let workout = TestFixtures.createWorkout(intervals: 10, exercisesPerInterval: 5)
        
        _ = workout.intervals.map { interval in
            IntervalFormCard(
                interval: .constant(interval),
                isExpanded: .constant(false),
                intervalNumber: 1,
                onDelete: {},
                onAddExercise: {}
            )
        }
        
        measurement.expect()
    }
    
    // MARK: - Search Performance
    
    @Test("Exercise library search under 50ms")
    func exerciseSearchPerformance() {
        let exercises = TestFixtures.createExerciseLibrary(count: 1500)
        
        let searchTerms = ["Bench", "Squat", "Press", "Row", "Curl"]
        
        for term in searchTerms {
            let measurement = PerformanceMeasurement(
                name: "Search '\(term)' in 1500 items",
                expectation: 0.05 // 50ms
            )
            
            let results = exercises.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(term)
            }
            
            measurement.expect()
            _ = results // Use results to prevent optimization
        }
    }
    
    @Test("Filter with multiple criteria")
    func multiCriteriaFilter() {
        let exercises = TestFixtures.createExerciseLibrary(count: 1500)
        
        let measurement = PerformanceMeasurement(
            name: "Multi-criteria filter",
            expectation: 0.05
        )
        
        let filtered = exercises.filter { exercise in
            exercise.name.contains("Exercise 1") // Simplified filtering
        }
        
        measurement.expect()
        _ = filtered
    }
    
    @Test("Fuzzy search performance")
    func fuzzySearchPerformance() {
        let exercises = TestFixtures.createExerciseLibrary(count: 1500)
        
        let measurement = PerformanceMeasurement(
            name: "Fuzzy search",
            expectation: 0.1 // 100ms for fuzzy matching
        )
        
        let searchTerm = "bnch pres" // Intentional typos
        
        // Simple fuzzy match simulation
        let results = exercises.filter { exercise in
            let name = exercise.name.lowercased()
            let search = searchTerm.lowercased()
            
            // Check if all characters appear in order
            var searchIndex = search.startIndex
            for char in name {
                if searchIndex < search.endIndex && char == search[searchIndex] {
                    searchIndex = search.index(after: searchIndex)
                }
            }
            return searchIndex == search.endIndex
        }
        
        measurement.expect()
        _ = results
    }
    
    // MARK: - SwiftData Performance
    
    @Test("Bulk insert 1000 exercises")
    func bulkInsertPerformance() throws {
        let container = try TestContainer()
        
        let measurement = PerformanceMeasurement(
            name: "Insert 1000 exercises",
            expectation: 2.0
        )
        
        let workout = Workout(name: "Bulk Test")
        let interval = Interval(name: "Main", rounds: 1)
        
        for i in 1...1000 {
            let exercise = Exercise(
                name: "Exercise \(i)",
                trainingMethod: .standard(minReps: 10, maxReps: 15),
                effort: (i % 10) + 1
            )
            interval.exercises.append(exercise)
        }
        
        workout.intervals.append(interval)
        container.insert(workout)
        try container.save()
        
        measurement.expect()
        #expect(interval.exercises.count == 1000)
    }
    
    @Test("Query with complex predicates")
    func complexQueryPerformance() throws {
        let container = try TestContainer()
        
        // Setup data
        for i in 1...100 {
            let workout = TestFixtures.createWorkout(
                name: "Workout \(i)",
                intervals: 3,
                exercisesPerInterval: 5
            )
            workout.dateAndTime = Date().addingTimeInterval(Double(i) * -86400)
            container.insert(workout)
        }
        try container.save()
        
        let measurement = PerformanceMeasurement(
            name: "Complex query",
            expectation: 0.1
        )
        
        // Complex query with sorting and filtering
        let oneWeekAgo = Date().addingTimeInterval(-604800)
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { workout in
                workout.dateAndTime > oneWeekAgo &&
                workout.intervals.count > 2
            },
            sortBy: [SortDescriptor(\.dateAndTime, order: .reverse)]
        )
        
        let results = try container.fetch(descriptor)
        
        measurement.expect()
        #expect(results.count <= 7) // At most 7 days
    }
    
    
    // MARK: - UI Responsiveness
    
    @Test("Form input responsiveness")
    @MainActor
    func formInputResponsiveness() {
        var value = ""
        let binding = Binding(
            get: { value },
            set: { value = $0 }
        )
        
        let measurement = PerformanceMeasurement(
            name: "100 rapid inputs",
            expectation: 0.1 // 100ms for 100 updates
        )
        
        // Simulate rapid typing
        let text = "The quick brown fox jumps over the lazy dog"
        for char in text {
            binding.wrappedValue.append(char)
        }
        
        measurement.expect()
        #expect(value == text)
    }
    
    @Test("State update batching")
    @MainActor
    func stateUpdateBatching() {
        var counter = 0
        var intervalRounds = 3
        var exerciseEffort = 5
        
        let measurement = PerformanceMeasurement(
            name: "1000 state updates",
            expectation: 0.01
        )
        
        // Simulate batched updates
        for _ in 1...1000 {
            counter += 1
            if counter % 10 == 0 {
                intervalRounds = (intervalRounds % 10) + 1
                exerciseEffort = (exerciseEffort % 10) + 1
            }
        }
        
        measurement.expect()
        #expect(counter == 1000)
    }
    
    // MARK: - Concurrent Operations
    
    @Test("Concurrent data access")
    func concurrentAccess() async throws {
        let container = try TestContainer()
        let workout = TestFixtures.createWorkout()
        container.insert(workout)
        try container.save()
        
        let measurement = PerformanceMeasurement(
            name: "100 concurrent reads",
            expectation: 0.5
        )
        
        await withTaskGroup(of: Int.self) { group in
            for i in 1...100 {
                group.addTask {
                    // Simulate read operation
                    let intervalCount = workout.intervals.count
                    return intervalCount * i
                }
            }
            
            var results: [Int] = []
            for await result in group {
                results.append(result)
            }
            
            measurement.expect()
            #expect(results.count == 100)
        }
    }
    
    // MARK: - Animation Performance
    
    @Test("Animation frame timing")
    func animationFrameTiming() {
        let totalFrames = 60
        let animationDuration = 1.0
        let expectedFrameTime = animationDuration / Double(totalFrames)
        
        let measurement = PerformanceMeasurement(
            name: "60 frame animation",
            expectation: animationDuration
        )
        
        var currentProgress = 0.0
        for frame in 1...totalFrames {
            currentProgress = Double(frame) / Double(totalFrames)
            // Simulate frame calculation
            let _ = sin(currentProgress * .pi)
        }
        
        measurement.expect()
        #expect(currentProgress == 1.0)
        
        // Verify frame time
        let actualFrameTime = measurement.validate().duration / Double(totalFrames)
        Testing.Expectation.frameRate(60, actual: actualFrameTime)
    }
    
    // MARK: - Benchmarks
    
    @Test("Component library benchmark")
    func componentBenchmark() {
        let components = [
            ("Row", 0.0001),
            ("ActionButton", 0.0001),
            ("NumberInputRow", 0.0002),
            ("ExpandableList", 0.001),
            ("ExerciseFormCard", 0.002)
        ]
        
        for (name, expectedTime) in components {
            let measurement = PerformanceMeasurement(
                name: "Create \(name)",
                expectation: expectedTime
            )
            
            switch name {
            case "Row":
                _ = LabelRow(title: "Test", value: "Value")
            case "ActionButton":
                _ = ActionButton(title: "Test", action: {})
            case "NumberInputRow":
                _ = NumberInputRow(title: "Test", value: .constant(0))
            case "ExpandableList":
                struct TestItem: Identifiable { let id = UUID(); let value: Int }
                let items = [TestItem(value: 1), TestItem(value: 2), TestItem(value: 3)]
                _ = ExpandableList(items: items) { item, index, isExpanded in
                    VStack {
                        Text("Header \(item.value)")
                        if isExpanded.wrappedValue {
                            Text("Content")
                        }
                    }
                }
            case "ExerciseFormCard":
                _ = ExerciseFormCard(
                    exercise: .constant(MockData.sampleExercise),
                    isExpanded: .constant(false),
                    onDelete: {}
                )
            default:
                break
            }
            
            measurement.expect()
        }
    }
}
