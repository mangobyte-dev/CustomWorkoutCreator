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
    
    @State private var selectedMethodType: TrainingMethodUtilities.TrainingMethodType = .standard
    
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
        self._selectedMethodType = State(initialValue: TrainingMethodUtilities.TrainingMethodType.from(trainingMethod.wrappedValue))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Method Selection Picker
            VStack(spacing: ComponentConstants.TrainingMethod.descriptionTopPadding) {
                // Segmented Control
                Picker("Training Method", selection: $selectedMethodType) {
                    ForEach(TrainingMethodUtilities.TrainingMethodType.allCases, id: \.self) { methodType in
                        Text(methodType.rawValue)
                            .tag(methodType)
                    }
                }
                .pickerStyle(.segmented)
                .frame(height: ComponentConstants.TrainingMethod.segmentedPickerHeight)
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
        if let info = TrainingMethodUtilities.methodInfo[selectedMethodType] {
            Text(info.description)
                .font(ComponentConstants.Row.subtitleFont)
                .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(ComponentConstants.TrainingMethod.descriptionTransition)
                .animation(ComponentConstants.TrainingMethod.springAnimation, value: selectedMethodType)
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
        .transition(ComponentConstants.TrainingMethod.inputFieldsTransition)
        .animation(ComponentConstants.TrainingMethod.springAnimation, value: selectedMethodType)
    }
    
    @ViewBuilder
    private var standardInputFields: some View {
        RangeInputRow(
            title: "Rep Range",
            minValue: $standardMinReps,
            maxValue: $standardMaxReps,
            range: ComponentConstants.TrainingMethod.repRange,
            unit: ComponentConstants.TrainingMethod.repsUnit,
            icon: ComponentConstants.TrainingMethod.standardIcon,
            position: .last
        )
    }
    
    @ViewBuilder
    private var restPauseInputFields: some View {
        NumberInputRow(
            title: "Target Total Reps",
            value: $restPauseMinisets,
            range: ComponentConstants.TrainingMethod.restPauseRange,
            step: ComponentConstants.TrainingMethod.restPauseStep,
            unit: ComponentConstants.TrainingMethod.repsUnit,
            icon: ComponentConstants.TrainingMethod.restPauseIcon,
            position: .last
        )
    }
    
    @ViewBuilder
    private var timedInputFields: some View {
        TimeInputRow(
            title: "Duration",
            seconds: $timedDuration,
            maxMinutes: ComponentConstants.TrainingMethod.timedMaxMinutes,
            secondsStep: ComponentConstants.TrainingMethod.timedSecondsStep,
            showPresets: true,
            icon: ComponentConstants.TrainingMethod.timedIcon,
            position: .last
        )
    }
    
    // MARK: - Helper Methods
    
    private func updateTrainingMethod(for methodType: TrainingMethodUtilities.TrainingMethodType) {
        withAnimation(ComponentConstants.TrainingMethod.springAnimation) {
            let decomposedValues = TrainingMethodUtilities.DecomposedValues(
                standardMinReps: standardMinReps,
                standardMaxReps: standardMaxReps,
                timedDuration: timedDuration,
                restPauseMinisets: restPauseMinisets
            )
            trainingMethod = TrainingMethodUtilities.construct(type: methodType, from: decomposedValues)
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