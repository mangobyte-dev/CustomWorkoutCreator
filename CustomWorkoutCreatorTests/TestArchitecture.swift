//
//  TestArchitecture.swift
//  CustomWorkoutCreatorTests
//
//  Created by Developer on 07/08/2025.
//

import Testing
import SwiftUI
import SwiftData
@testable import CustomWorkoutCreator

// MARK: - Test Fixtures

enum TestFixtures {
    static func createWorkout(
        name: String = "Test Workout",
        intervals: Int = 3,
        exercisesPerInterval: Int = 4
    ) -> Workout {
        let workout = Workout(name: name)
        
        for i in 1...intervals {
            let interval = Interval(
                name: "Interval \(i)",
                rounds: 3,
                restBetweenRounds: 60,
                restAfterInterval: 90
            )
            
            for j in 1...exercisesPerInterval {
                let exercise = Exercise(
                    name: "Exercise \(i)-\(j)",
                    trainingMethod: .standard(minReps: 10, maxReps: 15),
                    effort: min(10, 5 + j),
                    weight: Double(100 + j * 10),
                    restAfter: 45
                )
                interval.exercises.append(exercise)
            }
            
            workout.intervals.append(interval)
        }
        
        return workout
    }
    
    static func createExerciseLibrary(count: Int = 100) -> [ExerciseData] {
        (1...count).map { i in
            ExerciseData(
                exerciseId: "exercise-\(i)",
                name: "Exercise \(i)"
            )
        }
    }
    
    static func createSampleWorkout() -> Workout {
        createWorkout(name: "Sample Workout", intervals: 3, exercisesPerInterval: 4)
    }
    
    static func createComplexWorkout() -> Workout {
        createWorkout(name: "Complex Workout", intervals: 5, exercisesPerInterval: 6)
    }
    
    static func createExerciseItems(_ count: Int) -> [ExerciseItem] {
        (1...count).map { i in
            ExerciseItem(
                name: "Exercise Item \(i)",
                gifUrl: i % 10 == 0 ? "exercise-\(i)" : nil
            )
        }
    }
}

// MARK: - Test Container

struct TestContainer {
    let container: ModelContainer
    let context: ModelContext
    
    init() throws {
        let config = ModelConfiguration(
            isStoredInMemoryOnly: true,
            allowsSave: true
        )
        
        container = try ModelContainer(
            for: Workout.self,
            Interval.self,
            Exercise.self,
            configurations: config
        )
        
        context = ModelContext(container)
        context.autosaveEnabled = false
    }
    
    func save() throws {
        try context.save()
    }
    
    func insert(_ model: any PersistentModel) {
        context.insert(model)
    }
    
    func delete(_ model: any PersistentModel) {
        context.delete(model)
    }
    
    func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
        try context.fetch(descriptor)
    }
    
    static func makeInMemory() throws -> TestContainer {
        try TestContainer()
    }
}

// MARK: - Performance Measurement

struct PerformanceMeasurement {
    private let startTime: Date
    private let name: String
    private let expectation: TimeInterval
    
    init(name: String, expectation: TimeInterval = 0.1) {
        self.name = name
        self.expectation = expectation
        self.startTime = Date()
    }
    
    func validate() -> (duration: TimeInterval, passed: Bool) {
        let duration = Date().timeIntervalSince(startTime)
        let passed = duration < expectation
        return (duration, passed)
    }
    
    func expect() {
        let (duration, passed) = validate()
        #expect(passed, "Performance test '\(name)' took \(duration)s, expected < \(expectation)s")
    }
}

// MARK: - Test Environment

struct TestEnvironment {
    let container: TestContainer
    
    init() throws {
        container = try TestContainer()
    }
    
    func createEnvironment() -> EnvironmentValues {
        var values = EnvironmentValues()
        values.modelContext = container.context
        return values
    }
}

// MARK: - Expectation Extensions

extension Testing.Expectation {
    static func frameRate(_ fps: Double, actual: TimeInterval) {
        let expectedFrameTime = 1.0 / fps
        #expect(actual < expectedFrameTime, 
                "Expected \(fps)fps (\(expectedFrameTime)s per frame), got \(actual)s")
    }
}

// MARK: - Test Tags

extension Tag {
    @Tag static var unit: Self
    @Tag static var integration: Self
    @Tag static var performance: Self
    @Tag static var swiftData: Self
    @Tag static var component: Self
    @Tag static var view: Self
    @Tag static var workflow: Self
}

// MARK: - Mock Data

struct MockData {
    static let sampleExercise = Exercise(
        name: "Bench Press",
        trainingMethod: .standard(minReps: 8, maxReps: 12),
        effort: 8,
        weight: 185,
        restAfter: 120,
        tempo: .controlled,
        notes: "Keep core tight"
    )
    
    static let sampleInterval = Interval(
        name: "Main Set",
        rounds: 5,
        restBetweenRounds: 90,
        restAfterInterval: 180
    )
    
    static let sampleWorkout = Workout(
        name: "Upper Body Day",
        dateAndTime: Date()
    )
    
    static func exercises(count: Int) -> [Exercise] {
        (1...count).map { i in
            Exercise(
                name: "Exercise \(i)",
                trainingMethod: [
                    TrainingMethod.standard(minReps: 10, maxReps: 15),
                    TrainingMethod.restPause(targetTotal: 50),
                    TrainingMethod.timed(seconds: 60)
                ].randomElement()!,
                effort: (i % 10) + 1,
                weight: Double(i * 10),
                restAfter: 30 + (i % 4) * 15
            )
        }
    }
}

// MARK: - Async Test Helpers

struct AsyncTestHelper {
    static func waitFor(
        _ condition: @escaping () async -> Bool,
        timeout: TimeInterval = 5.0,
        message: String = "Condition not met"
    ) async throws {
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < timeout {
            if await condition() {
                return
            }
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        Issue.record("Timeout: \(message)")
    }
}

// MARK: - SwiftUI Test Helpers

@MainActor
struct ViewTestHelper {
    static func renderView<V: View>(
        _ view: V,
        environment: @escaping (inout EnvironmentValues) -> Void = { _ in }
    ) -> some View {
        var envValues = EnvironmentValues()
        environment(&envValues)
        // Return the view with environment modifications applied via transformEnvironment
        return view.transformEnvironment(\.self) { env in
            environment(&env)
        }
    }
    
    static func testBinding<T>(_ initialValue: T) -> Binding<T> {
        var value = initialValue
        return Binding(
            get: { value },
            set: { value = $0 }
        )
    }
}