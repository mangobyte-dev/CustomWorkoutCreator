import SwiftUI

// MARK: - TrainingMethodPicker Component
struct TrainingMethodPicker: View {
    @Binding var trainingMethod: TrainingMethod
    let showDescription: Bool
    
    // Decomposed storage bindings for each method type
    @Binding var standardMinReps: Int
    @Binding var standardMaxReps: Int
    @Binding var timedDuration: Int
    @Binding var restPauseMinisets: Int
    
    // Pre-computed static values following CLAUDE.md performance principles
    static let segmentedPickerHeight: CGFloat = 32
    static let descriptionTopPadding: CGFloat = 8
    static let inputsTopPadding: CGFloat = 12
    static let transitionDuration: Double = 0.3
    static let springAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.8)
    
    // Static method information to avoid runtime allocations
    private static let methodInfo: [TrainingMethodType: (title: String, description: String)] = [
        .standard: (
            title: "Standard",
            description: "Traditional rep ranges with minimum and maximum targets"
        ),
        .restPause: (
            title: "Rest-Pause",
            description: "Reach target total reps using multiple mini-sets with short rests"
        ),
        .timed: (
            title: "Timed",
            description: "Perform exercise for a specific duration rather than counting reps"
        )
    ]
    
    // Helper enum for consistent method handling
    private enum TrainingMethodType: String, CaseIterable {
        case standard = "Standard"
        case restPause = "Rest-Pause"
        case timed = "Timed"
    }
    
    @State private var selectedMethodType: TrainingMethodType = .standard
    
    init(
        trainingMethod: Binding<TrainingMethod>,
        showDescription: Bool = true,
        standardMinReps: Binding<Int>,
        standardMaxReps: Binding<Int>,
        timedDuration: Binding<Int>,
        restPauseMinisets: Binding<Int>
    ) {
        self._trainingMethod = trainingMethod
        self.showDescription = showDescription
        self._standardMinReps = standardMinReps
        self._standardMaxReps = standardMaxReps
        self._timedDuration = timedDuration
        self._restPauseMinisets = restPauseMinisets
        
        // Initialize selected method type based on current training method
        self._selectedMethodType = State(initialValue: Self.methodTypeFromTrainingMethod(trainingMethod.wrappedValue))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Method Selection Picker
            VStack(spacing: Self.descriptionTopPadding) {
                // Segmented Control
                Picker("Training Method", selection: $selectedMethodType) {
                    ForEach(TrainingMethodType.allCases, id: \.self) { methodType in
                        Text(methodType.rawValue)
                            .tag(methodType)
                    }
                }
                .pickerStyle(.segmented)
                .frame(height: Self.segmentedPickerHeight)
                .onChange(of: selectedMethodType) { oldValue, newValue in
                    updateTrainingMethod(for: newValue)
                }
                
                // Method Description
                if showDescription {
                    methodDescriptionView
                }
            }
            .padding(.horizontal, ComponentConstants.Row.horizontalPadding)
            .padding(.vertical, ComponentConstants.Row.verticalPadding)
            .background(ComponentConstants.Row.backgroundColor)
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: ComponentConstants.Row.cornerRadius,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: ComponentConstants.Row.cornerRadius,
                style: .continuous
            ))
            
            // Dynamic Input Fields
            dynamicInputFields
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: ComponentConstants.Row.cornerRadius,
                    bottomTrailingRadius: ComponentConstants.Row.cornerRadius,
                    topTrailingRadius: 0,
                    style: .continuous
                ))
        }
    }
    
    // MARK: - Method Description View
    
    @ViewBuilder
    private var methodDescriptionView: some View {
        if let info = Self.methodInfo[selectedMethodType] {
            Text(info.description)
                .font(ComponentConstants.Row.subtitleFont)
                .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
                .animation(Self.springAnimation, value: selectedMethodType)
        }
    }
    
    // MARK: - Dynamic Input Fields
    
    @ViewBuilder
    private var dynamicInputFields: some View {
        VStack(spacing: 1) {
            switch selectedMethodType {
            case .standard:
                standardInputFields
            case .restPause:
                restPauseInputFields
            case .timed:
                timedInputFields
            }
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        ))
        .animation(Self.springAnimation, value: selectedMethodType)
    }
    
    @ViewBuilder
    private var standardInputFields: some View {
        RangeInputRow(
            title: "Rep Range",
            minValue: $standardMinReps,
            maxValue: $standardMaxReps,
            range: 1...100,
            unit: "reps",
            icon: "arrow.clockwise",
            position: .last
        )
    }
    
    @ViewBuilder
    private var restPauseInputFields: some View {
        NumberInputRow(
            title: "Target Total Reps",
            value: $restPauseMinisets,
            range: 5...200,
            step: 5,
            unit: "reps",
            icon: "target",
            position: .last
        )
    }
    
    @ViewBuilder
    private var timedInputFields: some View {
        TimeInputRow(
            title: "Duration",
            seconds: $timedDuration,
            maxMinutes: 10,
            secondsStep: 5,
            showPresets: true,
            icon: "timer",
            position: .last
        )
    }
    
    // MARK: - Helper Methods
    
    private static func methodTypeFromTrainingMethod(_ trainingMethod: TrainingMethod) -> TrainingMethodType {
        switch trainingMethod {
        case .standard:
            return .standard
        case .restPause:
            return .restPause
        case .timed:
            return .timed
        }
    }
    
    private func updateTrainingMethod(for methodType: TrainingMethodType) {
        withAnimation(Self.springAnimation) {
            switch methodType {
            case .standard:
                trainingMethod = .standard(minReps: standardMinReps, maxReps: standardMaxReps)
            case .restPause:
                trainingMethod = .restPause(targetTotal: restPauseMinisets, minReps: 5, maxReps: 10)
            case .timed:
                trainingMethod = .timed(seconds: timedDuration)
            }
        }
    }
}

