//
//  WorkoutFormView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 20/07/2025.
//

import SwiftUI
import SwiftData

struct WorkoutFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let workout: Workout?
    
    @State private var workoutName = ""
    @State private var intervals: [Interval] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Workout Details") {
                    TextField("Workout Name", text: $workoutName)
                }
                
                Section("Intervals") {
                    ForEach($intervals) { $interval in
                        IntervalRow(interval: $interval)
                    }
                    .onDelete { indices in
                        intervals.remove(atOffsets: indices)
                    }
                    
                    Button("Add Interval") {
                        let newInterval = Interval()
                        newInterval.name = "Interval \(intervals.count + 1)"
                        intervals.append(newInterval)
                    }
                }
            }
            .navigationTitle(workout == nil ? "New Workout" : "Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty)
                }
            }
            .onAppear {
                loadWorkoutData()
            }
        }
    }
    
    private func loadWorkoutData() {
        if let workout = workout {
            workoutName = workout.name
            intervals = workout.intervals
        }
    }
    
    private func saveWorkout() {
        if let existingWorkout = workout {
            existingWorkout.name = workoutName
            existingWorkout.intervals = intervals
        } else {
            let newWorkout = Workout(
                name: workoutName,
                dateAndTime: Date(),
                intervals: intervals
            )
            modelContext.insert(newWorkout)
        }
        dismiss()
    }
}

struct IntervalRow: View {
    @Binding var interval: Interval
    @State private var isExpanded = true
    @State private var showingNewExercisePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                TextField("Interval Name", text: Binding(
                    get: { interval.name ?? "" },
                    set: { interval.name = $0.isEmpty ? nil : $0 }
                ))
                .font(.headline)
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.secondary)
                    .onTapGesture {
                        isExpanded.toggle()
                    }
            }
            
            if isExpanded {
                // Rounds
                HStack {
                    Text("Rounds")
                    Spacer()
                    Stepper("\(interval.rounds)", value: $interval.rounds, in: 1...10)
                }
                
                // Exercises
                Text("Exercises")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                
                ForEach($interval.exercises) { $exercise in
                    ExerciseRow(exercise: $exercise)
                }
                .onDelete { indices in
                    interval.exercises.remove(atOffsets: indices)
                }
                
                Button {
                    showingNewExercisePicker = true
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle")
                }
                .font(.callout)
                .padding(.top, 4)
                .sheet(isPresented: $showingNewExercisePicker) {
                    ExercisePicker(selectedExercise: .constant(nil)) { selected in
                        let newExercise = Exercise()
                        newExercise.exerciseItem = selected
                        newExercise.trainingMethod = .standard(minReps: 8, maxReps: 12)
                        interval.exercises.append(newExercise)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExerciseRow: View {
    @Binding var exercise: Exercise
    @State private var showingExercisePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Exercise selection button
            Button {
                showingExercisePicker = true
            } label: {
                HStack {
                    // GIF thumbnail if available
                    if let exerciseItem = exercise.exerciseItem,
                       let gifUrl = exerciseItem.gifUrl {
                        GifImageView(gifUrl)
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.quaternary.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay {
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                    }
                    
                    // Exercise name or prompt
                    if let exerciseItem = exercise.exerciseItem {
                        Text(exerciseItem.name)
                            .font(.callout)
                            .foregroundStyle(.primary)
                    } else {
                        Text("Select Exercise")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            
            // Training method info
            HStack {
                Text("Effort: \(exercise.effort)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(methodDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePicker(selectedExercise: Binding(
                get: { exercise.exerciseItem },
                set: { _ in }
            )) { selected in
                exercise.exerciseItem = selected
            }
        }
    }
    
    private var methodDescription: String {
        switch exercise.trainingMethod {
        case .standard(let minReps, let maxReps):
            return "\(minReps)-\(maxReps) reps"
        case .timed(let seconds):
            return "\(seconds)s"
        case .restPause(let total, _, _):
            return "\(total) total"
        }
    }
}

#Preview("New Workout", traits: .sampleData) {
    WorkoutFormView(workout: nil)
}

#Preview("Edit Workout", traits: .sampleData) {
    WorkoutFormView(workout: .previewStrength)
}