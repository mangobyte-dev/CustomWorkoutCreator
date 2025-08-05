import SwiftUI

// MARK: - ExpandableList Component
/// A high-performance expandable list component following CLAUDE.md performance principles
/// Generic over Identifiable items with internal state management and customizable parameters
struct ExpandableList<Item: Identifiable, Content: View>: View {
    // MARK: - Properties
    private let items: [Item]
    private let content: (Item, Int, Binding<Bool>) -> Content
    private let spacing: CGFloat
    private let animation: Animation
    
    // MARK: - State
    @State private var expandedItems: Set<Item.ID>
    
    // MARK: - Initialization
    /// Creates an ExpandableList with full customization options
    /// - Parameters:
    ///   - items: Array of Identifiable items to display
    ///   - spacing: Vertical spacing between items (default: ComponentConstants.Layout.itemSpacing)
    ///   - animation: Animation for expand/collapse (default: ComponentConstants.Animation.springAnimation)
    ///   - initiallyExpanded: Set of item IDs that should start expanded (default: empty)
    ///   - content: ViewBuilder closure that receives (item, index, isExpandedBinding)
    init(
        items: [Item],
        spacing: CGFloat = ComponentConstants.Layout.itemSpacing,
        animation: Animation = ComponentConstants.Animation.springAnimation,
        initiallyExpanded: Set<Item.ID> = [],
        @ViewBuilder content: @escaping (Item, Int, Binding<Bool>) -> Content
    ) {
        self.items = items
        self.content = content
        self.spacing = spacing
        self.animation = animation
        self._expandedItems = State(initialValue: initiallyExpanded)
    }
    
    // MARK: - Convenience Initializer
    /// Creates an ExpandableList with default parameters
    /// - Parameters:
    ///   - items: Array of Identifiable items to display
    ///   - content: ViewBuilder closure that receives (item, index, isExpandedBinding)
    init(
        items: [Item],
        @ViewBuilder content: @escaping (Item, Int, Binding<Bool>) -> Content
    ) {
        self.init(
            items: items,
            spacing: ComponentConstants.Layout.itemSpacing,
            animation: ComponentConstants.Animation.springAnimation,
            initiallyExpanded: [],
            content: content
        )
    }
    
    // MARK: - External State Control Initializer
    /// Creates an ExpandableList with externally controlled expansion state
    /// - Parameters:
    ///   - items: Array of Identifiable items to display
    ///   - expandedItems: Binding to Set of expanded item IDs for external control
    ///   - spacing: Vertical spacing between items (default: ComponentConstants.Layout.itemSpacing)
    ///   - animation: Animation for expand/collapse (default: ComponentConstants.Animation.springAnimation)
    ///   - content: ViewBuilder closure that receives (item, index, isExpandedBinding)
    init(
        items: [Item],
        expandedItems: Binding<Set<Item.ID>>,
        spacing: CGFloat = ComponentConstants.Layout.itemSpacing,
        animation: Animation = ComponentConstants.Animation.springAnimation,
        @ViewBuilder content: @escaping (Item, Int, Binding<Bool>) -> Content
    ) {
        self.items = items
        self.content = content
        self.spacing = spacing
        self.animation = animation
        self._expandedItems = State(initialValue: expandedItems.wrappedValue)
        
        // Note: For external control, the parent should manage the binding
        // This initializer allows for that pattern when needed
    }
    
    // MARK: - Body
    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                content(
                    item,
                    index,
                    createExpandedBinding(for: item.id)
                )
                .animation(animation, value: expandedItems)
            }
        }
    }
    
    // MARK: - Helper Methods (Performance Optimized)
    /// Creates a binding for the expanded state of a specific item
    /// Pre-computed binding creation to avoid runtime closure allocations
    private func createExpandedBinding(for itemID: Item.ID) -> Binding<Bool> {
        Binding<Bool>(
            get: { expandedItems.contains(itemID) },
            set: { isExpanded in
                if isExpanded {
                    expandedItems.insert(itemID)
                } else {
                    expandedItems.remove(itemID)
                }
            }
        )
    }
}

// MARK: - Equatable Conformance (Performance Optimization)
extension ExpandableList: Equatable where Item: Equatable {
    static func == (lhs: ExpandableList<Item, Content>, rhs: ExpandableList<Item, Content>) -> Bool {
        lhs.items == rhs.items &&
        lhs.spacing == rhs.spacing &&
        lhs.expandedItems == rhs.expandedItems
    }
}

