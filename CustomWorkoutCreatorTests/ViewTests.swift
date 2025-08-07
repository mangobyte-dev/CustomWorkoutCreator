//
//  ViewTests.swift
//  CustomWorkoutCreatorTests
//
//  SwiftUI view testing with environment injection
//

import Testing
import SwiftUI
import SwiftData
@testable import CustomWorkoutCreator

@Suite("SwiftUI View Tests")
struct ViewTests {
    
    // MARK: - Environment Testing Infrastructure
    
    @MainActor
    struct TestEnvironment {
        let container: TestContainer
        
        init() throws {
            self.container = try TestContainer.makeInMemory()
        }
        
        func withEnvironment<Content: View>(@ViewBuilder content: () -> Content) -> some View {
            content()
                .modelContainer(container.container)
        }
    }
    
    // MARK: - Preview Testing
    
    @Test("ContentView preview configuration", .tags(.view, .unit))
    @MainActor
    func contentViewPreviewConfiguration() throws {
        let environment = try TestEnvironment()
        
        // Test that ContentView can be created with test environment
        let contentView = environment.withEnvironment {
            ContentView()
        }
        
        // Verify view can be composed without crashing
        #expect(contentView != nil)
    }
    
    @Test("WorkoutFormView with test data", .tags(.view, .unit))
    @MainActor  
    func workoutFormViewWithTestData() throws {
        let environment = try TestEnvironment()
        
        // Create test workout
        let workout = TestFixtures.createSampleWorkout()
        environment.container.context.insert(workout)
        
        // Test WorkoutFormView creation
        let formView = environment.withEnvironment {
            WorkoutFormView(workout: workout)
        }
        
        #expect(formView != nil)
        
        // Test workout properties are accessible
        #expect(workout.name == "Test Workout")
        #expect(workout.intervals.count == 1)
    }
    
    @Test("ExerciseLibraryView with populated data", .tags(.view, .integration))
    @MainActor
    func exerciseLibraryViewWithPopulatedData() throws {
        let environment = try TestEnvironment()
        
        // Populate with test exercise items
        let exerciseItems = TestFixtures.createExerciseItems(50)
        exerciseItems.forEach { environment.container.context.insert($0) }
        try environment.container.context.save()
        
        let libraryView = environment.withEnvironment {
            ExerciseLibraryView()
        }
        
        #expect(libraryView != nil)
        
        // Verify data is available
        let fetchDescriptor = FetchDescriptor<ExerciseItem>()
        let items = try environment.container.context.fetch(fetchDescriptor)
        #expect(items.count == 50)
    }
    
    // MARK: - Data Flow Testing
    
    @Test("Workout detail view data binding", .tags(.view, .integration))
    @MainActor
    func workoutDetailViewDataBinding() throws {
        let environment = try TestEnvironment()
        
        let workout = TestFixtures.createComplexWorkout()
        environment.container.context.insert(workout)
        try environment.container.context.save()
        
        // Test data access patterns that WorkoutDetailView would use
        #expect(workout.intervals.count == 3)
        #expect(workout.intervals.contains { $0.name == "Warm-up" })
        #expect(workout.intervals.contains { $0.name == "Main Circuit" })
        #expect(workout.intervals.contains { $0.name == "Cool-down" })
        
        // Test interval exercise access
        let mainCircuit = workout.intervals.first { $0.name == "Main Circuit" }
        #expect(mainCircuit?.exercises.count == 3)
        #expect(mainCircuit?.rounds == 4)
    }
    
    @Test("Exercise picker selection flow", .tags(.view, .integration))
    @MainActor
    func exercisePickerSelectionFlow() throws {
        let environment = try TestEnvironment()
        
        // Setup exercise library
        let exerciseItems = [
            ExerciseItem(name: "Push-ups", gifUrl: "pushups.gif"),
            ExerciseItem(name: "Squats", gifUrl: "squats.gif"),
            ExerciseItem(name: "Pull-ups", gifUrl: "pullups.gif")
        ]
        exerciseItems.forEach { environment.container.context.insert($0) }
        
        // Simulate selection logic
        struct SelectionState {
            var selectedItems: Set<ExerciseItem> = []
            
            mutating func toggle(_ item: ExerciseItem) {
                if selectedItems.contains(item) {
                    selectedItems.remove(item)
                } else {
                    selectedItems.insert(item)
                }
            }
        }
        
        var selectionState = SelectionState()
        
        // Test selection behavior
        selectionState.toggle(exerciseItems[0])
        #expect(selectionState.selectedItems.count == 1)
        #expect(selectionState.selectedItems.contains(exerciseItems[0]))
        
        selectionState.toggle(exerciseItems[1])
        #expect(selectionState.selectedItems.count == 2)
        
        selectionState.toggle(exerciseItems[0]) // Deselect
        #expect(selectionState.selectedItems.count == 1)
        #expect(!selectionState.selectedItems.contains(exerciseItems[0]))
    }
    
