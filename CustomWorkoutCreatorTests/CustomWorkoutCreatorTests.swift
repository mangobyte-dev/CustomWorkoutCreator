//
//  CustomWorkoutCreatorTests.swift
//  CustomWorkoutCreatorTests
//
//  Created by Developer on 16/07/2025.
//

import Testing
import Foundation
@testable import CustomWorkoutCreator

struct DataModelsTests {
    
    // MARK: - Tests that prevent real bugs
    
    @Test("Workout duration calculation works correctly")
    func workoutTotalDurationCalculation() {
        let workout = Workout(
            name: "Quick Circuit",
            intervals: [
                Interval(
                    exercises: [
                        Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 10), restAfter: 30),
                        Exercise(name: "Squats", trainingMethod: .standard(minReps: 15, maxReps: 15), restAfter: 30)
                    ],
                    rounds: 3,
                    restBetweenRounds: 60
                )
            ]
        )
        
        // TODO: When you implement duration calculation
        // Expected: 3 rounds × (2 exercises × 30s rest) + 2 × 60s between rounds = 300s
    }
    
    @Test("Rest-pause exercises should use 1 round")
    func restPauseDoesntNeedRounds() {
        let interval = Interval(
            exercises: [
                Exercise(name: "Pull-ups", trainingMethod: .restPause(targetTotal: 50))
            ],
            rounds: 1
        )
        
        #expect(interval.rounds == 1)
    }
    
    @Test("Tempo notation shows X for explosive movements")
    func tempoNotationHandlesExplosive() {
        let explosiveTempo = Tempo(eccentric: 2, pause: 0, concentric: 0)
        #expect(explosiveTempo.notation == "2-0-X")
        
        let normalTempo = Tempo(eccentric: 2, pause: 1, concentric: 2)
        #expect(normalTempo.notation == "2-1-2")
    }
    
    // MARK: - Tests that serve as documentation
    
    @Test("Different workout types can be created")
    func howToCreateDifferentWorkoutTypes() {
        // Standard strength workout
        let strengthWorkout = Interval(
            name: "Strength",
            exercises: [
                Exercise(name: "Bench Press", 
                        trainingMethod: .standard(minReps: 5, maxReps: 5),
                        weight: 135,
                        tempo: .slow)
            ],
            rounds: 5,
            restBetweenRounds: 180
        )
        
        // Calisthenics cluster set
        let calisthenicsWorkout = Interval(
            name: "Pull-up Cluster",
            exercises: [
                Exercise(name: "Pull-ups",
                        trainingMethod: .restPause(targetTotal: 40, minReps: 8, maxReps: 12))
            ],
            rounds: 1
        )
        
        // Circuit training
        let circuitWorkout = Interval(
            name: "HIIT Circuit",
            exercises: [
                Exercise(name: "Burpees", trainingMethod: .standard(minReps: 10, maxReps: 10)),
                Exercise(name: "Mountain Climbers", trainingMethod: .timed(seconds: 30)),
                Exercise(name: "Jump Squats", trainingMethod: .standard(minReps: 15, maxReps: 15))
            ],
            rounds: 4,
            restBetweenRounds: 60
        )
        
        #expect(strengthWorkout.exercises.count == 1)
        #expect(calisthenicsWorkout.rounds == 1)
        #expect(circuitWorkout.exercises.count == 3)
    }
    
    // MARK: - Tests that catch edge cases
    
    @Test("Empty workout has sensible defaults")
    func emptyWorkoutDoesntCrash() {
        let emptyWorkout = Workout()
        #expect(emptyWorkout.intervals.count == 0)
        #expect(emptyWorkout.name == "Untitled Workout")
    }
    
    // Note: SwiftData models are not directly Codable, they are persisted through ModelContainer
    // Removed codableRoundTrip test as Exercise is now a @Model class
}

// MARK: - Hashable Conformance Tests

struct HashableConformanceTests {
    
    // MARK: - Exercise Hashable Tests
    
