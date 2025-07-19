//
//  CustomWorkoutCreatorApp.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import SwiftUI
import SwiftData

@main
struct CustomWorkoutCreatorApp: App {
    @State private var workoutStore: WorkoutStore?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(workoutStore)
        }
        .modelContainer(for: Workout.self) { result in
            switch result {
            case let .success(container):
                workoutStore = WorkoutStore(modelContainer: container)
            case let .failure(error):
                print("Failed to create model container: \(error)")
            }
        }
    }
}
