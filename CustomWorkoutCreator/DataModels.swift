//
//  DataModels.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import Foundation
import SwiftData

// MARK: - Core Models

@Model
class Workout: Hashable, Comparable {
    var id = UUID()
    var name: String = "Untitled Workout"
    var dateAndTime = Date()
    var totalDuration: TimeInterval = 0
    @Relationship(deleteRule: .cascade) var intervals: [Interval] = []
    
    init(id: UUID = UUID(), name: String = "Untitled Workout", dateAndTime: Date = Date(), intervals: [Interval] = []) {
        self.id = id
        self.name = name
        self.dateAndTime = dateAndTime
        self.intervals = intervals
    }
    
    // MARK: - Hashable
    // Hash only the id for performance - SwiftUI uses this for identity
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable
    // Full equality check for detecting actual changes to minimize SwiftUI redraws
    // We compare all value properties and check intervals count for structural changes
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.dateAndTime == rhs.dateAndTime &&
        lhs.totalDuration == rhs.totalDuration &&
        lhs.intervals.count == rhs.intervals.count
    }
    
    // MARK: - Comparable
    // Sort by dateAndTime - most recent first
    static func < (lhs: Workout, rhs: Workout) -> Bool {
        lhs.dateAndTime > rhs.dateAndTime
    }
}

@Model
class Interval: Hashable, Comparable {
    var id = UUID()
    var name: String? // Optional name for the interval (e.g., "Warmup", "Main Set", "Cooldown")
    @Relationship(deleteRule: .cascade) var exercises: [Exercise] = []
    var rounds = 1 // How many times to repeat this interval
    var restBetweenRounds: Int? // Optional rest between rounds in seconds
    var restAfterInterval: Int? // Optional rest after completing all rounds
    
    init(id: UUID = UUID(), name: String? = nil, exercises: [Exercise] = [], rounds: Int = 1, restBetweenRounds: Int? = nil, restAfterInterval: Int? = nil) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.rounds = rounds
        self.restBetweenRounds = restBetweenRounds
        self.restAfterInterval = restAfterInterval
    }
    
    // MARK: - Hashable
    // Hash only the id for performance - SwiftUI uses this for identity
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable
    // Full equality check for detecting actual changes to minimize SwiftUI redraws
    // We compare all value properties and check exercises count for structural changes
    static func == (lhs: Interval, rhs: Interval) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.rounds == rhs.rounds &&
        lhs.restBetweenRounds == rhs.restBetweenRounds &&
        lhs.restAfterInterval == rhs.restAfterInterval &&
        lhs.exercises.count == rhs.exercises.count
    }
    
    // MARK: - Comparable
    // Sort by name (if present), then by id for stable ordering
    static func < (lhs: Interval, rhs: Interval) -> Bool {
        switch (lhs.name, rhs.name) {
        case let (lhsName?, rhsName?):
            return lhsName < rhsName
        case (nil, _?):
            return false // nil names come after named intervals
        case (_?, nil):
            return true // named intervals come before nil names
        case (nil, nil):
            return lhs.id.uuidString < rhs.id.uuidString // stable ordering by id
        }
    }
}

// MARK: - TrainingMethod Enum (kept for API compatibility)

enum TrainingMethod: Codable {
    case standard(minReps: Int, maxReps: Int)
    case restPause(targetTotal: Int, minReps: Int = 5, maxReps: Int = 10)
    case timed(seconds: Int)
    
    enum CodingKeys: String, CodingKey {
        case type, reps, minReps, maxReps, targetTotal, seconds
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
class Exercise: Hashable, Comparable {
    var id = UUID()
    
    // Reference to exercise library item
    @Relationship var exerciseItem: ExerciseItem?
    
    // Legacy name property for backward compatibility
    // For new exercises, name should come from exerciseItem
    private var legacyName: String = ""
    
    // Computed property for name - uses exerciseItem.name if available, otherwise legacyName
    var name: String {
        get {
            exerciseItem?.name ?? legacyName
        }
        set {
            // If we have an exerciseItem, this shouldn't be set directly
            // But for compatibility, we'll store in legacyName
            legacyName = newValue
        }
    }
    
    // Store enum data as separate properties to avoid SwiftData crash
    private var methodType: String = "standard"
    private var minReps: Int = 10
    private var maxReps: Int = 10
    private var targetTotal: Int = 0
    private var seconds: Int = 30
    
