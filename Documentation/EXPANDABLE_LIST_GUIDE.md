# ExpandableList Implementation Guide

**Created:** August 5, 2025  
**Purpose:** Comprehensive guide for implementing ExpandableList correctly, avoiding common mistakes

## 🎯 Overview

ExpandableList is a high-performance component that manages expansion state for lists of items. It eliminates boilerplate code and ensures consistent animations across the app.

## ✅ CORRECT Implementation

### Basic Usage Pattern

```swift
// CORRECT: Let ExpandableList manage its own state
struct MyView: View {
    let items: [MyItem]
    
    var body: some View {
        ScrollView {
            ExpandableList(items: items) { item, index, isExpanded in
                MyItemCard(
                    item: item,
                    index: index,
                    isExpanded: isExpanded  // Pass binding directly
                )
            }
            .padding()
        }
    }
}

// CORRECT: Child component accepts binding
struct MyItemCard: View {
    let item: MyItem
    let index: Int
    @Binding var isExpanded: Bool  // Accept binding from parent
    
    var body: some View {
        Expandable(
            isExpanded: $isExpanded,  // Use binding
            header: { /* header content */ },
            content: { /* expanded content */ }
        )
    }
}
```

### With Initial Expansion

```swift
// CORRECT: Specify initially expanded items
ExpandableList(
    items: intervals,
    initiallyExpanded: [intervals.first?.id].compactMap { $0 }
) { interval, index, isExpanded in
    IntervalCard(
        interval: interval,
        isExpanded: isExpanded
    )
}
```

### Nested ExpandableList

```swift
// CORRECT: Nested expandable lists for hierarchical data
struct IntervalFormCard: View {
    @Binding var interval: Interval
    @Binding var isExpanded: Bool
    
    var body: some View {
        Expandable(
            isExpanded: $isExpanded,
            header: { /* interval header */ },
            content: {
                // Nested ExpandableList for exercises
                ExpandableList(items: interval.exercises) { exercise, index, exerciseExpanded in
                    ExerciseFormCard(
                        exercise: bindingForExercise(at: index),
                        isExpanded: exerciseExpanded
                    ) {
                        deleteExercise(at: index)
                    }
                }
            }
        )
    }
    
    private func bindingForExercise(at index: Int) -> Binding<Exercise> {
        Binding<Exercise>(
            get: { interval.exercises[index] },
            set: { interval.exercises[index] = $0 }
        )
    }
}
```

## ❌ COMMON MISTAKES TO AVOID

### Mistake 1: Managing State Externally

```swift
// ❌ WRONG: Don't manage expansion state outside ExpandableList
struct BadView: View {
    @State private var expandedItems: Set<UUID> = []  // Don't do this!
    
    var body: some View {
        ForEach(items) { item in
            MyCard(
                item: item,
                isExpanded: Binding(
                    get: { expandedItems.contains(item.id) },
                    set: { isExpanded in
                        if isExpanded {
                            expandedItems.insert(item.id)
                        } else {
                            expandedItems.remove(item.id)
                        }
                    }
                )
            )
        }
    }
}

// ✅ CORRECT: Use ExpandableList instead
struct GoodView: View {
    var body: some View {
        ExpandableList(items: items) { item, index, isExpanded in
            MyCard(item: item, isExpanded: isExpanded)
        }
    }
}
```

### Mistake 2: Using Internal State in List Items

```swift
// ❌ WRONG: Don't use @State inside items that will be in a list
struct BadCard: View {
    let item: Item
    @State private var isExpanded = false  // This causes animation issues!
    
    var body: some View {
        Expandable(
            isExpanded: $isExpanded,  // Internal state breaks list animations
            header: { /* ... */ },
            content: { /* ... */ }
        )
    }
}

// ✅ CORRECT: Accept binding from parent
struct GoodCard: View {
    let item: Item
    @Binding var isExpanded: Bool  // Accept from ExpandableList
    
    var body: some View {
        Expandable(
            isExpanded: $isExpanded,
            header: { /* ... */ },
            content: { /* ... */ }
        )
    }
}
```

### Mistake 3: Wrong Animation Placement

