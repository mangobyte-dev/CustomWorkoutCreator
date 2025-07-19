# CRUD-Focused Implementation Plan for CustomWorkoutCreator

## Core Principle
Dead simple CRUD implementation using vanilla SwiftUI. No polish, just functionality.

## Phase 1: CREATE (Workout Creation) - UPDATED SINGLE SCREEN APPROACH

### 1.1 Basic Workout Creation Flow
```
WorkoutsView (+ button) → NewWorkoutView (all-in-one) → Save
```

### 1.2 NewWorkoutView - Single Screen
- **Form with sections:**
  - TextField for workout name
  - **Intervals Section:**
    - List of intervals (expandable/collapsible)
    - Each interval shows:
      - Name (inline editable)
      - Rounds & rest (inline steppers)
      - List of exercises
      - "Add Exercise" button
    - "Add Interval" button at bottom
  - Save button (enabled only when has name + intervals with exercises)

### 1.3 Inline Interval Editing
- **Each interval row contains:**
  - TextField for name (optional, placeholder "Interval 1")
  - Stepper for rounds (1-10)
  - Stepper for rest between rounds (0-300s)
  - Exercises list below
  - "Add Exercise" button

### 1.4 Inline Exercise Editing
- **Each exercise row contains:**
  - TextField for exercise name
  - Picker for training method (segmented control)
  - Based on method:
    - Standard: Stepper for reps
    - Timed: Stepper for seconds
    - Rest-pause: TextField for target
  - Swipe to delete

## Phase 2: READ (Workout List)

### 2.1 WorkoutsView Enhancement
- **List of workouts showing:**
  - Workout name
  - Date created
  - Number of intervals
  - Total exercises count
- NavigationLink to each workout (leads to Update view)
- Empty state: "No workouts. Tap + to create one."

## Phase 3: UPDATE (Edit Workout)

### 3.1 EditWorkoutView
- **Reuse NewWorkoutView with:**
  - Pre-filled data
  - Title "Edit Workout"
  - Save changes to existing workout
  - Cancel button to discard changes

### 3.2 Navigation Flow
```
WorkoutsList → Tap workout → EditWorkoutView (same as create but pre-filled)
```

## Phase 4: DELETE

### 4.1 Swipe to Delete
- **In WorkoutsView list:**
  - .swipeActions with delete button
  - Confirmation not needed (SwiftData handles it)

### 4.2 Delete in Edit Mode
- **In EditWorkoutView:**
  - Delete button in toolbar
  - Deletes workout and pops navigation

## Implementation Details

### File Structure
```
Views/
├── WorkoutsView.swift (R+D)
├── NewWorkoutView.swift (C+U)
├── AddIntervalView.swift (C+U)
└── AddExercisesView.swift (C+U)
```

### Data Flow Pattern
```swift
// CREATE
@State private var workoutName = ""
@State private var intervals: [Interval] = []

// Pass data down, actions up
AddIntervalView(intervals: $intervals)

// SAVE
let workout = Workout(name: workoutName)
workout.intervals = intervals
workoutStore.addWorkout(workout)

// UPDATE
@Bindable var workout: Workout
// Direct binding to workout properties

// DELETE  
workoutStore.deleteWorkout(workout)
```

### Key Components Only
- Form
- List  
- TextField
- Stepper
- Picker
- NavigationStack/Link
- .sheet()
- .toolbar
- .swipeActions

### Minimal Validation
- Workout needs name + at least 1 interval
- Interval needs at least 1 exercise
- Exercise needs name + training method config

### Example Implementation Priority
1. NewWorkoutView with ability to add name
2. AddIntervalView as sheet
3. AddExercisesView to add exercises to interval
4. Save workout to SwiftData
5. WorkoutsView to list all workouts
6. Navigate to EditWorkoutView (reuse NewWorkoutView)
7. Swipe to delete in list
8. Delete button in edit view

## Success Metrics
- Can create a workout with multiple intervals and exercises
- Can view all created workouts
- Can edit any workout and save changes
- Can delete workouts
- All data persists via SwiftData

No animations, no custom colors, no fancy transitions. Just working CRUD.