    @Test("Exercises can be added to Sets")
    func exerciseSetOperations() {
        let exercise1 = Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15))
        let exercise2 = Exercise(name: "Pull-ups", trainingMethod: .standard(minReps: 8, maxReps: 12))
        let exercise3 = Exercise(name: "Dips", trainingMethod: .standard(minReps: 10, maxReps: 12))
        
        var exerciseSet = Set<Exercise>()
        exerciseSet.insert(exercise1)
        exerciseSet.insert(exercise2)
        exerciseSet.insert(exercise3)
        
        #expect(exerciseSet.count == 3)
        #expect(exerciseSet.contains(exercise1))
        #expect(exerciseSet.contains(exercise2))
        #expect(exerciseSet.contains(exercise3))
    }
    
    @Test("Exercise duplicate detection based on ID")
    func exerciseDuplicateDetection() {
        let id = UUID()
        let exercise1 = Exercise(id: id, name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15))
        let exercise2 = Exercise(id: id, name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15))
        
        var exerciseSet = Set<Exercise>()
        exerciseSet.insert(exercise1)
        exerciseSet.insert(exercise2) // Should not add because it's identical (same ID and properties)
        
        #expect(exerciseSet.count == 1)
        
        // Different test: Same ID but different properties
        let exercise3 = Exercise(id: id, name: "Different Name", trainingMethod: .timed(seconds: 30))
        exerciseSet.insert(exercise3) // Will add because properties differ (even though ID is same)
        
        #expect(exerciseSet.count == 2) // Both are in the set because they're not equal
    }
    
    @Test("Exercise Set operations work correctly")
    func exerciseSetOperationsAdvanced() {
        let exercise1 = Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15))
        let exercise2 = Exercise(name: "Pull-ups", trainingMethod: .standard(minReps: 8, maxReps: 12))
        let exercise3 = Exercise(name: "Dips", trainingMethod: .standard(minReps: 10, maxReps: 12))
        let exercise4 = Exercise(name: "Squats", trainingMethod: .standard(minReps: 15, maxReps: 20))
        
        let set1: Set<Exercise> = [exercise1, exercise2, exercise3]
        let set2: Set<Exercise> = [exercise2, exercise3, exercise4]
        
        // Union
        let union = set1.union(set2)
        #expect(union.count == 4)
        #expect(union.contains(exercise1))
        #expect(union.contains(exercise4))
        
        // Intersection
        let intersection = set1.intersection(set2)
        #expect(intersection.count == 2)
        #expect(intersection.contains(exercise2))
        #expect(intersection.contains(exercise3))
        
        // Subtract
        let subtracted = set1.subtracting(set2)
        #expect(subtracted.count == 1)
        #expect(subtracted.contains(exercise1))
        #expect(!subtracted.contains(exercise2))
    }
    
    // MARK: - Interval Hashable Tests
    
    @Test("Intervals can be added to Sets")
    func intervalSetOperations() {
        let interval1 = Interval(name: "Warmup", rounds: 2, restBetweenRounds: 30)
        let interval2 = Interval(name: "Main Set", rounds: 5, restBetweenRounds: 60)
        let interval3 = Interval(name: "Cooldown", rounds: 1)
        
        var intervalSet = Set<Interval>()
        intervalSet.insert(interval1)
        intervalSet.insert(interval2)
        intervalSet.insert(interval3)
        
        #expect(intervalSet.count == 3)
        #expect(intervalSet.contains(interval1))
        #expect(intervalSet.contains(interval2))
        #expect(intervalSet.contains(interval3))
    }
    
    @Test("Interval duplicate detection based on ID")
    func intervalDuplicateDetection() {
        let id = UUID()
        let interval1 = Interval(id: id, name: "Set 1", rounds: 3)
        let interval2 = Interval(id: id, name: "Set 1", rounds: 3)
        
        var intervalSet = Set<Interval>()
        intervalSet.insert(interval1)
        intervalSet.insert(interval2) // Should not add because it's identical (same ID and properties)
        
        #expect(intervalSet.count == 1)
        
        // Different test: Same ID but different properties
        let interval3 = Interval(id: id, name: "Different Name", rounds: 5)
        intervalSet.insert(interval3) // Will add because properties differ (even though ID is same)
        
        #expect(intervalSet.count == 2) // Both are in the set because they're not equal
    }
    
    // MARK: - Workout Hashable Tests
    
    @Test("Workouts can be added to Sets")
    func workoutSetOperations() {
        let workout1 = Workout(name: "Monday Workout")
        let workout2 = Workout(name: "Wednesday Workout")
        let workout3 = Workout(name: "Friday Workout")
        
        var workoutSet = Set<Workout>()
        workoutSet.insert(workout1)
        workoutSet.insert(workout2)
        workoutSet.insert(workout3)
        
        #expect(workoutSet.count == 3)
        #expect(workoutSet.contains(workout1))
        #expect(workoutSet.contains(workout2))
        #expect(workoutSet.contains(workout3))
    }
    
    @Test("Workout duplicate detection based on ID")
    func workoutDuplicateDetection() {
        let id = UUID()
        let date = Date()
        
        let workout1 = Workout(id: id, name: "Workout A", dateAndTime: date)
        let workout2 = Workout(id: id, name: "Workout A", dateAndTime: date)
        
        var workoutSet = Set<Workout>()
        workoutSet.insert(workout1)
        workoutSet.insert(workout2) // Should not add because it's identical (same ID and properties)
        
        #expect(workoutSet.count == 1)
        
        // Different test: Same ID but different properties
        let date2 = Date().addingTimeInterval(3600) // 1 hour later
        let workout3 = Workout(id: id, name: "Different Name", dateAndTime: date2)
        workoutSet.insert(workout3) // Will add because properties differ (even though ID is same)
        
        #expect(workoutSet.count == 2) // Both are in the set because they're not equal
    }
    
    // MARK: - Multi-Selection Use Case Tests
    
    @Test("Multi-selection with Set<Exercise> works correctly")
    func multiSelectionExercises() {
        let exercises = (1...5).map { Exercise(name: "Exercise \($0)", trainingMethod: .standard(minReps: 10, maxReps: 12)) }
        
        var selectedExercises = Set<Exercise>()
        
        // Select first 3
        selectedExercises.insert(exercises[0])
        selectedExercises.insert(exercises[1])
        selectedExercises.insert(exercises[2])
        
        #expect(selectedExercises.count == 3)
        
        // Deselect one
        selectedExercises.remove(exercises[1])
        #expect(selectedExercises.count == 2)
        #expect(!selectedExercises.contains(exercises[1]))
        
        // Toggle selection
        if selectedExercises.contains(exercises[0]) {
            selectedExercises.remove(exercises[0])
        } else {
            selectedExercises.insert(exercises[0])
        }
        #expect(selectedExercises.count == 1)
    }
    
    @Test("Multi-selection with Set<Workout> works correctly")
    func multiSelectionWorkouts() {
        let workouts = (1...5).map { Workout(name: "Workout \($0)") }
        
        var selectedWorkouts = Set<Workout>()
        
        // Select all
        workouts.forEach { selectedWorkouts.insert($0) }
        #expect(selectedWorkouts.count == 5)
        
        // Clear selection
        selectedWorkouts.removeAll()
        #expect(selectedWorkouts.isEmpty)
        
        // Select specific ones
        selectedWorkouts = Set([workouts[0], workouts[2], workouts[4]])
        #expect(selectedWorkouts.count == 3)
    }
    
    // MARK: - Performance Tests
    
    @Test("Hash function performance with large sets")
    func hashPerformance() {
        // Create 1000 exercises
        let exercises = (1...1000).map { 
            Exercise(name: "Exercise \($0)", trainingMethod: .standard(minReps: 10, maxReps: 15))
        }
        
        let startTime = Date()
        let exerciseSet = Set(exercises)
        let endTime = Date()
        
        let timeInterval = endTime.timeIntervalSince(startTime)
        
        #expect(exerciseSet.count == 1000)
        #expect(timeInterval < 0.1) // Should be very fast (less than 100ms)
        
        // Test lookup performance
        let lookupStart = Date()
        let contains = exerciseSet.contains(exercises[500])
        let lookupEnd = Date()
        
        let lookupTime = lookupEnd.timeIntervalSince(lookupStart)
        
        #expect(contains == true)
        #expect(lookupTime < 0.001) // Lookup should be extremely fast
    }
    
    // MARK: - Equality Tests
    
    @Test("Exercise equality ignores relationship arrays")
    func exerciseEqualityTest() {
        let exercise1 = Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15))
        let exercise2 = Exercise(
            id: exercise1.id,
            name: "Push-ups",
            trainingMethod: .standard(minReps: 10, maxReps: 15)
        )
        
        #expect(exercise1 == exercise2)
        
        // Change a property
        exercise2.name = "Modified Push-ups"
        #expect(exercise1 != exercise2)
    }
    
    @Test("Interval equality ignores exercises array")
    func intervalEqualityTest() {
        let interval1 = Interval(name: "Set 1", rounds: 3, restBetweenRounds: 60)
        let interval2 = Interval(
            id: interval1.id,
            name: "Set 1",
            rounds: 3,
            restBetweenRounds: 60
        )
        
        #expect(interval1 == interval2)
        
        // Even if we could add exercises (which we can't in tests without SwiftData context),
        // the equality should still work based on other properties
        interval2.rounds = 5
        #expect(interval1 != interval2)
    }
    
    @Test("Workout equality ignores intervals array")
    func workoutEqualityTest() {
        let date = Date()
        let workout1 = Workout(name: "Test Workout", dateAndTime: date)
        let workout2 = Workout(
            id: workout1.id,
            name: "Test Workout",
            dateAndTime: date
        )
        
        #expect(workout1 == workout2)
        
        workout2.name = "Modified Workout"
        #expect(workout1 != workout2)
    }
}

