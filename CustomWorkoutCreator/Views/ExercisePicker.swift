//
//  ExercisePicker.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 2025-08-07
//

import SwiftUI
import SwiftData

// MARK: - Recent Exercises Manager
@Observable
final class RecentExercisesManager {
    private static let maxRecent = 10
    private static let key = "recentExerciseIDs"
    
    var recentIDs: [UUID] = []
    
    init() {
        loadRecent()
    }
    
    func addRecent(_ exerciseItem: ExerciseItem) {
        recentIDs.removeAll { $0 == exerciseItem.id }
        recentIDs.insert(exerciseItem.id, at: 0)
        if recentIDs.count > Self.maxRecent {
            recentIDs = Array(recentIDs.prefix(Self.maxRecent))
        }
        saveRecent()
    }
    
    func getRecent(from exercises: [ExerciseItem]) -> [ExerciseItem] {
        recentIDs.compactMap { id in
            exercises.first { $0.id == id }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadRecent() {
        if let data = UserDefaults.standard.data(forKey: Self.key),
           let ids = try? JSONDecoder().decode([UUID].self, from: data) {
            recentIDs = ids
        }
    }
    
    private func saveRecent() {
        if let data = try? JSONEncoder().encode(recentIDs) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }
}

// MARK: - Exercise Picker View
struct ExercisePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExerciseItem.name) private var exercises: [ExerciseItem]
    
    @Binding var selectedExercise: ExerciseItem?
    @State private var searchText = ""
    @State private var model = ExerciseLibraryModel()
    @State private var recentManager = RecentExercisesManager()
    
    let onSelection: (ExerciseItem) -> Void
    
    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("Select Exercise")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText)
                .toolbar { toolbarContent }
        }
        .onAppear {
            model.updateExercises(exercises)
        }
        .onChange(of: searchText) { _, newValue in
            model.searchText = newValue
        }
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private var mainContent: some View {
        if model.filteredExercises.isEmpty {
            emptyStateView
        } else {
            exerciseList
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Exercises Found",
            systemImage: "magnifyingglass",
            description: Text("Try adjusting your search")
        )
    }
    
    @ViewBuilder
    private var exerciseList: some View {
        List {
            // Recent exercises section
            if searchText.isEmpty && !recentExercises.isEmpty {
                recentSection
            }
            
            // All exercises
            allExercisesSection
        }
    }
    
    @ViewBuilder
    private var recentSection: some View {
        Section {
            ForEach(recentExercises) { item in
                exerciseRow(for: item)
            }
        } header: {
            Label("Recent", systemImage: "clock")
        }
    }
    
    @ViewBuilder
    private var allExercisesSection: some View {
        Section {
            ForEach(model.filteredExercises) { item in
                exerciseRow(for: item)
            }
        } header: {
            if !searchText.isEmpty {
                Text("Search Results")
            } else if !recentExercises.isEmpty {
                Text("All Exercises")
            }
        }
    }
    
    @ViewBuilder
    private func exerciseRow(for item: ExerciseItem) -> some View {
        Button {
            selectExercise(item)
        } label: {
            HStack(spacing: 12) {
                // GIF thumbnail
                if let gifUrl = item.gifUrl, model.hasGif(for: item) {
                    GifImageView(gifUrl)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.quaternary.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                }
                
                // Exercise name
                Text(item.name)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                // Selection indicator
                if selectedExercise?.id == item.id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
    }
    
    // MARK: - Computed Properties
    
    private var recentExercises: [ExerciseItem] {
        recentManager.getRecent(from: exercises)
    }
    
    // MARK: - Actions
    
    private func selectExercise(_ item: ExerciseItem) {
        recentManager.addRecent(item)
        onSelection(item)
        dismiss()
    }
}

#Preview("Exercise Picker", traits: .sampleData) {
    ExercisePicker(selectedExercise: .constant(nil)) { selected in
        print("Selected: \(selected.name)")
    }
}