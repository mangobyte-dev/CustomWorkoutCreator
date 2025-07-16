//
//  DataModels.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import Foundation

struct Workout: Identifiable, Codable {
    var id = UUID()
    var name: String = "Untitled Workout"
    var dateAndTime: Date = Date()
    var totalDuration: TimeInterval = 0
    var intervals: [Interval] = []
}

struct Interval: Identifiable, Codable {
    var id = UUID()
    var name: String? // Optional name like "Warmup", "Main Set", etc.
    var exercises: [Exercise] = []
    var rounds: Int = 1
    var restBetweenRounds: Int? // Optional rest between rounds
}

enum TrainingMethod: Codable {
    case standard(reps: Int)
    case restPause(targetTotal: Int, repRange: String? = nil)
    case timed(seconds: Int)
}

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var trainingMethod: TrainingMethod
    var weight: Double? // Optional - for weighted exercises
    var restAfter: Int? // Optional - rest after this exercise in seconds
    var tempo: Tempo? // Optional - movement tempo/cadence
    var notes: String? // Optional - additional form cues, instructions
}

/// Tempo controls the speed of each phase of an exercise movement
///
/// **Eccentric**: The "negative" or muscle lengthening phase
/// - Push-up: lowering down (chest to floor)
/// - Pull-up: lowering down (arms extending)
/// - Squat: lowering down
/// - Bicep curl: lowering weight down
///
/// **Concentric**: The "positive" or muscle shortening phase
/// - Push-up: pushing up
/// - Pull-up: pulling up
/// - Squat: standing up
/// - Bicep curl: curling weight up
struct Tempo: Codable {
    var eccentric: Int // Seconds for muscle lengthening phase (usually the "lowering")
    var pause: Int // Seconds to pause (usually at bottom/stretched position)
    var concentric: Int // Seconds for muscle shortening phase (usually the "lifting")
    
    // Common tempo patterns
    static let controlled = Tempo(eccentric: 2, pause: 0, concentric: 1) // 2-0-1
    static let slow = Tempo(eccentric: 3, pause: 1, concentric: 2) // 3-1-2
    static let explosive = Tempo(eccentric: 2, pause: 0, concentric: 0) // 2-0-X (X = explosive)
    static let paused = Tempo(eccentric: 2, pause: 3, concentric: 1) // 2-3-1 (pause squats, etc.)
    
    /// Returns tempo in standard notation (e.g., "3-1-2")
    /// Read as: "3 seconds down, 1 second pause, 2 seconds up"
    var notation: String {
        let c = concentric == 0 ? "X" : "\(concentric)"
        return "\(eccentric)-\(pause)-\(c)"
    }
}

// Convenience extensions
extension Workout {
    static var example: Workout {
        Workout(
            name: "Full Body Circuit",
            intervals: [
                Interval(
                    name: "Upper Body Circuit",
                    exercises: [
                        Exercise(name: "Push-ups", trainingMethod: .standard(reps: 15)),
                        Exercise(name: "Dips", trainingMethod: .standard(reps: 12))
                    ],
                    rounds: 4,
                    restBetweenRounds: 60
                ),
                Interval(
                    name: "Core",
                    exercises: [
                        Exercise(name: "Plank", trainingMethod: .timed(seconds: 60))
                    ],
                    rounds: 3,
                    restBetweenRounds: 30
                ),
                Interval(
                    name: "Pull-up Challenge",
                    exercises: [
                        Exercise(name: "Pull-ups", trainingMethod: .restPause(targetTotal: 50, repRange: "8-12RM"))
                    ],
                    rounds: 1
                ),
                Interval(
                    exercises: [Exercise(name: "Step Ups", trainingMethod: .standard(reps: 20))],
                    rounds: 5
                ),
                Interval(
                    exercises: [Exercise(name: "Glute Bridges", trainingMethod: .standard(reps: 15))],
                    rounds: 5
                )
            ]
        )
    }
}