    // Computed property to maintain API compatibility
    var trainingMethod: TrainingMethod {
        get {
            switch methodType {
            case "standard":
                return .standard(minReps: minReps, maxReps: maxReps)
            case "restPause":
                return .restPause(targetTotal: targetTotal, minReps: minReps, maxReps: maxReps)
            case "timed":
                return .timed(seconds: seconds)
            default:
                return .standard(minReps: 10, maxReps: 10)
            }
        }
        set {
            switch newValue {
            case let .standard(min, max):
                methodType = "standard"
                minReps = min
                maxReps = max
            case let .restPause(total, min, max):
                methodType = "restPause"
                targetTotal = total
                minReps = min
                maxReps = max
            case let .timed(sec):
                methodType = "timed"
                seconds = sec
            }
        }
    }
    
    var effort: Int = 7 // Expected effort level 1-10
    var weight: Double? // Optional - for weighted exercises
    var restAfter: Int? // Optional - rest after this exercise in seconds
    var tempo: Tempo? // Optional - movement tempo/cadence
    var notes: String? // Optional - additional form cues, instructions
    
    // Primary initializer with exerciseItem reference
    init(id: UUID = UUID(), exerciseItem: ExerciseItem, trainingMethod: TrainingMethod, effort: Int = 7, weight: Double? = nil, restAfter: Int? = nil, tempo: Tempo? = nil, notes: String? = nil) {
        self.id = id
        self.exerciseItem = exerciseItem
        self.legacyName = "" // Not used when exerciseItem is provided
        self.trainingMethod = trainingMethod
        self.effort = effort
        self.weight = weight
        self.restAfter = restAfter
        self.tempo = tempo
        self.notes = notes
    }
    
    // Legacy initializer for backward compatibility
    init(id: UUID = UUID(), name: String, trainingMethod: TrainingMethod, effort: Int = 7, weight: Double? = nil, restAfter: Int? = nil, tempo: Tempo? = nil, notes: String? = nil) {
        self.id = id
        self.exerciseItem = nil
        self.legacyName = name
        self.trainingMethod = trainingMethod
        self.effort = effort
        self.weight = weight
        self.restAfter = restAfter
        self.tempo = tempo
        self.notes = notes
    }
    
    // MARK: - Hashable
    // Hash only the id for performance - SwiftUI uses this for identity
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable
    // Full equality check for detecting actual changes to minimize SwiftUI redraws
    // We compare all value properties including decomposed enum values and relationships
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id &&
        lhs.exerciseItem == rhs.exerciseItem &&
        lhs.legacyName == rhs.legacyName &&
        lhs.methodType == rhs.methodType &&
        lhs.minReps == rhs.minReps &&
        lhs.maxReps == rhs.maxReps &&
        lhs.targetTotal == rhs.targetTotal &&
        lhs.seconds == rhs.seconds &&
        lhs.effort == rhs.effort &&
        lhs.weight == rhs.weight &&
        lhs.restAfter == rhs.restAfter &&
        lhs.tempo == rhs.tempo &&
        lhs.notes == rhs.notes
    }
    
    // MARK: - Comparable
    // Sort by effort (higher effort first), then by name
    static func < (lhs: Exercise, rhs: Exercise) -> Bool {
        if lhs.effort != rhs.effort {
            return lhs.effort > rhs.effort // Higher effort first
        }
        return lhs.name < rhs.name // Alphabetical by name
    }
    
    // MARK: - Convenience Methods
    
    /// Creates an Exercise from an ExerciseItem with default training parameters
    /// This is the preferred way to create new exercises from the library
    static func from(exerciseItem: ExerciseItem, trainingMethod: TrainingMethod = .standard(minReps: 10, maxReps: 12), effort: Int = 7) -> Exercise {
        return Exercise(
            exerciseItem: exerciseItem,
            trainingMethod: trainingMethod,
            effort: effort
        )
    }
}

// MARK: - ExerciseItem Model

/// Represents a library item for exercises - lightweight reference data only
/// This model serves as the foundation for the exercise library feature
@Model
class ExerciseItem: Hashable, Comparable {
    var id = UUID()
    var name: String = ""
    var gifUrl: String? // Optional URL to exercise demonstration GIF
    
    init(id: UUID = UUID(), name: String, gifUrl: String? = nil) {
        self.id = id
        self.name = name
        self.gifUrl = gifUrl
    }
    
    // MARK: - Hashable
    // Hash only the id for performance - SwiftUI uses this for identity
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable
    // Full equality check for detecting actual changes to minimize SwiftUI redraws
    static func == (lhs: ExerciseItem, rhs: ExerciseItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.gifUrl == rhs.gifUrl
    }
    