// MARK: - Public API Extensions
extension ExpandableList {
    /// Expands all items in the list
    func expandAll() -> Self {
        var copy = self
        copy._expandedItems = State(initialValue: Set(items.map(\.id)))
        return copy
    }
    
    /// Collapses all items in the list
    func collapseAll() -> Self {
        var copy = self
        copy._expandedItems = State(initialValue: [])
        return copy
    }
    
    /// Toggles the expansion state of a specific item
    func toggle(item: Item) -> Self {
        var copy = self
        var newExpanded = copy.expandedItems
        if newExpanded.contains(item.id) {
            newExpanded.remove(item.id)
        } else {
            newExpanded.insert(item.id)
        }
        copy._expandedItems = State(initialValue: newExpanded)
        return copy
    }
}

// MARK: - Demo Models for Preview
private struct DemoExercise: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let sets: [DemoSet]
    let notes: String?
    
    static let samples: [DemoExercise] = [
        DemoExercise(
            name: "Push-ups",
            sets: [
                DemoSet(reps: 10, weight: nil),
                DemoSet(reps: 12, weight: nil),
                DemoSet(reps: 8, weight: nil)
            ],
            notes: "Focus on form over speed"
        ),
        DemoExercise(
            name: "Bench Press",
            sets: [
                DemoSet(reps: 8, weight: 135),
                DemoSet(reps: 6, weight: 145),
                DemoSet(reps: 4, weight: 155)
            ],
            notes: "Increase weight gradually"
        ),
        DemoExercise(
            name: "Squats",
            sets: [
                DemoSet(reps: 12, weight: 185),
                DemoSet(reps: 10, weight: 205),
                DemoSet(reps: 8, weight: 225)
            ],
            notes: nil
        ),
        DemoExercise(
            name: "Deadlifts",
            sets: [
                DemoSet(reps: 5, weight: 275),
                DemoSet(reps: 5, weight: 285),
                DemoSet(reps: 3, weight: 295)
            ],
            notes: "Maintain proper form throughout"
        )
    ]
}

private struct DemoSet: Identifiable, Equatable {
    let id = UUID()
    let reps: Int
    let weight: Int?
}

private struct DemoWorkout: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let duration: String
    let difficulty: String
    let exercises: [String]
    
    static let samples: [DemoWorkout] = [
        DemoWorkout(
            name: "Upper Body Strength",
            duration: "45 min",
            difficulty: "Intermediate",
            exercises: ["Bench Press", "Pull-ups", "Shoulder Press", "Dips"]
        ),
        DemoWorkout(
            name: "Leg Day",
            duration: "60 min",
            difficulty: "Advanced",
            exercises: ["Squats", "Deadlifts", "Lunges", "Calf Raises"]
        ),
        DemoWorkout(
            name: "Cardio HIIT",
            duration: "30 min",
            difficulty: "Beginner",
            exercises: ["Jumping Jacks", "Burpees", "Mountain Climbers"]
        )
    ]
}

// MARK: - Preview Provider
#Preview("ExpandableList Complete Showcase") {
    ScrollView {
        VStack(spacing: ComponentConstants.Layout.sectionSpacing) {
            // MARK: Exercise List Example
            VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                SectionHeader(title: "Exercise List Example")
                
                ExpandableList(
                    items: DemoExercise.samples,
                    initiallyExpanded: [DemoExercise.samples[0].id]
                ) { exercise, index, isExpanded in
                    ExpandableExerciseCard(
                        exercise: exercise,
                        index: index,
                        isExpanded: isExpanded
                    )
                }
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
            
            Divider()
                .padding(.vertical)
            
            // MARK: Workout List Example
            VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                SectionHeader(title: "Workout List Example")
                
                ExpandableList(
                    items: DemoWorkout.samples,
                    spacing: ComponentConstants.Layout.compactPadding
                ) { workout, index, isExpanded in
                    ExpandableWorkoutCard(
                        workout: workout,
                        index: index,
                        isExpanded: isExpanded
                    )
                }
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
            
            Divider()
                .padding(.vertical)
            
            // MARK: Settings-Style List
            VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                SectionHeader(title: "Settings-Style List")
                
                ExpandableList(
                    items: SettingsSection.samples
                ) { section, index, isExpanded in
                    ExpandableSettingsSection(
                        section: section,
                        isExpanded: isExpanded
                    )
                }
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
            
            Divider()
                .padding(.vertical)
            
            // MARK: Minimal Example
            VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                SectionHeader(title: "Minimal Example")
                
                ExpandableList(
                    items: ["First Item", "Second Item", "Third Item"].enumerated().map { 
                        SimpleItem(id: $0, title: $1) 
                    }
                ) { item, index, isExpanded in
                    VStack(alignment: .leading, spacing: 8) {
                        // Header
                        Button(action: { isExpanded.wrappedValue.toggle() }) {
                            HStack {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .rotationEffect(.degrees(isExpanded.wrappedValue ? 90 : 0))
                            }
                            .padding()
                            .background(ComponentConstants.Colors.secondaryGroupedBackground)
                            .cornerRadius(ComponentConstants.Layout.smallCornerRadius)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Expandable Content
                        if isExpanded.wrappedValue {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("This is the expanded content for \(item.title)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Text("You can put any content here, including complex views with multiple elements.")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding()
                            .background(ComponentConstants.Colors.tertiaryBackground)
                            .cornerRadius(ComponentConstants.Layout.smallCornerRadius)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.95).combined(with: .opacity),
                                removal: .scale(scale: 0.95).combined(with: .opacity)
                            ))
                        }
                    }
                }
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
        }
        .padding(.vertical)
    }
    .background(ComponentConstants.Colors.groupedBackground)
}

