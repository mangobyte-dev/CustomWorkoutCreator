//
//  WorkoutDetailView_New.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 20/07/2025.
//
// REFACTORED VERSION IN PROGRESS
// This is a duplicate of WorkoutDetailView.swift created for parallel refactoring
// to improve performance based on CLAUDE.md guidelines.

import SwiftUI
import SwiftData

struct WorkoutDetailView_New: View {
    let workout: Workout
    @State private var showingEditView = false
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - @ViewBuilder Computed Properties for Conditionals
    
    @ViewBuilder
    private var intervalsContent: some View {
        if workout.intervals.isEmpty {
            ContentUnavailableView(
                "No Intervals",
                systemImage: "rectangle.stack.badge.plus",
                description: Text("Add intervals to build your workout")
            )
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .frame(minHeight: 200)
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
        } else {
            ExpandableList(items: workout.intervals) { interval, index, isExpanded in
                IntervalCard(
                    interval: interval,
                    intervalNumber: index + 1,
                    isExpanded: isExpanded
                )
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
        }
    }
    
    // MARK: - Action Functions
    
    private func showEditView() {
        showingEditView = true
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: ComponentConstants.Layout.sectionSpacing) {
                // Workout Overview Section - Using Row components
                VStack(spacing: ComponentConstants.Layout.sectionSpacing) {
                    SectionHeader(title: "Overview")
                        .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                    
                    VStack(spacing: 1) {
                        // Name row
                        LabelRow(title: "Name", value: workout.name, position: .first)
                        
                        // Date/Time row - Custom row for complex content
                        Row(
                            position: .middle,
                            content: {
                                Text("Date Created")
                                    .font(ComponentConstants.Row.titleFont)
                                    .foregroundColor(ComponentConstants.Row.primaryTextColor)
                            },
                            trailing: {
                                HStack(spacing: 4) {
                                    Text(workout.dateAndTime, style: .date)
                                        .font(ComponentConstants.Row.valueFont)
                                    Text(workout.dateAndTime, style: .time)
                                        .font(ComponentConstants.Row.valueFont)
                                        .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                                }
                            }
                        )
                        
                        // Duration row
                        Row(
                            position: .last,
                            content: {
                                Text("Total Duration")
                                    .font(ComponentConstants.Row.titleFont)
                                    .foregroundColor(ComponentConstants.Row.primaryTextColor)
                            },
                            trailing: {
                                Label(WorkoutDetailViewCache.formatDuration(workout.totalDuration), systemImage: "timer")
                                    .font(ComponentConstants.Row.valueFont)
                                    .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                            }
                        )
                    }
                    .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                }
                
                // Intervals Section
                VStack(spacing: ComponentConstants.Layout.sectionSpacing) {
                    SectionHeader(title: "Intervals") {
                        Text("\(workout.intervals.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
                    
                    intervalsContent
                }
            }
        }
        .background(ComponentConstants.Colors.groupedBackground)
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit", action: showEditView)
            }
        }
        .sheet(isPresented: $showingEditView) {
            WorkoutFormView(workout: workout)
        }
    }
}



#Preview(traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView_New(workout: .previewStrength)
    }
}

#Preview("HIIT Workout_New", traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView_New(workout: .previewHIIT)
    }
}

#Preview("Rest-Pause Workout_New", traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView_New(workout: .previewRestPause)
    }
}

#Preview("Empty Workout_New", traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView_New(workout: .previewEmpty)
    }
}
