# WorkoutFormView Refactoring Plan

**Status:** Planned  
**Priority:** High  
**Estimated Effort:** 2-3 days

## 🎯 Goal

Transform the workout form from basic `Form` components to a high-performance `ScrollView + LazyVStack + Custom Components` architecture with professional input controls.

---

## 📋 Current Issues

### Limitations of Current Form
- Basic TextField/Stepper components lack visual appeal
- Limited customization options
- Poor performance with many intervals/exercises
- No custom input for rep ranges, time, rest periods
- Cramped UI in standard Form sections

### User Experience Gaps
- Can't easily input rep ranges (e.g., "8-12 reps")
- Time input is awkward with steppers
- No visual feedback for effort levels
- Training method selection is hidden
- Rest periods are not intuitive to set

---

## 🏗️ Proposed Architecture

### Core Structure
```
ScrollView
└── LazyVStack (spacing: sectionSpacing)
    ├── Workout Details Section
    ├── Intervals Section (LazyVStack)
    │   ├── IntervalFormCard #1
    │   ├── IntervalFormCard #2
    │   └── ...
    └── Add Interval Button
```

### Benefits
- **Performance**: LazyVStack only renders visible content
- **Customization**: Full control over input components
- **Consistency**: Reuses existing component system
- **User Experience**: Professional, intuitive controls

---

## 🧩 New Components to Build

### 1. NumberInputRow
**Purpose**: Input numbers with +/- buttons and direct text entry

```swift
struct NumberInputRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int = 1
    let unit: String? // "reps", "seconds", etc.
    let icon: String?
    let position: RowPosition
    
    var body: some View {
        Row(position: position) {
            // Icon/Label
        } content: {
            Text(title)
        } trailing: {
            HStack {
                Button("-") { decrease() }
                Text("\(value)")
                Button("+") { increase() }
            }
        }
    }
}
```

**Usage Examples**:
- Rounds: 1-20
- Rest seconds: 0-300
- Target reps: 10-100

### 2. RangeInputRow
**Purpose**: Input min-max ranges like "8-12 reps"

```swift
struct RangeInputRow: View {
    let title: String
    @Binding var minValue: Int
    @Binding var maxValue: Int
    let range: ClosedRange<Int>
    let unit: String
    let position: RowPosition
    
    var body: some View {
        Row(position: position) {
            // Icon
        } content: {
            Text(title)
        } trailing: {
            HStack {
                TextField("Min", value: $minValue)
                Text("-")
                TextField("Max", value: $maxValue)
                Text(unit)
            }
        }
    }
}
```

**Usage Examples**:
- Rep range: 8-12 reps
- Rest range: 30-60 seconds

### 3. TimeInputRow
**Purpose**: Input time with minutes:seconds format

```swift
struct TimeInputRow: View {
    let title: String
    @Binding var seconds: Int
    let position: RowPosition
    
    private var minutes: Int { seconds / 60 }
    private var remainingSeconds: Int { seconds % 60 }
    
    var body: some View {
        Row(position: position) {
            // Clock icon
        } content: {
            Text(title)
        } trailing: {
            HStack {
                Picker("Minutes", selection: $minutes)
                Text(":")
                Picker("Seconds", selection: $remainingSeconds)
            }
        }
    }
}
```

**Usage Examples**:
- Exercise duration: 0:45
- Rest period: 1:30
- Interval time: 5:00

### 4. EffortSliderRow
**Purpose**: Visual slider for effort level

```swift
struct EffortSliderRow: View {
    let title: String
    @Binding var effort: Int
    let position: RowPosition
    
    var body: some View {
        Row(position: position) {
            // Effort icon
        } content: {
            VStack(alignment: .leading) {
                Text(title)
                Slider(value: $effort, in: 1...10) {
                    // Custom gradient track
                    // Color changes based on value
                }
            }
        } trailing: {
            Text("\(effort)/10")
        }
    }
}
```

**Features**:
- Gradient from green (easy) to red (hard)
- Haptic feedback on change
- Visual number display

### 5. TrainingMethodPicker
**Purpose**: Select training method with dynamic inputs

```swift
struct TrainingMethodPicker: View {
    @Binding var method: TrainingMethod
    
    var body: some View {
        VStack(spacing: 1) {
            // Segmented control
            Picker("Method", selection: $methodType) {
                Text("Standard").tag("standard")
                Text("Rest-Pause").tag("restpause")
                Text("Timed").tag("timed")
            }
            .pickerStyle(.segmented)
            
            // Dynamic inputs based on selection
            switch method {
            case .standard:
                RangeInputRow(...)
            case .timed:
                TimeInputRow(...)
            case .restPause:
                NumberInputRow(...)
            }
        }
    }
}
```

---

## 📦 Enhanced Form Cards

### IntervalFormCard
**Purpose**: Complete interval editing interface

