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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Workout.self, ExerciseItem.self])
    }
}
