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
    
    private var exerciseGifUrl: String? {
        exercise.exerciseItem?.gifUrl
    }
    
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
        case let .standard(minReps, maxReps):
            return minReps == maxReps ? "\(minReps) reps" : "\(minReps)-\(maxReps) reps"
        case let .timed(seconds):
            return "\(seconds) seconds"
        case let .restPause(targetTotal, minReps, maxReps):
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
    
    // MARK: - Static Constants
    private static let separatorWidth: CGFloat = 0.5
    private static let separatorPadding: CGFloat = 8.0
    private static let separatorColor: Color = Color(UIColor.separator)
    
    
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
    
    // MARK: - Static Grid Layout Constants
    private static let gridVerticalSpacing: CGFloat = 4.0
    
    // MARK: - Dynamic Row System
    
    /// Represents a single row of detail information in the grid
    private struct DetailRowData: Identifiable {
        let id = UUID()
        let leftContent: AnyView?
        let rightContent: AnyView?
        
        init<L: View, R: View>(left: L?, right: R?) {
            // Fix AnyView initialization - explicitly handle optionals to avoid type inference issues
            if let leftView = left {
                self.leftContent = AnyView(leftView)
            } else {
                self.leftContent = nil
            }
            
            if let rightView = right {
                self.rightContent = AnyView(rightView)
            } else {
                self.rightContent = nil
            }
        }
    }
    
    /// Reusable component for displaying a single row with left/right content and center separator
    private struct DetailRow: View {
        let data: DetailRowData
        
        var body: some View {
            HStack(spacing: 0) {
                // Left content (flexible width)
                if let leftContent = data.leftContent {
                    leftContent
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                
                // Center separator (fixed width: 1pt + 4pt padding each side = 9pt total)
                    
                
                // Right content (flexible width)
                if let rightContent = data.rightContent {
                    rightContent
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        
        // Static separator constants
        private static let separatorWidth: CGFloat = 1.0
        private static let separatorPadding: CGFloat = 4.0
        private static let separatorColor: Color = Color(UIColor.separator)
    }
    
    /// Pre-computed array of rows based on available exercise data
    /// Handles all combinations: weight, rest, tempo in optimal layout
    private var detailRows: [DetailRowData] {
        var rows: [DetailRowData] = []
        
        let hasWeight = exercise.weight != nil
        let hasRest = exercise.restAfter != nil
        let hasTempo = exercise.tempo != nil
        
        // Determine optimal layout based on available data
        switch (hasWeight, hasRest, hasTempo) {
        case (true, true, true):
            // All three: Weight + Rest, Tempo on second row
            rows.append(DetailRowData(left: weightLabel, right: restLabel))
            rows.append(DetailRowData(left: tempoLabel, right: nil as EmptyView?))
            
        case (true, true, false):
            // Weight + Rest only
            rows.append(DetailRowData(left: weightLabel, right: restLabel))
            
        case (true, false, true):
            // Weight + Tempo
            rows.append(DetailRowData(left: weightLabel, right: tempoLabel))
            
        case (false, true, true):
            // Rest + Tempo
            rows.append(DetailRowData(left: restLabel, right: tempoLabel))
            
        case (true, false, false):
            // Weight only
            rows.append(DetailRowData(left: weightLabel, right: nil as EmptyView?))
            
        case (false, true, false):
            // Rest only
            rows.append(DetailRowData(left: restLabel, right: nil as EmptyView?))
            
        case (false, false, true):
            // Tempo only
            rows.append(DetailRowData(left: tempoLabel, right: nil as EmptyView?))
            
        case (false, false, false):
            // No optional details (handled by hasOptionalDetails check)
            break
        }
        
        return rows
    }
    
    // MARK: - Optional Details Grid
    @ViewBuilder
    private var optionalDetailsGrid: some View {
        if hasOptionalDetails {
            VStack(alignment: .leading, spacing: Self.gridVerticalSpacing) {
                // Dynamic rows
                ForEach(detailRows) { rowData in
                    DetailRow(data: rowData)
                }
                
                // Notes (always full width if present)
                if let notes = exercise.notes, !notes.isEmpty {
                    notesText
                }
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Exercise GIF (if available)
            if let gifUrl = exerciseGifUrl, !gifUrl.isEmpty {
                AsyncImage(url: URL(string: gifUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 120)
                        .cornerRadius(8)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
            }
            
            // Exercise Name and Effort
            HStack {
                Text(exercise.name)
                    .bold()
                Spacer()
                Text(trainingMethodDescription)
                Spacer()
                Label("\(exercise.effort)", systemImage: "flame.fill")
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                    .font(.caption)
                    .padding(6)
                    .background(Capsule().fill(effortColor))
            }
            // Optional Details Grid
            optionalDetailsGrid
            
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

#Preview("Exercise with GIF", traits: .sampleData) {
    ExerciseCard(
        exercise: Exercise(
            exerciseItem: ExerciseItem(name: "Push-ups", gifUrl: "https://example.com/pushups.gif"),
            trainingMethod: .standard(minReps: 15, maxReps: 20),
            effort: 6,
            notes: "Keep body straight, engage core"
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
