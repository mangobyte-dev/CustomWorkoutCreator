import SwiftUI

// MARK: - ExerciseEditSheet Component
/// Full-screen sheet for editing exercise configuration
/// Follows CLAUDE.md performance principles
struct ExerciseEditSheet: View {
    @Binding var exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    @State private var showingExercisePicker = false
    
    // Decomposed storage for TrainingMethod to avoid SwiftData crashes
    @State private var decomposedValues = TrainingMethodUtilities.DecomposedValues()
    
    // Track if changes were made
    @State private var originalExercise: Exercise?
    
    // Prevent full view rerenders by isolating training method changes
    @State private var trainingMethodType: TrainingMethodUtilities.TrainingMethodType = .standard
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Exercise Info Section
                    VStack(spacing: 1) {
                        SectionHeader(title: "Exercise")
                        
                        // Exercise display with change button
                        Row(position: .only) {
                            HStack(spacing: 12) {
                                // GIF thumbnail - Using stable component to prevent recreating
                                StableExerciseThumbnail(exerciseItem: exercise.exerciseItem)
                                
                                // Exercise name
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text("Tap to change exercise")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingExercisePicker = true
                        }
                    }
                    
                    // Training Method Section
                    TrainingMethodSection(
                        exercise: $exercise,
                        decomposedValues: $decomposedValues
                    )
                    
                    // Effort Level Section
                    VStack(spacing: 1) {
                        SectionHeader(title: "Configuration")
                        
                        EffortSliderRow(
                            title: "Effort Level",
                            effort: $exercise.effort,
                            icon: "gauge",
                            position: .first
                        )
                        
                        // Optional: Add more configuration options here
                        if exercise.weight != nil {
                            NumberInputRow(
                                title: "Weight (lbs)",
                                value: Binding(
                                    get: { Int(exercise.weight ?? 0) },
                                    set: { exercise.weight = $0 > 0 ? Double($0) : nil }
                                ),
                                range: 0...500,
                                icon: "scalemass",
                                position: .middle
                            )
                        }
                        
                        if exercise.restAfter != nil {
                            TimeInputRow(
                                title: "Rest After",
                                seconds: Binding(
                                    get: { exercise.restAfter ?? 0 },
                                    set: { exercise.restAfter = $0 > 0 ? $0 : nil }
                                ),
                                icon: "pause.circle",
                                position: .last
                            )
                        }
                    }
                    
                    // Notes Section (if exists)
                    if let notes = exercise.notes, !notes.isEmpty {
                        VStack(spacing: 1) {
                            SectionHeader(title: "Notes")
                            
                            Row(position: .only) {
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.vertical)
                .safeAreaInset(edge: .bottom) {
                    // Add safe area padding for bottom content
                    Color.clear.frame(height: 20)
                }
            }
            .background(ComponentConstants.Colors.groupedBackground)
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Restore original if available
                        if let original = originalExercise {
                            exercise = original
                        }
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
        .onAppear {
            // Store original for cancel
            originalExercise = exercise
            syncDecomposedValues()
            trainingMethodType = TrainingMethodUtilities.TrainingMethodType.from(exercise.trainingMethod)
        }
        .sheet(isPresented: $showingExercisePicker) {
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
                showingExercisePicker = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func syncDecomposedValues() {
        decomposedValues.update(from: exercise.trainingMethod)
    }
}

// MARK: - Isolated Training Method Section
// This component isolates training method changes to prevent parent view rerenders
private struct TrainingMethodSection: View {
    @Binding var exercise: Exercise
    @Binding var decomposedValues: TrainingMethodUtilities.DecomposedValues
    
    var body: some View {
        VStack(spacing: 1) {
            SectionHeader(title: "Training Method")
            
            TrainingMethodPicker(
                trainingMethod: trainingMethodBinding,
                showDescription: true,
                standardMinReps: $decomposedValues.standardMinReps,
                standardMaxReps: $decomposedValues.standardMaxReps,
                timedDuration: $decomposedValues.timedDuration,
                restPauseMinisets: $decomposedValues.restPauseMinisets
            )
        }
    }
    
    private var trainingMethodBinding: Binding<TrainingMethod> {
        TrainingMethodUtilities.createSyncedBinding(
            trainingMethod: Binding<TrainingMethod>(
                get: { exercise.trainingMethod },
                set: { exercise.trainingMethod = $0 }
            ),
            decomposedValues: $decomposedValues
        )
    }
}

// MARK: - Preview Provider
#Preview("Exercise Edit Sheet") {
    @Previewable @State var exercise = Exercise(
        exerciseItem: ExerciseItem(name: "Push-ups", gifUrl: "01qpYSe"),
        trainingMethod: .standard(minReps: 10, maxReps: 15),
        effort: 7
    )
    
    ExerciseEditSheet(exercise: $exercise)
}