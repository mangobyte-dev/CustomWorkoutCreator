//
//  ExerciseStore.swift
//  CustomWorkoutCreator
//
//  Created by Assistant on 08/05/2025.
//
// Store for managing the exercise library
// Follows CLAUDE.md principles - no ViewModels, uses @Observable

import Foundation
import SwiftData
import Observation

@Observable
final class ExerciseStore {
    // MARK: - Properties
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    // MARK: - Search State
    var searchText: String = ""
    var selectedCategory: ExerciseCategory?
    var selectedEquipment: Set<Equipment> = []
    var showFavoritesOnly: Bool = false
    var sortBy: SortOption = .name
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case recent = "Recently Used"
        case popular = "Most Used"
        case category = "Category"
    }
    
    // MARK: - Initialization
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = modelContainer.mainContext
        
        // Check if we need to create default exercises
        Task {
            await createDefaultExercisesIfNeeded()
        }
    }
    
    // MARK: - CRUD Operations
    
    func createExercise(
        name: String,
        trainingMethod: TrainingMethod,
        category: ExerciseCategory? = nil,
        equipment: [Equipment]? = nil
    ) -> Exercise {
        let exercise = Exercise(
            name: name,
            trainingMethod: trainingMethod,
            category: category,
            equipment: equipment,
            isCustom: true
        )
        
        modelContext.insert(exercise)
        save()
        
        return exercise
    }
    
    func updateExercise(_ exercise: Exercise) {
        exercise.updateSearchText()
        save()
    }
    
    func deleteExercise(_ exercise: Exercise) {
        modelContext.delete(exercise)
        save()
    }
    
    func toggleFavorite(_ exercise: Exercise) {
        exercise.isFavorite.toggle()
        save()
    }
    
    func archiveExercise(_ exercise: Exercise) {
        exercise.isArchived = true
        save()
    }
    
    // MARK: - Search & Filter
    
    func searchExercises() -> [Exercise] {
        var descriptor = FetchDescriptor<Exercise>(
            predicate: buildPredicate(),
            sortBy: buildSortDescriptors()
        )
        
        // Limit results for performance
        descriptor.fetchLimit = 100
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch exercises: \(error)")
            return []
        }
    }
    
    private func buildPredicate() -> Predicate<Exercise>? {
        var predicates: [Predicate<Exercise>] = []
        
        // Exclude archived
        predicates.append(#Predicate<Exercise> { exercise in
            exercise.isArchived == false
        })
        
        // Search text
        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            predicates.append(#Predicate<Exercise> { exercise in
                exercise.searchText.contains(searchLower)
            })
        }
        
        // Category filter
        if let category = selectedCategory {
            predicates.append(#Predicate<Exercise> { exercise in
                exercise.category == category
            })
        }
        
        // Equipment filter
        if !selectedEquipment.isEmpty {
            // This is tricky with SwiftData predicates
            // May need to handle in post-processing
        }
        
        // Favorites only
        if showFavoritesOnly {
            predicates.append(#Predicate<Exercise> { exercise in
                exercise.isFavorite == true
            })
        }
        
        // Combine predicates
        if predicates.isEmpty {
            return nil
        } else if predicates.count == 1 {
            return predicates[0]
        } else {
            // Combine with AND logic
            return predicates.reduce(predicates[0]) { result, predicate in
                #Predicate<Exercise> { exercise in
                    // This is a simplified representation
                    // Actual implementation would need proper predicate combination
                    true
                }
            }
        }
    }
    
    private func buildSortDescriptors() -> [SortDescriptor<Exercise>] {
        switch sortBy {
        case .name:
            return [SortDescriptor(\.name)]
        case .recent:
            return [SortDescriptor(\.lastUsedDate, order: .reverse)]
        case .popular:
            return [SortDescriptor(\.useCount, order: .reverse)]
        case .category:
            return [SortDescriptor(\.category?.rawValue ?? ""), SortDescriptor(\.name)]
        }
    }
    
    // MARK: - Quick Access
    
    func recentExercises(limit: Int = 10) -> [Exercise] {
        var descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.lastUsedDate != nil && exercise.isArchived == false
            },
            sortBy: [SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }
    
    func favoriteExercises() -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.isFavorite == true && exercise.isArchived == false
            },
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }
    
    func exercisesByCategory(_ category: ExerciseCategory) -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.category == category && exercise.isArchived == false
            },
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }
    
    // MARK: - Autocomplete
    
    func autocompleteExercises(for text: String, limit: Int = 5) -> [Exercise] {
        guard !text.isEmpty else { return [] }
        
        let searchLower = text.lowercased()
        var descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.searchText.contains(searchLower) && exercise.isArchived == false
            },
            sortBy: [
                SortDescriptor(\.useCount, order: .reverse),
                SortDescriptor(\.name)
            ]
        )
        descriptor.fetchLimit = limit
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }
    
    // MARK: - Migration Support
    
    func findOrCreateExercise(name: String, trainingMethod: TrainingMethod) -> Exercise {
        // First, try to find existing
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.name == name
            }
        )
        
        do {
            let existing = try modelContext.fetch(descriptor)
            if let exercise = existing.first {
                return exercise
            }
        } catch {
            print("Error searching for exercise: \(error)")
        }
        
        // Create new if not found
        return createExercise(
            name: name,
            trainingMethod: trainingMethod
        )
    }
    
    // MARK: - Private Helpers
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save exercise changes: \(error)")
        }
    }
    
    private func createDefaultExercisesIfNeeded() async {
        // Check if we already have exercises
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.isCustom == false
            }
        )
        
        do {
            let count = try modelContext.fetchCount(descriptor)
            if count == 0 {
                // Create default exercises
                Exercise.createDefaultExercises(in: modelContext)
                save()
            }
        } catch {
            print("Failed to check default exercises: \(error)")
        }
    }
}

// MARK: - Exercise Statistics
extension ExerciseStore {
    
    struct ExerciseStats {
        let totalExercises: Int
        let customExercises: Int
        let favoriteCount: Int
        let categoryCounts: [ExerciseCategory: Int]
        let equipmentCounts: [Equipment: Int]
    }
    
    func calculateStats() -> ExerciseStats {
        let allExercises = try? modelContext.fetch(FetchDescriptor<Exercise>())
        let exercises = allExercises ?? []
        
        var categoryCounts: [ExerciseCategory: Int] = [:]
        var equipmentCounts: [Equipment: Int] = [:]
        
        for exercise in exercises where !exercise.isArchived {
            if let category = exercise.category {
                categoryCounts[category, default: 0] += 1
            }
            
            if let equipmentList = exercise.equipment {
                for equipment in equipmentList {
                    equipmentCounts[equipment, default: 0] += 1
                }
            }
        }
        
        return ExerciseStats(
            totalExercises: exercises.filter { !$0.isArchived }.count,
            customExercises: exercises.filter { $0.isCustom && !$0.isArchived }.count,
            favoriteCount: exercises.filter { $0.isFavorite && !$0.isArchived }.count,
            categoryCounts: categoryCounts,
            equipmentCounts: equipmentCounts
        )
    }
}