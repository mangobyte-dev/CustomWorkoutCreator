//
//  ExerciseCard.swift
//  CustomWorkoutCreator
//
//  Created by Assistant on 07/31/2025.
//

import SwiftUI

// MARK: - Exercise Card Component
/// Displays detailed exercise information following CLAUDE.md performance principles
/// Pre-computes all values and uses static lookup tables for optimal performance
struct ExerciseCard: View {
    let exercise: Exercise
    
    // MARK: - Supporting Types
    private enum TrainingMethodType: Hashable {
        case standard
        case timed
        case restPause
    }
    
    // MARK: - Static Lookup Tables
    
    private static let trainingMethodIcons: [TrainingMethodType: String] = [
        .standard: "number",
        .timed: "timer",
        .restPause: "pause.rectangle"
    ]
    
    private static let effortColors: [(range: ClosedRange<Int>, color: Color)] = [
        (1...3, .green),
        (4...6, .yellow),
        (7...8, .orange),
        (9...10, .red)
    ]
    
    // MARK: - Pre-computed Properties
    
    private var trainingMethodType: TrainingMethodType {
        switch exercise.trainingMethod {
        case .standard: return .standard
        case .timed: return .timed
        case .restPause: return .restPause
        }
    }
    
    private var trainingMethodIcon: String {
        Self.trainingMethodIcons[trainingMethodType] ?? "questionmark"
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
    
    private var effortColor: Color {
        Self.effortColors.first { $0.range.contains(exercise.effort) }?.color ?? .gray
    }
    
    private var hasOptionalDetails: Bool {
        exercise.weight != nil || 
        exercise.restAfter != nil || 
        exercise.tempo != nil || 
        (exercise.notes != nil && !exercise.notes!.isEmpty)
    }
    
    private func calculateSeparatorHeight() -> CGFloat {
        // Calculate the number of rows in the left column
        let leftColumnRows = (exercise.weight != nil ? 1 : 0) + (exercise.tempo != nil ? 1 : 0)
        // Calculate the number of rows in the right column
        let rightColumnRows = exercise.restAfter != nil ? 1 : 0
        // Take the maximum of both columns
        let maxRows = max(leftColumnRows, rightColumnRows)
        // Each row is approximately 20 points (caption font + 4pt spacing)
        return CGFloat(maxRows) * 20
    }
    
    
    // MARK: - @ViewBuilder Computed Properties
    
    @ViewBuilder
    private var weightLabel: some View {
        if let weight = exercise.weight {
            Label("\(weight.formatted()) lbs", systemImage: "scalemass")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var restLabel: some View {
        if let restAfter = exercise.restAfter {
            Label("\(restAfter)s rest", systemImage: "pause.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var tempoLabel: some View {
        if let tempo = exercise.tempo {
            Label("\(tempo.eccentric)-\(tempo.pause)-\(tempo.concentric) tempo", systemImage: "metronome")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var notesText: some View {
        if let notes = exercise.notes, !notes.isEmpty {
            Text(notes)
                .font(.caption)
                .foregroundStyle(.secondary)
                .italic()
        }
    }
    
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
                    .foregroundStyle(effortColor)
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
            
            // Optional Details Grid
            if hasOptionalDetails {
                // 2-column grid with vertical separator
                HStack(alignment: .top, spacing: 0) {
                    // Left column
                    VStack(alignment: .leading, spacing: 4) {
                        // Weight in left column
                        if exercise.weight != nil {
                            weightLabel
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Tempo in left column (second row)
                        if exercise.tempo != nil {
                            tempoLabel
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Vertical separator
                    if (exercise.weight != nil || exercise.tempo != nil) && exercise.restAfter != nil {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(width: 0.5)
                            .frame(height: calculateSeparatorHeight())
                            .padding(.vertical, 2)
                    }
                    
                    // Right column
                    VStack(alignment: .leading, spacing: 4) {
                        // Rest in right column
                        if exercise.restAfter != nil {
                            restLabel
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 4)
                
                // Notes on its own line if present (always full width)
                notesText
            }
        }
    }
}

// MARK: - Equatable Conformance
extension ExerciseCard: Equatable {
    static func == (lhs: ExerciseCard, rhs: ExerciseCard) -> Bool {
        lhs.exercise == rhs.exercise
    }
}

// MARK: - Preview Provider
#Preview("Standard Exercise") {
    ExerciseCard(
        exercise: Exercise(
            name: "Bench Press",
            trainingMethod: .standard(minReps: 8, maxReps: 12),
            effort: 7,
            weight: 185,
            restAfter: 60,
            tempo: Tempo(eccentric: 3, pause: 1, concentric: 1),
            notes: "Focus on form, squeeze at top"
        )
    )
    .padding()
    .background(ComponentConstants.Colors.secondaryGroupedBackground)
    .cornerRadius(ComponentConstants.Layout.cornerRadius)
}

#Preview("Timed Exercise") {
    ExerciseCard(
        exercise: Exercise(
            name: "Plank",
            trainingMethod: .timed(seconds: 60),
            effort: 8,
            notes: "Keep core tight"
        )
    )
    .padding()
    .background(ComponentConstants.Colors.secondaryGroupedBackground)
    .cornerRadius(ComponentConstants.Layout.cornerRadius)
}

#Preview("Rest-Pause Exercise") {
    ExerciseCard(
        exercise: Exercise(
            name: "Pull-ups",
            trainingMethod: .restPause(targetTotal: 50, minReps: 5, maxReps: 10),
            effort: 9,
            restAfter: 90
        )
    )
    .padding()
    .background(ComponentConstants.Colors.secondaryGroupedBackground)
    .cornerRadius(ComponentConstants.Layout.cornerRadius)
}

#Preview("Minimal Exercise") {
    ExerciseCard(
        exercise: Exercise(
            name: "Jumping Jacks",
            trainingMethod: .standard(minReps: 20, maxReps: 20),
            effort: 3
        )
    )
    .padding()
    .background(ComponentConstants.Colors.secondaryGroupedBackground)
    .cornerRadius(ComponentConstants.Layout.cornerRadius)
}

#Preview("Exercise List") {
    ScrollView {
        VStack(spacing: 12) {
            ExerciseCard(
                exercise: Exercise(
                    name: "Squats",
                    trainingMethod: .standard(minReps: 12, maxReps: 15),
                    effort: 7,
                    weight: 225,
                    restAfter: 90,
                    tempo: Tempo(eccentric: 3, pause: 0, concentric: 1)
                )
            )
            
            Divider()
            
            ExerciseCard(
                exercise: Exercise(
                    name: "Romanian Deadlifts",
                    trainingMethod: .standard(minReps: 10, maxReps: 12),
                    effort: 8,
                    weight: 185,
                    restAfter: 60
                )
            )
            
            Divider()
            
            ExerciseCard(
                exercise: Exercise(
                    name: "Walking Lunges",
                    trainingMethod: .standard(minReps: 12, maxReps: 12),
                    effort: 6,
                    weight: 50,
                    notes: "Each leg"
                )
            )
        }
        .padding()
        .background(ComponentConstants.Colors.secondaryGroupedBackground)
        .cornerRadius(ComponentConstants.Layout.cornerRadius)
    }
}