```swift
struct IntervalFormCard: View {
    @Binding var interval: Interval
    @State private var isExpanded = true
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Expandable header
            headerSection
            
            if isExpanded {
                // Interval settings
                VStack(spacing: 1) {
                    NumberInputRow("Rounds", value: $interval.rounds)
                    TimeInputRow("Rest Between", seconds: $interval.restBetweenRounds)
                    TimeInputRow("Rest After", seconds: $interval.restAfterInterval)
                }
                
                // Exercises
                exercisesSection
            }
        }
        .background(ComponentConstants.Row.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

**Features**:
- Expandable/collapsible
- Inline exercise management
- Visual hierarchy
- Swipe to delete

### ExerciseFormCard
**Purpose**: Exercise configuration with visual picker

```swift
struct ExerciseFormCard: View {
    @Binding var exercise: Exercise
    @State private var isExpanded = false
    @State private var showingPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Exercise selection (shows GIF + name)
            Button {
                showingPicker = true
            } label: {
                HStack {
                    GifImageView(exercise.exerciseItem?.gifUrl)
                        .frame(width: 40, height: 40)
                    Text(exercise.exerciseItem?.name ?? "Select Exercise")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            
            if isExpanded {
                // Training configuration
                VStack(spacing: 1) {
                    TrainingMethodPicker(method: $exercise.trainingMethod)
                    EffortSliderRow("Effort", effort: $exercise.effort)
                    // Additional settings based on method
                }
            }
        }
    }
}
```

**Features**:
- Visual exercise selection
- Dynamic inputs based on training method
- Effort visualization
- Compact/expanded states

---

## 🎨 Refactored WorkoutFormView

### Main Structure

```swift
struct WorkoutFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let workout: Workout?
    
    @State private var workoutName = ""
    @State private var intervals: [Interval] = []
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case workoutName
        case intervalName(UUID)
        case numberInput(UUID, String)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: ComponentConstants.Layout.sectionSpacing) {
                    workoutDetailsSection
                    intervalsSection
                    addIntervalButton
                    
                    // Keyboard padding
                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .background(ComponentConstants.Colors.groupedBackground)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onAppear { loadWorkoutData() }
        }
    }
}
```

### ViewBuilder Sections

```swift
@ViewBuilder
private var workoutDetailsSection: some View {
    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
        SectionHeader(title: "Workout Details")
        
        VStack(spacing: 1) {
            Row(position: .only) {
                Image(systemName: "figure.run")
            } content: {
                TextField("Workout Name", text: $workoutName)
                    .focused($focusedField, equals: .workoutName)
            } trailing: {
                if !workoutName.isEmpty {
                    Button {
                        workoutName = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
    }
}

@ViewBuilder
private var intervalsSection: some View {
    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
        SectionHeader(title: "Intervals") {
            Text("\(intervals.count)")
        }
        
        LazyVStack(spacing: ComponentConstants.Layout.itemSpacing) {
            ForEach($intervals) { $interval in
                IntervalFormCard(
                    interval: $interval,
                    onDelete: { deleteInterval(interval) }
                )
            }
        }
    }
}

@ViewBuilder
private var addIntervalButton: some View {
    ActionButton(
        "Add Interval",
        icon: "plus.circle",
        style: .secondary,
        size: .medium
    ) {
        withAnimation {
            addNewInterval()
        }
    }
}
```

---

## ⚡ Performance Optimizations

### LazyVStack Benefits
- Only renders visible intervals
- Smooth scrolling with many items
- Reduced memory footprint
- Better than Form for complex layouts

### State Management
```swift
// Focused field tracking
@FocusState private var focusedField: Field?

// Keyboard management
.toolbar {
    ToolbarItemGroup(placement: .keyboard) {
        Button("Previous") { moveToPreviousField() }
        Button("Next") { moveToNextField() }
        Spacer()
        Button("Done") { focusedField = nil }
    }
}
```

### Animations
```swift
// Smooth insertions
withAnimation(.spring()) {
    intervals.append(newInterval)
}

// Expandable sections
withAnimation(.easeInOut(duration: 0.3)) {
    isExpanded.toggle()
}
```

### Haptic Feedback
```swift
// On value changes
let impact = UIImpactFeedbackGenerator(style: .light)
impact.impactOccurred()

// On deletions
let notification = UINotificationFeedbackGenerator()
notification.notificationOccurred(.warning)
```

---

## 📋 Implementation Plan

### Phase 1: Core Input Components (Day 1)
1. Create NumberInputRow
2. Create RangeInputRow
3. Create TimeInputRow
4. Create EffortSliderRow
5. Create TrainingMethodPicker

### Phase 2: Form Cards (Day 1-2)
1. Create ExerciseFormCard
2. Create IntervalFormCard
3. Integrate with exercise picker
4. Add expand/collapse animations

### Phase 3: Main Form Refactor (Day 2)
1. Refactor WorkoutFormView structure
2. Replace Form with ScrollView + LazyVStack
3. Integrate new components
4. Add keyboard management

### Phase 4: Polish (Day 2-3)
1. Add haptic feedback
2. Implement smooth animations
3. Test with many intervals
4. Performance optimization

---

## 🎯 Success Metrics

### User Experience
- Intuitive input controls
- Visual feedback for all interactions
- Smooth animations
- Professional appearance

### Performance
- 60 FPS scrolling with 20+ intervals
- <100MB memory usage
- Instant response to inputs
- No lag when adding/removing items

### Code Quality
- Reusable components
- Consistent with design system
- Well-documented
- Testable units

---

## 🚀 Expected Outcome

The refactored WorkoutFormView will provide:
- **Professional UI**: Custom controls designed for fitness apps
- **Better UX**: Intuitive input for reps, time, effort
- **High Performance**: Smooth even with complex workouts
- **Visual Feedback**: See exercises with GIFs while editing
- **Consistent Design**: Uses existing component system

This refactoring will elevate the workout creation experience from functional to exceptional, matching the quality of the exercise library system.