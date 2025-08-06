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
                ExerciseItem.loadFromBundle(in: modelContext)
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
    
    // Check if exercise has a GIF for demonstration label
    private var hasGif: Bool {
        guard let gifUrl = exerciseItem.gifUrl, !gifUrl.isEmpty else { 
            return false
        }
        return Bundle.main.url(forResource: gifUrl, withExtension: "gif", subdirectory: "ExerciseGIFs") != nil
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Step 5.15: GIF thumbnail with Step 5.16 placeholder fallback
            gifThumbnailView
            
            // Step 5.14: Enhanced content layout
            VStack(alignment: .leading, spacing: 6) {
                Text(exerciseItem.name)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    demonstrationLabel
                    
                }
            }
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var gifThumbnailView: some View {
        Group {
            if let gifName = exerciseItem.gifUrl, !gifName.isEmpty {
                // Use GifImageView for animated GIF display
                GifImageView(gifName)
            } else {
                // Step 5.16: Placeholder for exercises without GIFs
                placeholderImage
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary.opacity(0.3))
        }
    }
    
    @ViewBuilder
    private var loadingPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary.opacity(0.3))
            .overlay {
                ProgressView()
                    .scaleEffect(0.7)
            }
    }
    
    @ViewBuilder
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary.opacity(0.3))
            .overlay {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
    }
    
    @ViewBuilder
    private var demonstrationLabel: some View {
        if hasGif {
            Label("Video", systemImage: "play.circle.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
                .labelStyle(.titleAndIcon)
        } else {
            Text("No demo")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    ExerciseLibraryView()
}