// MARK: - Convenience Factory Extensions
extension Row {
    static func trainingMethodPicker(
        trainingMethod: Binding<TrainingMethod>,
        showDescription: Bool = true,
        standardMinReps: Binding<Int>,
        standardMaxReps: Binding<Int>,
        timedDuration: Binding<Int>,
        restPauseMinisets: Binding<Int>
    ) -> some View {
        TrainingMethodPicker(
            trainingMethod: trainingMethod,
            showDescription: showDescription,
            standardMinReps: standardMinReps,
            standardMaxReps: standardMaxReps,
            timedDuration: timedDuration,
            restPauseMinisets: restPauseMinisets
        )
    }
}

// MARK: - Equatable for Performance
extension TrainingMethodPicker: Equatable {
    static func == (lhs: TrainingMethodPicker, rhs: TrainingMethodPicker) -> Bool {
        // Cannot directly compare Bindings, would need to compare the actual values
        // For now, just compare showDescription
        lhs.showDescription == rhs.showDescription
    }
}

// MARK: - Preview Provider
#Preview {
    @Previewable @State var trainingMethod: TrainingMethod = .standard(minReps: 8, maxReps: 12)
    @Previewable @State var standardMin = 8
    @Previewable @State var standardMax = 12
    @Previewable @State var timedSeconds = 60
    @Previewable @State var restPauseTotal = 50
    
    TrainingMethodPicker(
        trainingMethod: $trainingMethod,
        showDescription: true,
        standardMinReps: $standardMin,
        standardMaxReps: $standardMax,
        timedDuration: $timedSeconds,
        restPauseMinisets: $restPauseTotal
    )
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}

#Preview("Compact") {
    @Previewable @State var method: TrainingMethod = .restPause(targetTotal: 30, minReps: 5, maxReps: 10)
    @Previewable @State var standardMin = 10
    @Previewable @State var standardMax = 15
    @Previewable @State var timedSeconds = 45
    @Previewable @State var restPauseTotal = 30
    
    TrainingMethodPicker(
        trainingMethod: $method,
        showDescription: false,
        standardMinReps: $standardMin,
        standardMaxReps: $standardMax,
        timedDuration: $timedSeconds,
        restPauseMinisets: $restPauseTotal
    )
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}