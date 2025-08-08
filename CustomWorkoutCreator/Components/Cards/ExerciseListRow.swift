import SwiftUI

// MARK: - ExerciseListRow Component
/// Simple row displaying exercise info with inline action buttons
/// Follows CLAUDE.md performance principles with pre-computed values
struct ExerciseListRow: View {
    let exercise: Exercise
    let onTap: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    
    // Pre-computed static values
    private static let thumbnailSize: CGFloat = 32
    private static let cornerRadius: CGFloat = 6
    private static let buttonSpacing: CGFloat = 8
    private static let horizontalPadding: CGFloat = 12
    private static let verticalPadding: CGFloat = 8
    
    var body: some View {
        HStack(spacing: 12) {
            // GIF thumbnail (if available)
            if let gifUrl = exercise.exerciseItem?.gifUrl {
                GifImageView(gifUrl)
                    .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
                    .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
            } else {
                // Placeholder icon when no GIF
                Image(systemName: "figure.run")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: Self.thumbnailSize, height: Self.thumbnailSize)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
            }
            
            // Exercise name
            Text(exercise.name)
                .font(.body)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Training method badge
            TrainingMethodBadge(method: exercise.trainingMethod)
            
            // Effort indicator
            EffortIndicator(level: exercise.effort)
            
            // Action buttons
            HStack(spacing: Self.buttonSpacing) {
                // Duplicate button
                Button {
                    onDuplicate()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.body)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                // Delete button
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, Self.verticalPadding)
        .padding(.horizontal, Self.horizontalPadding)
        .background(ComponentConstants.Colors.secondaryGroupedBackground)
        .cornerRadius(ComponentConstants.Layout.cornerRadius)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Equatable for Performance
extension ExerciseListRow: Equatable {
    static func == (lhs: ExerciseListRow, rhs: ExerciseListRow) -> Bool {
        lhs.exercise.id == rhs.exercise.id &&
        lhs.exercise.name == rhs.exercise.name &&
        lhs.exercise.trainingMethod == rhs.exercise.trainingMethod &&
        lhs.exercise.effort == rhs.exercise.effort
    }
}

// MARK: - Preview Provider
#Preview("Exercise List Row") {
    VStack(spacing: 12) {
        ExerciseListRow(
            exercise: Exercise(
                exerciseItem: ExerciseItem(name: "Push-ups", gifUrl: "01qpYSe"),
                trainingMethod: .standard(minReps: 10, maxReps: 15),
                effort: 7
            ),
            onTap: { print("Tapped") },
            onDuplicate: { print("Duplicate") },
            onDelete: { print("Delete") }
        )
        
        ExerciseListRow(
            exercise: Exercise(
                exerciseItem: ExerciseItem(name: "Plank"),
                trainingMethod: .timed(seconds: 60),
                effort: 5
            ),
            onTap: { print("Tapped") },
            onDuplicate: { print("Duplicate") },
            onDelete: { print("Delete") }
        )
        
        ExerciseListRow(
            exercise: Exercise(
                exerciseItem: ExerciseItem(name: "Very Long Exercise Name That Should Truncate"),
                trainingMethod: .restPause(targetTotal: 50),
                effort: 9
            ),
            onTap: { print("Tapped") },
            onDuplicate: { print("Duplicate") },
            onDelete: { print("Delete") }
        )
    }
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}