import SwiftUI

// MARK: - EffortIndicator Component
/// Compact visual indicator for effort level (1-10)
/// Follows CLAUDE.md performance principles with static color lookups
struct EffortIndicator: View {
    let level: Int
    
    // Pre-computed static values
    private static let indicatorSize: CGFloat = 24
    private static let fontSize: CGFloat = 12
    private static let cornerRadius: CGFloat = 4
    
    // Static color lookup table
    private static let effortColors: [(range: ClosedRange<Int>, color: Color)] = [
        (1...3, .green),
        (4...6, .yellow),
        (7...8, .orange),
        (9...10, .red)
    ]
    
    // Computed color based on effort level
    private var color: Color {
        Self.effortColors.first { $0.range.contains(level) }?.color ?? .gray
    }
    
    var body: some View {
        Text("\(level)")
            .font(.system(size: Self.fontSize, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: Self.indicatorSize, height: Self.indicatorSize)
            .background(color)
            .cornerRadius(Self.cornerRadius)
    }
}

// MARK: - Alternative Dot-Based Indicator
/// Visual dots indicator for effort level (more visual, less numeric)
struct EffortDotsIndicator: View {
    let level: Int
    
    private static let dotSize: CGFloat = 6
    private static let spacing: CGFloat = 2
    
    // Static color lookup
    private static let effortColors: [(range: ClosedRange<Int>, color: Color)] = [
        (1...3, .green),
        (4...6, .yellow),
        (7...8, .orange),
        (9...10, .red)
    ]
    
    private var color: Color {
        Self.effortColors.first { $0.range.contains(level) }?.color ?? .gray
    }
    
    private var filledDots: Int {
        min(max(level / 2, 1), 5) // Convert 1-10 to 1-5 dots
    }
    
    var body: some View {
        HStack(spacing: Self.spacing) {
            ForEach(1...5, id: \.self) { index in
                Circle()
                    .fill(index <= filledDots ? color : Color.gray.opacity(0.3))
                    .frame(width: Self.dotSize, height: Self.dotSize)
            }
        }
    }
}

// MARK: - Preview Provider
#Preview("Effort Indicators") {
    VStack(spacing: 20) {
        // Numeric indicators
        VStack(alignment: .leading, spacing: 12) {
            Text("Numeric Indicators").font(.headline)
            HStack(spacing: 12) {
                ForEach(1...10, id: \.self) { level in
                    VStack {
                        EffortIndicator(level: level)
                        Text("L\(level)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        
        Divider()
        
        // Dots indicators
        VStack(alignment: .leading, spacing: 12) {
            Text("Dots Indicators").font(.headline)
            VStack(spacing: 8) {
                ForEach([2, 5, 7, 10], id: \.self) { level in
                    HStack {
                        Text("Effort \(level):")
                            .font(.caption)
                            .frame(width: 60, alignment: .leading)
                        EffortDotsIndicator(level: level)
                        Spacer()
                    }
                }
            }
        }
        
        Divider()
        
        // In context
        VStack(alignment: .leading, spacing: 12) {
            Text("In Context").font(.headline)
            HStack {
                Text("Push-ups")
                Spacer()
                TrainingMethodBadge(method: .standard(minReps: 10, maxReps: 15))
                EffortIndicator(level: 7)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
    }
    .padding()
}