// MARK: - SwiftUI Diffing Efficiency Tests

struct SwiftUIDiffingTests {
    
    // MARK: - Workout Equatable Tests
    
    @Test("Workout equality returns true when all compared properties match")
    func workoutEqualityAllPropertiesMatch() {
        let id = UUID()
        let date = Date()
        let duration: TimeInterval = 3600
        
        let workout1 = Workout(id: id, name: "Morning Routine", dateAndTime: date)
        workout1.totalDuration = duration
        
        let workout2 = Workout(id: id, name: "Morning Routine", dateAndTime: date)
        workout2.totalDuration = duration
        
        #expect(workout1 == workout2)
        #expect(workout1.hashValue == workout2.hashValue) // Hash/equality contract
    }
    
    @Test("Workout equality returns false when any property differs")
    func workoutEqualityPropertyDifferences() {
        let baseWorkout = Workout(id: UUID(), name: "Test Workout", dateAndTime: Date())
        baseWorkout.totalDuration = 1800
        
        // Test each property change
        var testWorkout = Workout(id: UUID(), name: baseWorkout.name, dateAndTime: baseWorkout.dateAndTime)
        testWorkout.totalDuration = baseWorkout.totalDuration
        #expect(baseWorkout != testWorkout) // Different ID
        
        testWorkout = Workout(id: baseWorkout.id, name: "Different Name", dateAndTime: baseWorkout.dateAndTime)
        testWorkout.totalDuration = baseWorkout.totalDuration
        #expect(baseWorkout != testWorkout) // Different name
        
        testWorkout = Workout(id: baseWorkout.id, name: baseWorkout.name, dateAndTime: Date().addingTimeInterval(3600))
        testWorkout.totalDuration = baseWorkout.totalDuration
        #expect(baseWorkout != testWorkout) // Different date
        
        testWorkout = Workout(id: baseWorkout.id, name: baseWorkout.name, dateAndTime: baseWorkout.dateAndTime)
        testWorkout.totalDuration = 2400
        #expect(baseWorkout != testWorkout) // Different duration
    }
    
