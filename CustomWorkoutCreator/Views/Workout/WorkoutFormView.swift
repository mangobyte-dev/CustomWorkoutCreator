//
//  WorkoutFormView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 20/07/2025.
//
// Refactored to use high-performance ScrollView + LazyVStack architecture
// Following CLAUDE.md performance principles

import SwiftUI
import SwiftData

struct WorkoutFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let workout: Workout?
    
    @State private var workoutName = ""
    @State private var intervals: [Interval] = []
    @State private var showingExercisePicker = false
    @State private var selectedIntervalIndex: Int?
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case workoutName
        case intervalName(Int)
    }
    
    // Pre-computed static values
    private static let headerSpacing: CGFloat = ComponentConstants.Layout.sectionSpacing
    private static let contentSpacing: CGFloat = ComponentConstants.Layout.sectionSpacing
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Self.contentSpacing) {
                    // Workout Name Section
                    VStack(spacing: ComponentConstants.Layout.compactPadding) {
                        SectionHeader(title: "Workout Details")
                            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                        
                        VStack(spacing: 0) {
                            Row(position: .only) {
                                HStack(spacing: ComponentConstants.Row.contentSpacing) {
                                    Text("Name")
                                        .font(ComponentConstants.Row.titleFont)
                                        .foregroundStyle(ComponentConstants.Row.primaryTextColor)
                                    
                                    TextField("Workout Name", text: $workoutName)
                                        .font(ComponentConstants.Row.valueFont)
                                        .foregroundStyle(ComponentConstants.Row.primaryTextColor)
                                        .multilineTextAlignment(.trailing)
                                        .focused($focusedField, equals: .workoutName)
                                }
                            }
                        }
                        .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                    }
                    
                    // Intervals Section
                    VStack(spacing: ComponentConstants.Layout.compactPadding) {
                        HStack {
                            SectionHeader(title: "Intervals") {
                                Text("\(intervals.count)")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Spacer()
                            
                            ActionButton(
                                title: "Add Interval",
                                icon: "plus.circle",
                                style: .ghost,
                                size: .small
                            ) {
                                addInterval()
                            }
                        }
                        .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                        
                        if intervals.isEmpty {
                            // Empty state
                            ContentUnavailableView(
                                "No Intervals",
                                systemImage: "rectangle.stack.badge.plus",
                                description: Text("Tap 'Add Interval' to build your workout")
                            )
                            .frame(minHeight: 200)
                            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                        } else {
                            // Intervals list
                            ExpandableList(items: intervals) { interval, index, isExpanded in
                                IntervalFormCard(
                                    interval: bindingForInterval(at: index),
                                    isExpanded: isExpanded,
                                    intervalNumber: index + 1
                                ) {
                                    deleteInterval(at: index)
                                } onAddExercise: {
                                    selectedIntervalIndex = index
                                    showingExercisePicker = true
                                }
                            }
                            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                        }
                    }
                }
                .padding(.vertical, ComponentConstants.Layout.defaultPadding)
            }
            .background(ComponentConstants.Colors.groupedBackground)
            .navigationTitle(workout == nil ? "New Workout" : "Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .onAppear {
                loadWorkoutData()
            }
            .sheet(isPresented: $showingExercisePicker) {
                if let index = selectedIntervalIndex {
                    ExercisePicker(selectedExercise: .constant(nil)) { selected in
                        addExerciseToInterval(selected, at: index)
                        showingExercisePicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadWorkoutData() {
        if let workout = workout {
            workoutName = workout.name
            intervals = workout.intervals
        } else {
            // Start with one empty interval for new workouts
            if intervals.isEmpty {
                let newInterval = Interval()
                newInterval.name = "Interval 1"
                newInterval.rounds = 1
                intervals.append(newInterval)
            }
        }
    }
    
    private func saveWorkout() {
        if let existingWorkout = workout {
            existingWorkout.name = workoutName
            existingWorkout.intervals = intervals
        } else {
            let newWorkout = Workout(
                name: workoutName,
                dateAndTime: Date(),
                intervals: intervals
            )
            modelContext.insert(newWorkout)
        }
        dismiss()
    }
    
    private func addInterval() {
        let newInterval = Interval()
        newInterval.name = "Interval \(intervals.count + 1)"
        newInterval.rounds = 1
        intervals.append(newInterval)
    }
    
    private func deleteInterval(at index: Int) {
        guard index < intervals.count else { return }
        intervals.remove(at: index)
    }
    
    private func addExerciseToInterval(_ exerciseItem: ExerciseItem, at index: Int) {
        guard index < intervals.count else { return }
        
        let newExercise = Exercise.from(
            exerciseItem: exerciseItem,
            trainingMethod: .standard(minReps: 8, maxReps: 12),
            effort: 7
        )
        
        intervals[index].exercises.append(newExercise)
    }
    
    private func bindingForInterval(at index: Int) -> Binding<Interval> {
        Binding<Interval>(
            get: { intervals[index] },
            set: { intervals[index] = $0 }
        )
    }
}

// MARK: - Preview Provider
#Preview("New Workout", traits: .sampleData) {
    WorkoutFormView(workout: nil)
}

#Preview("Edit Workout", traits: .sampleData) {
    WorkoutFormView(workout: .previewStrength)
}

#Preview("Empty Workout", traits: .sampleData) {
    WorkoutFormView(workout: .previewEmpty)
}