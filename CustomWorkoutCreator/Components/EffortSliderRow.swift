import SwiftUI

// MARK: - EffortSliderRow Component
struct EffortSliderRow: View {
    let title: String
    @Binding var effort: Int
    let showLabels: Bool
    let icon: String?
    let position: RowPosition
    
    // Pre-computed static values following CLAUDE.md performance principles
    static let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    static let effortRange: ClosedRange<Int> = 1...10
    
    // Static gradient colors - pre-computed to avoid runtime allocations
    static let gradientColors: [Color] = [
        Color.green,        // Easy (1-3)
        Color.yellow,       // Medium (4-7)
        Color.red          // Hard (8-10)
    ]
    
    // Static effort level descriptions
    static let effortDescriptions: [String] = [
        "Very Light", "Light", "Light-Moderate", "Moderate", "Moderate-Hard",
        "Hard", "Very Hard", "Extremely Hard", "Maximum", "Maximum+"
    ]
    
    // Static effort labels for display
    static let effortLabels = ["Easy", "Medium", "Hard"]
    static let effortLabelPositions: [CGFloat] = [0.15, 0.5, 0.85]
    
    // Animation constants
    static let sliderAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    static let scaleAnimation: Animation = .easeInOut(duration: 0.1)
    static let colorTransitionDuration: Double = 0.2
    
    // Slider styling constants
    static let sliderHeight: CGFloat = 8
    static let thumbSize: CGFloat = 24
    static let trackCornerRadius: CGFloat = 4
    static let thumbCornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2
    static let shadowOffset: CGFloat = 1
    
    @State private var isDragging = false
    @State private var lastHapticValue = 0
    
    init(
        title: String,
        effort: Binding<Int>,
        showLabels: Bool = true,
        icon: String? = nil,
        position: RowPosition = .middle
    ) {
        self.title = title
        self._effort = effort
        self.showLabels = showLabels
        self.icon = icon
        self.position = position
        self._lastHapticValue = State(initialValue: effort.wrappedValue)
    }
    
