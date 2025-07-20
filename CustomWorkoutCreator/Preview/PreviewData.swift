//
//  PreviewData.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 20/07/2025.
//

import Foundation

// MARK: - Workout Preview Data
extension Workout {
    static let previewStrength = Workout(
        name: "Upper Body Strength",
        dateAndTime: Date(),
        intervals: [Interval.previewCompound, Interval.previewIsolation]
    )
    
    static let previewHIIT = Workout(
        name: "Quick HIIT Circuit",
        dateAndTime: Date(),
        intervals: [Interval.previewWarmup, Interval.previewCircuit]
    )
    
    static let previewRestPause = Workout(
        name: "Advanced Rest-Pause",
        dateAndTime: Date(),
        intervals: [Interval.previewRestPauseDips, Interval.previewRestPauseChinups]
    )
    
    static let previewEmpty = Workout(
        name: "Empty Workout",
        dateAndTime: Date(),
        intervals: []
    )
    
    static let previewData = [
        previewStrength,
        previewHIIT,
        previewRestPause
    ]
}

// MARK: - Interval Preview Data
extension Interval {
    static let previewCompound = Interval(
        name: "Compound Movements",
        exercises: [Exercise.previewBenchPress, Exercise.previewPullups],
        rounds: 4,
        restBetweenRounds: 300,
        restAfterInterval: 300
    )
    
    static let previewIsolation = Interval(
        name: "Isolation Work",
        exercises: [Exercise.previewCurls, Exercise.previewTriceps],
        rounds: 3,
        restBetweenRounds: 90,
        restAfterInterval: nil
    )
    
    static let previewWarmup = Interval(
        name: "Warm-up",
        exercises: [Exercise.previewJumpingJacks, Exercise.previewHighKnees],
        rounds: 2,
        restBetweenRounds: 30,
        restAfterInterval: 60
    )
    
    static let previewCircuit = Interval(
        name: "Main Circuit",
        exercises: [Exercise.previewBurpees, Exercise.previewMountainClimbers, Exercise.previewJumpSquats],
        rounds: 4,
        restBetweenRounds: 90,
        restAfterInterval: nil
    )
    
    static let previewRestPauseDips = Interval(
        exercises: [Exercise.previewDips],
        rounds: 1,
        restBetweenRounds: nil,
        restAfterInterval: 300
    )
    
    static let previewRestPauseChinups = Interval(
        exercises: [Exercise.previewChinups],
        rounds: 1,
        restBetweenRounds: nil,
        restAfterInterval: nil
    )
    
    static let previewSingle = Interval(
        name: "Single Exercise",
        exercises: [Exercise.previewPushups],
        rounds: 1,
        restBetweenRounds: nil,
        restAfterInterval: nil
    )
}

// MARK: - Exercise Preview Data
extension Exercise {
    // Strength exercises
    static let previewBenchPress = Exercise(
        name: "Bench Press",
        trainingMethod: .standard(minReps: 6, maxReps: 8),
        effort: 8,
        weight: 185,
        restAfter: 180,
        tempo: .slow
    )
    
    static let previewPullups = Exercise(
        name: "Pull-ups",
        trainingMethod: .standard(minReps: 8, maxReps: 12),
        effort: 9,
        weight: nil,
        restAfter: 120
    )
    
    static let previewCurls = Exercise(
        name: "Dumbbell Curls",
        trainingMethod: .standard(minReps: 12, maxReps: 15),
        effort: 7,
        weight: 30,
        restAfter: 60
    )
    
    static let previewTriceps = Exercise(
        name: "Tricep Extensions",
        trainingMethod: .standard(minReps: 12, maxReps: 15),
        effort: 7,
        weight: 25,
        restAfter: 60
    )
    
    // HIIT exercises
    static let previewJumpingJacks = Exercise(
        name: "Jumping Jacks",
        trainingMethod: .timed(seconds: 30),
        effort: 5,
        restAfter: 10
    )
    
    static let previewHighKnees = Exercise(
        name: "High Knees",
        trainingMethod: .timed(seconds: 30),
        effort: 6,
        restAfter: 10
    )
    
    static let previewBurpees = Exercise(
        name: "Burpees",
        trainingMethod: .standard(minReps: 10, maxReps: 10),
        effort: 9,
        restAfter: 30
    )
    
    static let previewMountainClimbers = Exercise(
        name: "Mountain Climbers",
        trainingMethod: .timed(seconds: 45),
        effort: 8,
        restAfter: 30
    )
    
    static let previewJumpSquats = Exercise(
        name: "Jump Squats",
        trainingMethod: .standard(minReps: 15, maxReps: 15),
        effort: 8,
        restAfter: 30
    )
    
    // Rest-pause exercises
    static let previewDips = Exercise(
        name: "Dips",
        trainingMethod: .restPause(targetTotal: 50, minReps: 8, maxReps: 12),
        effort: 10,
        notes: "Use assistance band if needed"
    )
    
    static let previewChinups = Exercise(
        name: "Chin-ups",
        trainingMethod: .restPause(targetTotal: 40, minReps: 6, maxReps: 10),
        effort: 10
    )
    
    // Basic exercises
    static let previewPushups = Exercise(
        name: "Push-ups",
        trainingMethod: .standard(minReps: 10, maxReps: 20),
        effort: 6,
        tempo: .controlled
    )
    
    static let previewSquats = Exercise(
        name: "Bodyweight Squats",
        trainingMethod: .standard(minReps: 15, maxReps: 25),
        effort: 5
    )
    
    static let previewPlank = Exercise(
        name: "Plank",
        trainingMethod: .timed(seconds: 60),
        effort: 7
    )
}
