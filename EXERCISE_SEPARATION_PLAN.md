# Exercise Model Separation & Enhancement Plan

**Created:** August 5, 2025

## Overview

This document outlines the comprehensive plan to refactor Exercise from an embedded model to a standalone SwiftData model with multimedia support and search capabilities.

## Current Architecture Analysis

### Current Structure
```swift
@Model Workout {
    var intervals: [Interval]
}

@Model Interval {
    var exercises: [Exercise]  // Embedded, not standalone
}

struct Exercise: Codable {
    // Basic properties only
    // No multimedia support
    // Not searchable/reusable
}
```

### Limitations
1. **No Reusability**: Exercises recreated for each workout
2. **No History**: Can't track exercise progression
3. **No Library**: No template/favorite exercises
4. **No Media**: No form videos or technique guides
5. **No Search**: Can't find previously used exercises

## Proposed Architecture

### New Structure
```swift
@Model Exercise {
    // Core Properties
    var id: UUID
    var name: String
    var trainingMethod: TrainingMethod
    var category: ExerciseCategory?
    var equipment: [Equipment]?
    var muscleGroups: [MuscleGroup]?
    
    // Multimedia
    var videoURL: String?
    var gifURL: String?
    var thumbnailURL: String?
    var formNotes: String?
    
    // Metadata
    var createdDate: Date
    var lastUsedDate: Date?
    var useCount: Int
    var isCustom: Bool
    var isFavorite: Bool
    
    // Relationships
    @Relationship(inverse: \IntervalExercise.exercise)
    var intervalExercises: [IntervalExercise]
}

@Model IntervalExercise {
    // Bridge entity for Interval <-> Exercise
    var id: UUID
    var orderIndex: Int
    var effort: Int
    var weight: Double?
    var restAfter: Int?
    var tempo: Tempo?
    var notes: String?
    
    // Relationships
    @Relationship var interval: Interval
    @Relationship var exercise: Exercise
}

@Model Interval {
    // Updated to use bridge entity
    @Relationship(inverse: \IntervalExercise.interval)
    var intervalExercises: [IntervalExercise]
}
```

## Implementation Phases

### Phase 1: Data Model Refactoring
1. **Create new Exercise @Model class**
   - Add all current properties
   - Add multimedia properties
   - Add metadata for search/filtering

2. **Create IntervalExercise bridge entity**
   - Maintains order within interval
   - Stores workout-specific values (weight, reps, etc.)
   - Links Exercise template to Interval instance

3. **Update Interval model**
   - Replace [Exercise] with relationship
   - Maintain computed properties for compatibility

4. **Create migration logic**
   - Convert existing embedded exercises
   - Preserve all current data
   - Handle duplicates intelligently

### Phase 2: Exercise Library Infrastructure
1. **Create ExerciseStore**
   - CRUD operations for exercises
   - Search functionality
   - Category filtering
   - Favorite management

2. **Add default exercises**
   - Common exercises pre-populated
   - Categorized by muscle group
   - Include form tips

3. **Search implementation**
   - Full-text search on name
   - Filter by category/equipment
   - Sort by usage/favorites

### Phase 3: UI Components
1. **Exercise Picker View**
   - Search bar with live results
   - Category filters
   - Recent/favorite sections
   - "Create New" option

2. **Exercise Detail View**
   - Display all exercise info
   - Show multimedia content
   - Edit capabilities for custom exercises
   - Usage history

3. **Update WorkoutFormView**
   - Replace text field with picker
   - Support quick-add for new exercises
   - Maintain current UX flow

### Phase 4: Multimedia Support
1. **URL Storage**
   - Store URLs only (not binary data)
   - Support YouTube, Vimeo, GIF services
   - Thumbnail generation/caching

2. **Media Display Components**
   - GIF player component
   - Video preview with external player
   - Lazy loading for performance

3. **Media Management**
   - Add/edit media URLs
   - Validate URLs
   - Handle loading states

## Migration Strategy

### Step 1: Parallel Implementation
1. Create new models alongside existing
2. Build new UI components
3. Test thoroughly before switching

### Step 2: Data Migration
```swift
func migrateExercises(context: ModelContext) async {
    let workouts = try await context.fetch(FetchDescriptor<Workout>())
    var exerciseMap: [String: Exercise] = [:]
    
    for workout in workouts {
        for interval in workout.intervals {
            for oldExercise in interval.exercises {
                // Create or find exercise template
                let exercise = exerciseMap[oldExercise.name] ?? createExercise(from: oldExercise)
                exerciseMap[oldExercise.name] = exercise
                
                // Create bridge entity
                let intervalExercise = IntervalExercise(
                    exercise: exercise,
                    interval: interval,
                    effort: oldExercise.effort,
                    // ... copy other properties
                )
                
                context.insert(intervalExercise)
            }
        }
    }
}
```

### Step 3: Compatibility Layer
- Maintain computed properties for smooth transition
- Update UI components gradually
- Ensure no data loss

## Performance Considerations

### Optimizations
1. **Lazy Loading**: Don't fetch all exercises at once
2. **Indexed Search**: Add database indexes for name, category
3. **Relationship Limits**: Use pagination for large datasets
4. **Media Caching**: Cache thumbnails and GIFs locally
5. **Batch Operations**: Group database operations

### Following CLAUDE.md
- No ViewModels - use @Query directly
- Pre-compute search indexes
- Static categories and equipment lists
- Minimize relationship traversals

## UI/UX Considerations

### Exercise Selection Flow
1. **Quick Add**: Type name → Auto-complete → Select or Create
2. **Browse**: Categories → Filtered list → Select
3. **Search**: Full search → Results → Select
4. **Favorites**: Quick access to starred exercises

### Data Entry
- Preserve current single-screen approach
- Inline editing where possible
- Progressive disclosure for advanced options

## Benefits

1. **Exercise Library**: Build personal exercise database
2. **Form Guides**: Embed technique videos/GIFs
3. **Progress Tracking**: See exercise history over time
4. **Faster Creation**: Autofill from previous workouts
5. **Consistency**: Standardized exercise names
6. **Sharing**: Potential to share exercise templates

## Risks & Mitigation

### Risk 1: Migration Complexity
- **Mitigation**: Extensive testing, backup system

### Risk 2: Performance Impact
- **Mitigation**: Careful relationship design, lazy loading

### Risk 3: UI Complexity
- **Mitigation**: Progressive enhancement, maintain simplicity

### Risk 4: Data Duplication
- **Mitigation**: Smart deduplication during migration

## Success Criteria

1. **Zero Data Loss**: All existing exercises preserved
2. **Performance**: No degradation in app speed
3. **Usability**: Exercise creation remains fast
4. **Search Works**: Find exercises quickly
5. **Media Loads**: GIFs/videos display properly

## Implementation Timeline

### Week 1: Data Model & Migration
- New models created
- Migration logic implemented
- Basic CRUD operations

### Week 2: Exercise Library
- Search implementation
- Category system
- Default exercises

### Week 3: UI Integration
- Exercise picker
- Update form views
- Maintain current flow

### Week 4: Multimedia
- Media display components
- URL management
- Performance optimization

## Next Steps

1. Review and approve plan
2. Create branch for parallel development
3. Start with Phase 1: Data Model
4. Build incrementally with testing

This is indeed a significant refactoring, but the benefits of a proper exercise library with multimedia support will greatly enhance the app's value and usability.