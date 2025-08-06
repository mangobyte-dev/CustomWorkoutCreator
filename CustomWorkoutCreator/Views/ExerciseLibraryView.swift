//
//  ExerciseLibraryView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 2025-08-06
//

import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExerciseItem.name) private var exercises: [ExerciseItem]
    @State private var searchText = ""
    @State private var showingAddExercise = false
    
    // Step 5.8: Add filteredExercises computed property
    var filteredExercises: [ExerciseItem] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) 
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Exercise Library")
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $searchText)
                .toolbar {
                    toolbarContent
                }
                .sheet(isPresented: $showingAddExercise) {
                    // Placeholder for future exercise form view
                    Text("Add Exercise Form")
                }
        }
        .task {
            if exercises.isEmpty {
                ExerciseItem.createDefaultExercises(in: modelContext)
            }
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var contentView: some View {
        if filteredExercises.isEmpty {
            emptyStateView
        } else {
            exerciseListView
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Exercises",
            systemImage: "dumbbell",
            description: Text(searchText.isEmpty ? "Tap + to add your first exercise" : "No exercises match your search")
        )
    }
    
    @ViewBuilder
    private var exerciseListView: some View {
        List {
            ForEach(filteredExercises) { exerciseItem in
                ExerciseItemRow(exerciseItem: exerciseItem)
            }
            .onDelete { indices in
                deleteExercises(at: indices)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingAddExercise = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    private func deleteExercises(at indices: IndexSet) {
        for index in indices {
            if filteredExercises.indices.contains(index) {
                modelContext.delete(filteredExercises[index])
            }
        }
    }
}

struct ExerciseItemRow: View {
    let exerciseItem: ExerciseItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exerciseItem.name)
                    .font(.headline)
                
                demonstrationLabel
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var demonstrationLabel: some View {
        if let gifUrl = exerciseItem.gifUrl, !gifUrl.isEmpty {
            Text("Has demonstration")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ExerciseLibraryView()
}
