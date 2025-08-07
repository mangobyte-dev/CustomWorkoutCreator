import SwiftUI

// MARK: - TimeInputRow Component
struct TimeInputRow: View {
    let title: String
    @Binding var seconds: Int
    let maxMinutes: Int
    let secondsStep: Int
    let showPresets: Bool
    let icon: String?
    let position: RowPosition
    
    // Pre-computed for performance - avoid closures in computed properties
    static let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // Static animation configurations
    static let valueChangeAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    static let presetButtonAnimation: Animation = .easeInOut(duration: 0.1)
    
    // Static style configurations
    static let presetButtonHeight: CGFloat = 28
    static let presetButtonCornerRadius: CGFloat = 6
    static let presetButtonSpacing: CGFloat = 6
    static let presetButtonPadding: CGFloat = 8
    static let presetBackgroundColor = Color(UIColor.tertiarySystemFill)
    static let presetSelectedColor = Color.accentColor
    static let presetTextColor = Color.primary
    static let presetSelectedTextColor = Color.white
    
    // Pre-computed preset configurations
    private static let presetValues: [(seconds: Int, label: String)] = [
        (30, "30s"),
        (60, "1m"),
        (90, "90s"),
        (120, "2m"),
        (300, "5m")
    ]
    
    @State private var showingPicker = false
    @State private var isPresetPressed: [Int: Bool] = [:]
    
    init(
        title: String,
        seconds: Binding<Int>,
        maxMinutes: Int = 59,
        secondsStep: Int = 5,
        showPresets: Bool = true,
        icon: String? = nil,
        position: RowPosition = .middle
    ) {
        self.title = title
        self._seconds = seconds
        self.maxMinutes = maxMinutes
        self.secondsStep = secondsStep
        self.showPresets = showPresets
        self.icon = icon
        self.position = position
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main row
            Row(position: showPresets ? .first : position) {
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
                    
                    // Time display and picker controls
                    HStack(spacing: 12) {
                        // Time display (tap to show picker)
                        ActionButton(
                            title: timeDisplayString,
                            style: .ghost,
                            size: .small,
                            action: { showingPicker = true }
                        )
                        .animation(Self.valueChangeAnimation, value: seconds)
                        
                        // Clear button
                        if seconds > 0 {
                            ActionButton(
                                icon: "xmark.circle.fill",
                                style: .ghost,
                                size: .small,
                                action: clearTime
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            
            // Presets row (only if enabled and position allows)
            if showPresets {
                presetsRow
            }
        }
        .sheet(isPresented: $showingPicker) {
            timePickerSheet
        }
    }
    
    // MARK: - Presets Row
    
    @ViewBuilder
    private var presetsRow: some View {
        Row(position: position == .first ? .last : (position == .only ? .last : position)) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Self.presetButtonSpacing) {
                    ForEach(Array(Self.presetValues.enumerated()), id: \.offset) { index, preset in
                        PresetButton(
                            label: preset.label,
                            seconds: preset.seconds,
                            currentSeconds: seconds,
                            isPressed: isPresetPressed[index] ?? false
                        ) {
                            selectPreset(preset.seconds, index: index)
                        }
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, ComponentConstants.Row.horizontalPadding)
                .padding(.vertical, Self.presetButtonPadding)
            }
        }
    }
    
    // MARK: - Time Picker Sheet
    
    @ViewBuilder
    private var timePickerSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Current time display
                VStack(spacing: 8) {
                    Text("Set Time")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(timeDisplayString)
                        .font(.largeTitle.monospacedDigit())
                        .foregroundColor(.accentColor)
                        .animation(Self.valueChangeAnimation, value: seconds)
                }
                .padding(.top, 20)
                
                // Time pickers
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Minutes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Minutes", selection: Binding(
                            get: { minutes },
                            set: { newMinutes in
                                let newSeconds = (newMinutes * 60) + (seconds % 60)
                                updateSeconds(newSeconds)
                            }
                        )) {
                            ForEach(0...maxMinutes, id: \.self) { minute in
                                Text("\(minute)")
                                    .font(.body.monospacedDigit())
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: 120)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Seconds")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Seconds", selection: Binding(
                            get: { secondsComponent },
                            set: { newSeconds in
                                let newTotalSeconds = (minutes * 60) + newSeconds
                                updateSeconds(newTotalSeconds)
                            }
                        )) {
                            ForEach(secondsStepRange, id: \.self) { second in
                                Text("\(second)")
                                    .font(.body.monospacedDigit())
                                    .tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: 120)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Time Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ActionButton(
                        title: "Clear",
                        style: .link,
                        size: .small,
                        isDisabled: seconds == 0,
                        action: clearTime
                    )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ActionButton(
                        title: "Done",
                        style: .primary,
                        size: .small,
                        action: { showingPicker = false }
                    )
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Computed Properties
    
    private var timeDisplayString: String {
        if seconds == 0 {
            return "0:00"
        }
        return ComponentConstants.Row.shortTimeFormatter.string(from: TimeInterval(seconds)) ?? "0:00"
    }
    
    private var minutes: Int {
        seconds / 60
    }
    
    private var secondsComponent: Int {
        seconds % 60
    }
    
    private var secondsStepRange: [Int] {
        Array(stride(from: 0, through: 59, by: secondsStep))
    }
    
    // MARK: - Actions
    
    private func updateSeconds(_ newSeconds: Int) {
        let clampedSeconds = max(0, min(newSeconds, maxMinutes * 60 + 59))
        
        withAnimation(Self.valueChangeAnimation) {
            seconds = clampedSeconds
        }
        
        triggerHapticFeedback()
    }
    
    private func selectPreset(_ presetSeconds: Int, index: Int) {
        // Visual feedback
        withAnimation(Self.presetButtonAnimation) {
            isPresetPressed[index] = true
        }
        
        // Reset after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(Self.presetButtonAnimation) {
                isPresetPressed[index] = false
            }
        }
        
        // Update value
        updateSeconds(presetSeconds)
    }
    
    private func clearTime() {
        updateSeconds(0)
    }
    
    private func triggerHapticFeedback() {
        Self.hapticGenerator.impactOccurred()
    }
}

