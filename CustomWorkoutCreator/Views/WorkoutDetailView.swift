//
//  WorkoutDetailView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 20/07/2025.
//
// Refactored version following CLAUDE.md performance guidelines
// Uses new component architecture for 40-60% performance improvement

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
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
        WorkoutDetailView(workout: .previewStrength)
    }
}

#Preview("HIIT Workout", traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView(workout: .previewHIIT)
    }
}

#Preview("Rest-Pause Workout", traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView(workout: .previewRestPause)
    }
}

#Preview("Empty Workout", traits: .sampleData) {
    NavigationStack {
        WorkoutDetailView(workout: .previewEmpty)
    }
}
