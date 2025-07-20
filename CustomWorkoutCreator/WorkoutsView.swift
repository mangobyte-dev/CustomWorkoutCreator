//
//  WorkoutsView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import SwiftUI
import SwiftData

struct WorkoutsView: View {
    @Environment(WorkoutStore.self) private var workoutStore
    @State private var showingNewWorkout = false
    @State private var workouts: [Workout] = []
    
    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    ContentUnavailableView("No Workouts", systemImage: "figure.run", description: Text("Tap + to create your first workout"))
                } else {
                    List {
                        ForEach(workouts) { workout in
                            WorkoutRow(workout: workout)
                        }
                        .onDelete { indices in
                            deleteWorkouts(at: indices)
                        }
                    }
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewWorkout = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewWorkout) {
                NewWorkoutView()
            }
            .onAppear {
                loadWorkouts()
            }
            .onChange(of: showingNewWorkout) { _, isShowing in
                if !isShowing {
                    loadWorkouts()
                }
            }
        }
    }
    
    private func loadWorkouts() {
        workouts = workoutStore.fetchAllWorkouts()
    }
    
    private func deleteWorkouts(at indices: IndexSet) {
        for index in indices {
            if workouts.indices.contains(index) {
                workoutStore.deleteWorkout(workouts[index])
            }
        }
        loadWorkouts()
    }
}

struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.name)
                .font(.headline)
            
            HStack {
                Label("\(workout.intervals.count) intervals", systemImage: "repeat")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(formatDuration(workout.totalDuration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}



#Preview(traits: .sampleData) {
    WorkoutsView()
}
