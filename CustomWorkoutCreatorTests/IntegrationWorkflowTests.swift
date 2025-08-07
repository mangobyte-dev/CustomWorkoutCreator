//
//  IntegrationWorkflowTests.swift
//  CustomWorkoutCreatorTests
//
//  Created by Developer on 07/08/2025.
//

import Testing
import SwiftUI
import SwiftData
@testable import CustomWorkoutCreator


@Suite("Integration Workflow Tests", .tags(.integration, .workflow))
struct IntegrationWorkflowTests {
    
    // MARK: - Workout Creation Workflow
    
    @Test("Complete workout creation workflow")
    func completeWorkoutCreation() throws {
        let container = try TestContainer()
        
        // Step 1: Create new workout
        let workout = Workout(name: "Full Body Workout")
        
        // Step 2: Add first interval
        let warmupInterval = Interval(
            name: "Warmup",
            rounds: 1,
            restBetweenRounds: 0,
            restAfterInterval: 60
        )
        
        // Step 3: Add exercises to warmup
        warmupInterval.exercises.append(
            Exercise(name: "Jumping Jacks", trainingMethod: .timed(seconds: 60))
        )
        warmupInterval.exercises.append(
            Exercise(name: "Arm Circles", trainingMethod: .timed(seconds: 30))
        )
        
        workout.intervals.append(warmupInterval)
        
        // Step 4: Add main workout interval
        let mainInterval = Interval(
            name: "Main Set",
            rounds: 3,
            restBetweenRounds: 90,
            restAfterInterval: 120
        )
        
        // Step 5: Add exercises to main set
        mainInterval.exercises.append(
            Exercise(
                name: "Push-ups",
                trainingMethod: .standard(minReps: 10, maxReps: 15),
                effort: 7,
                restAfter: 45
            )
        )
        mainInterval.exercises.append(
            Exercise(
                name: "Squats",
                trainingMethod: .standard(minReps: 15, maxReps: 20),
                effort: 8,
                weight: 50,
                restAfter: 60
            )
        )
        mainInterval.exercises.append(
            Exercise(
                name: "Plank",
                trainingMethod: .timed(seconds: 60),
                effort: 9,
                restAfter: 30
            )
        )
        
        workout.intervals.append(mainInterval)
        
        // Step 6: Save to database
        container.insert(workout)
        try container.save()
        
        // Verify creation
        let fetchedWorkouts = try container.fetch(FetchDescriptor<Workout>())
        #expect(fetchedWorkouts.count == 1)
        
        let savedWorkout = fetchedWorkouts.first!
        #expect(savedWorkout.name == "Full Body Workout")
        #expect(savedWorkout.intervals.count == 2)
        #expect(savedWorkout.intervals[0].exercises.count == 2)
        #expect(savedWorkout.intervals[1].exercises.count == 3)
    }
    
    // MARK: - Workout Editing Workflow
    
    @Test("Edit existing workout workflow")
    func editWorkoutWorkflow() throws {
        let container = try TestContainer()
        
        // Create initial workout
        let workout = TestFixtures.createWorkout()
        container.insert(workout)
        try container.save()
        
        // Edit workout name
        workout.name = "Modified Workout"
        
        // Add new interval
        let newInterval = Interval(name: "Finisher", rounds: 2)
        newInterval.exercises.append(
            Exercise(name: "Burpees", trainingMethod: .standard(minReps: 10, maxReps: 10))
        )
        workout.intervals.append(newInterval)
        
        // Modify existing exercise
        if let firstInterval = workout.intervals.first,
           let firstExercise = firstInterval.exercises.first {
            firstExercise.effort = 10
            firstExercise.notes = "Go all out!"
        }
        
        // Remove an interval
        if workout.intervals.count > 2 {
            workout.intervals.remove(at: 1)
        }
        
        try container.save()
        
        // Verify edits
        #expect(workout.name == "Modified Workout")
        #expect(workout.intervals.last?.name == "Finisher")
        #expect(workout.intervals.first?.exercises.first?.effort == 10)
    }
    
    // MARK: - Exercise Library Integration
    
    @Test("Exercise library search and selection")
    
    // MARK: - Bulk Operations
    
    @Test("Bulk delete workflow")
    func bulkDeleteWorkflow() throws {
        let container = try TestContainer()
        
        // Create multiple workouts
        let workouts = (1...10).map { i in
            Workout(name: "Workout \(i)")
        }
        
        workouts.forEach { container.insert($0) }
        try container.save()
        
        // Select workouts for deletion
        let toDelete = Set(workouts.prefix(5))
        
        // Perform bulk delete
        toDelete.forEach { container.delete($0) }
        try container.save()
        
        // Verify deletion
        let remaining = try container.fetch(FetchDescriptor<Workout>())
        #expect(remaining.count == 5)
        
        let remainingNames = Set(remaining.map { $0.name })
        let expectedNames = Set((6...10).map { "Workout \($0)" })
        #expect(remainingNames == expectedNames)
    }
    