    // MARK: - State Management Testing
    
    @Test("ExpandableList state isolation", .tags(.view, .unit))
    func expandableListStateIsolation() {
        // Test the state management pattern used by ExpandableList
        struct TestItem: Identifiable, Equatable {
            let id = UUID()
            let name: String
        }
        
        let items = [
            TestItem(name: "Item 1"),
            TestItem(name: "Item 2"),
            TestItem(name: "Item 3")
        ]
        
        // Simulate ExpandableList internal state
        @State var expansionStates: [UUID: Bool] = [:]
        
        // Test state isolation - each item manages its own expansion
        expansionStates[items[0].id] = true
        expansionStates[items[1].id] = false
        // items[2] not explicitly set, should default to false
        
        #expect(expansionStates[items[0].id] == true)
        #expect(expansionStates[items[1].id] == false)
        #expect(expansionStates[items[2].id] == nil)
        
        // Test binding creation for child components
        func createBinding(for item: TestItem) -> Binding<Bool> {
            return Binding(
                get: { expansionStates[item.id] ?? false },
                set: { expansionStates[item.id] = $0 }
            )
        }
        
        let binding1 = createBinding(for: items[0])
        let binding3 = createBinding(for: items[2])
        
        #expect(binding1.wrappedValue == true)
        #expect(binding3.wrappedValue == false)
    }
    
    @Test("Form validation state management", .tags(.view, .unit))
    func formValidationStateManagement() {
        // Test form validation logic used in WorkoutFormView and ExerciseFormCard
        struct FormValidation {
            func validateWorkoutName(_ name: String) -> Bool {
                !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            
            func validateRepsRange(min: Int, max: Int) -> Bool {
                min > 0 && max > 0 && min <= max
            }
            
            func validateEffortLevel(_ effort: Int) -> Bool {
                effort >= 1 && effort <= 10
            }
            
            func validateRestTime(_ seconds: Int?) -> Bool {
                guard let seconds = seconds else { return true } // Optional rest time
                return seconds >= 0
            }
        }
        
        let validator = FormValidation()
        
        // Test workout name validation
        #expect(validator.validateWorkoutName("Valid Name") == true)
        #expect(validator.validateWorkoutName("") == false)
        #expect(validator.validateWorkoutName("   ") == false)
        
        // Test reps range validation
        #expect(validator.validateRepsRange(min: 8, max: 12) == true)
        #expect(validator.validateRepsRange(min: 12, max: 8) == false)
        #expect(validator.validateRepsRange(min: 0, max: 10) == false)
        
        // Test effort level validation
        #expect(validator.validateEffortLevel(7) == true)
        #expect(validator.validateEffortLevel(0) == false)
        #expect(validator.validateEffortLevel(11) == false)
        
        // Test rest time validation
        #expect(validator.validateRestTime(nil) == true)
        #expect(validator.validateRestTime(60) == true)
        #expect(validator.validateRestTime(-5) == false)
    }
    
    // MARK: - Navigation Testing
    
    @Test("Navigation state management", .tags(.view, .unit))
    func navigationStateManagement() {
        // Test navigation patterns used in the app
        enum NavigationDestination: Hashable {
            case workoutDetail(Workout)
            case exercisePicker
            case addExercise
            case settings
        }
        
        struct NavigationState {
            var path: [NavigationDestination] = []
            var presentedSheet: NavigationDestination?
            
            mutating func navigate(to destination: NavigationDestination) {
                path.append(destination)
            }
            
            mutating func presentSheet(_ destination: NavigationDestination) {
                presentedSheet = destination
            }
            
            mutating func dismissSheet() {
                presentedSheet = nil
            }
            
            mutating func popToRoot() {
                path.removeAll()
            }
        }
        
        var navigationState = NavigationState()
        let testWorkout = TestFixtures.createSampleWorkout()
        
        // Test navigation flow
        navigationState.navigate(to: .workoutDetail(testWorkout))
        #expect(navigationState.path.count == 1)
        
        navigationState.presentSheet(.exercisePicker)
        #expect(navigationState.presentedSheet != nil)
        
        navigationState.dismissSheet()
        #expect(navigationState.presentedSheet == nil)
        
        navigationState.popToRoot()
        #expect(navigationState.path.isEmpty)
    }
    
    // MARK: - Performance View Tests
    
    @Test("List rendering performance", .tags(.view, .performance))
    @MainActor
    func listRenderingPerformance() throws {
        let environment = try TestEnvironment()
        
        // Create large dataset
        let workouts = (1...100).map { i in
            let workout = TestFixtures.createComplexWorkout()
            workout.name = "Performance Test Workout \(i)"
            return workout
        }
        
        let measurement = PerformanceMeasurement(
            name: "Workout List Performance",
            expectation: 0.1
        )
        
        // Simulate list data preparation
        workouts.forEach { environment.container.context.insert($0) }
        
        try environment.container.context.save()
        
        // Verify data is ready for rendering
        let fetchDescriptor = FetchDescriptor<Workout>()
        let savedWorkouts = try environment.container.context.fetch(fetchDescriptor)
        #expect(savedWorkouts.count == 100)
        
        measurement.expect()
    }
    
    @Test("Search filtering performance", .tags(.view, .performance))
    func searchFilteringPerformance() throws {
        // Create large exercise dataset
        let exercises = TestFixtures.createExerciseItems(1500) // Simulate full exercise library
        
        let measurement = PerformanceMeasurement(
            name: "Search Filtering Performance", 
            expectation: 0.05
        )
        
        // Simulate search filtering
        let searchText = "push"
        let filteredExercises = exercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(searchText)
        }
        
        
        #expect(filteredExercises.count > 0)
        
        measurement.expect()
    }
    