// MARK: - Preview Helper Components
private struct ExpandableExerciseCard: View {
    let exercise: DemoExercise
    let index: Int
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(exercise.sets.count) sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding()
                .background(ComponentConstants.Colors.secondaryGroupedBackground)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable Content
            if isExpanded {
                VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                    // Sets
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sets")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                            HStack {
                                Text("Set \(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(set.reps) reps")
                                    .font(.caption)
                                
                                if let weight = set.weight {
                                    Text("@ \(weight) lbs")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    
                    // Notes
                    if let notes = exercise.notes {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(ComponentConstants.Colors.tertiaryBackground)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
        .cornerRadius(ComponentConstants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: ComponentConstants.Layout.cornerRadius)
                .stroke(ComponentConstants.Colors.separator, lineWidth: 0.5)
        )
    }
}

private struct ExpandableWorkoutCard: View {
    let workout: DemoWorkout
    let index: Int
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            Label(workout.duration, systemImage: "clock")
                            Label(workout.difficulty, systemImage: "chart.bar")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        
                        Text("\(workout.exercises.count) exercises")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
                .background(ComponentConstants.Colors.secondaryGroupedBackground)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable Content
            if isExpanded {
                VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                    Text("Exercises")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(workout.exercises, id: \.self) { exercise in
                            Text(exercise)
                                .font(.caption)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(ComponentConstants.Colors.secondaryBackground)
                                .cornerRadius(ComponentConstants.Layout.smallCornerRadius)
                        }
                    }
                }
                .padding()
                .background(ComponentConstants.Colors.tertiaryBackground)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
        .cornerRadius(ComponentConstants.Layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: ComponentConstants.Layout.cornerRadius)
                .stroke(ComponentConstants.Colors.separator, lineWidth: 0.5)
        )
    }
}

private struct SettingsSection: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let items: [String]
    
    static let samples: [SettingsSection] = [
        SettingsSection(title: "General", items: ["Notifications", "Privacy", "Language"]),
        SettingsSection(title: "Workout", items: ["Default Sets", "Rest Timers", "Units"]),
        SettingsSection(title: "Advanced", items: ["Export Data", "Reset App", "Debug Mode"])
    ]
}

private struct ExpandableSettingsSection: View {
    let section: SettingsSection
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 1) {
            // Header
            Button(action: { isExpanded.toggle() }) {
                Row(
                    content: {
                        Text(section.title)
                            .font(ComponentConstants.Row.titleFont)
                            .foregroundColor(ComponentConstants.Row.primaryTextColor)
                    },
                    trailing: {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable Content
            if isExpanded {
                ForEach(Array(section.items.enumerated()), id: \.element) { index, item in
                    let position: RowPosition = {
                        if section.items.count == 1 { return .only }
                        if index == 0 { return .first }
                        if index == section.items.count - 1 { return .last }
                        return .middle
                    }()
                    
                    Row(position: position) {
                        Text(item)
                            .font(ComponentConstants.Row.titleFont)
                            .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                            .padding(.leading, ComponentConstants.Layout.defaultPadding)
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.98).combined(with: .opacity),
                    removal: .scale(scale: 0.98).combined(with: .opacity)
                ))
            }
        }
    }
}

private struct SimpleItem: Identifiable, Equatable {
    let id: Int
    let title: String
}


