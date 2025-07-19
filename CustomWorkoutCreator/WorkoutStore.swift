//
//  WorkoutStore.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import SwiftUI
import SwiftData

@Observable
class WorkoutStore {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
    }
    
    func fetchAllWorkouts() -> [Workout] {
        do {
            let descriptor = FetchDescriptor<Workout>(
                sortBy: [SortDescriptor(\.dateAndTime, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch workouts: \(error)")
            return []
        }
    }
    
    func addWorkout(_ workout: Workout) {
        modelContext.insert(workout)
        do {
            try modelContext.save()
        } catch {
            print("Failed to save workout: \(error)")
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }
    
    func updateWorkout() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to update workout: \(error)")
        }
    }
}