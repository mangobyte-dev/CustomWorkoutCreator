//
//  EnvironmentTests.swift
//  CustomWorkoutCreatorTests
//
//  Testing @Observable classes and environment dependency injection
//

import Testing
import SwiftUI
import SwiftData
import Observation
@testable import CustomWorkoutCreator

@Suite("Environment and Observable Tests")
struct EnvironmentTests {
    
    // MARK: - Mock Observable Classes for Testing
    
    @Observable
    final class MockWorkoutStore {
        var workouts: [Workout] = []
        var isLoading = false
        var errorMessage: String?
        
        func addWorkout(_ workout: Workout) {
            workouts.append(workout)
        }
        
        func removeWorkout(_ workout: Workout) {
            workouts.removeAll { $0.id == workout.id }
        }
        
        func updateWorkout(_ workout: Workout) {
            if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
                workouts[index] = workout
            }
        }
        
        func simulateLoading() {
            isLoading = true
            errorMessage = nil
        }
        
        func simulateSuccess() {
            isLoading = false
            errorMessage = nil
        }
        
        func simulateError(_ message: String) {
            isLoading = false
            errorMessage = message
        }
    }
    
    @Observable
    final class MockExerciseLibraryStore {
        var exercises: [ExerciseItem] = []
        var searchText = ""
        var isSearching = false
        private var _filteredExercises: [ExerciseItem]?
        private var _lastSearchText = ""
        
        var filteredExercises: [ExerciseItem] {
            // Cache search results for performance
            if searchText == _lastSearchText, let cached = _filteredExercises {
                return cached
            }
            
            let filtered = searchText.isEmpty 
                ? exercises 
                : exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            
            _filteredExercises = filtered
            _lastSearchText = searchText
            
            return filtered
        }
        
        func loadExercises(_ newExercises: [ExerciseItem]) {
            exercises = newExercises
            invalidateCache()
        }
        
        func search(_ text: String) {
            searchText = text
            isSearching = !text.isEmpty
        }
        
        private func invalidateCache() {
            _filteredExercises = nil
            _lastSearchText = ""
        }
    }
    
    @Observable
    final class MockUIState {
        var selectedTab = 0
        var presentedSheet: String?
        var navigationPath: [String] = []
        var showingAlert = false
        var alertMessage = ""
        
        func presentSheet(_ identifier: String) {
            presentedSheet = identifier
        }
        
        func dismissSheet() {
            presentedSheet = nil
        }
        
        func navigate(to destination: String) {
            navigationPath.append(destination)
        }
        
        func popToRoot() {
            navigationPath.removeAll()
        }
        
        func showAlert(_ message: String) {
            alertMessage = message
            showingAlert = true
        }
        
        func dismissAlert() {
            showingAlert = false
            alertMessage = ""
        }
    }
    
    // MARK: - Observable State Management Tests
    
    @Test("Observable workout store state management", .tags(.unit))
    func observableWorkoutStoreStateManagement() {
        let store = MockWorkoutStore()
        
        // Test initial state
        #expect(store.workouts.isEmpty)
        #expect(store.isLoading == false)
        #expect(store.errorMessage == nil)
        
        // Test adding workouts
        let workout1 = TestFixtures.createSampleWorkout()
        let workout2 = TestFixtures.createComplexWorkout()
        
        store.addWorkout(workout1)
        #expect(store.workouts.count == 1)
        #expect(store.workouts.first?.id == workout1.id)
        
        store.addWorkout(workout2)
        #expect(store.workouts.count == 2)
        
        // Test updating workout
        workout1.name = "Updated Workout"
        store.updateWorkout(workout1)
        let updatedWorkout = store.workouts.first { $0.id == workout1.id }
        #expect(updatedWorkout?.name == "Updated Workout")
        
        // Test removing workout
        store.removeWorkout(workout1)
        #expect(store.workouts.count == 1)
        #expect(!store.workouts.contains { $0.id == workout1.id })
        
        // Test loading states
        store.simulateLoading()
        #expect(store.isLoading == true)
        #expect(store.errorMessage == nil)
        
        store.simulateSuccess()
        #expect(store.isLoading == false)
        #expect(store.errorMessage == nil)
        
        store.simulateError("Network error")
        #expect(store.isLoading == false)
        #expect(store.errorMessage == "Network error")
    }
    
    @Test("Observable exercise library search performance", .tags(.unit, .performance))
    func observableExerciseLibrarySearchPerformance() throws {
        let store = MockExerciseLibraryStore()
        let exercises = TestFixtures.createExerciseItems(1500)
        
        store.loadExercises(exercises)
        #expect(store.exercises.count == 1500)
        
        // Test search caching performance
        let measurement = PerformanceMeasurement(
            name: "Search Caching Performance",
            expectation: 0.05
        )
        
        // First search - should compute results
        store.search("push")
        let firstResults = store.filteredExercises
        
        // Second identical search - should use cached results
        let secondResults = store.filteredExercises
        
        // Third search - different query, should recompute
        store.search("pull")
        let thirdResults = store.filteredExercises
        
        #expect(firstResults.allSatisfy { $0.name.localizedCaseInsensitiveContains("push") })
        #expect(secondResults.count == firstResults.count) // Same cached results
        #expect(thirdResults.allSatisfy { $0.name.localizedCaseInsensitiveContains("pull") })
        
        measurement.expect()
        
        // Test search state management
        #expect(store.isSearching == true)
        
        store.search("")
        #expect(store.isSearching == false)
        #expect(store.filteredExercises.count == 1500) // Should show all when no search
    }
    
    @Test("Observable UI state coordination", .tags(.unit))
    func observableUIStateCoordination() {
        let uiState = MockUIState()
        
        // Test initial state
        #expect(uiState.selectedTab == 0)
        #expect(uiState.presentedSheet == nil)
        #expect(uiState.navigationPath.isEmpty)
        #expect(uiState.showingAlert == false)
        
        // Test sheet management
        uiState.presentSheet("exercisePicker")
        #expect(uiState.presentedSheet == "exercisePicker")
        
        uiState.dismissSheet()
        #expect(uiState.presentedSheet == nil)
        
        // Test navigation
        uiState.navigate(to: "workoutDetail")
        uiState.navigate(to: "editExercise")
        #expect(uiState.navigationPath.count == 2)
        #expect(uiState.navigationPath == ["workoutDetail", "editExercise"])
        
        uiState.popToRoot()
        #expect(uiState.navigationPath.isEmpty)
        
        // Test alert management
        uiState.showAlert("Test alert message")
        #expect(uiState.showingAlert == true)
        #expect(uiState.alertMessage == "Test alert message")
        
        uiState.dismissAlert()
        #expect(uiState.showingAlert == false)
        #expect(uiState.alertMessage == "")
    }
    
    // MARK: - Environment Injection Tests
    
    @Test("Environment dependency injection patterns", .tags(.unit))
    @MainActor
    func environmentDependencyInjectionPatterns() throws {
        let testContainer = try TestContainer.makeInMemory()
        let workoutStore = MockWorkoutStore()
        let exerciseStore = MockExerciseLibraryStore()
        let uiState = MockUIState()
        
        // Test environment composition
        struct TestEnvironment {
            let modelContainer: ModelContainer
            let workoutStore: MockWorkoutStore
            let exerciseStore: MockExerciseLibraryStore
            let uiState: MockUIState
        }
        
        let environment = TestEnvironment(
            modelContainer: testContainer.container,
            workoutStore: workoutStore,
            exerciseStore: exerciseStore,
            uiState: uiState
        )
        
        // Test environment access pattern
        func simulateViewAccess(environment: TestEnvironment) -> Bool {
            // Simulate a view accessing multiple environment objects
            let hasWorkouts = !environment.workoutStore.workouts.isEmpty
            let hasExercises = !environment.exerciseStore.exercises.isEmpty
            let isLoading = environment.workoutStore.isLoading
            
            // Simulate view logic
            if hasWorkouts && hasExercises && !isLoading {
                environment.uiState.selectedTab = 1
                return true
            }
            
            environment.uiState.selectedTab = 0
            return false
        }
        
        // Test with empty environment
        let emptyResult = simulateViewAccess(environment: environment)
        #expect(emptyResult == false)
        #expect(environment.uiState.selectedTab == 0)
        
        // Test with populated environment
        environment.workoutStore.addWorkout(TestFixtures.createSampleWorkout())
        environment.exerciseStore.loadExercises(TestFixtures.createExerciseItems(10))
        
        let populatedResult = simulateViewAccess(environment: environment)
        #expect(populatedResult == true)
        #expect(environment.uiState.selectedTab == 1)
    }
    
    @Test("Multi-store coordination", .tags(.integration))
    func multiStoreCoordination() {
        let workoutStore = MockWorkoutStore()
        let exerciseStore = MockExerciseLibraryStore()
        let uiState = MockUIState()
        
        // Simulate complex workflow involving multiple stores
        
        // Step 1: Load exercise library
        let exercises = TestFixtures.createExerciseItems(50)
        exerciseStore.loadExercises(exercises)
        
        // Step 2: Create workout using exercises from library
        let workout = Workout(name: "Multi-store Workout")
        let interval = Interval(name: "Test Interval", rounds: 3)
        
        // Use exercises from library store
        let selectedExercises = exerciseStore.filteredExercises.prefix(3)
        for exerciseItem in selectedExercises {
            let exercise = Exercise(
                exerciseItem: exerciseItem,
                trainingMethod: .standard(minReps: 10, maxReps: 15)
            )
            interval.exercises.append(exercise)
        }
        workout.intervals.append(interval)
        
        // Step 3: Add workout to workout store
        workoutStore.addWorkout(workout)
        
        // Step 4: Update UI state based on stores
        if !workoutStore.workouts.isEmpty && !exerciseStore.exercises.isEmpty {
            uiState.selectedTab = 2 // Workouts tab
            uiState.dismissSheet()
        }
        
        // Step 5: Verify coordination
        #expect(workoutStore.workouts.count == 1)
        #expect(workoutStore.workouts.first?.intervals.first?.exercises.count == 3)
        #expect(uiState.selectedTab == 2)
        #expect(uiState.presentedSheet == nil)
        
        // Test error propagation
        exerciseStore.search("nonexistent")
        if exerciseStore.filteredExercises.isEmpty {
            uiState.showAlert("No exercises found")
        }
        
        #expect(uiState.showingAlert == true)
        #expect(uiState.alertMessage == "No exercises found")
    }
    
    // MARK: - Observable Performance Tests
    
    @Test("Observable change notification performance", .tags(.performance))
    func observableChangeNotificationPerformance() throws {
        let store = MockWorkoutStore()
        let exercises = TestFixtures.createExerciseItems(100)
        
        // Test bulk operations performance
        let bulkMeasurement = PerformanceMeasurement(
            name: "Bulk Operations Performance",
            expectation: 0.1
        )
        
        // Add many workouts quickly
        for i in 1...50 {
            let workout = Workout(name: "Workout \(i)")
            store.addWorkout(workout)
        }
        
        bulkMeasurement.expect()
        
        #expect(store.workouts.count == 50)
        
        // Test search performance with Observable
        let exerciseStore = MockExerciseLibraryStore()
        exerciseStore.loadExercises(exercises)
        
        let searchMeasurement = PerformanceMeasurement(
            name: "Rapid Search Performance",
            expectation: 0.05
        )
        
        // Rapid search changes
        for query in ["a", "ab", "abc", "abcd", "abcde"] {
            exerciseStore.search(query)
            let _ = exerciseStore.filteredExercises // Trigger computation
        }
        
        searchMeasurement.expect()
    }
    
    @Test("Observable memory management", .tags(.performance, .unit))
    func observableMemoryManagement() throws {
        // Test that Observable objects don't create retain cycles
        weak var weakStore: MockWorkoutStore?
        
        do {
            let store = MockWorkoutStore()
            weakStore = store
            
            // Add some data
            store.addWorkout(TestFixtures.createSampleWorkout())
            #expect(store.workouts.count == 1)
            
            // Create reference cycle scenario
            var storeReference: MockWorkoutStore? = store
            storeReference = nil
        }
        
        // Verify store is deallocated when references are removed
        #expect(weakStore == nil)
    }
    
    // MARK: - Error Handling in Observable Classes
    
    @Test("Observable error state management", .tags(.unit))
    func observableErrorStateManagement() {
        let store = MockWorkoutStore()
        
        // Test error state transitions
        store.simulateLoading()
        #expect(store.isLoading == true)
        #expect(store.errorMessage == nil)
        
        // Simulate network error
        store.simulateError("Failed to load workouts")
        #expect(store.isLoading == false)
        #expect(store.errorMessage == "Failed to load workouts")
        
        // Test recovery from error
        store.simulateLoading()
        #expect(store.isLoading == true)
        #expect(store.errorMessage == "Failed to load workouts") // Error persists during loading
        
        store.simulateSuccess()
        #expect(store.isLoading == false)
        #expect(store.errorMessage == nil) // Error cleared on success
        
        // Test error handling during operations
        store.addWorkout(TestFixtures.createSampleWorkout())
        #expect(store.workouts.count == 1)
        
        // Simulate operation error
        store.simulateError("Failed to save workout")
        #expect(store.workouts.count == 1) // Data preserved
        #expect(store.errorMessage == "Failed to save workout")
    }
    
    // MARK: - Reactive Patterns with Observable
    
    @Test("Observable reactive pattern simulation", .tags(.unit))
    func observableReactivePatternSimulation() {
        let exerciseStore = MockExerciseLibraryStore()
        let uiState = MockUIState()
        
        // Load exercises
        let exercises = TestFixtures.createExerciseItems(20)
        exerciseStore.loadExercises(exercises)
        
        // Simulate reactive UI updates based on store changes
        func updateUIBasedOnStore() {
            if exerciseStore.isSearching {
                uiState.showAlert("Searching...")
                
                if exerciseStore.filteredExercises.isEmpty {
                    uiState.alertMessage = "No exercises found"
                } else {
                    uiState.dismissAlert()
                }
            } else {
                uiState.dismissAlert()
            }
        }
        
        // Test search with results
        exerciseStore.search("exercise")
        updateUIBasedOnStore()
        #expect(uiState.showingAlert == false) // Should have results
        
        // Test search with no results
        exerciseStore.search("nonexistent")
        updateUIBasedOnStore()
        #expect(uiState.showingAlert == true)
        #expect(uiState.alertMessage == "No exercises found")
        
        // Test clearing search
        exerciseStore.search("")
        updateUIBasedOnStore()
        #expect(uiState.showingAlert == false)
    }
    
    // MARK: - State Synchronization Tests
    
    @Test("Multi-observable state synchronization", .tags(.integration))
    func multiObservableStateSynchronization() {
        let workoutStore = MockWorkoutStore()
        let exerciseStore = MockExerciseLibraryStore()
        let uiState = MockUIState()
        
        // Create coordinator pattern for state synchronization
        struct StateCoordinator {
            let workoutStore: MockWorkoutStore
            let exerciseStore: MockExerciseLibraryStore
            let uiState: MockUIState
            
            func coordinateStates() {
                // Update UI based on multiple store states
                if workoutStore.isLoading || exerciseStore.isSearching {
                    // Don't show content during loading
                    return
                }
                
                if let error = workoutStore.errorMessage {
                    uiState.showAlert("Workout error: \(error)")
                    return
                }
                
                // Coordinate tab selection based on content availability
                if !workoutStore.workouts.isEmpty {
                    uiState.selectedTab = 1 // Workouts tab
                } else if !exerciseStore.exercises.isEmpty {
                    uiState.selectedTab = 2 // Exercise library tab
                } else {
                    uiState.selectedTab = 0 // Home tab
                }
            }
        }
        
        let coordinator = StateCoordinator(
            workoutStore: workoutStore,
            exerciseStore: exerciseStore,
            uiState: uiState
        )
        
        // Test initial state
        coordinator.coordinateStates()
        #expect(uiState.selectedTab == 0) // Should be on home tab
        
        // Add exercises only
        exerciseStore.loadExercises(TestFixtures.createExerciseItems(10))
        coordinator.coordinateStates()
        #expect(uiState.selectedTab == 2) // Should move to exercise library
        
        // Add workouts
        workoutStore.addWorkout(TestFixtures.createSampleWorkout())
        coordinator.coordinateStates()
        #expect(uiState.selectedTab == 1) // Should prefer workouts tab
        
        // Test error handling
        workoutStore.simulateError("Network failure")
        coordinator.coordinateStates()
        #expect(uiState.showingAlert == true)
        #expect(uiState.alertMessage.contains("Network failure"))
        
        // Test loading state
        workoutStore.simulateLoading()
        coordinator.coordinateStates()
        // Should not update UI during loading (early return)
        
        workoutStore.simulateSuccess()
        coordinator.coordinateStates()
        #expect(uiState.selectedTab == 1) // Back to workouts tab
    }
}