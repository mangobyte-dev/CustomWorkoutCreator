//
//  PreviewContainer.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 20/07/2025.
//

import SwiftUI
import SwiftData

@MainActor
class PreviewContainer {
    static let shared = PreviewContainer()
    
    let container: ModelContainer
    
    private init() {
        let schema = Schema([
            Workout.self,
            Interval.self,
            Exercise.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            allowsSave: true
        )
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            // Critical: Disable autosave to prevent timing issues during delete operations
            container.mainContext.autosaveEnabled = false
            
            addSampleData()
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
    
    private func addSampleData() {
        let context = container.mainContext
        
        // Create a variety of workouts for testing different UI states
        
        // 1. Strength Training Workout
        let strengthWorkout = Workout(
            name: "Upper Body Strength",
            dateAndTime: Date().addingTimeInterval(-86400), // Yesterday
            intervals: [
                Interval(
                    name: "Compound Movements",
                    exercises: [
                        Exercise(
                            name: "Bench Press",
                            trainingMethod: .standard(minReps: 6, maxReps: 8),
                            effort: 8,
                            weight: 185,
                            restAfter: 180,
                            tempo: .slow
                        ),
                        Exercise(
                            name: "Pull-ups",
                            trainingMethod: .standard(minReps: 8, maxReps: 12),
                            effort: 9,
                            weight: nil,
                            restAfter: 120
                        )
                    ],
                    rounds: 4,
                    restBetweenRounds: 300,
                    restAfterInterval: 300
                ),
                Interval(
                    name: "Isolation Work",
                    exercises: [
                        Exercise(
                            name: "Dumbbell Curls",
                            trainingMethod: .standard(minReps: 12, maxReps: 15),
                            effort: 7,
                            weight: 30,
                            restAfter: 60
                        ),
                        Exercise(
                            name: "Tricep Extensions",
                            trainingMethod: .standard(minReps: 12, maxReps: 15),
                            effort: 7,
                            weight: 25,
                            restAfter: 60
                        )
                    ],
                    rounds: 3,
                    restBetweenRounds: 90,
                    restAfterInterval: nil
                )
            ]
        )
        strengthWorkout.totalDuration = 2400 // 40 minutes
        
        // 2. HIIT Circuit Workout
        let hiitWorkout = Workout(
            name: "Quick HIIT Circuit",
            dateAndTime: Date().addingTimeInterval(-172800), // 2 days ago
            intervals: [
                Interval(
                    name: "Warm-up",
                    exercises: [
                        Exercise(
                            name: "Jumping Jacks",
                            trainingMethod: .timed(seconds: 30),
                            effort: 5,
                            restAfter: 10
                        ),
                        Exercise(
                            name: "High Knees",
                            trainingMethod: .timed(seconds: 30),
                            effort: 6,
                            restAfter: 10
                        )
                    ],
                    rounds: 2,
                    restBetweenRounds: 30,
                    restAfterInterval: 60
                ),
                Interval(
                    name: "Main Circuit",
                    exercises: [
                        Exercise(
                            name: "Burpees",
                            trainingMethod: .standard(minReps: 10, maxReps: 10),
                            effort: 9,
                            restAfter: 30
                        ),
                        Exercise(
                            name: "Mountain Climbers",
                            trainingMethod: .timed(seconds: 45),
                            effort: 8,
                            restAfter: 30
                        ),
                        Exercise(
                            name: "Jump Squats",
                            trainingMethod: .standard(minReps: 15, maxReps: 15),
                            effort: 8,
                            restAfter: 30
                        )
                    ],
                    rounds: 4,
                    restBetweenRounds: 90,
                    restAfterInterval: nil
                )
            ]
        )
        hiitWorkout.totalDuration = 1200 // 20 minutes
        
        // 3. Rest-Pause Workout
        let restPauseWorkout = Workout(
            name: "Advanced Rest-Pause",
            dateAndTime: Date().addingTimeInterval(-259200), // 3 days ago
            intervals: [
                Interval(
                    exercises: [
                        Exercise(
                            name: "Dips",
                            trainingMethod: .restPause(targetTotal: 50, minReps: 8, maxReps: 12),
                            effort: 10,
                            notes: "Use assistance band if needed"
                        )
                    ],
                    rounds: 1,
                    restBetweenRounds: nil,
                    restAfterInterval: 300
                ),
                Interval(
                    exercises: [
                        Exercise(
                            name: "Chin-ups",
                            trainingMethod: .restPause(targetTotal: 40, minReps: 6, maxReps: 10),
                            effort: 10
                        )
                    ],
                    rounds: 1,
                    restBetweenRounds: nil,
                    restAfterInterval: nil
                )
            ]
        )
        restPauseWorkout.totalDuration = 900 // 15 minutes
        
        // 4. Empty Workout (for testing empty states)
        let emptyWorkout = Workout(
            name: "Planned Workout",
            dateAndTime: Date().addingTimeInterval(86400), // Tomorrow
            intervals: []
        )
        emptyWorkout.totalDuration = 0
        
        // Insert all workouts
        context.insert(strengthWorkout)
        context.insert(hiitWorkout)
        context.insert(restPauseWorkout)
        context.insert(emptyWorkout)
        
        // Save the context
        do {
            try context.save()
        } catch {
            print("Failed to save preview data: \(error)")
        }
    }
}

// Helper for creating custom preview scenarios
extension PreviewContainer {
    static func withCustomData(_ customizer: @escaping (ModelContainer) -> Void) -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Workout.self,
            configurations: config
        )
        container.mainContext.autosaveEnabled = false
        customizer(container)
        return container
    }
}