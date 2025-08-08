import SwiftUI

// MARK: - ExerciseFormCard Component
struct ExerciseFormCard: View {
    @Binding var exercise: Exercise
    @Binding var isExpanded: Bool
    @State private var showingPicker = false
    let onDelete: () -> Void
    
    // Decomposed storage for TrainingMethod to avoid SwiftData crashes
    // Synced with exercise.trainingMethod
    @State private var decomposedValues = TrainingMethodUtilities.DecomposedValues()
    
    // Pre-computed static values following CLAUDE.md performance principles
    private static let thumbnailSize: CGSize = CGSize(width: 40, height: 40)
    private static let headerSpacing: CGFloat = 12
    private static let expandedContentSpacing: CGFloat = 1
    
    var body: some View {
        Expandable(
            isExpanded: $isExpanded,
            header: {
                // Header content - Exercise selection button and GIF thumbnail
                HStack(spacing: Self.headerSpacing) {
                    // Exercise selection button
                    ActionButton(
                        title: exerciseName,
                        icon: "figure.run",
                        style: .ghost,
                        size: .medium
                    ) {
                        showingPicker = true
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // GIF Thumbnail
                    if let gifUrl = exercise.exerciseItem?.gifUrl {
                        GifImageView(gifUrl)
                            .frame(width: Self.thumbnailSize.width, height: Self.thumbnailSize.height)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
        },
        content: {
            // Expanded content - Training method configuration, effort slider, and delete button
            VStack(spacing: Self.expandedContentSpacing) {
                // Training method configuration
                TrainingMethodPicker(
                    trainingMethod: trainingMethodBinding,
                    showDescription: false,
                    standardMinReps: $decomposedValues.standardMinReps,
                    standardMaxReps: $decomposedValues.standardMaxReps,
                    timedDuration: $decomposedValues.timedDuration,
                    restPauseMinisets: $decomposedValues.restPauseMinisets
                )
                
                // Effort level slider
                EffortSliderRow(
                    title: "Effort Level",
                    effort: $exercise.effort,
                    icon: "gauge",
                    position: .middle
                )
                
                
                // Delete button
                VStack(spacing: 0) {
                    ActionButton.danger(
                        title: "Delete Exercise",
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
        })
        .onAppear {
            syncDecomposedValues()
        }
        .onChange(of: exercise.trainingMethod) { _, _ in
            syncDecomposedValues()
        }
        .sheet(isPresented: $showingPicker) {
            ExercisePicker(selectedExercise: .constant(nil)) { selectedItem in
                // Create new exercise from selected item, preserving current configuration
                let newExercise = Exercise.from(
                    exerciseItem: selectedItem,
                    trainingMethod: exercise.trainingMethod,
                    effort: exercise.effort
                )
                // Copy additional properties
                newExercise.weight = exercise.weight
                newExercise.restAfter = exercise.restAfter
                newExercise.tempo = exercise.tempo
                newExercise.notes = exercise.notes
                
                // Replace the exercise
                exercise = newExercise
                showingPicker = false
            }
        }
    }
    
    
    // MARK: - Computed Properties
    
    private var exerciseName: String {
        if exercise.name.isEmpty {
            return "Select Exercise"
        }
        return exercise.name
    }
    
    // Custom binding that updates decomposed values when TrainingMethod changes
    private var trainingMethodBinding: Binding<TrainingMethod> {
        TrainingMethodUtilities.createSyncedBinding(
            trainingMethod: Binding<TrainingMethod>(
                get: { exercise.trainingMethod },
                set: { exercise.trainingMethod = $0 }
            ),
            decomposedValues: $decomposedValues
        )
    }
    
    // MARK: - Helper Methods
    
    private func syncDecomposedValues() {
        decomposedValues.update(from: exercise.trainingMethod)
    }
}

// MARK: - Equatable for Performance
extension ExerciseFormCard: Equatable {
    static func == (lhs: ExerciseFormCard, rhs: ExerciseFormCard) -> Bool {
        lhs.exercise.id == rhs.exercise.id &&
        lhs.isExpanded == rhs.isExpanded
    }
}

// MARK: - Preview Provider
#Preview("Exercise Form Card") {
    struct PreviewWrapper: View {
        @State private var exercise = Exercise(
            exerciseItem: ExerciseItem(name: "Push-ups", gifUrl: "01qpYSe"),
            trainingMethod: .standard(minReps: 8, maxReps: 12),
            effort: 7
        )
        @State private var isExpanded = false
        
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    ExerciseFormCard(
                        exercise: $exercise,
                        isExpanded: $isExpanded
                    ) {
                        print("Delete exercise")
                    }
                    .animation(.spring(), value: isExpanded)
                    
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

#Preview("Multiple Cards") {
    @Previewable @State var exercises = [
        Exercise(
            exerciseItem: ExerciseItem(name: "Push-ups", gifUrl: "01qpYSe"),
            trainingMethod: .standard(minReps: 10, maxReps: 15),
            effort: 6
        ),
        Exercise(
            exerciseItem: ExerciseItem(name: "Pull-ups", gifUrl: nil),
            trainingMethod: .restPause(targetTotal: 50, minReps: 5, maxReps: 8),
            effort: 8
        ),
        Exercise(
            exerciseItem: ExerciseItem(name: "Plank", gifUrl: nil),
            trainingMethod: .timed(seconds: 60),
            effort: 7
        )
    ]
    
    ScrollView {
        ExpandableList(items: exercises) { exercise, index, isExpanded in
            ExerciseFormCard(
                exercise: .constant(exercise),
                isExpanded: isExpanded
            ) {
                print("Delete exercise at index \(index)")
            }
        }
        .padding()
    }
    .background(ComponentConstants.Colors.groupedBackground)
}
