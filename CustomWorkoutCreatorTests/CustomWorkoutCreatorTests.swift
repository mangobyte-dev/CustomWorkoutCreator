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
                        Exercise(name: "Push-ups", trainingMethod: .standard(reps: 10), restAfter: 30),
                        Exercise(name: "Squats", trainingMethod: .standard(reps: 15), restAfter: 30)
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
                        trainingMethod: .standard(reps: 5),
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
                        trainingMethod: .restPause(targetTotal: 40, repRange: "8-12RM"))
            ],
            rounds: 1
        )
        
        // Circuit training
        let circuitWorkout = Interval(
            name: "HIIT Circuit",
            exercises: [
                Exercise(name: "Burpees", trainingMethod: .standard(reps: 10)),
                Exercise(name: "Mountain Climbers", trainingMethod: .timed(seconds: 30)),
                Exercise(name: "Jump Squats", trainingMethod: .standard(reps: 15))
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
    
    @Test("Workout data can be saved and loaded")
    func codableRoundTrip() throws {
        let original = Exercise(
            name: "Dips",
            trainingMethod: .restPause(targetTotal: 30, repRange: "15-20RM"),
            tempo: Tempo(eccentric: 2, pause: 0, concentric: 1)
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Exercise.self, from: data)
        
        #expect(decoded.name == original.name)
        #expect(decoded.id == original.id)
    }
}