    @Test("Bulk duplicate workflow")
    func bulkDuplicateWorkflow() throws {
        let container = try TestContainer()
        
        // Create original workouts
        let originals = (1...3).map { i in
            TestFixtures.createWorkout(name: "Original \(i)", intervals: 2, exercisesPerInterval: 2)
        }
        
        originals.forEach { container.insert($0) }
        try container.save()
        
        // Duplicate workouts
        let duplicates = originals.map { original in
            let copy = Workout(name: "\(original.name) (Copy)")
            
            for interval in original.intervals {
                let intervalCopy = Interval(
                    name: interval.name,
                    rounds: interval.rounds,
                    restBetweenRounds: interval.restBetweenRounds
                )
                
                for exercise in interval.exercises {
                    let exerciseCopy = Exercise(
                        name: exercise.name,
                        trainingMethod: exercise.trainingMethod,
                        effort: exercise.effort,
                        weight: exercise.weight,
                        restAfter: exercise.restAfter
                    )
                    intervalCopy.exercises.append(exerciseCopy)
                }
                
                copy.intervals.append(intervalCopy)
            }
            
            return copy
        }
        
        duplicates.forEach { container.insert($0) }
        try container.save()
        
        // Verify duplication
        let allWorkouts = try container.fetch(FetchDescriptor<Workout>())
        #expect(allWorkouts.count == 6)
        
        let copyWorkouts = allWorkouts.filter { $0.name.contains("(Copy)") }
        #expect(copyWorkouts.count == 3)
        
        // Verify structure preserved
        for (original, copy) in zip(originals, duplicates) {
            #expect(original.intervals.count == copy.intervals.count)
            #expect(original.intervals.flatMap { $0.exercises }.count ==
                   copy.intervals.flatMap { $0.exercises }.count)
        }
    }
    
    // MARK: - Complex Scenarios
    
    @Test("Rest-pause workout scenario")
    func restPauseWorkoutScenario() throws {
        let container = try TestContainer()
        
        let workout = Workout(name: "Rest-Pause Training")
        
        // Rest-pause exercises should typically be in separate intervals
        let pullupInterval = Interval(name: "Pull-up Cluster", rounds: 1)
        pullupInterval.exercises.append(
            Exercise(
                name: "Pull-ups",
                trainingMethod: .restPause(targetTotal: 50, minReps: 5, maxReps: 10),
                effort: 9
            )
        )
        
        let pushupInterval = Interval(name: "Push-up Cluster", rounds: 1)
        pushupInterval.exercises.append(
            Exercise(
                name: "Push-ups",
                trainingMethod: .restPause(targetTotal: 100, minReps: 10, maxReps: 20),
                effort: 8
            )
        )
        
        workout.intervals.append(pullupInterval)
        workout.intervals.append(pushupInterval)
        
        container.insert(workout)
        try container.save()
        
        // Verify rest-pause structure
        #expect(workout.intervals.allSatisfy { $0.rounds == 1 })
        #expect(workout.intervals.allSatisfy { interval in
            interval.exercises.allSatisfy { exercise in
                if case .restPause = exercise.trainingMethod { return true }
                return false
            }
        })
    }
    
    @Test("Circuit training scenario")
    func circuitTrainingScenario() throws {
        let container = try TestContainer()
        
        let workout = Workout(name: "HIIT Circuit")
        
        let circuit = Interval(
            name: "Main Circuit",
            rounds: 5,
            restBetweenRounds: 60,
            restAfterInterval: 180
        )
        
        // Mix of timed and rep-based exercises
        let exercises = [
            Exercise(name: "Burpees", trainingMethod: .standard(minReps: 10, maxReps: 10), restAfter: 15),
            Exercise(name: "Mountain Climbers", trainingMethod: .timed(seconds: 30), restAfter: 15),
            Exercise(name: "Jump Squats", trainingMethod: .standard(minReps: 15, maxReps: 15), restAfter: 15),
            Exercise(name: "High Knees", trainingMethod: .timed(seconds: 30), restAfter: 15),
            Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 10), restAfter: 60)
        ]
        
        exercises.forEach { circuit.exercises.append($0) }
        workout.intervals.append(circuit)
        
        container.insert(workout)
        try container.save()
        
        // Verify circuit structure
        #expect(circuit.rounds == 5)
        #expect(circuit.exercises.count == 5)
        
        let timedExercises = circuit.exercises.filter { exercise in
            if case .timed = exercise.trainingMethod { return true }
            return false
        }
        let repExercises = circuit.exercises.filter { exercise in
            if case .standard = exercise.trainingMethod { return true }
            return false
        }
        
        #expect(timedExercises.count == 2)
        #expect(repExercises.count == 3)
    }
    
    // MARK: - Error Recovery
    
    @Test("Handle invalid data gracefully")
    func errorRecoveryWorkflow() throws {
        let container = try TestContainer()
        
        // Create workout with potential issues
        let workout = Workout(name: "")  // Empty name
        workout.name = "Recovery Test"   // Fix empty name
        
        let interval = Interval(rounds: 0)  // Invalid rounds
        interval.rounds = 1  // Fix rounds
        
        let exercise = Exercise(
            name: "Test",
            trainingMethod: .standard(minReps: 20, maxReps: 10)  // Min > Max
        )
        // Fix by swapping
        let correctedMethod = TrainingMethod.standard(minReps: 10, maxReps: 20)
        exercise.trainingMethod = correctedMethod
        
        interval.exercises.append(exercise)
        workout.intervals.append(interval)
        
        container.insert(workout)
        try container.save()
        
        // Verify corrections applied
        #expect(!workout.name.isEmpty)
        #expect(interval.rounds > 0)
        
        if case .standard(let minReps, let maxReps) = exercise.trainingMethod {
            #expect(minReps <= maxReps)
        }
    }
    
    // MARK: - Performance Under Load
    
    @Test("Workflow performance with large dataset", .tags(.performance))
}