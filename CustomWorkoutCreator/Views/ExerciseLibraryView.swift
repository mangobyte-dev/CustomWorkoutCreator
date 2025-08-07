//
//  ExerciseLibraryView.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 2025-08-06
//

import SwiftUI
import SwiftData

// MARK: - Observable Model with Smart Caching
@Observable
final class ExerciseLibraryModel {
    var exercises: [ExerciseItem] = []
    var searchText = ""
    
    private var _filteredItems: [ExerciseItem]?
    private var _lastFilterText = ""
    private var _gifAvailability: [UUID: Bool] = [:]
    
    var filteredExercises: [ExerciseItem] {
        if searchText == _lastFilterText, let cached = _filteredItems {
            return cached
        }
        
        _lastFilterText = searchText
        _filteredItems = searchText.isEmpty 
            ? exercises 
            : exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        
        return _filteredItems ?? []
    }
    
    func precomputeGifAvailability() {
        print("🔄 Pre-computing GIF availability for \(exercises.count) exercises")
        var foundCount = 0
        var missingCount = 0
        
        for exercise in exercises {
            if let gifName = exercise.gifUrl {
                // Try all possible paths
                let hasGif = Bundle.main.url(forResource: gifName, withExtension: "gif") != nil ||
                            Bundle.main.url(forResource: gifName, withExtension: "gif", subdirectory: "ExerciseGIFs") != nil ||
                            Bundle.main.url(forResource: gifName, withExtension: "gif", subdirectory: "Resources/ExerciseGIFs") != nil
                
                _gifAvailability[exercise.id] = hasGif
                
                if hasGif {
                    foundCount += 1
                    if foundCount <= 3 {
                        print("✅ Found GIF for: '\(gifName)'")
                    }
                } else {
                    missingCount += 1
                    if missingCount <= 3 {
                        print("❌ Missing GIF for: '\(gifName)'")
                    }
                }
            }
        }
        
        print("📊 GIF availability: \(foundCount) found, \(missingCount) missing out of \(exercises.count) total")
    }
    
    func hasGif(for exercise: ExerciseItem) -> Bool {
        _gifAvailability[exercise.id] ?? false
    }
    
    func updateExercises(_ newExercises: [ExerciseItem]) {
        exercises = newExercises
        _filteredItems = nil
        precomputeGifAvailability()
    }
}

// MARK: - Main View with ViewBuilders
struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExerciseItem.name) private var exercises: [ExerciseItem]
    
    @State private var model = ExerciseLibraryModel()
    @State private var showingAddExercise = false
    @State private var searchTask: Task<Void, Never>?
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            mainContent
        }
        .task {
            loadInitialDataIfNeeded
        }
        .onAppear {
            model.updateExercises(exercises)
        }
        .onChange(of: exercises) { _, newValue in
            model.updateExercises(newValue)
        }
        .onChange(of: searchText) { _, newValue in
            performDebouncedSearch(newValue)
        }
    }
    
    // MARK: - ViewBuilder Components
    
    @ViewBuilder
    private var mainContent: some View {
        listOrEmptyState
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingAddExercise) { addExerciseSheet }
    }
    
    @ViewBuilder
    private var listOrEmptyState: some View {
        if model.filteredExercises.isEmpty {
            emptyStateView
        } else {
            optimizedListView
        }
    }
    
    @ViewBuilder
    private var optimizedListView: some View {
        List {
            ForEach(model.filteredExercises) { item in
                EquatableView(
                    content: OptimizedExerciseRow(
                        item: item,
                        hasGif: model.hasGif(for: item)
                    )
                )
            }
            .onDelete(perform: deleteExercises)
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView(
            emptyStateTitle,
            systemImage: "dumbbell",
            description: Text(emptyStateDescription)
        )
    }
    
    @ViewBuilder
    private var addExerciseSheet: some View {
        Text("Add Exercise Form")
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: { showingAddExercise = true }) {
                Image(systemName: "plus")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var emptyStateTitle: String {
        "No Exercises"
    }
    
    private var emptyStateDescription: String {
        searchText.isEmpty 
            ? "Tap + to add your first exercise" 
            : "No exercises match your search"
    }
    
    private var loadInitialDataIfNeeded: Void {
        if exercises.isEmpty {
            ExerciseItem.loadFromBundle(in: modelContext)
        }
    }
    
    // MARK: - Actions
    
    private func performDebouncedSearch(_ text: String) {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            if !Task.isCancelled {
                await MainActor.run {
                    model.searchText = text
                }
            }
        }
    }
    
    private func deleteExercises(at indices: IndexSet) {
        for index in indices {
            if model.filteredExercises.indices.contains(index) {
                modelContext.delete(model.filteredExercises[index])
            }
        }
    }
}

// MARK: - Optimized Row with ViewBuilders and Equatable
struct OptimizedExerciseRow: View, Equatable {
    let item: ExerciseItem
    let hasGif: Bool
    
    @State private var showGif = false
    
    var body: some View {
        rowContent
            .onAppear { enableGifLoading() }
            .onDisappear { showGif = false }
    }
    
    // MARK: - ViewBuilder Components
    
    @ViewBuilder
    private var rowContent: some View {
        HStack(spacing: 12) {
            thumbnailView
            textContent
            Spacer()
            chevronIcon
        }
        .padding(.vertical, 6)
    }
    
    @ViewBuilder
    private var thumbnailView: some View {
        Group {
            if showGif {
                gifOrPlaceholder
            } else {
                loadingPlaceholder
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    @ViewBuilder
    private var gifOrPlaceholder: some View {
        if let gifName = item.gifUrl, hasGif {
            let _ = print("🎯 Row loading GIF: '\(gifName)' (hasGif: true)")
            GifImageView(gifName)
        } else {
            let _ = print("⚠️ Row showing placeholder - gifUrl: '\(item.gifUrl ?? "nil")' hasGif: \(hasGif)")
            staticPlaceholder
        }
    }
    
    @ViewBuilder
    private var loadingPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary.opacity(0.3))
            .overlay {
                ProgressView()
                    .scaleEffect(0.5)
            }
    }
    
    @ViewBuilder
    private var staticPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary.opacity(0.3))
            .overlay {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(.secondary)
            }
    }
    
    @ViewBuilder
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            exerciseName
            if hasGif {
                demoLabel
            }
        }
    }
    
    @ViewBuilder
    private var exerciseName: some View {
        Text(item.name)
            .font(.headline)
            .lineLimit(2)
    }
    
    @ViewBuilder
    private var demoLabel: some View {
        Label("Demo", systemImage: "play.circle.fill")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    private var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }
    
    // MARK: - Helper Methods
    
    private func enableGifLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            showGif = true
        }
    }
    
    // MARK: - Equatable
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.item.id == rhs.item.id &&
        lhs.item.name == rhs.item.name &&
        lhs.item.gifUrl == rhs.item.gifUrl &&
        lhs.hasGif == rhs.hasGif
    }
}

#Preview {
    ExerciseLibraryView()
}
