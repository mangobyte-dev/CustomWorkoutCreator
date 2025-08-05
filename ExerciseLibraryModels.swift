//
//  ExerciseLibraryModels.swift
//  CustomWorkoutCreator
//
//  Created by Assistant on 08/05/2025.
//
// New data models for Exercise Library feature
// This file contains the refactored models to support standalone exercises

import Foundation
import SwiftData

// MARK: - Exercise Category
enum ExerciseCategory: String, Codable, CaseIterable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"
    case fullBody = "Full Body"
    case flexibility = "Flexibility"
    case custom = "Custom"
}

// MARK: - Equipment Type
enum Equipment: String, Codable, CaseIterable {
    case none = "Bodyweight"
    case barbell = "Barbell"
    case dumbbell = "Dumbbell"
    case kettlebell = "Kettlebell"
    case cable = "Cable"
    case machine = "Machine"
    case band = "Resistance Band"
    case pullupBar = "Pull-up Bar"
    case dipBars = "Dip Bars"
    case bench = "Bench"
    case other = "Other"
}

// MARK: - Muscle Group
enum MuscleGroup: String, Codable, CaseIterable {
    // Upper Body
    case chest = "Chest"
    case upperBack = "Upper Back"
    case lowerBack = "Lower Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case forearms = "Forearms"
    
    // Core
    case abs = "Abs"
    case obliques = "Obliques"
    
    // Lower Body
    case quads = "Quadriceps"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case calves = "Calves"
    case hipFlexors = "Hip Flexors"
    case adductors = "Adductors"
    case abductors = "Abductors"
}

// MARK: - Exercise Model (Standalone)
@Model
final class Exercise {
    // MARK: - Core Properties
    var id: UUID = UUID()
    var name: String = ""
    private var trainingMethodData: Data?  // Store as data for SwiftData
    
    // MARK: - Categorization
    var category: ExerciseCategory?
    var equipment: [Equipment]?
    var primaryMuscleGroups: [MuscleGroup]?
    var secondaryMuscleGroups: [MuscleGroup]?
    
    // MARK: - Multimedia
    var videoURL: String?
    var gifURL: String?
    var thumbnailURL: String?
    var formNotes: String?
    
    // MARK: - Metadata
    var createdDate: Date = Date()
    var lastUsedDate: Date?
    var useCount: Int = 0
    var isCustom: Bool = true
    var isFavorite: Bool = false
    var isArchived: Bool = false
    
    // MARK: - Search Optimization
    var searchText: String = ""  // Pre-computed for fast search
    
    // MARK: - Relationships
    @Relationship(inverse: \IntervalExercise.exercise)
    var intervalExercises: [IntervalExercise]?
    
    // MARK: - Computed Properties
    var trainingMethod: TrainingMethod {
        get {
            guard let data = trainingMethodData else { 
                return .standard(minReps: 10, maxReps: 10) 
            }
            return (try? JSONDecoder().decode(TrainingMethod.self, from: data)) ?? .standard(minReps: 10, maxReps: 10)
        }
        set {
            trainingMethodData = try? JSONEncoder().encode(newValue)
            updateSearchText()
        }
    }
    
    // MARK: - Initialization
    init(
        name: String,
        trainingMethod: TrainingMethod = .standard(minReps: 10, maxReps: 10),
        category: ExerciseCategory? = nil,
        equipment: [Equipment]? = nil,
        isCustom: Bool = true
    ) {
        self.name = name
        self.trainingMethod = trainingMethod
        self.category = category
        self.equipment = equipment
        self.isCustom = isCustom
        self.updateSearchText()
    }
    
    // MARK: - Methods
    func updateSearchText() {
        // Pre-compute search text for performance
        var components = [name.lowercased()]
        
        if let category = category {
            components.append(category.rawValue.lowercased())
        }
        
        if let equipment = equipment {
            components.append(contentsOf: equipment.map { $0.rawValue.lowercased() })
        }
        
        if let muscles = primaryMuscleGroups {
            components.append(contentsOf: muscles.map { $0.rawValue.lowercased() })
        }
        
        searchText = components.joined(separator: " ")
    }
    
    func recordUsage() {
        lastUsedDate = Date()
        useCount += 1
    }
}

// MARK: - IntervalExercise (Bridge Entity)
@Model
final class IntervalExercise {
    // MARK: - Identity
    var id: UUID = UUID()
    var orderIndex: Int = 0
    
    // MARK: - Workout-Specific Values
    var effort: Int = 5
    var weight: Double?
    var restAfter: Int?
    private var tempoData: Data?  // Store as data for SwiftData
    var notes: String?
    
    // MARK: - Relationships
    var interval: Interval?
    var exercise: Exercise?
    
    // MARK: - Computed Properties
    var tempo: Tempo? {
        get {
            guard let data = tempoData else { return nil }
            return try? JSONDecoder().decode(Tempo.self, from: data)
        }
        set {
            tempoData = try? JSONEncoder().encode(newValue)
        }
    }
    
    // MARK: - Initialization
    init(
        exercise: Exercise,
        interval: Interval,
        orderIndex: Int,
        effort: Int = 5,
        weight: Double? = nil,
        restAfter: Int? = nil,
        tempo: Tempo? = nil,
        notes: String? = nil
    ) {
        self.exercise = exercise
        self.interval = interval
        self.orderIndex = orderIndex
        self.effort = effort
        self.weight = weight
        self.restAfter = restAfter
        self.tempo = tempo
        self.notes = notes
    }
}

