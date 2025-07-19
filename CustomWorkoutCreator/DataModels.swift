//
//  DataModels.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import Foundation
import SwiftData

@Model
class Workout {
    var id = UUID()
    var name: String = "Untitled Workout"
    var dateAndTime: Date = Date()
    var totalDuration: TimeInterval = 0
    @Relationship(deleteRule: .cascade) var intervals: [Interval] = []
    
    init(id: UUID = UUID(), name: String = "Untitled Workout", dateAndTime: Date = Date(), totalDuration: TimeInterval = 0, intervals: [Interval] = []) {
        self.id = id
        self.name = name
        self.dateAndTime = dateAndTime
        self.totalDuration = totalDuration
        self.intervals = intervals
    }
}

@Model
class Interval {
    var id = UUID()
    var name: String? // Optional name like "Warmup", "Main Set", etc.
    @Relationship(deleteRule: .cascade) var exercises: [Exercise] = []
    var rounds: Int = 1
    var restBetweenRounds: Int? // Optional rest between rounds
    var restAfterInterval: Int? // Optional rest after completing all rounds
    
    init(id: UUID = UUID(), name: String? = nil, exercises: [Exercise] = [], rounds: Int = 1, restBetweenRounds: Int? = nil, restAfterInterval: Int? = nil) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.rounds = rounds
        self.restBetweenRounds = restBetweenRounds
        self.restAfterInterval = restAfterInterval
    }
}

enum TrainingMethod: Codable {
    case standard(minReps: Int, maxReps: Int)
    case restPause(targetTotal: Int, minReps: Int, maxReps: Int)
    case timed(seconds: Int)
    
    // Custom Codable implementation for SwiftData compatibility
    enum CodingKeys: String, CodingKey {
        case type
        case reps
        case minReps
        case maxReps
        case targetTotal
        case seconds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "standard":
            // Support legacy single reps value
            if let reps = try? container.decode(Int.self, forKey: .reps) {
                self = .standard(minReps: reps, maxReps: reps)
            } else {
                let minReps = try container.decode(Int.self, forKey: .minReps)
                let maxReps = try container.decode(Int.self, forKey: .maxReps)
                self = .standard(minReps: minReps, maxReps: maxReps)
            }
        case "restPause":
            let targetTotal = try container.decode(Int.self, forKey: .targetTotal)
            let minReps = try container.decodeIfPresent(Int.self, forKey: .minReps) ?? 5
            let maxReps = try container.decodeIfPresent(Int.self, forKey: .maxReps) ?? 10
            self = .restPause(targetTotal: targetTotal, minReps: minReps, maxReps: maxReps)
        case "timed":
            let seconds = try container.decode(Int.self, forKey: .seconds)
            self = .timed(seconds: seconds)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown training method type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .standard(minReps, maxReps):
            try container.encode("standard", forKey: .type)
            try container.encode(minReps, forKey: .minReps)
            try container.encode(maxReps, forKey: .maxReps)
        case let .restPause(targetTotal, minReps, maxReps):
            try container.encode("restPause", forKey: .type)
            try container.encode(targetTotal, forKey: .targetTotal)
            try container.encode(minReps, forKey: .minReps)
            try container.encode(maxReps, forKey: .maxReps)
        case let .timed(seconds):
            try container.encode("timed", forKey: .type)
            try container.encode(seconds, forKey: .seconds)
        }
    }
}

@Model
class Exercise {
    var id = UUID()
    var name: String
    var trainingMethod: TrainingMethod
    var effort: Int = 7 // Expected effort level 1-10
    var weight: Double? // Optional - for weighted exercises
    var restAfter: Int? // Optional - rest after this exercise in seconds
    var tempo: Tempo? // Optional - movement tempo/cadence
    var notes: String? // Optional - additional form cues, instructions
    
    init(id: UUID = UUID(), name: String, trainingMethod: TrainingMethod, effort: Int = 7, weight: Double? = nil, restAfter: Int? = nil, tempo: Tempo? = nil, notes: String? = nil) {
        self.id = id
        self.name = name
        self.trainingMethod = trainingMethod
        self.effort = effort
        self.weight = weight
        self.restAfter = restAfter
        self.tempo = tempo
        self.notes = notes
    }
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
    static func makeExample() -> Workout {
        Workout(
            name: "Full Body Circuit",
            intervals: [
                Interval(
                    name: "Upper Body Circuit",
                    exercises: [
                        Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 12, maxReps: 15)),
                        Exercise(name: "Dips", trainingMethod: .standard(minReps: 10, maxReps: 12))
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
                        Exercise(name: "Pull-ups", trainingMethod: .restPause(targetTotal: 50, minReps: 8, maxReps: 12))
                    ],
                    rounds: 1
                ),
                Interval(
                    exercises: [Exercise(name: "Step Ups", trainingMethod: .standard(minReps: 15, maxReps: 20))],
                    rounds: 5
                ),
                Interval(
                    exercises: [Exercise(name: "Glute Bridges", trainingMethod: .standard(minReps: 12, maxReps: 15))],
                    rounds: 5
                )
            ]
        )
    }
}