```swift
// ❌ WRONG: Don't add animation to individual items
ExpandableList(items: items) { item, index, isExpanded in
    ItemCard(item: item, isExpanded: isExpanded)
        .animation(.spring(), value: isExpanded)  // Don't do this!
}

// ✅ CORRECT: ExpandableList handles animations internally
ExpandableList(items: items) { item, index, isExpanded in
    ItemCard(item: item, isExpanded: isExpanded)
    // No animation modifier needed - ExpandableList handles it
}
```

### Mistake 4: Creating Bindings in ForEach

```swift
// ❌ WRONG: Complex binding creation in ForEach
ForEach($items) { $item in
    Expandable(
        isExpanded: Binding(
            get: { expandedItems.contains(item.id) },
            set: { _ in toggleExpansion(item.id) }
        ),
        header: { /* ... */ },
        content: { /* ... */ }
    )
}

// ✅ CORRECT: Let ExpandableList handle binding creation
ExpandableList(items: items) { item, index, isExpanded in
    Expandable(
        isExpanded: isExpanded,  // Simple, clean binding
        header: { /* ... */ },
        content: { /* ... */ }
    )
}
```

### Mistake 5: Using Expandable's Internal State

```swift
// ❌ WRONG: Don't rely on Expandable's initiallyExpanded
struct BadImplementation: View {
    var body: some View {
        ForEach(items) { item in
            Expandable(
                initiallyExpanded: true,  // This won't work properly in lists!
                header: { /* ... */ },
                content: { /* ... */ }
            )
        }
    }
}

// ✅ CORRECT: Use ExpandableList with initiallyExpanded
struct GoodImplementation: View {
    var body: some View {
        ExpandableList(
            items: items,
            initiallyExpanded: Set(items.prefix(2).map(\.id))  // First 2 expanded
        ) { item, index, isExpanded in
            Expandable(
                isExpanded: isExpanded,
                header: { /* ... */ },
                content: { /* ... */ }
            )
        }
    }
}
```

## 🏗️ Architecture Patterns

### Pattern 1: Simple List

```swift
struct SimpleListView: View {
    let workouts: [Workout]
    
    var body: some View {
        ScrollView {
            ExpandableList(items: workouts) { workout, index, isExpanded in
                WorkoutCard(
                    workout: workout,
                    workoutNumber: index + 1,
                    isExpanded: isExpanded
                )
            }
            .padding()
        }
    }
}
```

### Pattern 2: Editable List

```swift
struct EditableListView: View {
    @State var intervals: [Interval]
    
    var body: some View {
        ScrollView {
            ExpandableList(items: intervals) { interval, index, isExpanded in
                IntervalFormCard(
                    interval: bindingForInterval(at: index),
                    isExpanded: isExpanded,
                    intervalNumber: index + 1
                ) {
                    deleteInterval(at: index)
                }
            }
        }
    }
    
    private func bindingForInterval(at index: Int) -> Binding<Interval> {
        Binding<Interval>(
            get: { intervals[index] },
            set: { intervals[index] = $0 }
        )
    }
    
    private func deleteInterval(at index: Int) {
        intervals.remove(at: index)
    }
}
```

### Pattern 3: Nested Hierarchy

```swift
struct HierarchicalView: View {
    let sections: [Section]
    
    var body: some View {
        ScrollView {
            // Top level
            ExpandableList(items: sections) { section, sectionIndex, sectionExpanded in
                Expandable(
                    isExpanded: sectionExpanded,
                    header: {
                        Text(section.title)
                            .font(.headline)
                    },
                    content: {
                        // Nested level
                        ExpandableList(items: section.items) { item, itemIndex, itemExpanded in
                            ItemCard(
                                item: item,
                                isExpanded: itemExpanded
                            )
                        }
                    }
                )
            }
        }
    }
}
```

## 🎨 Customization Options

### Custom Spacing

```swift
ExpandableList(
    items: items,
    spacing: 8  // Custom spacing between items
) { item, index, isExpanded in
    ItemCard(item: item, isExpanded: isExpanded)
}
```

### Custom Animation

```swift
ExpandableList(
    items: items,
    animation: .easeInOut(duration: 0.25)  // Custom animation
) { item, index, isExpanded in
    ItemCard(item: item, isExpanded: isExpanded)
}
```

### With SwiftData

```swift
struct SwiftDataListView: View {
    @Query private var workouts: [Workout]
    
    var body: some View {
        ScrollView {
            // Convert to Array for ExpandableList
            ExpandableList(items: Array(workouts)) { workout, index, isExpanded in
                WorkoutCard(
                    workout: workout,
                    isExpanded: isExpanded
                )
            }
        }
    }
}
```