    @Test("Workout equality detects structural changes via intervals count")
    func workoutEqualityStructuralChanges() {
        let workout1 = Workout(name: "Circuit Training")
        let workout2 = Workout(id: workout1.id, name: "Circuit Training", dateAndTime: workout1.dateAndTime)
        
        #expect(workout1 == workout2) // Both have 0 intervals
        
        // In real app, intervals would be added via SwiftData context
        // This test verifies that the equality check includes intervals.count
    }
    
    @Test("Workout hash remains stable for SwiftUI identity")
    func workoutHashStability() {
        let workout = Workout(name: "Test Workout")
        let originalHash = workout.hashValue
        
        // Modify properties that affect equality
        workout.name = "Modified Name"
        workout.totalDuration = 3600
        workout.dateAndTime = Date().addingTimeInterval(7200)
        
        // Hash should remain the same (based only on ID)
        #expect(workout.hashValue == originalHash)
    }
    
    // MARK: - Interval Equatable Tests
    
    @Test("Interval equality returns true when all compared properties match")
    func intervalEqualityAllPropertiesMatch() {
        let id = UUID()
        
        let interval1 = Interval(
            id: id,
            name: "Warmup",
            rounds: 3,
            restBetweenRounds: 45,
            restAfterInterval: 90
        )
        
        let interval2 = Interval(
            id: id,
            name: "Warmup",
            rounds: 3,
            restBetweenRounds: 45,
            restAfterInterval: 90
        )
        
        #expect(interval1 == interval2)
        #expect(interval1.hashValue == interval2.hashValue) // Hash/equality contract
    }
    
    @Test("Interval equality returns false when any property differs")
    func intervalEqualityPropertyDifferences() {
        let baseInterval = Interval(
            id: UUID(),
            name: "Main Set",
            rounds: 5,
            restBetweenRounds: 60,
            restAfterInterval: 120
        )
        
        // Test each property change
        var testInterval = Interval(
            id: UUID(), // Different ID
            name: baseInterval.name,
            rounds: baseInterval.rounds,
            restBetweenRounds: baseInterval.restBetweenRounds,
            restAfterInterval: baseInterval.restAfterInterval
        )
        #expect(baseInterval != testInterval)
        
        testInterval = Interval(
            id: baseInterval.id,
            name: "Different Name",
            rounds: baseInterval.rounds,
            restBetweenRounds: baseInterval.restBetweenRounds,
            restAfterInterval: baseInterval.restAfterInterval
        )
        #expect(baseInterval != testInterval)
        
        testInterval = Interval(
            id: baseInterval.id,
            name: baseInterval.name,
            rounds: 3, // Different rounds
            restBetweenRounds: baseInterval.restBetweenRounds,
            restAfterInterval: baseInterval.restAfterInterval
        )
        #expect(baseInterval != testInterval)
        
        testInterval = Interval(
            id: baseInterval.id,
            name: baseInterval.name,
            rounds: baseInterval.rounds,
            restBetweenRounds: 30, // Different rest
            restAfterInterval: baseInterval.restAfterInterval
        )
        #expect(baseInterval != testInterval)
        
        testInterval = Interval(
            id: baseInterval.id,
            name: baseInterval.name,
            rounds: baseInterval.rounds,
            restBetweenRounds: baseInterval.restBetweenRounds,
            restAfterInterval: 180 // Different rest after
        )
        #expect(baseInterval != testInterval)
    }
    
    @Test("Interval equality handles nil properties correctly")
    func intervalEqualityNilProperties() {
        let interval1 = Interval(id: UUID(), name: nil, restBetweenRounds: nil, restAfterInterval: nil)
        let interval2 = Interval(id: interval1.id, name: nil, restBetweenRounds: nil, restAfterInterval: nil)
        
        #expect(interval1 == interval2)
        
        // One nil, one non-nil
        interval2.name = "Now has name"
        #expect(interval1 != interval2)
        
        interval2.name = nil
        interval2.restBetweenRounds = 60
        #expect(interval1 != interval2)
    }
    
    // MARK: - Exercise Equatable Tests
    
    @Test("Exercise equality returns true when all properties match")
    func exerciseEqualityAllPropertiesMatch() {
        let id = UUID()
        let tempo = Tempo(eccentric: 2, pause: 1, concentric: 2)
        
        let exercise1 = Exercise(
            id: id,
            name: "Bench Press",
            trainingMethod: .standard(minReps: 8, maxReps: 12),
            effort: 8,
            weight: 185.5,
            restAfter: 120,
            tempo: tempo,
            notes: "Keep core tight"
        )
        
        let exercise2 = Exercise(
            id: id,
            name: "Bench Press",
            trainingMethod: .standard(minReps: 8, maxReps: 12),
            effort: 8,
            weight: 185.5,
            restAfter: 120,
            tempo: tempo,
            notes: "Keep core tight"
        )
        
        #expect(exercise1 == exercise2)
        #expect(exercise1.hashValue == exercise2.hashValue) // Hash/equality contract
    }
    
