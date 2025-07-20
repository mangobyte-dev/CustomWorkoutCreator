//
//  WorkoutDetailView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 20/07/2025.
//

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let workout: Workout
    @State private var expandedIntervals: Set<UUID> = []
    @State private var showingEditView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            // Workout Overview Section
            Section {
                LabeledContent("Name", value: workout.name)
                    .font(.headline)
                
                LabeledContent("Date Created") {
                    Text(workout.dateAndTime, style: .date)
                    Text(workout.dateAndTime, style: .time)
                        .foregroundStyle(.secondary)
                }
                
                LabeledContent("Total Duration") {
                    Label(formatDuration(workout.totalDuration), systemImage: "timer")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Intervals Section
            if workout.intervals.isEmpty {
                Section {
                    Text("No intervals in this workout")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
            } else {
                ForEach(Array(workout.intervals.enumerated()), id: \.element.id) { index, interval in
                    Section {
                        IntervalDetailView(
                            interval: interval,
                            intervalNumber: index + 1,
                            isExpanded: expandedIntervals.contains(interval.id),
                            toggleExpanded: {
                                if expandedIntervals.contains(interval.id) {
                                    expandedIntervals.remove(interval.id)
                                } else {
                                    expandedIntervals.insert(interval.id)
                                }
                            }
                        )
                    }
                }
            }
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditView = true
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            WorkoutFormView(workout: workout)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if seconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
}

struct IntervalDetailView: View {
    let interval: Interval
    let intervalNumber: Int
    let isExpanded: Bool
    let toggleExpanded: () -> Void
    
    private var intervalTitle: String {
        interval.name ?? "Interval \(intervalNumber)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Interval Header - Always visible
            Button(action: toggleExpanded) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(intervalTitle)
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            if interval.rounds > 1 {
                                Label("\(interval.rounds) rounds", systemImage: "repeat")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let restBetween = interval.restBetweenRounds {
                                Label("\(restBetween)s between", systemImage: "pause.circle")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let restAfter = interval.restAfterInterval {
                                Label("\(restAfter)s after", systemImage: "arrow.right.circle")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .imageScale(.small)
                }
            }
            .buttonStyle(.plain)
            
            // Exercise List - Only visible when expanded
            if isExpanded {
                Divider()
                
                if interval.exercises.isEmpty {
                    Text("No exercises in this interval")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(interval.exercises) { exercise in
                        ExerciseDetailView(exercise: exercise)
                        
                        if exercise != interval.exercises.last {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise Name and Effort
            HStack {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Label("\(exercise.effort)/10", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(effortColor(exercise.effort))
            }
            
            // Training Method
            HStack {
                Image(systemName: trainingMethodIcon)
                    .foregroundStyle(.secondary)
                    .imageScale(.small)
                
                Text(trainingMethodDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Optional Details
            VStack(alignment: .leading, spacing: 4) {
                if let weight = exercise.weight {
                    Label("\(weight.formatted()) lbs", systemImage: "scalemass")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let restAfter = exercise.restAfter {
                    Label("\(restAfter)s rest", systemImage: "pause")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let tempo = exercise.tempo {
                    Label("\(tempo.eccentric)-\(tempo.pause)-\(tempo.concentric) tempo", systemImage: "metronome")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let notes = exercise.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
        }
    }
    
    private var trainingMethodIcon: String {
        switch exercise.trainingMethod {
        case .standard:
            return "number"
        case .timed:
            return "timer"
        case .restPause:
            return "pause.rectangle"
        }
    }
    
    private var trainingMethodDescription: String {
        switch exercise.trainingMethod {
        case .standard(let minReps, let maxReps):
            return minReps == maxReps ? "\(minReps) reps" : "\(minReps)-\(maxReps) reps"
        case .timed(let seconds):
            return "\(seconds) seconds"
        case .restPause(let targetTotal, let minReps, let maxReps):
            return "\(targetTotal) total (\(minReps)-\(maxReps) per set)"
        }
    }
    
    private func effortColor(_ effort: Int) -> Color {
        switch effort {
        case 1...3:
            return .green
        case 4...6:
            return .yellow
        case 7...8:
            return .orange
        case 9...10:
            return .red
        default:
            return .gray
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView(workout: .previewStrength)
    }
}

#Preview("HIIT Workout", traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView(workout: .previewHIIT)
    }
}

#Preview("Rest-Pause Workout", traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView(workout: .previewRestPause)
    }
}

#Preview("Empty Workout", traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView(workout: .previewEmpty)
    }
}