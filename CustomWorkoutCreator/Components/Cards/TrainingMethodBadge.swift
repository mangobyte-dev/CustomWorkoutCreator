import SwiftUI

// MARK: - TrainingMethodBadge Component
/// Compact badge displaying training method with icon and text
/// Follows CLAUDE.md performance principles with static lookups
struct TrainingMethodBadge: View {
    let method: TrainingMethod
    
    // Pre-computed static values
    private static let badgePadding = EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
    private static let cornerRadius: CGFloat = 4
    private static let iconSize: CGFloat = 12
    
    // Static lookup tables
    private enum MethodType {
        case standard
        case timed
        case restPause
    }
    
    private static let methodIcons: [MethodType: String] = [
        .standard: "number",
        .timed: "timer",
        .restPause: "pause.rectangle"
    ]
    
    private static let methodColors: [MethodType: Color] = [
        .standard: .blue,
        .timed: .green,
        .restPause: .orange
    ]
    
    // Computed properties
    private var methodType: MethodType {
        switch method {
        case .standard: return .standard
        case .timed: return .timed
        case .restPause: return .restPause
        }
    }
    
    private var icon: String {
        Self.methodIcons[methodType] ?? "questionmark"
    }
    
    private var color: Color {
        Self.methodColors[methodType] ?? .gray
    }
    
    private var text: String {
        switch method {
        case let .standard(minReps, maxReps):
            return minReps == maxReps ? "\(minReps)" : "\(minReps)-\(maxReps)"
        case let .timed(seconds):
            return "\(seconds)s"
        case let .restPause(targetTotal, _, _):
            return "RP \(targetTotal)"
        }
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: Self.iconSize))
            Text(text)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(Self.badgePadding)
        .background(color.opacity(0.15))
        .cornerRadius(Self.cornerRadius)
    }
}

// MARK: - Preview Provider
#Preview("Training Method Badges") {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            TrainingMethodBadge(method: .standard(minReps: 8, maxReps: 12))
            TrainingMethodBadge(method: .standard(minReps: 10, maxReps: 10))
            TrainingMethodBadge(method: .timed(seconds: 45))
            TrainingMethodBadge(method: .restPause(targetTotal: 50))
        }
        
        // In context
        HStack {
            Text("Push-ups")
            Spacer()
            TrainingMethodBadge(method: .standard(minReps: 15, maxReps: 20))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
    .padding()
}