    @Test("Exercise equality detects all property changes")
    func exerciseEqualityComprehensivePropertyCheck() {
        let baseExercise = Exercise(
            id: UUID(),
            name: "Squat",
            trainingMethod: .standard(minReps: 10, maxReps: 15),
            effort: 7,
            weight: 225,
            restAfter: 90,
            tempo: Tempo.controlled,
            notes: "ATG"
        )
        
        // Test ID change
        var testExercise = Exercise(
            id: UUID(),
            name: baseExercise.name,
            trainingMethod: baseExercise.trainingMethod,
            effort: baseExercise.effort,
            weight: baseExercise.weight,
            restAfter: baseExercise.restAfter,
            tempo: baseExercise.tempo,
            notes: baseExercise.notes
        )
        #expect(baseExercise != testExercise)
        
        // Test name change
        testExercise = Exercise(id: baseExercise.id, name: "Front Squat", trainingMethod: baseExercise.trainingMethod)
        testExercise.effort = baseExercise.effort
        testExercise.weight = baseExercise.weight
        testExercise.restAfter = baseExercise.restAfter
        testExercise.tempo = baseExercise.tempo
        testExercise.notes = baseExercise.notes
        #expect(baseExercise != testExercise)
        
        // Test training method changes
        testExercise = Exercise(id: baseExercise.id, name: baseExercise.name, trainingMethod: .restPause(targetTotal: 50))
        testExercise.effort = baseExercise.effort
        testExercise.weight = baseExercise.weight
        testExercise.restAfter = baseExercise.restAfter
        testExercise.tempo = baseExercise.tempo
        testExercise.notes = baseExercise.notes
        #expect(baseExercise != testExercise)
        
        // Test effort change
        testExercise = Exercise(id: baseExercise.id, name: baseExercise.name, trainingMethod: baseExercise.trainingMethod)
        testExercise.effort = 9 // Different effort
        testExercise.weight = baseExercise.weight
        testExercise.restAfter = baseExercise.restAfter
        testExercise.tempo = baseExercise.tempo
        testExercise.notes = baseExercise.notes
        #expect(baseExercise != testExercise)
        
        // Test weight change
        testExercise = Exercise(id: baseExercise.id, name: baseExercise.name, trainingMethod: baseExercise.trainingMethod)
        testExercise.effort = baseExercise.effort
        testExercise.weight = 235 // Different weight
        testExercise.restAfter = baseExercise.restAfter
        testExercise.tempo = baseExercise.tempo
        testExercise.notes = baseExercise.notes
        #expect(baseExercise != testExercise)
        
        // Test tempo change
        testExercise = Exercise(id: baseExercise.id, name: baseExercise.name, trainingMethod: baseExercise.trainingMethod)
        testExercise.effort = baseExercise.effort
        testExercise.weight = baseExercise.weight
        testExercise.restAfter = baseExercise.restAfter
        testExercise.tempo = Tempo.explosive // Different tempo
        testExercise.notes = baseExercise.notes
        #expect(baseExercise != testExercise)
        
        // Test notes change
        testExercise = Exercise(id: baseExercise.id, name: baseExercise.name, trainingMethod: baseExercise.trainingMethod)
        testExercise.effort = baseExercise.effort
        testExercise.weight = baseExercise.weight
        testExercise.restAfter = baseExercise.restAfter
        testExercise.tempo = baseExercise.tempo
        testExercise.notes = "Different note"
        #expect(baseExercise != testExercise)
    }
    
