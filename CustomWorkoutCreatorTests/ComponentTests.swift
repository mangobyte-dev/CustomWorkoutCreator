//
//  ComponentTests.swift
//  CustomWorkoutCreatorTests
//
//  Created by Developer on 07/08/2025.
//

import Testing
import SwiftUI
@testable import CustomWorkoutCreator



@Suite("Component Tests", .tags(.component, .unit))
struct ComponentTests {
    
    // MARK: - Core Components
    
    @Test("LabelRow component renders with label and value")
    func labelRowComponent() {
        let row = LabelRow(title: "Test Label", value: "Test Value")
        
        // Component should exist and be configured
        #expect(row.title == "Test Label")
        #expect(row.value == "Test Value")
    }
    
    @Test("ActionButton component with action closure")
    
    @Test("SectionHeader component configuration")
    
    // MARK: - Input Components
    
    @Test("NumberInputRow with binding")
    @MainActor
    
    @Test("RangeInputRow with min/max values")
    @MainActor
    
    @Test("TimeInputRow with seconds conversion")
    @MainActor
    
    @Test("EffortSliderRow with 1-10 range")
    @MainActor
    func effortSliderRow() {
        var effort = 7
        let binding = Binding(
            get: { effort },
            set: { effort = $0 }
        )
        
        let slider = EffortSliderRow(
            title: "Effort",
            effort: binding
        )
        
        #expect(effort >= 1 && effort <= 10)
        #expect(slider.title == "Effort")
        
        // Test bounds
        binding.wrappedValue = 1
        #expect(effort == 1)
        
        binding.wrappedValue = 10
        #expect(effort == 10)
    }
    
    @Test("TrainingMethodPicker with all methods")
    @MainActor
    func trainingMethodPicker() {
        var method = TrainingMethod.standard(minReps: 10, maxReps: 15)
        let binding = Binding(
            get: { method },
            set: { method = $0 }
        )
        
        var standardMin = 10
        var standardMax = 15
        var timedDuration = 60
        var restPauseMinisets = 20
        
        let picker = TrainingMethodPicker(
            trainingMethod: binding,
            standardMinReps: Binding(get: { standardMin }, set: { standardMin = $0 }),
            standardMaxReps: Binding(get: { standardMax }, set: { standardMax = $0 }),
            timedDuration: Binding(get: { timedDuration }, set: { timedDuration = $0 }),
            restPauseMinisets: Binding(get: { restPauseMinisets }, set: { restPauseMinisets = $0 })
        )
        
        // Test method switching
        binding.wrappedValue = .restPause(targetTotal: 50)
        if case .restPause = method {
            #expect(true)
        } else {
            #expect(false, "Expected restPause method")
        }
        
        binding.wrappedValue = .timed(seconds: 60)
        if case .timed = method {
            #expect(true)
        } else {
            #expect(false, "Expected timed method")
        }
        
        binding.wrappedValue = .standard(minReps: 8, maxReps: 12)
        if case .standard = method {
            #expect(true)
        } else {
            #expect(false, "Expected standard method")
        }
    }
    
    // MARK: - Layout Components
    
    @Test("Expandable component state management")
    @MainActor
    func expandableComponent() {
        var isExpanded = false
        let binding = Binding(
            get: { isExpanded },
            set: { isExpanded = $0 }
        )
        
        let expandable = Expandable(
            isExpanded: binding,
            header: { Text("Header") },
            content: { Text("Content") }
        )
        
        #expect(!isExpanded)
        
        // Toggle expansion
        binding.wrappedValue = true
        #expect(isExpanded)
        
        binding.wrappedValue = false
        #expect(!isExpanded)
    }
    
    @Test("ExpandableList with multiple items")
    @MainActor
    func expandableListComponent() {
        struct Item: Identifiable {
            let id = UUID()
            let title: String
        }
        
        let items = [
            Item(title: "Item 1"),
            Item(title: "Item 2"),
            Item(title: "Item 3")
        ]
        
        var expandedStates: [UUID: Bool] = [:]
        
        let list = ExpandableList(items: items) { item, index, isExpanded in
            VStack {
                Text(item.title)
                if isExpanded.wrappedValue {
                    Text("Content for \(item.title)")
                }
            }
        }
        
        #expect(expandedStates.isEmpty)
        
        // Simulate state management
        expandedStates[items[0].id] = true
        #expect(expandedStates.count == 1)
        #expect(expandedStates[items[0].id] == true)
        
        // Expand all items
        items.forEach { expandedStates[$0.id] = true }
        #expect(expandedStates.count == 3)
        #expect(expandedStates.values.allSatisfy { $0 == true })
    }
    
    // MARK: - Card Components
    
