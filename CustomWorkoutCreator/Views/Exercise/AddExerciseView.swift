//
//  AddExerciseView.swift
//  CustomWorkoutCreator
//
//  Created by Claude Code on 2025-08-07.
//

import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Observable Model for Form State
@Observable
final class AddExerciseFormModel {
    var exerciseName = ""
    var notes = ""
    var selectedCategory = "Other"
    var selectedPhotoItem: PhotosPickerItem?
    var selectedPhotoData: Data?
    var isLoadingPhoto = false
    var showingDuplicateAlert = false
    var duplicateExerciseName = ""
    
    // Pre-computed validation
    var isNameValid: Bool {
        !exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var canSave: Bool {
        isNameValid && !isLoadingPhoto
    }
    
    func reset() {
        exerciseName = ""
        notes = ""
        selectedCategory = "Other"
        selectedPhotoItem = nil
        selectedPhotoData = nil
        isLoadingPhoto = false
        showingDuplicateAlert = false
        duplicateExerciseName = ""
    }
}

// MARK: - Main View
struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExerciseItem.name) private var existingExercises: [ExerciseItem]
    
    @State private var model = AddExerciseFormModel()
    @FocusState private var focusedField: Field?
    
    private enum Field: Hashable {
        case name, notes
    }
    
    var body: some View {
        NavigationStack {
            formContent
                .navigationTitle("Add Exercise")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .alert("Duplicate Exercise", isPresented: $model.showingDuplicateAlert) {
                    duplicateAlert
                }
        }
        .onAppear {
            focusedField = .name
        }
        .onChange(of: model.selectedPhotoItem) { _, newItem in
            loadSelectedPhoto(newItem)
        }
    }
    
    // MARK: - ViewBuilder Components
    
    @ViewBuilder
    private var formContent: some View {
        Form {
            nameSection
            notesSection
            categorySection
            photoSection
        }
        .onSubmit {
            handleSubmit()
        }
    }
    
    @ViewBuilder
    private var nameSection: some View {
        Section {
            TextField("Exercise Name", text: $model.exerciseName)
                .focused($focusedField, equals: .name)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
        } header: {
            Text("Exercise Details")
        } footer: {
            nameValidationFooter
        }
    }
    
    @ViewBuilder
    private var nameValidationFooter: some View {
        if !model.exerciseName.isEmpty && !model.isNameValid {
            Text("Please enter a valid exercise name")
                .foregroundStyle(.red)
        }
    }
    
    @ViewBuilder
    private var notesSection: some View {
        Section {
            TextField("Optional description or notes", text: $model.notes, axis: .vertical)
                .focused($focusedField, equals: .notes)
                .textInputAutocapitalization(.sentences)
                .lineLimit(3...6)
        } header: {
            Text("Notes (Optional)")
        }
    }
    
    @ViewBuilder
    private var categorySection: some View {
        Section {
            Picker("Category", selection: $model.selectedCategory) {
                ForEach(exerciseCategories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text("Category")
        }
    }
    
    @ViewBuilder
    private var photoSection: some View {
        Section {
            photoSelectionRow
            if let photoData = model.selectedPhotoData {
                selectedPhotoPreview(photoData)
            }
        } header: {
            Text("Photo (Optional)")
        } footer: {
            Text("Add a custom photo to help identify this exercise")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var photoSelectionRow: some View {
        HStack {
            Image(systemName: "camera")
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)
            
            Text("Add Photo")
                .foregroundStyle(.blue)
            
            Spacer()
            
            PhotosPicker(
                selection: $model.selectedPhotoItem,
                matching: .images
            ) {
                Text(model.selectedPhotoData == nil ? "Choose" : "Change")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            
            if model.isLoadingPhoto {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
    
    @ViewBuilder
    private func selectedPhotoPreview(_ photoData: Data) -> some View {
        VStack(spacing: 8) {
            if let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Button("Remove Photo") {
                removeSelectedPhoto()
            }
            .font(.footnote)
            .foregroundStyle(.red)
        }
    }
    
    @ViewBuilder
    private var duplicateAlert: some View {
        Button("Cancel", role: .cancel) { }
        Button("Add Anyway") {
            saveExercise()
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                handleSave()
            }
            .disabled(!model.canSave)
        }
        
        ToolbarItem(placement: .keyboard) {
            keyboardToolbar
        }
    }
    
    @ViewBuilder
    private var keyboardToolbar: some View {
        HStack {
            Spacer()
            Button("Done") {
                focusedField = nil
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var exerciseCategories: [String] {
        [
            "Chest", "Back", "Shoulders", "Arms", "Legs", 
            "Glutes", "Core", "Cardio", "Flexibility", "Other"
        ]
    }
    
    // MARK: - Actions
    
    private func handleSubmit() {
        switch focusedField {
        case .name:
            focusedField = .notes
        case .notes:
            focusedField = nil
        case .none:
            break
        }
    }
    
    private func handleSave() {
        let trimmedName = model.exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for duplicates
        if existingExercises.contains(where: { $0.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame }) {
            model.duplicateExerciseName = trimmedName
            model.showingDuplicateAlert = true
        } else {
            saveExercise()
        }
    }
    
    private func saveExercise() {
        let trimmedName = model.exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = model.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Save photo to documents directory if provided
        var photoFileName: String? = nil
        if let photoData = model.selectedPhotoData {
            photoFileName = savePhotoToDocuments(photoData, exerciseName: trimmedName)
        }
        
        // Create new exercise item
        let newExercise = ExerciseItem(
            name: trimmedName,
            gifUrl: photoFileName // Store the local filename instead of a URL
        )
        
        // Add notes as a property if we extend the model in the future
        // For now, we could store it in a separate notes system or extend ExerciseItem
        
        modelContext.insert(newExercise)
        
        do {
            try modelContext.save()
            print("✅ Successfully saved custom exercise: '\(trimmedName)'")
            dismiss()
        } catch {
            print("❌ Error saving exercise: \(error)")
            // In a production app, you'd show an error alert here
        }
    }
    
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) {
        guard let item else {
            model.selectedPhotoData = nil
            return
        }
        
        model.isLoadingPhoto = true
        
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        model.selectedPhotoData = data
                        model.isLoadingPhoto = false
                    }
                }
            } catch {
                await MainActor.run {
                    print("❌ Error loading photo: \(error)")
                    model.selectedPhotoData = nil
                    model.isLoadingPhoto = false
                }
            }
        }
    }
    
    private func removeSelectedPhoto() {
        model.selectedPhotoItem = nil
        model.selectedPhotoData = nil
    }
    
    private func savePhotoToDocuments(_ photoData: Data, exerciseName: String) -> String? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let documentsDirectory else { return nil }
        
        // Create a safe filename from the exercise name with custom prefix
        let safeFileName = exerciseName
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
            .lowercased()
        
        let fileName = "\(safeFileName)_custom_\(UUID().uuidString.prefix(8)).jpg"
        let fileURL = documentsDirectory.appendingPathComponent("custom_exercises").appendingPathComponent(fileName)
        
        do {
            // Create custom exercises directory if it doesn't exist
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            // Optimize image data for storage
            if let image = UIImage(data: photoData),
               let compressedData = image.jpegData(compressionQuality: 0.8) {
                try compressedData.write(to: fileURL)
            } else {
                try photoData.write(to: fileURL)
            }
            
            print("✅ Saved custom exercise photo: \(fileName)")
            return fileName
        } catch {
            print("❌ Error saving photo: \(error)")
            return nil
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AddExerciseView()
    }
    .modelContainer(for: ExerciseItem.self, inMemory: true)
}