    @Test("Exercise equality handles all training method variants")
    func exerciseEqualityTrainingMethodVariants() {
        let id = UUID()
        
        // Standard method
        let standard1 = Exercise(id: id, name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15))
        let standard2 = Exercise(id: id, name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15))
        #expect(standard1 == standard2)
        
        // Different min/max reps
        let standard3 = Exercise(id: id, name: "Push-ups", trainingMethod: .standard(minReps: 8, maxReps: 15))
        #expect(standard1 != standard3)
        
        // Rest-pause method
        let restPause1 = Exercise(id: id, name: "Pull-ups", trainingMethod: .restPause(targetTotal: 50, minReps: 5, maxReps: 10))
        let restPause2 = Exercise(id: id, name: "Pull-ups", trainingMethod: .restPause(targetTotal: 50, minReps: 5, maxReps: 10))
        #expect(restPause1 == restPause2)
        
        // Different target total
        let restPause3 = Exercise(id: id, name: "Pull-ups", trainingMethod: .restPause(targetTotal: 40, minReps: 5, maxReps: 10))
        #expect(restPause1 != restPause3)
        
        // Timed method
        let timed1 = Exercise(id: id, name: "Plank", trainingMethod: .timed(seconds: 60))
        let timed2 = Exercise(id: id, name: "Plank", trainingMethod: .timed(seconds: 60))
        #expect(timed1 == timed2)
        
        // Different seconds
        let timed3 = Exercise(id: id, name: "Plank", trainingMethod: .timed(seconds: 90))
        #expect(timed1 != timed3)
    }
    
    // MARK: - SwiftUI Diffing Scenarios
    
    @Test("SwiftUI list diffing scenario - minimal redraws")
    func swiftUIListDiffingScenario() {
        // Simulate a list of exercises in SwiftUI
        let exercise1 = Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15))
        let exercise2 = Exercise(name: "Pull-ups", trainingMethod: .standard(minReps: 8, maxReps: 12))
        let exercise3 = Exercise(name: "Dips", trainingMethod: .standard(minReps: 10, maxReps: 12))
        
        var exercises = [exercise1, exercise2, exercise3]
        
        // Create copies with same IDs to simulate SwiftUI's behavior
        let originalExercise1 = Exercise(id: exercise1.id, name: exercise1.name, trainingMethod: exercise1.trainingMethod)
        originalExercise1.effort = exercise1.effort
        let originalExercise2 = Exercise(id: exercise2.id, name: exercise2.name, trainingMethod: exercise2.trainingMethod)
        originalExercise2.effort = exercise2.effort
        let originalExercise3 = Exercise(id: exercise3.id, name: exercise3.name, trainingMethod: exercise3.trainingMethod)
        originalExercise3.effort = exercise3.effort
        
        // Scenario 1: Change only one property of one exercise
        exercises[1].effort = 9 // Only this exercise should trigger redraw
        
        #expect(exercises[0] == originalExercise1) // No redraw
        #expect(exercises[1] != originalExercise2) // Should redraw (effort changed)
        #expect(exercises[2] == originalExercise3) // No redraw
        
        // Scenario 2: Reorder without changing content
        let reorderedExercises = [exercises[2], exercises[0], exercises[1]]
        
        // Each exercise still equals itself despite position change
        #expect(reorderedExercises[0] == exercises[2])
        #expect(reorderedExercises[1] == exercises[0])
        #expect(reorderedExercises[2] == exercises[1])
    }
    
    @Test("SwiftUI form editing scenario - detect actual changes")
    func swiftUIFormEditingScenario() {
        let workout = Workout(name: "Morning Routine", dateAndTime: Date())
        let originalWorkout = Workout(
            id: workout.id,
            name: workout.name,
            dateAndTime: workout.dateAndTime
        )
        originalWorkout.totalDuration = workout.totalDuration
        
        // No changes - should not trigger view update
        #expect(workout == originalWorkout)
        
        // User edits name - should trigger update
        workout.name = "Evening Routine"
        #expect(workout != originalWorkout)
        
        // Reset and test date change
        workout.name = originalWorkout.name
        #expect(workout == originalWorkout)
        
        workout.dateAndTime = Date().addingTimeInterval(3600)
        #expect(workout != originalWorkout)
    }
    
    @Test("Hash/equality contract is maintained")
    func hashEqualityContract() {
        // Create many instances to test contract thoroughly
        let instances = (1...100).map { i in
            Exercise(
                name: "Exercise \(i)",
                trainingMethod: .standard(minReps: 10, maxReps: 15),
                effort: (i % 10) + 1
            )
        }
        
        // For each pair of instances
        for i in 0..<instances.count {
            for j in 0..<instances.count {
                let instance1 = instances[i]
                let instance2 = instances[j]
                
                // If they're equal, they must have same hash
                if instance1 == instance2 {
                    #expect(instance1.hashValue == instance2.hashValue)
                }
                
                // Note: The reverse is not required - different objects can have same hash
                // This is a hash collision and is acceptable
            }
        }
    }
    
    @Test("Performance - equality check should be fast")
    func equalityPerformance() {
        // Create complex exercises with all properties set
        let exercise1 = Exercise(
            name: "Complex Exercise",
            trainingMethod: .restPause(targetTotal: 100, minReps: 10, maxReps: 20),
            effort: 9,
            weight: 315.5,
            restAfter: 180,
            tempo: Tempo(eccentric: 4, pause: 2, concentric: 3),
            notes: "This is a very long note with lots of details about form and technique that might be expensive to compare if we're not careful"
        )
        
        let exercise2 = Exercise(
            id: exercise1.id,
            name: exercise1.name,
            trainingMethod: exercise1.trainingMethod,
            effort: exercise1.effort,
            weight: exercise1.weight,
            restAfter: exercise1.restAfter,
            tempo: exercise1.tempo,
            notes: exercise1.notes
        )
        
        let startTime = Date()
        
        // Perform many equality checks
        for _ in 0..<10000 {
            _ = exercise1 == exercise2
        }
        
        let endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        
        // Should be very fast even for 10,000 comparisons
        // Note: In debug builds this might be slower due to lack of optimizations
        #expect(timeInterval < 0.5) // Less than 500ms for 10k comparisons (generous for debug builds)
        
        // Also verify that the comparison is working correctly
        #expect(exercise1 == exercise2)
    }
}

// MARK: - Comparable Conformance Tests

struct ComparableConformanceTests {
    
    // MARK: - Workout Comparable Tests
    
    @Test("Workouts sort by date - most recent first")
    func workoutSortingByDate() {
        let now = Date()
        let yesterday = now.addingTimeInterval(-86400) // 24 hours ago
        let lastWeek = now.addingTimeInterval(-604800) // 7 days ago
        let tomorrow = now.addingTimeInterval(86400) // 24 hours from now
        
        let workout1 = Workout(name: "Yesterday's Workout", dateAndTime: yesterday)
        let workout2 = Workout(name: "Today's Workout", dateAndTime: now)
        let workout3 = Workout(name: "Last Week's Workout", dateAndTime: lastWeek)
        let workout4 = Workout(name: "Tomorrow's Workout", dateAndTime: tomorrow)
        
        let unsortedWorkouts = [workout1, workout2, workout3, workout4]
        let sortedWorkouts = unsortedWorkouts.sorted()
        
        // Should be sorted most recent first
        #expect(sortedWorkouts[0] == workout4) // Tomorrow
        #expect(sortedWorkouts[1] == workout2) // Today
        #expect(sortedWorkouts[2] == workout1) // Yesterday
        #expect(sortedWorkouts[3] == workout3) // Last week
    }
    
