//
//  ExerciseMigrationHelper.swift
//  CustomWorkoutCreator
//
//  Created by Assistant on 08/05/2025.
//
// Helper for migrating from embedded exercises to standalone exercise library

import Foundation
import SwiftData

final class ExerciseMigrationHelper {
    
    // MARK: - Migration Status
    enum MigrationStatus {
        case notStarted
        case inProgress(percentComplete: Double)
        case completed
        case failed(Error)
    }
    
    // MARK: - Migration Errors
    enum MigrationError: LocalizedError {
        case alreadyMigrated
        case noWorkoutsFound
        case saveFailed
        
        var errorDescription: String? {
            switch self {
            case .alreadyMigrated:
                return "Exercises have already been migrated"
            case .noWorkoutsFound:
                return "No workouts found to migrate"
            case .saveFailed:
                return "Failed to save migrated data"
            }
        }
    }
    
    // MARK: - Properties
    private let modelContext: ModelContext
    private let exerciseStore: ExerciseStore
    
    // MARK: - Initialization
    init(modelContext: ModelContext, exerciseStore: ExerciseStore) {
        self.modelContext = modelContext
        self.exerciseStore = exerciseStore
    }
    
    // MARK: - Migration Check
    
    /// Check if migration has already been performed
    func isMigrationNeeded() -> Bool {
        // Check UserDefaults for migration flag
        let migrationKey = "ExerciseLibraryMigrationCompleted"
        return !UserDefaults.standard.bool(forKey: migrationKey)
    }
    
    // MARK: - Main Migration Method
    
    /// Migrate all embedded exercises to standalone exercise library
    func migrateExercises(
        progress: @escaping (MigrationStatus) -> Void
    ) async throws {
        
        // Check if already migrated
        guard isMigrationNeeded() else {
            throw MigrationError.alreadyMigrated
        }
        
        progress(.inProgress(percentComplete: 0))
        
        // Fetch all workouts
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.dateAndTime)]
        )
        
        let workouts = try modelContext.fetch(descriptor)
        
        guard !workouts.isEmpty else {
            throw MigrationError.noWorkoutsFound
        }
        
        // Track unique exercises to avoid duplicates
        var exerciseMap: [String: Exercise] = [:]
        var totalExercises = 0
        var processedExercises = 0
        
        // Count total exercises
        for workout in workouts {
            for interval in workout.intervals {
                totalExercises += interval.exercises.count
            }
        }
        
        // Process each workout
        for workout in workouts {
            for interval in workout.intervals {
                // Store old exercises temporarily
                let oldExercises = interval.exercises
                
                // Clear the interval's exercises array to prepare for new relationships
                if interval.intervalExercises == nil {
                    interval.intervalExercises = []
                }
                
                // Process each exercise
                for (index, oldExercise) in oldExercises.enumerated() {
                    // Find or create the exercise template
                    let exerciseKey = "\(oldExercise.name)-\(oldExercise.trainingMethod)"
                    
                    let exercise: Exercise
                    if let existing = exerciseMap[exerciseKey] {
                        exercise = existing
                    } else {
                        // Create new exercise template
                        exercise = Exercise.fromLegacy(oldExercise)
                        modelContext.insert(exercise)
                        exerciseMap[exerciseKey] = exercise
                    }
                    
                    // Create bridge entity with workout-specific data
                    let intervalExercise = IntervalExercise(
                        exercise: exercise,
                        interval: interval,
                        orderIndex: index,
                        effort: oldExercise.effort,
                        weight: oldExercise.weight,
                        restAfter: oldExercise.restAfter,
                        tempo: oldExercise.tempo,
                        notes: oldExercise.notes
                    )
                    
                    modelContext.insert(intervalExercise)
                    interval.intervalExercises?.append(intervalExercise)
                    
                    // Update progress
                    processedExercises += 1
                    let percentComplete = Double(processedExercises) / Double(totalExercises)
                    progress(.inProgress(percentComplete: percentComplete))
                }
            }
        }
        
        // Save all changes
        do {
            try modelContext.save()
            
            // Mark migration as complete
            UserDefaults.standard.set(true, forKey: "ExerciseLibraryMigrationCompleted")
            
            progress(.completed)
            
            print("Migration completed: Created \(exerciseMap.count) unique exercises from \(totalExercises) instances")
            
        } catch {
            progress(.failed(error))
            throw MigrationError.saveFailed
        }
    }
    
    // MARK: - Rollback Support
    
    /// Rollback migration (for testing/debugging)
    func rollbackMigration() async throws {
        // Delete all IntervalExercise entities
        let bridgeDescriptor = FetchDescriptor<IntervalExercise>()
        let bridges = try modelContext.fetch(bridgeDescriptor)
        
        for bridge in bridges {
            modelContext.delete(bridge)
        }
        
        // Delete all Exercise entities
        let exerciseDescriptor = FetchDescriptor<Exercise>()
        let exercises = try modelContext.fetch(exerciseDescriptor)
        
        for exercise in exercises {
            modelContext.delete(exercise)
        }
        
        // Save changes
        try modelContext.save()
        
        // Clear migration flag
        UserDefaults.standard.removeObject(forKey: "ExerciseLibraryMigrationCompleted")
    }
    
    // MARK: - Migration Report
    
    struct MigrationReport {
        let totalWorkouts: Int
        let totalIntervals: Int
        let totalExerciseInstances: Int
        let uniqueExercisesCreated: Int
        let categoriesAssigned: [ExerciseCategory: Int]
        let migrationDate: Date
    }
    
    /// Generate a report of the migration results
    func generateMigrationReport() async throws -> MigrationReport {
        let workouts = try modelContext.fetch(FetchDescriptor<Workout>())
        let exercises = try modelContext.fetch(FetchDescriptor<Exercise>())
        let intervalExercises = try modelContext.fetch(FetchDescriptor<IntervalExercise>())
        
        var categoryCounts: [ExerciseCategory: Int] = [:]
        for exercise in exercises {
            if let category = exercise.category {
                categoryCounts[category, default: 0] += 1
            }
        }
        
        return MigrationReport(
            totalWorkouts: workouts.count,
            totalIntervals: workouts.flatMap { $0.intervals }.count,
            totalExerciseInstances: intervalExercises.count,
            uniqueExercisesCreated: exercises.count,
            categoriesAssigned: categoryCounts,
            migrationDate: Date()
        )
    }
}

// MARK: - Migration UI Helper
extension ExerciseMigrationHelper {
    
    /// Simple migration with completion handler
    static func performMigration(
        in modelContext: ModelContext,
        exerciseStore: ExerciseStore,
        completion: @escaping (Result<MigrationReport, Error>) -> Void
    ) {
        let helper = ExerciseMigrationHelper(
            modelContext: modelContext,
            exerciseStore: exerciseStore
        )
        
        Task {
            do {
                var latestStatus: MigrationStatus = .notStarted
                
                try await helper.migrateExercises { status in
                    latestStatus = status
                    
                    // Update UI on main thread if needed
                    Task { @MainActor in
                        switch status {
                        case .inProgress(let percent):
                            print("Migration progress: \(Int(percent * 100))%")
                        case .completed:
                            print("Migration completed successfully")
                        case .failed(let error):
                            print("Migration failed: \(error)")
                        default:
                            break
                        }
                    }
                }
                
                // Generate report
                let report = try await helper.generateMigrationReport()
                completion(.success(report))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
}