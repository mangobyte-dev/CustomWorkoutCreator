import SwiftUI

struct IntervalCard: View {
    let interval: Interval
    let intervalNumber: Int
    @Binding var isExpanded: Bool
    
    // MARK: - Pre-computed Display Values
    private var displayName: String {
        interval.name?.isEmpty == false ? interval.name! : "Interval \(intervalNumber)"
    }
    
    private var exerciseCount: Int {
        interval.exercises.count
    }
    
    private var roundCount: Int {
        interval.rounds
    }
    
    private var restSeconds: Int {
        interval.restBetweenRounds ?? 0
    }
    
    // MARK: - Pre-computed Strings
    private var exerciseCountText: String {
        "\(exerciseCount) \(exerciseCount == 1 ? "exercise" : "exercises")"
    }
    
    private var roundCountText: String {
        "\(roundCount) \(roundCount == 1 ? "round" : "rounds")"
    }
    
    private var restText: String {
        "\(restSeconds)s rest"
    }
    
    // MARK: - View Builders
    @ViewBuilder
    private var headerContent: some View {
        HStack(spacing: ComponentConstants.Row.contentSpacing) {
            Text(displayName)
                .font(.headline)
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            headerBadges
        }
    }
    
    @ViewBuilder
    private var headerBadges: some View {
        // Single badge showing exercise count and optionally rounds
        let badgeText = if roundCount > 1 {
            "\(exerciseCountText) • \(roundCountText)"
        } else {
            exerciseCountText
        }
        
        Badge(
            text: badgeText,
            color: Color.accentColor
        )
    }
    
    @ViewBuilder
    private var expandedContent: some View {
        if interval.exercises.isEmpty {
            Text("No exercises in this interval")
                .font(.body)
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, ComponentConstants.Layout.defaultPadding)
        } else {
            ForEach(Array(interval.exercises.enumerated()), id: \.element.id) { index, exercise in
                ExerciseCard(exercise: exercise)
                
                if index < interval.exercises.count - 1 {
                    Divider()
                }
            }
        }
    }
    
    var body: some View {
        Expandable(isExpanded: $isExpanded) {
            headerContent
        } content: {
            expandedContent
        }
    }
}

// MARK: - Badge Component
private struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(Color.primary.opacity(0.8))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }
}


// MARK: - Preview
#Preview("Single Round Interval") {
    @Previewable @State var isExpanded = true
    
    IntervalCard(
        interval: Interval(
            name: "Warm-up",
            exercises: [
                Exercise(name: "Jumping Jacks", trainingMethod: .timed(seconds: 30)),
                Exercise(name: "High Knees", trainingMethod: .timed(seconds: 30)),
                Exercise(name: "Arm Circles", trainingMethod: .timed(seconds: 30))
            ],
            rounds: 1,
            restBetweenRounds: 0
        ),
        intervalNumber: 1,
        isExpanded: $isExpanded
    )
    .padding()
}

#Preview("Multi-Round Interval") {
    @Previewable @State var isExpanded = false
    
    IntervalCard(
        interval: Interval(
            name: "HIIT Circuit",
            exercises: [
                Exercise(name: "Burpees", trainingMethod: .timed(seconds: 45)),
                Exercise(name: "Mountain Climbers", trainingMethod: .timed(seconds: 45), restAfter: 15),
                Exercise(name: "Jump Squats", trainingMethod: .timed(seconds: 45))
            ],
            rounds: 4,
            restBetweenRounds: 60
        ),
        intervalNumber: 2,
        isExpanded: $isExpanded
    )
    .padding()
}

#Preview("No Name Interval") {
    @Previewable @State var isExpanded = false
    
    IntervalCard(
        interval: Interval(
            name: nil,
            exercises: [
                Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 10, maxReps: 15)),
                Exercise(name: "Plank", trainingMethod: .timed(seconds: 60))
            ],
            rounds: 3,
            restBetweenRounds: 30
        ),
        intervalNumber: 3,
        isExpanded: $isExpanded
    )
    .padding()
}

#Preview("Multiple Cards") {
    let intervals = [
        Interval(
            name: "Warm-up",
            exercises: [
                Exercise(name: "Jumping Jacks", trainingMethod: .timed(seconds: 30))
            ],
            rounds: 1,
            restBetweenRounds: 0
        ),
        Interval(
            name: "Main Circuit",
            exercises: [
                Exercise(name: "Burpees", trainingMethod: .timed(seconds: 45)),
                Exercise(name: "Push-ups", trainingMethod: .standard(minReps: 12, maxReps: 15)),
                Exercise(name: "Squats", trainingMethod: .standard(minReps: 15, maxReps: 20)),
                Exercise(name: "Plank", trainingMethod: .timed(seconds: 45))
            ],
            rounds: 3,
            restBetweenRounds: 60
        ),
        Interval(
            name: "Cool Down",
            exercises: [
                Exercise(name: "Stretching", trainingMethod: .timed(seconds: 120))
            ],
            rounds: 1,
            restBetweenRounds: 0
        )
    ]
    
    ScrollView {
        ExpandableList(items: intervals) { interval, index, isExpanded in
            IntervalCard(
                interval: interval,
                intervalNumber: index + 1,
                isExpanded: isExpanded
            )
        }
        .padding()
    }
    .background(ComponentConstants.Colors.groupedBackground)
}