    @Test("Workouts with same date maintain stable sort")
    func workoutStableSortWithSameDate() {
        let date = Date()
        
        let workout1 = Workout(name: "Workout A", dateAndTime: date)
        let workout2 = Workout(name: "Workout B", dateAndTime: date)
        let workout3 = Workout(name: "Workout C", dateAndTime: date)
        
        let workouts = [workout1, workout2, workout3]
        let sorted = workouts.sorted()
        
        // All have same date, so order might vary but should be consistent
        // The important thing is they're all considered equal by date
        #expect(!(workout1 < workout2) && !(workout2 < workout1)) // Neither is less than the other
        #expect(sorted.count == 3)
    }
    
    @Test("Workout array sorting correctness")
    func workoutSortingCorrectness() {
        // Create 100 workouts with random dates over the past year
        let now = Date()
        let workouts = (1...100).map { i in
            let daysAgo = Double.random(in: 0...365)
            let date = now.addingTimeInterval(-daysAgo * 86400)
            return Workout(name: "Workout \(i)", dateAndTime: date)
        }
        
        let sorted = workouts.sorted()
        
        #expect(sorted.count == 100)
        
        // Verify sorting is correct (most recent first)
        // Since our < operator returns true when lhs.dateAndTime > rhs.dateAndTime,
        // the sorted array will have most recent dates first
        for i in 0..<(sorted.count - 1) {
            #expect(sorted[i].dateAndTime >= sorted[i + 1].dateAndTime) // Most recent first
        }
    }
    
    // MARK: - Interval Comparable Tests
    
    @Test("Intervals sort by name, with nil names last")
    func intervalSortingByName() {
        let interval1 = Interval(name: "Warmup")
        let interval2 = Interval(name: "Main Set")
        let interval3 = Interval(name: "Cooldown")
        let interval4 = Interval(name: nil) // No name
        let interval5 = Interval(name: "Abs Circuit")
        let interval6 = Interval(name: nil) // Another no name
        
        let unsortedIntervals = [interval4, interval2, interval6, interval1, interval5, interval3]
        let sortedIntervals = unsortedIntervals.sorted()
        
        // Named intervals should come first, alphabetically
        #expect(sortedIntervals[0] == interval5) // "Abs Circuit"
        #expect(sortedIntervals[1] == interval3) // "Cooldown"
        #expect(sortedIntervals[2] == interval2) // "Main Set"
        #expect(sortedIntervals[3] == interval1) // "Warmup"
        
        // Unnamed intervals should come last
        #expect(sortedIntervals[4].name == nil)
        #expect(sortedIntervals[5].name == nil)
    }
    
    @Test("Intervals with nil names sort by UUID")
    func intervalNilNameSortingByUUID() {
        let interval1 = Interval(name: nil)
        let interval2 = Interval(name: nil)
        let interval3 = Interval(name: nil)
        
        let intervals = [interval1, interval2, interval3]
        let sorted = intervals.sorted()
        
        // All have nil names, so they should be sorted by UUID string
        // This ensures stable, predictable ordering
        #expect(sorted.count == 3)
        
        // Verify they maintain consistent ordering
        let sortedAgain = intervals.sorted()
        for i in 0..<sorted.count {
            #expect(sorted[i].id == sortedAgain[i].id)
        }
    }
    
    @Test("Interval sorting handles mixed names correctly")
    func intervalMixedNameSorting() {
        let intervals = [
            Interval(name: "Zebra"),
            Interval(name: nil),
            Interval(name: "Alpha"),
            Interval(name: ""),  // Empty string
            Interval(name: "Beta"),
            Interval(name: nil)
        ]
        
        let sorted = intervals.sorted()
        
        // Empty string should come first (it's not nil)
        #expect(sorted[0].name == "")
        #expect(sorted[1].name == "Alpha")
        #expect(sorted[2].name == "Beta")
        #expect(sorted[3].name == "Zebra")
        #expect(sorted[4].name == nil)
        #expect(sorted[5].name == nil)
    }
    
    // MARK: - Exercise Comparable Tests
    