    var body: some View {
        Row(position: position) {
            VStack(spacing: 12) {
                // Header row with title and value
                HStack(spacing: ComponentConstants.Row.contentSpacing) {
                    // Leading icon if provided
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: ComponentConstants.Row.iconSize))
                            .foregroundColor(currentEffortColor)
                            .frame(width: ComponentConstants.Row.iconSize)
                            .animation(.easeInOut(duration: Self.colorTransitionDuration), value: effort)
                    }
                    
                    // Title
                    Text(title)
                        .font(ComponentConstants.Row.titleFont)
                        .foregroundColor(ComponentConstants.Row.primaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Effort value display
                    Text("\(effort)/10")
                        .font(ComponentConstants.Row.valueFont.monospacedDigit())
                        .foregroundColor(currentEffortColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(currentEffortColor.opacity(0.1))
                        )
                        .scaleEffect(isDragging ? 1.05 : 1.0)
                        .animation(Self.scaleAnimation, value: isDragging)
                        .animation(.easeInOut(duration: Self.colorTransitionDuration), value: effort)
                }
                
                // Custom slider
                VStack(spacing: 8) {
                    // Slider track and thumb
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: Self.trackCornerRadius)
                                .fill(ComponentConstants.Colors.tertiaryBackground)
                                .frame(height: Self.sliderHeight)
                            
                            // Gradient track (filled portion)
                            RoundedRectangle(cornerRadius: Self.trackCornerRadius)
                                .fill(currentGradient)
                                .frame(width: thumbPosition(in: geometry), height: Self.sliderHeight)
                            
                            // Thumb
                            Circle()
                                .fill(Color.white)
                                .frame(width: Self.thumbSize, height: Self.thumbSize)
                                .shadow(color: Color.black.opacity(0.2), radius: Self.shadowRadius, x: 0, y: Self.shadowOffset)
                                .overlay(
                                    Circle()
                                        .stroke(currentEffortColor, lineWidth: 2)
                                        .animation(.easeInOut(duration: Self.colorTransitionDuration), value: effort)
                                )
                                .scaleEffect(isDragging ? 1.1 : 1.0)
                                .animation(Self.scaleAnimation, value: isDragging)
                                .position(x: thumbPosition(in: geometry), y: geometry.size.height / 2)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            handleDragChanged(value: value, geometry: geometry)
                                        }
                                        .onEnded { _ in
                                            handleDragEnded()
                                        }
                                )
                        }
                    }
                    .frame(height: Self.thumbSize)
                    
                    // Effort labels
                    if showLabels {
                        HStack {
                            ForEach(0..<Self.effortLabels.count, id: \.self) { index in
                                Text(Self.effortLabels[index])
                                    .font(.caption2)
                                    .foregroundColor(effortLabelColor(for: index))
                                    .frame(maxWidth: .infinity, alignment: labelAlignment(for: index))
                            }
                        }
                        .animation(.easeInOut(duration: Self.colorTransitionDuration), value: effort)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentEffortColor: Color {
        effortColor(for: effort)
    }
    
    private var currentGradient: LinearGradient {
        let progress = CGFloat(effort - Self.effortRange.lowerBound) / CGFloat(Self.effortRange.upperBound - Self.effortRange.lowerBound)
        let color = effortColor(for: effort)
        
        return LinearGradient(
            gradient: Gradient(colors: [color.opacity(0.3), color]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Helper Methods
    
    private func thumbPosition(in geometry: GeometryProxy) -> CGFloat {
        let progress = CGFloat(effort - Self.effortRange.lowerBound) / CGFloat(Self.effortRange.upperBound - Self.effortRange.lowerBound)
        let availableWidth = geometry.size.width - Self.thumbSize
        return (availableWidth * progress) + (Self.thumbSize / 2)
    }
    
    private func effortColor(for value: Int) -> Color {
        let normalizedValue = CGFloat(value - 1) / CGFloat(Self.effortRange.upperBound - 1)
        
        if normalizedValue <= 0.3 {
            // Green range (1-3)
            return Self.gradientColors[0]
        } else if normalizedValue <= 0.7 {
            // Yellow range (4-7)
            let localProgress = (normalizedValue - 0.3) / 0.4
            return Color.lerp(from: Self.gradientColors[0], to: Self.gradientColors[1], progress: localProgress)
        } else {
            // Red range (8-10)
            let localProgress = (normalizedValue - 0.7) / 0.3
            return Color.lerp(from: Self.gradientColors[1], to: Self.gradientColors[2], progress: localProgress)
        }
    }
    
    private func effortLabelColor(for index: Int) -> Color {
        let currentCategory = effortCategory(for: effort)
        return currentCategory == index ? currentEffortColor : ComponentConstants.Row.secondaryTextColor
    }
    
    private func effortCategory(for value: Int) -> Int {
        switch value {
        case 1...3: return 0  // Easy
        case 4...7: return 1  // Medium
        case 8...10: return 2 // Hard
        default: return 1
        }
    }
    
    private func labelAlignment(for index: Int) -> Alignment {
        switch index {
        case 0: return .leading
        case Self.effortLabels.count - 1: return .trailing
        default: return .center
        }
    }
    
    private func handleDragChanged(value: DragGesture.Value, geometry: GeometryProxy) {
        if !isDragging {
            withAnimation(Self.scaleAnimation) {
                isDragging = true
            }
        }
        
        let availableWidth = geometry.size.width - Self.thumbSize
        let relativeX = value.location.x - (Self.thumbSize / 2)
        let progress = max(0, min(1, relativeX / availableWidth))
        let newValue = Int(round(progress * CGFloat(Self.effortRange.upperBound - Self.effortRange.lowerBound))) + Self.effortRange.lowerBound
        
        if newValue != effort && Self.effortRange.contains(newValue) {
            withAnimation(Self.sliderAnimation) {
                effort = newValue
            }
            
            // Trigger haptic feedback when crossing integer boundaries
            if newValue != lastHapticValue {
                Self.hapticGenerator.impactOccurred()
                lastHapticValue = newValue
            }
        }
    }
    
    private func handleDragEnded() {
        withAnimation(Self.scaleAnimation) {
            isDragging = false
        }
    }
}

// MARK: - Color Lerp Extension
private extension Color {
    static func lerp(from: Color, to: Color, progress: CGFloat) -> Color {
        let progress = max(0, min(1, progress))
        
        // Simple color interpolation between green -> yellow -> red
        if progress <= 0.5 {
            // Green to Yellow
            return Color(
                red: Double(progress * 2),
                green: 1.0,
                blue: 0.0
            )
        } else {
            // Yellow to Red
            return Color(
                red: 1.0,
                green: Double(2.0 - progress * 2),
                blue: 0.0
            )
        }
    }
}

// MARK: - Convenience Factory Extension
extension Row {
    static func effortSlider(
        _ title: String,
        effort: Binding<Int>,
        showLabels: Bool = true,
        icon: String? = nil,
        position: RowPosition = .middle
    ) -> some View {
        EffortSliderRow(
            title: title,
            effort: effort,
            showLabels: showLabels,
            icon: icon,
            position: position
        )
    }
}

// MARK: - Equatable for Performance
extension EffortSliderRow: Equatable {
    static func == (lhs: EffortSliderRow, rhs: EffortSliderRow) -> Bool {
        lhs.title == rhs.title &&
        lhs.effort == rhs.effort &&
        lhs.showLabels == rhs.showLabels &&
        lhs.icon == rhs.icon &&
        lhs.position == rhs.position
    }
}

// MARK: - Preview Provider
#Preview {
    @Previewable @State var cardioEffort = 5
    @Previewable @State var strengthEffort = 7
    
    VStack(spacing: 1) {
        EffortSliderRow(
            title: "Cardio Effort",
            effort: $cardioEffort,
            icon: "heart.fill",
            position: .first
        )
        
        EffortSliderRow(
            title: "Strength Effort",
            effort: $strengthEffort,
            icon: "dumbbell.fill",
            position: .last
        )
    }
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}

#Preview("Single Slider") {
    @Previewable @State var effort = 6
    
    EffortSliderRow(
        title: "RPE Scale",
        effort: $effort,
        showLabels: true,
        icon: "gauge",
        position: .only
    )
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}