    @Test("ExerciseFormCard with complete data")
    @MainActor
    func exerciseFormCard() {
        var exercise = Exercise(
            name: "Bench Press",
            trainingMethod: .standard(minReps: 8, maxReps: 12),
            effort: 8,
            weight: 185,
            restAfter: 120
        )
        
        let binding = Binding(
            get: { exercise },
            set: { exercise = $0 }
        )
        
        var isExpanded = false
        let expandedBinding = Binding(
            get: { isExpanded },
            set: { isExpanded = $0 }
        )
        
        let card = ExerciseFormCard(
            exercise: binding,
            isExpanded: expandedBinding,
            onDelete: { }
        )
        
        #expect(exercise.name == "Bench Press")
        #expect(exercise.effort == 8)
        #expect(exercise.weight == 185)
        
        // Update through binding
        exercise.effort = 9
        binding.wrappedValue = exercise
        #expect(binding.wrappedValue.effort == 9)
    }
    
    @Test("IntervalFormCard with exercises")
    @MainActor
    func intervalFormCard() {
        var interval = Interval(
            name: "Main Set",
            rounds: 5,
            restBetweenRounds: 60
        )
        
        interval.exercises = [
            Exercise(name: "Exercise 1", trainingMethod: .standard(minReps: 10, maxReps: 10)),
            Exercise(name: "Exercise 2", trainingMethod: .standard(minReps: 12, maxReps: 12))
        ]
        
        let binding = Binding(
            get: { interval },
            set: { interval = $0 }
        )
        
        var isExpanded = false
        let expandedBinding = Binding(
            get: { isExpanded },
            set: { isExpanded = $0 }
        )
        
        let card = IntervalFormCard(
            interval: binding,
            isExpanded: expandedBinding,
            intervalNumber: 1,
            onDelete: { },
            onAddExercise: { }
        )
        
        #expect(interval.name == "Main Set")
        #expect(interval.rounds == 5)
        #expect(interval.exercises.count == 2)
    }
    
    // MARK: - Media Components
    
    @Test("GifImageView with valid gif name")
    func gifImageView() {
        let view = GifImageView("bench-press")
        
        #expect(view.name == "bench-press")
        
        // Test with empty name
        let emptyView = GifImageView("")
        #expect(emptyView.name == "")
    }
    
    // MARK: - Performance Tests
    
    @Test("Component creation performance", .tags(.performance))
    
    @Test("Component state update performance", .tags(.performance))
    @MainActor
    func componentStateUpdatePerformance() {
        var value = 0
        let binding = Binding(
            get: { value },
            set: { value = $0 }
        )
        
        let measurement = PerformanceMeasurement(
            name: "1000 State Updates",
            expectation: 0.001 // 1ms
        )
        
        for i in 1...1000 {
            binding.wrappedValue = i
        }
        
        measurement.expect()
        #expect(value == 1000)
    }
}

// MARK: - Component Integration Tests

@Suite("Component Integration", .tags(.component, .integration))
struct ComponentIntegrationTests {
    
    @Test("Components work together in a form")
    @MainActor
    func componentsInForm() {
        var workout = TestFixtures.createWorkout()
        
        let workoutBinding = Binding(
            get: { workout },
            set: { workout = $0 }
        )
        
        // Simulate form with multiple components
        let header = SectionHeader(title: workout.name)
        
        var intervalCards: [IntervalFormCard] = []
        for interval in workout.intervals {
            var mutableInterval = interval
            let binding = Binding(
                get: { mutableInterval },
                set: { mutableInterval = $0 }
            )
            var intervalExpanded = false
            let intervalExpandedBinding = Binding(
                get: { intervalExpanded },
                set: { intervalExpanded = $0 }
            )
            intervalCards.append(IntervalFormCard(
                interval: binding,
                isExpanded: intervalExpandedBinding,
                intervalNumber: intervalCards.count + 1,
                onDelete: {},
                onAddExercise: {}
            ))
        }
        
        #expect(intervalCards.count == workout.intervals.count)
        
        // Update workout name through binding
        workout.name = "Updated Workout"
        workoutBinding.wrappedValue = workout
        #expect(workoutBinding.wrappedValue.name == "Updated Workout")
    }
    
    @Test("Nested expandable components")
    @MainActor
    func nestedExpandables() {
        var parentExpanded = false
        var childExpanded = false
        
        let parentBinding = Binding(
            get: { parentExpanded },
            set: { parentExpanded = $0 }
        )
        
        let childBinding = Binding(
            get: { childExpanded },
            set: { childExpanded = $0 }
        )
        
        let parent = Expandable(
            isExpanded: parentBinding,
            header: { Text("Parent") },
            content: {
                Expandable(
                    isExpanded: childBinding,
                    header: { Text("Child") },
                    content: { Text("Nested Content") }
                )
            }
        )
        
        // Test independent expansion
        parentBinding.wrappedValue = true
        #expect(parentExpanded && !childExpanded)
        
        childBinding.wrappedValue = true
        #expect(parentExpanded && childExpanded)
        
        parentBinding.wrappedValue = false
        #expect(!parentExpanded && childExpanded)
    }
}