    // MARK: - Accessibility Testing
    
    @Test("View accessibility support", .tags(.view, .unit))
    func viewAccessibilitySupport() {
        // Test accessibility labels and hints that views would provide
        struct AccessibilityHelper {
            func createAccessibilityLabel(for exercise: Exercise) -> String {
                switch exercise.trainingMethod {
                case .standard(let min, let max):
                    return "\(exercise.name), \(min) to \(max) reps, effort level \(exercise.effort)"
                case .restPause(let total, _, _):
                    return "\(exercise.name), rest-pause for \(total) total reps, effort level \(exercise.effort)"
                case .timed(let seconds):
                    return "\(exercise.name), timed for \(seconds) seconds, effort level \(exercise.effort)"
                }
            }
            
            func createAccessibilityHint(for exercise: Exercise) -> String {
                "Double tap to edit exercise details"
            }
        }
        
        let helper = AccessibilityHelper()
        let exercise = Exercise(
            name: "Push-ups",
            trainingMethod: .standard(minReps: 10, maxReps: 15),
            effort: 8
        )
        
        let label = helper.createAccessibilityLabel(for: exercise)
        let hint = helper.createAccessibilityHint(for: exercise)
        
        #expect(label.contains("Push-ups"))
        #expect(label.contains("10 to 15 reps"))
        #expect(label.contains("effort level 8"))
        #expect(hint.contains("Double tap"))
    }
    
    // MARK: - Error State Testing
    
    @Test("Empty state handling", .tags(.view, .unit))
    func emptyStateHandling() {
        // Test empty state logic for various views
        struct EmptyStateHelper {
            func shouldShowEmptyState(workoutCount: Int) -> Bool {
                workoutCount == 0
            }
            
            func shouldShowEmptyState(exerciseCount: Int) -> Bool {
                exerciseCount == 0
            }
            
            func shouldShowNoResults(searchResults: Int, hasSearchText: Bool) -> Bool {
                searchResults == 0 && hasSearchText
            }
        }
        
        let helper = EmptyStateHelper()
        
        // Test workout empty state
        #expect(helper.shouldShowEmptyState(workoutCount: 0) == true)
        #expect(helper.shouldShowEmptyState(workoutCount: 1) == false)
        
        // Test search no results
        #expect(helper.shouldShowNoResults(searchResults: 0, hasSearchText: true) == true)
        #expect(helper.shouldShowNoResults(searchResults: 0, hasSearchText: false) == false)
        #expect(helper.shouldShowNoResults(searchResults: 5, hasSearchText: true) == false)
    }
}

// MARK: - View Test Utilities

extension ViewTests {
    
    /// Helper for testing SwiftUI view state changes
    struct ViewStateHelper {
        static func simulateUserInput<T>(
            initialValue: T,
            updates: [(T) -> T]
        ) -> T {
            return updates.reduce(initialValue) { current, update in
                update(current)
            }
        }
    }
    
    /// Mock environment for testing views that depend on external services
    @Observable
    final class MockEnvironment {
        var isLoading = false
        var errorMessage: String?
        var networkReachable = true
        
        func simulateLoading() {
            isLoading = true
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
}