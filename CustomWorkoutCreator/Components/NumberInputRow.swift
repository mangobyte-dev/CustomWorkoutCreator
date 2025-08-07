import SwiftUI

// MARK: - NumberInputRow Component
struct NumberInputRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let unit: String?
    let icon: String?
    let position: RowPosition
    
    // Pre-computed for performance - avoid closures in computed properties
    static let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    static let longPressDelay: Double = 0.5
    static let longPressInterval: Double = 0.1
    
    // Static animation configurations
    static let buttonPressAnimation: Animation = .easeInOut(duration: 0.1)
    static let valueChangeAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    
    // Static button style configurations
    static let buttonSize: CGFloat = 44
    static let buttonCornerRadius: CGFloat = 8
    static let buttonBackgroundColor = Color(UIColor.tertiarySystemFill)
    static let buttonPressedColor = Color(UIColor.quaternarySystemFill)
    static let buttonTextColor = Color.primary
    static let buttonIconSize: CGFloat = 18
    
    @State private var isDecrementPressed = false
    @State private var isIncrementPressed = false
    @State private var longPressTimer: Timer?
    
    init(
        title: String,
        value: Binding<Int>,
        range: ClosedRange<Int> = 1...100,
        step: Int = 1,
        unit: String? = nil,
        icon: String? = nil,
        position: RowPosition = .middle
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.unit = unit
        self.icon = icon
        self.position = position
    }
    
    var body: some View {
        Row(position: position) {
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
                
                // Number input controls
                HStack(spacing: 12) {
                    // Decrement button
                    NumberInputButton(
                        systemName: "minus",
                        isPressed: isDecrementPressed,
                        isEnabled: canDecrement
                    ) {
                        decrementValue()
                    } onLongPress: {
                        startLongPressDecrement()
                    } onLongPressEnd: {
                        stopLongPress()
                    }
                    
                    // Value display
                    Text(displayValue)
                        .font(ComponentConstants.Row.valueFont.monospacedDigit())
                        .foregroundColor(ComponentConstants.Row.primaryTextColor)
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 60)
                        .animation(Self.valueChangeAnimation, value: value)
                    
                    // Increment button
                    NumberInputButton(
                        systemName: "plus",
                        isPressed: isIncrementPressed,
                        isEnabled: canIncrement
                    ) {
                        incrementValue()
                    } onLongPress: {
                        startLongPressIncrement()
                    } onLongPressEnd: {
                        stopLongPress()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var displayValue: String {
        if let unit = unit {
            return "\(value) \(unit)"
        } else {
            return "\(value)"
        }
    }
    
    private var canDecrement: Bool {
        value > range.lowerBound
    }
    
    private var canIncrement: Bool {
        value < range.upperBound
    }
    
    // MARK: - Actions
    
    private func decrementValue() {
        guard canDecrement else { return }
        
        withAnimation(Self.valueChangeAnimation) {
            value = max(range.lowerBound, value - step)
        }
        
        triggerHapticFeedback()
    }
    
    private func incrementValue() {
        guard canIncrement else { return }
        
        withAnimation(Self.valueChangeAnimation) {
            value = min(range.upperBound, value + step)
        }
        
        triggerHapticFeedback()
    }
    
    private func startLongPressDecrement() {
        guard canDecrement else { return }
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: Self.longPressInterval, repeats: true) { _ in
            if canDecrement {
                decrementValue()
            } else {
                stopLongPress()
            }
        }
    }
    
    private func startLongPressIncrement() {
        guard canIncrement else { return }
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: Self.longPressInterval, repeats: true) { _ in
            if canIncrement {
                incrementValue()
            } else {
                stopLongPress()
            }
        }
    }
    
    private func stopLongPress() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
    
    private func triggerHapticFeedback() {
        Self.hapticGenerator.impactOccurred()
    }
}

// MARK: - NumberInputButton Helper Component
private struct NumberInputButton: View {
    let systemName: String
    let isPressed: Bool
    let isEnabled: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onLongPressEnd: () -> Void
    
    @State private var isButtonPressed = false
    
    var body: some View {
        ActionButton(
            icon: systemName,
            style: .secondary,
            size: .small,
            isDisabled: !isEnabled,
            action: onTap
        )
        .onLongPressGesture(
            minimumDuration: NumberInputRow.longPressDelay,
            maximumDistance: 50,
            pressing: { pressing in
                withAnimation(NumberInputRow.buttonPressAnimation) {
                    isButtonPressed = pressing
                }
                
                if pressing {
                    onLongPress()
                } else {
                    onLongPressEnd()
                }
            },
            perform: {}
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(NumberInputRow.buttonPressAnimation) {
                        isButtonPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(NumberInputRow.buttonPressAnimation) {
                        isButtonPressed = false
                    }
                }
        )
    }
}

// MARK: - Convenience Factory Extensions
extension Row {
    static func numberInput(
        _ title: String,
        value: Binding<Int>,
        range: ClosedRange<Int> = 1...100,
        step: Int = 1,
        unit: String? = nil,
        icon: String? = nil,
        position: RowPosition = .middle
    ) -> some View {
        NumberInputRow(
            title: title,
            value: value,
            range: range,
            step: step,
            unit: unit,
            icon: icon,
            position: position
        )
    }
}

// MARK: - Equatable for Performance
extension NumberInputRow: Equatable {
    static func == (lhs: NumberInputRow, rhs: NumberInputRow) -> Bool {
        lhs.title == rhs.title &&
        lhs.value == rhs.value &&
        lhs.range == rhs.range &&
        lhs.step == rhs.step &&
        lhs.unit == rhs.unit &&
        lhs.icon == rhs.icon &&
        lhs.position == rhs.position
    }
}

// MARK: - Preview Provider
#Preview {
    @Previewable @State var rounds = 3
    @Previewable @State var reps = 12
    
    VStack(spacing: 1) {
        NumberInputRow(
            title: "Rounds",
            value: $rounds,
            range: 1...20,
            icon: "repeat",
            position: .first
        )
        
        NumberInputRow(
            title: "Reps",
            value: $reps,
            range: 5...50,
            unit: "reps",
            icon: "arrow.clockwise",
            position: .last
        )
    }
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}

#Preview("Single Row") {
    @Previewable @State var weight = 50
    
    NumberInputRow(
        title: "Weight",
        value: $weight,
        range: 5...200,
        step: 5,
        unit: "lbs",
        icon: "scalemass",
        position: .only
    )
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}
