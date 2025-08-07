# Current File Mapping - Pre-Reorganization

**Generated:** August 7, 2025  
**Purpose:** Document current file locations before reorganization

## 📍 Current File Locations

### Root Level Files (/CustomWorkoutCreator/)
```
❌ CLAUDE.md                          → Move to Documentation/Guides/
❌ PROGRESS.md                         → Move to Documentation/Progress/
❌ test_exercise_loading.swift         → Move to Tests/IntegrationTests/
❌ Components/                         → Delete (empty folder)
✅ CustomWorkoutCreator.xcodeproj     → Keep at root
✅ CustomWorkoutCreator.xctestplan    → Keep at root
✅ CustomWorkoutCreatorTests/         → Keep (reorganize internally)
✅ Documentation/                      → Keep (reorganize internally)
✅ Archive/                           → Move to Documentation/Archive/
```

### App Root Files (/CustomWorkoutCreator/CustomWorkoutCreator/)
```
❌ ContentView.swift                  → Move to App/
❌ CustomWorkoutCreatorApp.swift      → Move to App/
❌ DataModels.swift                   → Move to Models/
❌ HomeView.swift                     → Move to Views/Main/
❌ SettingsView.swift                 → Move to Views/Main/
❌ WorkoutsView.swift                 → Move to Views/Main/
✅ Assets.xcassets                    → Keep in Resources/
✅ Resources/                         → Keep as is
✅ Preview/                           → Keep as is
✅ Views/                             → Reorganize internally
✅ Components/                        → Reorganize internally
```

### Views Folder (/CustomWorkoutCreator/CustomWorkoutCreator/Views/)
```
Current:
- AddExerciseView.swift              → Views/Exercise/
- ExerciseCard.swift                 → Views/Workout/
- ExerciseLibraryView.swift          → Views/Main/
- ExercisePicker.swift               → Views/Exercise/
- IntervalCard.swift                 → Views/Workout/
- WorkoutDetailView.swift            → Views/Workout/
- WorkoutDetailViewCache.swift       → Views/Workout/
- WorkoutFormView.swift              → Views/Workout/
```

### Components Folder (/CustomWorkoutCreator/CustomWorkoutCreator/Components/)
```
Current (all mixed together):
Core Components:
- ComponentConstants.swift           → Components/Core/
- Row.swift                          → Components/Core/
- SectionHeader.swift                → Components/Core/
- ActionButton.swift                 → Components/Core/
- EquatableView.swift                → Components/Core/

Layout Components:
- Expandable.swift                   → Components/Layout/
- ExpandableList.swift               → Components/Layout/

Input Components:
- NumberInputRow.swift               → Components/Input/
- RangeInputRow.swift                → Components/Input/
- TimeInputRow.swift                 → Components/Input/
- EffortSliderRow.swift             → Components/Input/
- TrainingMethodPicker.swift         → Components/Input/

Card Components:
- ExerciseFormCard.swift             → Components/Cards/
- IntervalFormCard.swift             → Components/Cards/

Media Components:
- GifImageView.swift                 → Components/Media/
```

### Documentation Folder (/CustomWorkoutCreator/Documentation/)
```
Current:
- COMPONENTS_DOCUMENTATION.md         → Documentation/Guides/
- COMPLETED_FEATURES.md              → Documentation/Progress/
- EXPANDABLE_LIST_GUIDE.md           → Documentation/Guides/
- PROGRESS.md                        → Documentation/Progress/
- WORKOUT_FORM_REFACTORING_PLAN.md   → Documentation/Architecture/
```

### Archive Folder (/CustomWorkoutCreator/Archive/)
```
Current (by phase):
- Exercise_Refactoring_Completed/    → Documentation/Archive/Exercise_Library_Implementation/
- Implementation_Completed/           → Documentation/Archive/Phase1_Component_Refactoring/
- Phase1_Completed/                   → Documentation/Archive/Phase1_Component_Refactoring/
```

## 🔄 File Movement Commands

