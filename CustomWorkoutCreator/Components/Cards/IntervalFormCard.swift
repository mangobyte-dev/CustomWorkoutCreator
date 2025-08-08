import SwiftUI

// MARK: - IntervalFormCard Component
struct IntervalFormCard: View {
    @Binding var interval: Interval
    @Binding var isExpanded: Bool
    let intervalNumber: Int
    let onDelete: () -> Void
    let onAddExercise: () -> Void
    
    // Sheet presentation state for exercise editing
    @State private var editingExerciseID: UUID?
    
    // Stable rounds value to prevent stepper value from disappearing
    @State private var roundsValue: Int = 1
    
    // Pre-computed static values following CLAUDE.md performance principles
    private static let headerSpacing: CGFloat = 12
    private static let expandedContentSpacing: CGFloat = 1
    private static let minExercisesHeight: CGFloat = 100
    
    var body: some View {
        Expandable(
            isExpanded: $isExpanded,
            header: {
                // Header content - Interval name and exercise count
                HStack(spacing: Self.headerSpacing) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(intervalName)
                            .font(.headline)
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                        
                        Text(exerciseCountText)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Exercise count badge
                    if interval.exercises.count > 0 {
                        Badge(
                            text: "\(interval.exercises.count)",
                            color: Color.accentColor
                        )
                    }
                }
            },
            content: {
                // Expanded content - Name input, rounds, rest, exercises, and action buttons
                VStack(spacing: Self.expandedContentSpacing) {
                    // Interval name input
                    VStack(spacing: 0) {
                        Row(position: .only) {
                            HStack(spacing: ComponentConstants.Row.contentSpacing) {
                                Text("Name")
                                    .font(ComponentConstants.Row.titleFont)
                                    .foregroundStyle(ComponentConstants.Row.primaryTextColor)
                                
                                TextField("Interval \(intervalNumber)", text: intervalNameBinding)
                                    .font(ComponentConstants.Row.valueFont)
                                    .foregroundStyle(ComponentConstants.Row.primaryTextColor)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                    
                    // Rounds configuration
                    NumberInputRow(
                        title: "Rounds",
                        value: stableRoundsBinding,
                        range: 1...20,
                        icon: "repeat",
                        position: .first
                    )
                    
                    // Rest between rounds
                    TimeInputRow(
                        title: "Rest Between Rounds",
                        seconds: restBetweenRoundsBinding,
                        icon: "pause.circle",
                        position: .last
                    )
                    
                    // Exercises section
                    VStack(spacing: Self.expandedContentSpacing) {
                        // Section header with add button
                        HStack {
                            Text("Exercises")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.primary)
                            
                            Spacer()
                            
                            ActionButton(
                                title: "Add Exercise",
                                icon: "plus.circle",
                                style: .ghost,
                                size: .small
                            ) {
                                onAddExercise()
                            }
                        }
                        .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                        .padding(.vertical, ComponentConstants.Layout.compactPadding)
                        
                        // Exercise list or empty state
                        if interval.exercises.isEmpty {
                            VStack(spacing: ComponentConstants.Layout.compactPadding) {
                                Image(systemName: "figure.run")
                                    .font(.largeTitle)
                                    .foregroundStyle(Color.secondary)
                                
                                Text("No exercises added")
                                    .font(.body)
                                    .foregroundStyle(Color.secondary)
                                
                                Text("Tap 'Add Exercise' to get started")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: Self.minExercisesHeight)
                            .padding()
                        } else {
                            // Exercise list using ExerciseListRow
                            VStack(spacing: ComponentConstants.Layout.compactPadding) {
                                ForEach(interval.exercises, id: \.id) { exercise in
                                    ExerciseListRow(
                                        exercise: exercise,
                                        onTap: {
                                            editingExerciseID = exercise.id
                                        },
                                        onDuplicate: {
                                            duplicateExercise(id: exercise.id)
                                        },
                                        onDelete: {
                                            deleteExercise(id: exercise.id)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                        }
                    }
                    .background(ComponentConstants.Colors.tertiaryBackground)
                    
                    // Delete interval button
                    VStack(spacing: 0) {
                        ActionButton.danger(
                            title: "Delete Interval",
                            icon: "trash",
                            size: .small
                        ) {
                            onDelete()
                        }
                        .padding(.horizontal, ComponentConstants.Row.horizontalPadding)
                        .padding(.vertical, ComponentConstants.Row.verticalPadding)
                        .frame(maxWidth: .infinity)
                        .background(ComponentConstants.Row.backgroundColor)
                    }
                }
            }
        )
        .onAppear {
            // Initialize stable rounds value
            roundsValue = interval.rounds
        }
        .onChange(of: interval.rounds) { _, newValue in
            // Sync stable rounds when interval changes externally
            if roundsValue != newValue {
                roundsValue = newValue
            }
        }
        .sheet(item: Binding<EditingExercise?>(
            get: {
                guard let id = editingExerciseID,
                      let exercise = interval.exercises.first(where: { $0.id == id }) else {
                    return nil
                }
                return EditingExercise(id: id, exercise: exercise)
            },
            set: { _ in
                editingExerciseID = nil
            }
        )) { editingExercise in
            if let exerciseBinding = bindingForExercise(id: editingExercise.id) {
                ExerciseEditSheet(exercise: exerciseBinding)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var intervalName: String {
        if let name = interval.name, !name.isEmpty {
            return name
        }
        return "Interval \(intervalNumber)"
    }
    
    private var intervalNameBinding: Binding<String> {
        Binding<String>(
            get: { interval.name ?? "" },
            set: { interval.name = $0.isEmpty ? nil : $0 }
        )
    }
    
    private var stableRoundsBinding: Binding<Int> {
        Binding<Int>(
            get: { roundsValue },
            set: { newValue in
                roundsValue = newValue
                interval.rounds = newValue
            }
        )
    }
    
    private var restBetweenRoundsBinding: Binding<Int> {
        Binding<Int>(
            get: { interval.restBetweenRounds ?? 0 },
            set: { interval.restBetweenRounds = $0 > 0 ? $0 : nil }
        )
    }
    
    private var exerciseCountText: String {
        let count = interval.exercises.count
        if count == 0 {
            return "No exercises"
        } else if count == 1 {
            return "1 exercise"
        } else {
            return "\(count) exercises"
        }
    }
    
    // MARK: - Helper Methods
    
    private func bindingForExercise(id: UUID) -> Binding<Exercise>? {
        guard interval.exercises.contains(where: { $0.id == id }) else {
            return nil
        }
        
        return Binding<Exercise>(
            get: {
                // Always find fresh index to avoid stale references
                guard let currentIndex = interval.exercises.firstIndex(where: { $0.id == id }) else {
                    // This shouldn't happen in normal flow, but provide fallback
                    return Exercise()
                }
                return interval.exercises[currentIndex]
            },
            set: { newValue in
                // Update using fresh index lookup
                if let currentIndex = interval.exercises.firstIndex(where: { $0.id == id }) {
                    interval.exercises[currentIndex] = newValue
                }
            }
        )
    }
    
    private func deleteExercise(id: UUID) {
        withAnimation(.smooth(duration: 0.3)) {
            interval.exercises.removeAll(where: { $0.id == id })
        }
    }
    
    private func duplicateExercise(id: UUID) {
        guard let originalExercise = interval.exercises.first(where: { $0.id == id }) else {
            return
        }
        
        withAnimation(.smooth(duration: 0.3)) {
            // Create a copy with all properties preserved
            let duplicatedExercise = Exercise(
                exerciseItem: originalExercise.exerciseItem ?? ExerciseItem(name: "Unknown Exercise", gifUrl: nil),
                trainingMethod: originalExercise.trainingMethod,
                effort: originalExercise.effort
            )
            
            // Copy additional properties
            duplicatedExercise.weight = originalExercise.weight
            duplicatedExercise.restAfter = originalExercise.restAfter
            duplicatedExercise.tempo = originalExercise.tempo
            duplicatedExercise.notes = originalExercise.notes
            
            // Find the index to insert after the original
            if let originalIndex = interval.exercises.firstIndex(where: { $0.id == id }) {
                interval.exercises.insert(duplicatedExercise, at: originalIndex + 1)
            } else {
                // Fallback: append to end
                interval.exercises.append(duplicatedExercise)
            }
        }
    }
}

// MARK: - EditingExercise Identifiable Wrapper
private struct EditingExercise: Identifiable {
    let id: UUID
    let exercise: Exercise
}

// MARK: - Badge Component (reused from IntervalCard)
private struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }
}

// MARK: - Equatable for Performance
extension IntervalFormCard: Equatable {
    static func == (lhs: IntervalFormCard, rhs: IntervalFormCard) -> Bool {
        lhs.interval.id == rhs.interval.id &&
        lhs.isExpanded == rhs.isExpanded &&
        lhs.intervalNumber == rhs.intervalNumber
    }
}

// MARK: - Preview Provider
#Preview("Interval Form Card") {
    struct PreviewWrapper: View {
        @State private var interval = Interval(
            name: "Warm-up",
            exercises: [
                Exercise(
                    exerciseItem: ExerciseItem(name: "Jumping Jacks", gifUrl: nil),
                    trainingMethod: .timed(seconds: 30),
                    effort: 5
                ),
                Exercise(
                    exerciseItem: ExerciseItem(name: "High Knees", gifUrl: nil),
                    trainingMethod: .timed(seconds: 30),
                    effort: 6
                )
            ],
            rounds: 1,
            restBetweenRounds: 0
        )
        @State private var isExpanded = true
        
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    IntervalFormCard(
                        interval: $interval,
                        isExpanded: $isExpanded,
                        intervalNumber: 1
                    ) {
                        print("Delete interval")
                    } onAddExercise: {
                        // Add a sample exercise
                        let newExercise = Exercise(
                            exerciseItem: ExerciseItem(name: "New Exercise", gifUrl: nil),
                            trainingMethod: .standard(minReps: 8, maxReps: 12),
                            effort: 7
                        )
                        interval.exercises.append(newExercise)
                    }
                    .animation(.spring(), value: isExpanded)
                    .animation(.spring(), value: interval.exercises.count)
                    
                    Button("Toggle Expansion") {
                        isExpanded.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .background(ComponentConstants.Colors.groupedBackground)
        }
    }
    
    return PreviewWrapper()
}

#Preview("Empty Interval") {
    struct PreviewWrapper: View {
        @State private var interval = Interval(
            name: nil,
            exercises: [],
            rounds: 3,
            restBetweenRounds: 60
        )
        @State private var isExpanded = true
        
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    IntervalFormCard(
                        interval: $interval,
                        isExpanded: $isExpanded,
                        intervalNumber: 2
                    ) {
                        print("Delete interval")
                    } onAddExercise: {
                        // Add a sample exercise
                        let newExercise = Exercise(
                            exerciseItem: ExerciseItem(name: "Burpees", gifUrl: nil),
                            trainingMethod: .timed(seconds: 45),
                            effort: 8
                        )
                        interval.exercises.append(newExercise)
                    }
                    .animation(.spring(), value: interval.exercises.count)
                }
                .padding()
            }
            .background(ComponentConstants.Colors.groupedBackground)
        }
    }
    
    return PreviewWrapper()
}

#Preview("Multiple Intervals") {
    struct PreviewWrapper: View {
        @State private var intervals = [
            Interval(
                name: "Warm-up",
                exercises: [
                    Exercise(
                        exerciseItem: ExerciseItem(name: "Jumping Jacks", gifUrl: nil),
                        trainingMethod: .timed(seconds: 30),
                        effort: 5
                    )
                ],
                rounds: 1,
                restBetweenRounds: 0
            ),
            Interval(
                name: "Main Circuit",
                exercises: [
                    Exercise(
                        exerciseItem: ExerciseItem(name: "Push-ups", gifUrl: nil),
                        trainingMethod: .standard(minReps: 10, maxReps: 15),
                        effort: 7
                    ),
                    Exercise(
                        exerciseItem: ExerciseItem(name: "Squats", gifUrl: nil),
                        trainingMethod: .standard(minReps: 15, maxReps: 20),
                        effort: 6
                    )
                ],
                rounds: 3,
                restBetweenRounds: 60
            ),
            Interval(
                name: nil,
                exercises: [],
                rounds: 2,
                restBetweenRounds: 30
            )
        ]
        @State private var expandedStates = [true, false, false]
        
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(intervals.indices, id: \.self) { index in
                        IntervalFormCard(
                            interval: bindingForInterval(at: index),
                            isExpanded: $expandedStates[index],
                            intervalNumber: index + 1
                        ) {
                            print("Delete interval at index \(index)")
                        } onAddExercise: {
                            let newExercise = Exercise(
                                exerciseItem: ExerciseItem(name: "New Exercise", gifUrl: nil),
                                trainingMethod: .standard(minReps: 8, maxReps: 12),
                                effort: 7
                            )
                            intervals[index].exercises.append(newExercise)
                        }
                        .animation(.spring(), value: intervals[index].exercises.count)
                    }
                }
                .padding()
            }
            .background(ComponentConstants.Colors.groupedBackground)
        }
        
        private func bindingForInterval(at index: Int) -> Binding<Interval> {
            return Binding<Interval>(
                get: { intervals[index] },
                set: { intervals[index] = $0 }
            )
        }
    }
    
    return PreviewWrapper()
}