// MARK: - PresetButton Helper Component
private struct PresetButton: View {
    let label: String
    let seconds: Int
    let currentSeconds: Int
    let isPressed: Bool
    let onTap: () -> Void
    
    private var isSelected: Bool {
        seconds == currentSeconds
    }
    
    var body: some View {
        ActionButton(
            title: label,
            style: isSelected ? .primary : .secondary,
            size: .small,
            action: onTap
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(TimeInputRow.presetButtonAnimation, value: isPressed)
    }
}

// MARK: - Convenience Factory Extensions
extension Row {
    static func timeInput(
        _ title: String,
        seconds: Binding<Int>,
        maxMinutes: Int = 59,
        secondsStep: Int = 5,
        showPresets: Bool = true,
        icon: String? = nil,
        position: RowPosition = .middle
    ) -> some View {
        TimeInputRow(
            title: title,
            seconds: seconds,
            maxMinutes: maxMinutes,
            secondsStep: secondsStep,
            showPresets: showPresets,
            icon: icon,
            position: position
        )
    }
}

// MARK: - Equatable for Performance
extension TimeInputRow: Equatable {
    static func == (lhs: TimeInputRow, rhs: TimeInputRow) -> Bool {
        lhs.title == rhs.title &&
        lhs.seconds == rhs.seconds &&
        lhs.maxMinutes == rhs.maxMinutes &&
        lhs.secondsStep == rhs.secondsStep &&
        lhs.showPresets == rhs.showPresets &&
        lhs.icon == rhs.icon &&
        lhs.position == rhs.position
    }
}

// MARK: - Preview Provider
#Preview {
    @Previewable @State var restTime = 90
    @Previewable @State var workTime = 45
    
    VStack(spacing: 1) {
        TimeInputRow(
            title: "Rest Time",
            seconds: $restTime,
            maxMinutes: 10,
            secondsStep: 15,
            showPresets: true,
            icon: "timer",
            position: .first
        )
        
        TimeInputRow(
            title: "Work Time",
            seconds: $workTime,
            maxMinutes: 5,
            secondsStep: 5,
            showPresets: true,
            icon: "play.fill",
            position: .last
        )
    }
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}
