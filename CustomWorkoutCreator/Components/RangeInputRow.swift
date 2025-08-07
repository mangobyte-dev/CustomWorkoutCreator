import SwiftUI

// MARK: - RangeInputRow Component
struct RangeInputRow: View {
    let title: String
    @Binding var minValue: Int
    @Binding var maxValue: Int
    let range: ClosedRange<Int>
    let unit: String?
    let icon: String?
    let position: RowPosition
    
    // Pre-computed for performance - avoid closures in computed properties
    static let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // Static animation configurations
    static let valueChangeAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    static let clearAnimation: Animation = .easeInOut(duration: 0.15)
    
    // Static layout constants
    static let stepperWidth: CGFloat = 70
    static let labelSpacing: CGFloat = 4
    static let controlSpacing: CGFloat = 16
    
    // Static text styles
    static let rangeLabel = Font.caption
    static let rangeValue = Font.body.monospacedDigit()
    
    init(
        title: String,
        minValue: Binding<Int>,
        maxValue: Binding<Int>,
        range: ClosedRange<Int> = 1...100,
        unit: String? = nil,
        icon: String? = nil,
        position: RowPosition = .middle
    ) {
        self.title = title
        self._minValue = minValue
        self._maxValue = maxValue
        self.range = range
        self.unit = unit
        self.icon = icon
        self.position = position
    }
    
    var body: some View {
        Row(position: position) {
            VStack(spacing: 8) {
                // First row: Icon, Title, and Unit
                HStack(spacing: ComponentConstants.Row.contentSpacing) {
                    // Leading icon if provided
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: ComponentConstants.Row.iconSize))
                            .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                            .frame(width: ComponentConstants.Row.iconSize)
                    }
                    
                    // Title
                    Text(title)
                        .font(ComponentConstants.Row.titleFont)
                        .foregroundColor(ComponentConstants.Row.primaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Unit label if provided
                    if let unit = unit {
                        Text(unit)
                            .font(ComponentConstants.Row.valueFont)
                            .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                    }
                }
                
                // Second row: Min and Max steppers in cards
                HStack(spacing: 12) {
                    // Min value card
                    VStack(spacing: 8) {
                        Text(formatValue(minValue))
                            .font(.title2.monospacedDigit().weight(.semibold))
                            .foregroundColor(ComponentConstants.Row.primaryTextColor)
                            .frame(maxWidth: .infinity)
                        
                        Stepper("", value: $minValue, in: minRange)
                            .labelsHidden()
                            .onChange(of: minValue) { oldValue, newValue in
                                handleMinChange(from: oldValue, to: newValue)
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                    )
                    
                    // Separator
                    Text("–")
                        .font(.title3)
                        .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                    
                    // Max value card
                    VStack(spacing: 8) {
                        Text(formatValue(maxValue))
                            .font(.title2.monospacedDigit().weight(.semibold))
                            .foregroundColor(ComponentConstants.Row.primaryTextColor)
                            .frame(maxWidth: .infinity)
                        
                        Stepper("", value: $maxValue, in: maxRange)
                            .labelsHidden()
                            .onChange(of: maxValue) { oldValue, newValue in
                                handleMaxChange(from: oldValue, to: newValue)
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                    )
                    
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var minRange: ClosedRange<Int> {
        range.lowerBound...min(range.upperBound, maxValue)
    }
    
    private var maxRange: ClosedRange<Int> {
        max(range.lowerBound, minValue)...range.upperBound
    }
    
    private func formatValue(_ value: Int) -> String {
        "\(value)"
    }
    
    // MARK: - Actions
    
    private func handleMinChange(from oldValue: Int, to newValue: Int) {
        // Ensure min doesn't exceed max
        if newValue > maxValue {
            withAnimation(Self.valueChangeAnimation) {
                maxValue = newValue
            }
        }
        
        // Haptic feedback
        if oldValue != newValue {
            Self.hapticGenerator.impactOccurred()
        }
    }
    
    private func handleMaxChange(from oldValue: Int, to newValue: Int) {
        // Ensure max doesn't go below min
        if newValue < minValue {
            withAnimation(Self.valueChangeAnimation) {
                minValue = newValue
            }
        }
        
        // Haptic feedback
        if oldValue != newValue {
            Self.hapticGenerator.impactOccurred()
        }
    }
}

// MARK: - Convenience Factory Extensions
extension Row {
    static func rangeInput(
        _ title: String,
        minValue: Binding<Int>,
        maxValue: Binding<Int>,
        range: ClosedRange<Int> = 1...100,
        unit: String? = nil,
        icon: String? = nil,
        position: RowPosition = .middle
    ) -> some View {
        RangeInputRow(
            title: title,
            minValue: minValue,
            maxValue: maxValue,
            range: range,
            unit: unit,
            icon: icon,
            position: position
        )
    }
}

// MARK: - Equatable for Performance
extension RangeInputRow: Equatable {
    static func == (lhs: RangeInputRow, rhs: RangeInputRow) -> Bool {
        lhs.title == rhs.title &&
        lhs.minValue == rhs.minValue &&
        lhs.maxValue == rhs.maxValue &&
        lhs.range == rhs.range &&
        lhs.unit == rhs.unit &&
        lhs.icon == rhs.icon &&
        lhs.position == rhs.position
    }
}

// MARK: - Preview Provider
#Preview {
    @Previewable @State var repsMin = 8
    @Previewable @State var repsMax = 12
    @Previewable @State var restMin = 30
    @Previewable @State var restMax = 60
    
    VStack(spacing: 1) {
        RangeInputRow(
            title: "Reps",
            minValue: $repsMin,
            maxValue: $repsMax,
            range: 1...50,
            unit: "reps",
            icon: "arrow.clockwise",
            position: .first
        )
        
        RangeInputRow(
            title: "Rest Time",
            minValue: $restMin,
            maxValue: $restMax,
            range: 0...300,
            unit: "seconds",
            icon: "timer",
            position: .last
        )
    }
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}