// MARK: - Exercise Extensions for Compatibility
extension Exercise {
    /// Creates a legacy Exercise struct for compatibility
    func toLegacyExercise() -> LegacyExercise {
        return LegacyExercise(
            name: name,
            trainingMethod: trainingMethod,
            effort: 5  // Default, will be overridden by IntervalExercise
        )
    }
    
    /// Creates an Exercise from legacy data
    static func fromLegacy(_ legacy: LegacyExercise, isCustom: Bool = true) -> Exercise {
        let exercise = Exercise(
            name: legacy.name,
            trainingMethod: legacy.trainingMethod,
            isCustom: isCustom
        )
        
        // Try to infer category from name (basic heuristic)
        exercise.inferCategory()
        
        return exercise
    }
    
    private func inferCategory() {
        let lowercasedName = name.lowercased()
        
        // Basic category inference
        switch lowercasedName {
        case let name where name.contains("bench") || name.contains("chest") || name.contains("push-up"):
            category = .chest
        case let name where name.contains("pull") || name.contains("row") || name.contains("back"):
            category = .back
        case let name where name.contains("squat") || name.contains("lunge") || name.contains("leg"):
            category = .legs
        case let name where name.contains("curl") || name.contains("bicep"):
            category = .biceps
        case let name where name.contains("tricep") || name.contains("dip"):
            category = .triceps
        case let name where name.contains("shoulder") || name.contains("press") || name.contains("raise"):
            category = .shoulders
        case let name where name.contains("core") || name.contains("plank") || name.contains("ab"):
            category = .core
        case let name where name.contains("run") || name.contains("jump") || name.contains("burpee"):
            category = .cardio
        default:
            category = .custom
        }
    }
}

// MARK: - Type Alias for Migration
typealias LegacyExercise = DataModels.Exercise

// MARK: - Interval Extension
extension Interval {
    /// Computed property to get exercises in order (for compatibility)
    var exercises: [Exercise] {
        guard let intervalExercises = intervalExercises else { return [] }
        return intervalExercises
            .sorted { $0.orderIndex < $1.orderIndex }
            .compactMap { $0.exercise }
    }
    
    /// Add exercise to interval
    func addExercise(_ exercise: Exercise, effort: Int = 5, weight: Double? = nil, restAfter: Int? = nil, tempo: Tempo? = nil, notes: String? = nil) {
        let maxIndex = intervalExercises?.map { $0.orderIndex }.max() ?? -1
        
        let intervalExercise = IntervalExercise(
            exercise: exercise,
            interval: self,
            orderIndex: maxIndex + 1,
            effort: effort,
            weight: weight,
            restAfter: restAfter,
            tempo: tempo,
            notes: notes
        )
        
        if intervalExercises == nil {
            intervalExercises = []
        }
        intervalExercises?.append(intervalExercise)
        
        exercise.recordUsage()
    }
}

// MARK: - Exercise Protocols
extension Exercise: Identifiable {}
extension Exercise: Hashable {
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension IntervalExercise: Identifiable {}
extension IntervalExercise: Hashable {
    static func == (lhs: IntervalExercise, rhs: IntervalExercise) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Default Exercises
extension Exercise {
    static let defaultExercises: [(name: String, category: ExerciseCategory, equipment: [Equipment], method: TrainingMethod)] = [
        // Chest
        ("Push-ups", .chest, [.none], .standard(minReps: 10, maxReps: 15)),
        ("Bench Press", .chest, [.barbell, .bench], .standard(minReps: 8, maxReps: 12)),
        ("Dumbbell Chest Press", .chest, [.dumbbell, .bench], .standard(minReps: 8, maxReps: 12)),
        ("Chest Fly", .chest, [.dumbbell, .bench], .standard(minReps: 10, maxReps: 15)),
        
        // Back
        ("Pull-ups", .back, [.pullupBar], .standard(minReps: 5, maxReps: 10)),
        ("Bent-Over Row", .back, [.barbell], .standard(minReps: 8, maxReps: 12)),
        ("Lat Pulldown", .back, [.cable], .standard(minReps: 10, maxReps: 15)),
        
        // Legs
        ("Squats", .legs, [.none], .standard(minReps: 10, maxReps: 15)),
        ("Barbell Squats", .legs, [.barbell], .standard(minReps: 8, maxReps: 12)),
        ("Lunges", .legs, [.none], .standard(minReps: 10, maxReps: 12)),
        ("Romanian Deadlifts", .legs, [.barbell], .standard(minReps: 8, maxReps: 12)),
        
        // Core
        ("Plank", .core, [.none], .timed(seconds: 60)),
        ("Crunches", .core, [.none], .standard(minReps: 15, maxReps: 25)),
        ("Russian Twists", .core, [.none], .standard(minReps: 20, maxReps: 30)),
        
        // Add more as needed...
    ]
    
    static func createDefaultExercises(in context: ModelContext) {
        for (name, category, equipment, method) in defaultExercises {
            let exercise = Exercise(
                name: name,
                trainingMethod: method,
                category: category,
                equipment: equipment,
                isCustom: false
            )
            context.insert(exercise)
        }
    }
}