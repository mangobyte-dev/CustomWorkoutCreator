//
//  WorkoutsView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 16/07/2025.
//

import SwiftUI
import SwiftData

struct WorkoutsView: View {
    @Query(sort: \Workout.dateAndTime, order: .reverse) private var workouts: [Workout]
    @Environment(\.modelContext) private var modelContext
    @State private var showingNewWorkout = false
    
    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    ContentUnavailableView("No Workouts", systemImage: "figure.run", description: Text("Tap + to create your first workout"))
                } else {
                    List {
                        ForEach(workouts) { workout in
                            NavigationLink {
                                WorkoutDetailView(workout: workout)
                            } label: {
                                WorkoutRow(workout: workout)
                            }
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
                WorkoutFormView(workout: nil)
            }
        }
    }
    
    private func deleteWorkouts(at indices: IndexSet) {
        for index in indices {
            if workouts.indices.contains(index) {
                modelContext.delete(workouts[index])
            }
        }
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
