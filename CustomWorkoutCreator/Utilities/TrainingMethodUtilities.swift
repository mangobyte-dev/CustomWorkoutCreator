import SwiftUI

// MARK: - TrainingMethod Utilities
/// Centralized utilities for TrainingMethod decomposition and construction
/// Eliminates duplicate code across TrainingMethodPicker, ExerciseEditSheet, and ExerciseFormCard
/// Follows CLAUDE.md performance principles with pre-computed constants

enum TrainingMethodUtilities {
    
    // MARK: - TrainingMethodType Enum
    /// Standardized enum for consistent TrainingMethod handling across components
    enum TrainingMethodType: String, CaseIterable, Identifiable {
        case standard = "Standard"
        case restPause = "Rest-Pause"
        case timed = "Timed"
        
        var id: String { rawValue }
        
        /// Returns the appropriate TrainingMethodType for a given TrainingMethod
        static func from(_ trainingMethod: TrainingMethod) -> TrainingMethodType {
            switch trainingMethod {
            case .standard:
                return .standard
            case .restPause:
                return .restPause
            case .timed:
                return .timed
            }
        }
    }
    
    // MARK: - DecomposedValues Struct
    /// State container for managing TrainingMethod values in UI components
    /// Provides consistent state management across all components
    struct DecomposedValues: Equatable {
        var standardMinReps: Int
        var standardMaxReps: Int
        var timedDuration: Int
        var restPauseMinisets: Int
        
        /// Default values following established patterns from existing code
        static let `default` = DecomposedValues(
            standardMinReps: 8,
            standardMaxReps: 12,
            timedDuration: 45,
            restPauseMinisets: 20
        )
        
        /// Initialize with default values
        init() {
            self = .default
        }
        
        /// Initialize with custom values
        init(standardMinReps: Int, standardMaxReps: Int, timedDuration: Int, restPauseMinisets: Int) {
            self.standardMinReps = standardMinReps
            self.standardMaxReps = standardMaxReps
            self.timedDuration = timedDuration
            self.restPauseMinisets = restPauseMinisets
        }
    }
    
    // MARK: - Decomposition Methods
    /// Converts a TrainingMethod enum into DecomposedValues for UI state management
    /// @param trainingMethod The TrainingMethod to decompose
    /// @returns DecomposedValues struct containing the decomposed state
    static func decompose(_ trainingMethod: TrainingMethod) -> DecomposedValues {
        var values = DecomposedValues.default
        
        switch trainingMethod {
        case let .standard(minReps, maxReps):
            values.standardMinReps = minReps
            values.standardMaxReps = maxReps
        case let .restPause(targetTotal, _, _):
            values.restPauseMinisets = targetTotal
        case let .timed(seconds):
            values.timedDuration = seconds
        }
        
        return values
    }
    
    /// Updates an existing DecomposedValues instance with data from a TrainingMethod
    /// @param values The DecomposedValues instance to update (passed as inout)
    /// @param trainingMethod The TrainingMethod to extract values from
    static func updateDecomposedValues(_ values: inout DecomposedValues, from trainingMethod: TrainingMethod) {
        switch trainingMethod {
        case let .standard(minReps, maxReps):
            values.standardMinReps = minReps
            values.standardMaxReps = maxReps
        case let .restPause(targetTotal, _, _):
            values.restPauseMinisets = targetTotal
        case let .timed(seconds):
            values.timedDuration = seconds
        }
    }
    
    // MARK: - Construction Methods
    /// Constructs a TrainingMethod from a TrainingMethodType and DecomposedValues
    /// @param type The type of TrainingMethod to construct
    /// @param values The DecomposedValues containing the state data
    /// @returns A constructed TrainingMethod with appropriate parameters
    static func construct(type: TrainingMethodType, from values: DecomposedValues) -> TrainingMethod {
        switch type {
        case .standard:
            return .standard(minReps: values.standardMinReps, maxReps: values.standardMaxReps)
        case .restPause:
            return .restPause(targetTotal: values.restPauseMinisets, minReps: 5, maxReps: 10)
        case .timed:
            return .timed(seconds: values.timedDuration)
        }
    }
    
    // MARK: - Helper Methods
    /// Creates a Binding<TrainingMethod> that automatically syncs with DecomposedValues
    /// @param trainingMethod The source Binding<TrainingMethod>
    /// @param decomposedValues The Binding<DecomposedValues> to keep in sync
    /// @returns A Binding<TrainingMethod> that updates decomposed values when changed
    static func createSyncedBinding(
        trainingMethod: Binding<TrainingMethod>,
        decomposedValues: Binding<DecomposedValues>
    ) -> Binding<TrainingMethod> {
        Binding<TrainingMethod>(
            get: {
                trainingMethod.wrappedValue
            },
            set: { newMethod in
                trainingMethod.wrappedValue = newMethod
                updateDecomposedValues(&decomposedValues.wrappedValue, from: newMethod)
            }
        )
    }
    
    // MARK: - Method Information
    /// Pre-computed method information to avoid runtime allocations
    /// Following CLAUDE.md performance principles
    static let methodInfo: [TrainingMethodType: (title: String, description: String)] = [
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
    
    // MARK: - Default Values
    /// Default values for each method type for consistent initialization
    static let defaultValues: [TrainingMethodType: DecomposedValues] = [
        .standard: DecomposedValues(
            standardMinReps: 8,
            standardMaxReps: 12,
            timedDuration: 45,
            restPauseMinisets: 20
        ),
        .restPause: DecomposedValues(
            standardMinReps: 8,
            standardMaxReps: 12,
            timedDuration: 45,
            restPauseMinisets: 20
        ),
        .timed: DecomposedValues(
            standardMinReps: 8,
            standardMaxReps: 12,
            timedDuration: 45,
            restPauseMinisets: 20
        )
    ]
}

// MARK: - Convenience Extensions
extension TrainingMethodUtilities.DecomposedValues {
    /// Creates DecomposedValues from a TrainingMethod
    /// Convenience initializer for easier use
    init(from trainingMethod: TrainingMethod) {
        self = TrainingMethodUtilities.decompose(trainingMethod)
    }
    
    /// Updates this DecomposedValues instance from a TrainingMethod
    /// Convenience method for in-place updates
    mutating func update(from trainingMethod: TrainingMethod) {
        TrainingMethodUtilities.updateDecomposedValues(&self, from: trainingMethod)
    }
}

// MARK: - Preview Helpers
#if DEBUG
extension TrainingMethodUtilities {
    /// Sample data for previews and testing
    static let sampleMethods: [TrainingMethod] = [
        .standard(minReps: 8, maxReps: 12),
        .restPause(targetTotal: 50, minReps: 5, maxReps: 10),
        .timed(seconds: 60)
    ]
    
    /// Sample DecomposedValues for previews
    static let sampleDecomposedValues = DecomposedValues(
        standardMinReps: 10,
        standardMaxReps: 15,
        timedDuration: 60,
        restPauseMinisets: 30
    )
}
#endif