import SwiftUI

/// A stable thumbnail view that doesn't recreate GifImageView when parent state changes
/// This component isolates the GIF rendering from frequently-changing parent bindings
struct StableExerciseThumbnail: View {
    let exerciseItem: ExerciseItem?
    let size: CGFloat
    let cornerRadius: CGFloat
    
    init(exerciseItem: ExerciseItem?, size: CGFloat = 40, cornerRadius: CGFloat = 6) {
        self.exerciseItem = exerciseItem
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        thumbnailContent
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    @ViewBuilder
    private var thumbnailContent: some View {
        if let gifUrl = exerciseItem?.gifUrl {
            GifImageView(gifUrl)
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(.tertiarySystemBackground))
                .overlay {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
        }
    }
}

/// Equatable conformance to prevent unnecessary redraws
extension StableExerciseThumbnail: Equatable {
    static func == (lhs: StableExerciseThumbnail, rhs: StableExerciseThumbnail) -> Bool {
        lhs.exerciseItem?.id == rhs.exerciseItem?.id &&
        lhs.exerciseItem?.gifUrl == rhs.exerciseItem?.gifUrl &&
        lhs.size == rhs.size &&
        lhs.cornerRadius == rhs.cornerRadius
    }
}