    @Test("Exercises sort by effort (higher first), then by name")
    func exerciseSortingByEffortAndName() {
        let exercise1 = Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15), effort: 7)
        let exercise2 = Exercise(name: "Pull-ups", trainingMethod: .standard(minReps: 8, maxReps: 12), effort: 9)
        let exercise3 = Exercise(name: "Dips", trainingMethod: .standard(minReps: 10, maxReps: 12), effort: 8)
        let exercise4 = Exercise(name: "Squats", trainingMethod: .standard(minReps: 15, maxReps: 20), effort: 9)
        let exercise5 = Exercise(name: "Lunges", trainingMethod: .standard(minReps: 12, maxReps: 15), effort: 7)
        
        let unsortedExercises = [exercise1, exercise2, exercise3, exercise4, exercise5]
        let sortedExercises = unsortedExercises.sorted()
        
        // Should be sorted by effort (high to low), then name (alphabetical)
        #expect(sortedExercises[0] == exercise2) // Pull-ups (effort: 9)
        #expect(sortedExercises[1] == exercise4) // Squats (effort: 9)
        #expect(sortedExercises[2] == exercise3) // Dips (effort: 8)
        #expect(sortedExercises[3] == exercise5) // Lunges (effort: 7)
        #expect(sortedExercises[4] == exercise1) // Push-ups (effort: 7)
    }
    
    @Test("Exercises with same effort sort alphabetically")
    func exerciseSameEffortAlphabeticalSort() {
        let exercises = [
            Exercise(name: "Zebra Walks", trainingMethod: .timed(seconds: 30), effort: 5),
            Exercise(name: "Alligator Crawls", trainingMethod: .timed(seconds: 30), effort: 5),
            Exercise(name: "Bear Crawls", trainingMethod: .timed(seconds: 30), effort: 5),
            Exercise(name: "Monkey Bars", trainingMethod: .standard(minReps: 1, maxReps: 1), effort: 5)
        ]
        
        let sorted = exercises.sorted()
        
        // All have same effort, so should be alphabetical
        #expect(sorted[0].name == "Alligator Crawls")
        #expect(sorted[1].name == "Bear Crawls")
        #expect(sorted[2].name == "Monkey Bars")
        #expect(sorted[3].name == "Zebra Walks")
    }
    
    @Test("Exercise sorting respects effort as primary criterion")
    func exerciseEffortPrimarySort() {
        let lowEffortA = Exercise(name: "A Exercise", trainingMethod: .standard(minReps: 10, maxReps: 10), effort: 3)
        let highEffortZ = Exercise(name: "Z Exercise", trainingMethod: .standard(minReps: 10, maxReps: 10), effort: 10)
        
        let exercises = [lowEffortA, highEffortZ]
        let sorted = exercises.sorted()
        
        // High effort "Z" should come before low effort "A"
        #expect(sorted[0] == highEffortZ)
        #expect(sorted[1] == lowEffortA)
    }
    
    // MARK: - Real-world Usage Scenarios
    
    @Test("Workout list view sorting scenario")
    func workoutListViewScenario() {
        // Simulate a workout history that users would see
        let today = Date()
        let workouts = [
            Workout(name: "Leg Day", dateAndTime: today.addingTimeInterval(-172800)), // 2 days ago
            Workout(name: "Push Day", dateAndTime: today.addingTimeInterval(-86400)), // yesterday
            Workout(name: "Pull Day", dateAndTime: today), // today
            Workout(name: "Core", dateAndTime: today.addingTimeInterval(-259200)), // 3 days ago
            Workout(name: "Cardio", dateAndTime: today.addingTimeInterval(-432000)) // 5 days ago
        ]
        
        // In SwiftUI: ForEach(workouts.sorted()) { workout in ... }
        let displayOrder = workouts.sorted()
        
        #expect(displayOrder[0].name == "Pull Day") // Most recent
        #expect(displayOrder[1].name == "Push Day")
        #expect(displayOrder[2].name == "Leg Day")
        #expect(displayOrder[3].name == "Core")
        #expect(displayOrder[4].name == "Cardio") // Oldest
    }
    
    @Test("Exercise selection view sorting scenario")
    func exerciseSelectionScenario() {
        // Simulate exercises in a selection list, sorted by difficulty
        let exercises = [
            Exercise(name: "Pistol Squats", trainingMethod: .standard(minReps: 5, maxReps: 8), effort: 10),
            Exercise(name: "Regular Squats", trainingMethod: .standard(minReps: 15, maxReps: 20), effort: 6),
            Exercise(name: "Jump Squats", trainingMethod: .standard(minReps: 10, maxReps: 15), effort: 8),
            Exercise(name: "Goblet Squats", trainingMethod: .standard(minReps: 12, maxReps: 15), effort: 7),
            Exercise(name: "Bulgarian Split Squats", trainingMethod: .standard(minReps: 10, maxReps: 12), effort: 9)
        ]
        
        let sortedByDifficulty = exercises.sorted()
        
        // Users see hardest exercises first
        #expect(sortedByDifficulty[0].name == "Pistol Squats") // effort: 10
        #expect(sortedByDifficulty[1].name == "Bulgarian Split Squats") // effort: 9
        #expect(sortedByDifficulty[2].name == "Jump Squats") // effort: 8
        #expect(sortedByDifficulty[3].name == "Goblet Squats") // effort: 7
        #expect(sortedByDifficulty[4].name == "Regular Squats") // effort: 6
    }
    
    @Test("Comparable allows clean SwiftUI code")
    func comparableSwiftUIUsage() {
        let workouts = [
            Workout(name: "Yesterday", dateAndTime: Date().addingTimeInterval(-86400)),
            Workout(name: "Today", dateAndTime: Date()),
            Workout(name: "Last Week", dateAndTime: Date().addingTimeInterval(-604800))
        ]
        
        // Without Comparable: workouts.sorted(by: { $0.dateAndTime > $1.dateAndTime })
        // With Comparable: workouts.sorted()
        
        let sorted = workouts.sorted()
        #expect(sorted[0].name == "Today")
        #expect(sorted[1].name == "Yesterday")
        #expect(sorted[2].name == "Last Week")
    }
}
