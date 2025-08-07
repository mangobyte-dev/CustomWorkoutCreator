# Exercise Model Refactoring Plan

**Created:** August 5, 2025  
**Status:** Planning Phase

## Overview
This document outlines the comprehensive plan to refactor Exercise from an embedded model to a standalone library item with multimedia support. The current Exercise will be renamed to IntervalExercise (keeping workout-specific data), and a new simplified Exercise model will be created with just id, name, and gifUrl.

## Architecture Changes

### Current State
```swift
@Model Exercise {
    // All properties mixed together
    var id: UUID
    var name: String
    var trainingMethod: TrainingMethod
    var effort: Int
    var weight: Double?
    var restAfter: Int?
    var tempo: Tempo?
    var notes: String?
}

Workout → Interval → [Exercise]
```

### Target State
```swift
@Model Exercise {
    // Simplified library item
    var id: UUID
    var name: String
    var gifUrl: String?
}

@Model IntervalExercise {
    // Workout-specific data
    var exercise: Exercise
    var effort: Int
    var weight: Double?
    var restAfter: Int?
    var tempo: Tempo?
    var notes: String?
    var trainingMethod: TrainingMethod
}

Workout → Interval → [IntervalExercise] → Exercise
```

## Key Changes Summary
1. **Rename**: Current Exercise → IntervalExercise (keeps effort, weight, reps, etc.)
2. **Create**: New Exercise model with only id, name, gifUrl
3. **Relationship**: Interval → IntervalExercise → Exercise
4. **Add**: AsyncImage support for exercise GIFs
5. **Migrate**: Existing data with zero loss

## Files Affected (14 total)

### Core Model Files
1. `/DataModels.swift` - Add new models, rename existing
2. `/ExerciseLibraryModels.swift` - Remove/integrate with main models
3. `/ExerciseStore.swift` - Update for new model structure
4. `/ExerciseMigrationHelper.swift` - Update migration logic

### UI Components
5. `/Views/ExerciseCard.swift` - Support both models during transition
6. `/Views/IntervalCard.swift` - Use IntervalExercise relationships
7. `/Views/WorkoutDetailView.swift` - Display new relationships
8. `/Views/WorkoutFormView.swift` - Add exercise picker
9. `/Views/WorkoutDetailViewCache.swift` - Update caching logic

### Preview & Test Files
10. `/Preview/PreviewData.swift` - New model preview data
11. `/Preview/PreviewModifier.swift` - Register new models
12. `/Preview/PreviewContainer.swift` - Update container setup
13. `/CustomWorkoutCreatorTests.swift` - Update tests

### App Configuration
14. `/CustomWorkoutCreatorApp.swift` - ModelContainer registration

## Implementation Phases

### Phase 1: Model Foundation (8 steps, ~45 min)

#### Step 1: Update DataModels.swift - Add IntervalExercise Model (5 min)
```swift
@Model
class IntervalExercise: Hashable, Comparable {
    var id = UUID()
    var orderIndex: Int = 0
    
    // Workout-specific values
    var effort: Int = 7
    var weight: Double?
    var restAfter: Int?
    var tempo: Tempo?
    var notes: String?
    
    // TrainingMethod storage (same pattern as current Exercise)
    private var methodType: String = "standard"
    private var minReps: Int = 10
    private var maxReps: Int = 10
    // ... rest of decomposed storage
    
    // Relationships
    var interval: Interval?
    var exercise: Exercise?
    
    // ... implementation
}
```

#### Step 2: Create New Standalone Exercise Model (5 min)
```swift
@Model
class Exercise: Hashable, Comparable {
    var id = UUID()
    var name: String = ""
    var gifUrl: String?
    
    // Metadata
    var isCustom: Bool = true
    var createdDate: Date = Date()
    var lastUsedDate: Date?
    var useCount: Int = 0
    
    // Relationship
    @Relationship(inverse: \IntervalExercise.exercise)
    var intervalExercises: [IntervalExercise] = []
}
```

#### Step 3: Move Current Exercise to LegacyExercise (5 min)
- Rename current Exercise class to OldExercise
- Create typealias: `typealias LegacyExercise = OldExercise`

#### Step 4: Update Interval Model Relationships (5 min)
```swift
// In Interval class
@Relationship(deleteRule: .cascade) var intervalExercises: [IntervalExercise] = []

// Computed property for compatibility
var exercises: [LegacyExercise] {
    // Temporary compatibility layer
    return []
}
```

#### Steps 5-8: ModelContainer Updates, Migration Helpers, Testing

### Phase 2: Exercise Library Infrastructure (4 steps, ~25 min)

#### Step 9: Create ExerciseStore (8 min)
```swift
@Observable
final class ExerciseStore {
    private let modelContainer: ModelContainer
    
    func createExercise(name: String, gifUrl: String? = nil) -> Exercise
    func getAllExercises() -> [Exercise]
    func searchExercises(query: String) -> [Exercise]
    func createDefaultExercises()
}
```

#### Step 10: Update PreviewModifier (5 min)
- Add ExerciseStore to environment
- Register new models in ModelContainer

