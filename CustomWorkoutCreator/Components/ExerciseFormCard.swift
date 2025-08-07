import SwiftUI

// MARK: - ExerciseFormCard Component
struct ExerciseFormCard: View {
    @Binding var exercise: Exercise
    @State private var isExpanded = false
    @State private var showingPicker = false
    let onDelete: () -> Void
    
    // Decomposed storage for TrainingMethod to avoid SwiftData crashes
    // Synced with exercise.trainingMethod
    @State private var standardMinReps: Int = 8
    @State private var standardMaxReps: Int = 12
    @State private var timedDuration: Int = 45
    @State private var restPauseMinisets: Int = 20
    
    // Pre-computed static values following CLAUDE.md performance principles
    private static let cardCornerRadius: CGFloat = 12
    private static let thumbnailSize: CGSize = CGSize(width: 40, height: 40)
    private static let expandCollapseAnimationDuration: Double = 0.4
    private static let springAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.8)
    
    // Static content spacing values
    private static let headerSpacing: CGFloat = 12
    private static let contentSpacing: CGFloat = 16
    private static let expandedContentSpacing: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Always visible
            headerContent
                .background(ComponentConstants.Row.backgroundColor)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: Self.cardCornerRadius,
                    bottomLeadingRadius: isExpanded ? 0 : Self.cardCornerRadius,
                    bottomTrailingRadius: isExpanded ? 0 : Self.cardCornerRadius,
                    topTrailingRadius: Self.cardCornerRadius,
                    style: .continuous
                ))
            
            // Expanded content - Conditionally visible
            if isExpanded {
                expandedContent
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: Self.cardCornerRadius,
                        bottomTrailingRadius: Self.cardCornerRadius,
                        topTrailingRadius: 0,
                        style: .continuous
                    ))
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.95, anchor: .top)
                            .combined(with: .opacity),
                        removal: .scale(scale: 0.95, anchor: .top)
                            .combined(with: .opacity)
                    ))
            }
        }
        .animation(Self.springAnimation, value: isExpanded)
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
    
    // MARK: - Header Content
    
    @ViewBuilder
    private var headerContent: some View {
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
            
            // Expand/Collapse button
            ActionButton(
                icon: chevronIcon,
                style: .ghost,
                size: .small
            ) {
                withAnimation(Self.springAnimation) {
                    isExpanded.toggle()
                }
            }
        }
        .padding(.horizontal, ComponentConstants.Row.horizontalPadding)
        .padding(.vertical, ComponentConstants.Row.verticalPadding)
    }
    
    // MARK: - Expanded Content
    
    @ViewBuilder
    private var expandedContent: some View {
        VStack(spacing: Self.expandedContentSpacing) {
            // Training method configuration
            TrainingMethodPicker(
                trainingMethod: trainingMethodBinding,
                showDescription: false,
                standardMinReps: $standardMinReps,
                standardMaxReps: $standardMaxReps,
                timedDuration: $timedDuration,
                restPauseMinisets: $restPauseMinisets
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
    }
    
    // MARK: - Computed Properties
    
    private var exerciseName: String {
        if exercise.name.isEmpty {
            return "Select Exercise"
        }
        return exercise.name
    }
    
    private var chevronIcon: String {
        isExpanded ? "chevron.up" : "chevron.down"
    }
    
    // Custom binding that updates decomposed values when TrainingMethod changes
    private var trainingMethodBinding: Binding<TrainingMethod> {
        Binding<TrainingMethod>(
            get: { exercise.trainingMethod },
            set: { newMethod in
                exercise.trainingMethod = newMethod
                // Update decomposed values to keep them in sync
                updateDecomposedValues(from: newMethod)
            }
        )
    }
    
    // MARK: - Helper Methods
    
    private func syncDecomposedValues() {
        updateDecomposedValues(from: exercise.trainingMethod)
    }
    
    private func updateDecomposedValues(from method: TrainingMethod) {
        switch method {
        case let .standard(minReps, maxReps):
            standardMinReps = minReps
            standardMaxReps = maxReps
        case let .restPause(targetTotal, _, _):
            restPauseMinisets = targetTotal
        case let .timed(seconds):
            timedDuration = seconds
        }
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
    @Previewable @State var exercise = Exercise(
        exerciseItem: ExerciseItem(name: "Push-ups", gifUrl: "01qpYSe"),
        trainingMethod: .standard(minReps: 8, maxReps: 12),
        effort: 7
    )
    
    VStack(spacing: 16) {
        ExerciseFormCard(exercise: $exercise) {
            print("Delete exercise")
        }
        
        Spacer()
    }
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
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
        VStack(spacing: 12) {
            ForEach(exercises.indices, id: \.self) { index in
                ExerciseFormCard(exercise: .constant(exercises[index])) {
                    exercises.remove(at: index)
                }
            }
        }
        .padding()
    }
    .background(ComponentConstants.Colors.groupedBackground)
}