    // MARK: - Comparable
    // Sort alphabetically by name for consistent ordering
    static func < (lhs: ExerciseItem, rhs: ExerciseItem) -> Bool {
        lhs.name < rhs.name
    }
    
    // MARK: - Performance Optimizations for List Display
    
    /// Checks if this ExerciseItem has visible changes compared to another
    /// Used for precise diffing in SwiftUI lists to minimize redraws
    func hasVisibleChanges(comparedTo other: ExerciseItem) -> Bool {
        self.id != other.id ||
        self.name != other.name ||
        self.gifUrl != other.gifUrl
    }
    
    // MARK: - Convenience Methods
    
    /// Creates an Exercise from this ExerciseItem with specified training parameters
    func createExercise(trainingMethod: TrainingMethod = .standard(minReps: 10, maxReps: 12), effort: Int = 7) -> Exercise {
        return Exercise(
            exerciseItem: self,
            trainingMethod: trainingMethod,
            effort: effort
        )
    }
}

// MARK: - Value Types (Codable structs used within models)

/// Represents the tempo/cadence of an exercise movement
/// Format: Eccentric-Pause-Concentric (e.g., 3-1-2 means 3 seconds down, 1 second pause, 2 seconds up)
struct Tempo: Codable, Hashable, Equatable {
    let eccentric: Int  // Muscle lengthening phase (lowering)
    let pause: Int      // Pause at the bottom/stretched position
    let concentric: Int // Muscle shortening phase (lifting) - 0 means explosive
    
    // Common tempo patterns
    static let normal = Tempo(eccentric: 1, pause: 0, concentric: 1) // 1-0-1
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
extension ExerciseItem {
    static func makeExamples() -> [ExerciseItem] {
        return [
            ExerciseItem(name: "Push-ups", gifUrl: nil),
            ExerciseItem(name: "Pull-ups", gifUrl: nil),
            ExerciseItem(name: "Squats", gifUrl: nil),
            ExerciseItem(name: "Lunges", gifUrl: nil),
            ExerciseItem(name: "Plank", gifUrl: nil),
            ExerciseItem(name: "Burpees", gifUrl: nil),
            ExerciseItem(name: "Dips", gifUrl: nil),
            ExerciseItem(name: "Mountain Climbers", gifUrl: nil)
        ]
    }
}

// MARK: - JSON Codable Struct for Bundle Loading
struct ExerciseData: Codable {
    let exerciseId: String
    let name: String
}

// MARK: - Default Exercise Library
extension ExerciseItem {
    /// Loads exercises from bundled JSON file containing 1,500 exercises
    static func loadFromBundle(in context: ModelContext) {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("Could not find exercises.json in bundle")
            createDefaultExercises(in: context)
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let exerciseDataArray = try JSONDecoder().decode([ExerciseData].self, from: data)
            
            print("Loading \(exerciseDataArray.count) exercises from bundle...")
            
            for exerciseData in exerciseDataArray {
                let exercise = ExerciseItem(
                    name: exerciseData.name,
                    gifUrl: exerciseData.exerciseId // Store just the exerciseId, we'll construct the bundle path in views
                )
                context.insert(exercise)
            }
            
            try context.save()
            print("Successfully loaded \(exerciseDataArray.count) exercises from bundle")
            
        } catch {
            print("Error loading exercises from bundle: \(error)")
            // Fallback to default exercises if bundle loading fails
            createDefaultExercises(in: context)
        }
    }
    
    /// Legacy method - kept for compatibility but replaced by loadFromBundle
    static func createDefaultExercises(in context: ModelContext) {
        let exercises = [
            // Chest
            ("Push-ups", "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExpushups/giphy.gif"),
            ("Bench Press", nil),
            ("Incline Dumbbell Press", nil),
            
            // Back
            ("Pull-ups", "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExpullups/giphy.gif"),
            ("Bent-Over Row", nil),
            ("Lat Pulldown", nil),
            
            // Legs
            ("Squats", "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExsquats/giphy.gif"),
            ("Lunges", nil),
            ("Romanian Deadlifts", nil),
            
            // Core
            ("Plank", "https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExplank/giphy.gif"),
            ("Crunches", nil),
            ("Russian Twists", nil),
            
            // Arms & Shoulders
            ("Bicep Curls", nil),
            ("Tricep Dips", nil),
            ("Shoulder Press", nil)
        ]

        for (name, gifUrl) in exercises {
            let exercise = ExerciseItem(name: name, gifUrl: gifUrl)
            context.insert(exercise)
        }
        try? context.save()
    }
}

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