#### Step 11: Create Sample Exercise Data (5 min)
```swift
extension Exercise {
    static let previewPushups = Exercise(
        name: "Push-ups",
        gifUrl: "https://example.com/pushups.gif"
    )
    // ... more preview data
}
```

#### Step 12: Test Store Integration (3 min)

### Phase 3: UI Component Updates (8 steps, ~55 min)

#### Step 13: Update ExerciseCard for Dual Support (6 min)
```swift
struct ExerciseCard: View {
    private let legacyExercise: LegacyExercise?
    private let intervalExercise: IntervalExercise?
    
    // Computed properties for unified access
    private var exerciseName: String { /* ... */ }
    private var gifUrl: String? { /* ... */ }
    
    // Two initializers for transition period
    init(exercise: LegacyExercise)
    init(intervalExercise: IntervalExercise)
}
```

#### Step 14: Add AsyncImage Support (8 min)
```swift
// In ExerciseCard body
if let gifUrl = exerciseGifUrl, !gifUrl.isEmpty {
    AsyncImage(url: URL(string: gifUrl)) { image in
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 120)
            .cornerRadius(8)
    } placeholder: {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 120)
            .overlay(ProgressView())
    }
}
```

#### Step 15: Update IntervalCard (6 min)
```swift
// Update to use IntervalExercise relationships
ForEach(interval.intervalExercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { intervalExercise in
    ExerciseCard(intervalExercise: intervalExercise)
}
```

#### Step 16: Create ExerciseSelectionView (10 min)
- Search functionality
- AsyncImage previews
- Multi-selection support
- Integration with WorkoutFormView

#### Steps 17-20: Additional UI Updates

### Phase 4: Data Migration Implementation (8 steps, ~50 min)

#### Step 21: Create MigrationService (10 min)
```swift
@Observable
final class MigrationService {
    var migrationProgress: Double = 0.0
    var migrationStatus: String = "Ready"
    var isMigrating: Bool = false
    
    func performMigration() async
    func rollbackMigration() async
}
```

#### Step 22: Create Migration UI (8 min)
- Progress indicator
- Status messages
- Migration benefits display

#### Step 23: Add Migration Check on Launch (6 min)
```swift
// In CustomWorkoutCreatorApp
@State private var needsMigration = false

var body: some Scene {
    WindowGroup {
        if needsMigration {
            MigrationView()
        } else {
            ContentView()
        }
    }
}
```

#### Steps 24-28: Rollback, Validation, Testing

### Phase 5: Preview & Testing Updates (6 steps, ~35 min)

#### Step 29: Update PreviewData (6 min)
- Replace Exercise previews with IntervalExercise
- Update Interval preview data
- Maintain backwards compatibility

#### Step 30: Update PreviewModifier Sample Data (5 min)
- Create sample exercises
- Link with intervals
- Test preview stability

#### Steps 31-34: Preview Updates and Testing

### Phase 6: Final Integration (6 steps, ~40 min)

#### Step 35: Update All ModelContainer References (5 min)
#### Step 36: Add Exercise Library Navigation (3 min)
#### Step 37: Create AsyncImage Loading States (6 min)
#### Step 38: Performance Testing (8 min)
#### Step 39: Data Integrity Testing (8 min)
#### Step 40: End-to-End Testing (10 min)

## Migration Strategy

### Data Flow
1. Fetch all legacy exercises
2. Group by name to create unique Exercise library
3. Create IntervalExercise for each legacy instance
4. Update Interval relationships
5. Clean up legacy data (keep for rollback)

### Rollback Plan
1. Remove IntervalExercise entities
2. Restore legacy relationships
3. Clean up Exercise library
4. Revert UI changes

## Risk Mitigation

### Data Loss Prevention
- Comprehensive migration testing
- Backup mechanisms
- Rollback capability
- Data validation checks

### Performance Considerations
- Lazy loading for AsyncImage
- Efficient relationship queries
- Pre-computed search indexes
- Caching for frequently used exercises

### UI Complexity
- Progressive enhancement
- Maintain current workflow
- Clear loading states
- Helpful error messages

## Success Criteria

1. **Zero Data Loss**: All workouts preserved
2. **Performance**: No degradation in app speed
3. **Feature Parity**: All current features work
4. **New Features**: Exercise library and GIFs functional
5. **Stable Previews**: No SwiftData crashes

## Benefits

1. **Exercise Library**: Reusable across workouts
2. **Form Guides**: GIF demonstrations
3. **Better Organization**: Centralized management
4. **Search & Filter**: Quick discovery
5. **Usage Tracking**: Popular/recent exercises
6. **Future Ready**: Foundation for sharing, categories, etc.

## Timeline

- Phase 1: 45 minutes
- Phase 2: 25 minutes  
- Phase 3: 55 minutes
- Phase 4: 50 minutes
- Phase 5: 35 minutes
- Phase 6: 40 minutes

**Total: 4-5 hours of focused development**

## Next Steps

1. Review and approve plan
2. Create feature branch
3. Begin Phase 1 implementation
4. Test incrementally
5. Deploy with confidence

---

*This plan was created with input from project-orchestrator, refactoring-architect, and swiftui-architecture-specialist agents to ensure comprehensive coverage of all technical aspects.*