## 🚨 Critical Rules

### Rule 1: Binding Flow
**Always** pass bindings from ExpandableList → Child Component → Expandable

```swift
ExpandableList { item, index, isExpanded in  // Source
    ChildCard(isExpanded: isExpanded)        // Pass through
        → Expandable(isExpanded: isExpanded) // Destination
}
```

### Rule 2: State Ownership
**Never** create expansion state in:
- Individual list items
- ForEach loops
- Child components

**Always** let ExpandableList own the expansion state.

### Rule 3: Animation Management
**Never** add animation modifiers to:
- Individual items in ExpandableList
- The ExpandableList itself
- Child components

**Always** let ExpandableList handle animations internally.

### Rule 4: Binding Creation
**Never** create complex bindings in view body.
**Always** use helper methods for binding creation:

```swift
private func bindingForItem(at index: Int) -> Binding<Item> {
    Binding<Item>(
        get: { items[index] },
        set: { items[index] = $0 }
    )
}
```

## 🎯 Performance Considerations

### Do's
- ✅ Use LazyVStack inside ScrollView
- ✅ Pre-compute static values
- ✅ Use ExpandableList for all expandable lists
- ✅ Let ExpandableList manage state
- ✅ Use initiallyExpanded for default expansion

### Don'ts
- ❌ Don't use Form with ExpandableList
- ❌ Don't manage expansion state manually
- ❌ Don't create bindings in view body
- ❌ Don't use @State in list items
- ❌ Don't add redundant animations

## 📝 Debugging Tips

### Issue: Animations Not Working
**Symptom**: Expand/collapse is instant or jerky
**Cause**: Usually internal state in child components
**Fix**: Ensure binding is passed from ExpandableList

### Issue: All Items Expand Together
**Symptom**: Clicking one item expands all
**Cause**: Shared state or incorrect binding
**Fix**: Check that each item gets its own binding from ExpandableList

### Issue: State Not Persisting
**Symptom**: Items collapse when scrolling
**Cause**: View recreation in LazyVStack
**Fix**: This is normal behavior; use initiallyExpanded for persistent defaults

### Issue: Performance Problems
**Symptom**: Lag when expanding/collapsing
**Cause**: Too many items or complex content
**Fix**: Use LazyVStack, simplify content, pre-compute values

## 🔍 Complete Example

```swift
import SwiftUI

struct WorkoutFormView: View {
    @State private var intervals: [Interval] = []
    @State private var showingExercisePicker = false
    @State private var selectedIntervalIndex: Int?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header section
                    workoutDetailsSection
                    
                    // Intervals section with ExpandableList
                    if !intervals.isEmpty {
                        ExpandableList(items: intervals) { interval, index, isExpanded in
                            IntervalFormCard(
                                interval: bindingForInterval(at: index),
                                isExpanded: isExpanded,
                                intervalNumber: index + 1
                            ) {
                                deleteInterval(at: index)
                            } onAddExercise: {
                                selectedIntervalIndex = index
                                showingExercisePicker = true
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Add interval button
                    addIntervalButton
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingExercisePicker) {
            if let index = selectedIntervalIndex {
                ExercisePicker { exerciseItem in
                    addExercise(exerciseItem, to: index)
                }
            }
        }
    }
    
    // Helper methods
    private func bindingForInterval(at index: Int) -> Binding<Interval> {
        Binding<Interval>(
            get: { intervals[index] },
            set: { intervals[index] = $0 }
        )
    }
    
    private func deleteInterval(at index: Int) {
        intervals.remove(at: index)
    }
    
    private func addExercise(_ item: ExerciseItem, to intervalIndex: Int) {
        let exercise = Exercise.from(exerciseItem: item)
        intervals[intervalIndex].exercises.append(exercise)
    }
}
```

## 📚 Summary

ExpandableList is powerful but requires correct implementation:

1. **Let it manage state** - Don't fight it
2. **Pass bindings through** - From ExpandableList to children
3. **Avoid internal state** - No @State in list items
4. **Trust the animations** - Don't add your own
5. **Keep it simple** - The component handles complexity for you

When implemented correctly, ExpandableList eliminates 90% of boilerplate code while providing smooth, consistent animations throughout your app.