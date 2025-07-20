//
//  PreviewModifier.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 20/07/2025.
//

import SwiftUI
import SwiftData

@MainActor
struct SampleDataPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
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
        
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        
        // Critical: Disable autosave to prevent timing issues during delete operations
        container.mainContext.autosaveEnabled = false
        
        // Add sample data
        let context = container.mainContext
        
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
                )
            ]
        )
        restPauseWorkout.totalDuration = 900 // 15 minutes
        
        // Insert all workouts
        context.insert(strengthWorkout)
        context.insert(hiitWorkout)
        context.insert(restPauseWorkout)
        
        // Save the context
        try context.save()
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
            .environment(WorkoutStore(modelContainer: context))
    }
}

// Convenience extension for easier use
extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleDataPreviewModifier())
}