### Phase 1: Documentation
```bash
# Move main docs
git mv CLAUDE.md Documentation/Guides/
git mv PROGRESS.md Documentation/Progress/

# Organize archive
mkdir -p Documentation/Archive/Phase1_Component_Refactoring
mkdir -p Documentation/Archive/Phase2_WorkoutDetailView  
mkdir -p Documentation/Archive/Phase3_WorkoutFormView
mkdir -p Documentation/Archive/Exercise_Library_Implementation

# Move archive files
git mv Archive/Implementation_Completed/* Documentation/Archive/Phase1_Component_Refactoring/
git mv Archive/Phase1_Completed/* Documentation/Archive/Phase1_Component_Refactoring/
git mv Archive/Exercise_Refactoring_Completed/* Documentation/Archive/Exercise_Library_Implementation/

# Remove empty folders
rmdir Archive/Implementation_Completed
rmdir Archive/Phase1_Completed
rmdir Archive/Exercise_Refactoring_Completed
rmdir Archive
rmdir Components  # Empty duplicate at root
```

### Phase 2: App Structure
```bash
# Create new structure
cd CustomWorkoutCreator
mkdir -p App Models Views/Main Views/Workout Views/Exercise

# Move app files
git mv CustomWorkoutCreatorApp.swift App/
git mv ContentView.swift App/

# Move models
git mv DataModels.swift Models/

# Move main views
git mv HomeView.swift Views/Main/
git mv SettingsView.swift Views/Main/
git mv WorkoutsView.swift Views/Main/
git mv Views/ExerciseLibraryView.swift Views/Main/

# Move workout views
git mv Views/WorkoutDetailView.swift Views/Workout/
git mv Views/WorkoutFormView.swift Views/Workout/
git mv Views/WorkoutDetailViewCache.swift Views/Workout/
git mv Views/IntervalCard.swift Views/Workout/
git mv Views/ExerciseCard.swift Views/Workout/

# Move exercise views
git mv Views/ExercisePicker.swift Views/Exercise/
git mv Views/AddExerciseView.swift Views/Exercise/
```

### Phase 3: Component Organization
```bash
# Create component structure
cd Components
mkdir -p Core Layout Input Cards Media

# Move core components
git mv ComponentConstants.swift Core/
git mv Row.swift Core/
git mv SectionHeader.swift Core/
git mv ActionButton.swift Core/
git mv EquatableView.swift Core/

# Move layout components
git mv Expandable.swift Layout/
git mv ExpandableList.swift Layout/

# Move input components
git mv NumberInputRow.swift Input/
git mv RangeInputRow.swift Input/
git mv TimeInputRow.swift Input/
git mv EffortSliderRow.swift Input/
git mv TrainingMethodPicker.swift Input/

# Move card components
git mv ExerciseFormCard.swift Cards/
git mv IntervalFormCard.swift Cards/

# Move media components
git mv GifImageView.swift Media/
```

### Phase 4: Test Organization
```bash
# Move test file
mkdir -p CustomWorkoutCreatorTests/IntegrationTests
git mv test_exercise_loading.swift CustomWorkoutCreatorTests/IntegrationTests/
```

## 📋 Import Updates Required

After reorganization, these imports will need updating:

### Common Import Changes
```swift
// Before
import SwiftUI

// After (no change for SwiftUI)
import SwiftUI

// Component imports might need path updates in Xcode project
```

### Files Referencing Moved Components
- Most view files will need their component references updated
- Test files will need path updates

## ✅ Validation Checklist

After each phase:
1. [ ] Build project
2. [ ] Run tests  
3. [ ] Check all previews
4. [ ] Verify no broken references
5. [ ] Commit changes

## 🎯 End Result

A clean, organized structure where:
- **Every file has a logical home**
- **Related files are grouped together**
- **Documentation is centralized**
- **Components are categorized by type**
- **Views are organized by feature area**
- **Tests mirror app structure**

This will make the codebase much easier to navigate and maintain!