import SwiftUI

// MARK: - Expandable Component
/// A reusable expandable container with animated header and content sections.
/// Follows CLAUDE.md performance principles with pre-computed values and Equatable conformance.
///
/// Usage:
/// 
/// With external state management (recommended for lists):
/// ```swift
/// @State private var isExpanded = false
/// 
/// Expandable(isExpanded: $isExpanded) {
///     Text("Section Title")
/// } content: {
///     Text("Content")
/// }
/// ```
///
/// With internal state management (for standalone usage):
/// ```swift
/// ExpandableState {
///     Text("Section Title")
/// } content: {
///     Text("Content")
/// }
/// ```
///
/// List Animation:
/// When using in a ScrollView/LazyVStack, apply animation to the container:
/// ```swift
/// @State private var expandedItems: Set<Int> = []
/// 
/// ScrollView {
///     VStack(spacing: 8) {
///         ForEach(items) { item in
///             Expandable(isExpanded: Binding(
///                 get: { expandedItems.contains(item.id) },
///                 set: { if $0 { expandedItems.insert(item.id) } else { expandedItems.remove(item.id) } }
///             )) { ... }
///         }
///     }
///     .animation(.spring(response: 0.4, dampingFraction: 0.8), value: expandedItems)
/// }
/// ```
struct Expandable<Header: View, Content: View>: View, Equatable {
    @Binding var isExpanded: Bool
    
    // ViewBuilder closures for lazy evaluation
    @ViewBuilder let header: () -> Header
    @ViewBuilder let content: () -> Content
    
    // Pre-computed animation values
    private let animation = ComponentConstants.Animation.springAnimation
    
    init(
        isExpanded: Binding<Bool>,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isExpanded = isExpanded
        self.header = header
        self.content = content
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with tap interaction
            Button(action: toggleExpanded) {
                HStack(spacing: ComponentConstants.Row.contentSpacing) {
                    header()
                    
                    Spacer(minLength: 0)
                    
                    // Animated chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.system(size: ComponentConstants.Expandable.chevronSize, weight: .medium))
                        .foregroundStyle(ComponentConstants.Expandable.chevronColor)
                        .rotationEffect(rotationAngle)
                        .animation(animation, value: isExpanded)
                }
                .padding(.horizontal, ComponentConstants.Expandable.headerPadding)
                .padding(.vertical, ComponentConstants.Row.verticalPadding)
                .contentShape(Rectangle())
            }
            .buttonStyle(ExpandableButtonStyle())
            
            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: ComponentConstants.Expandable.itemSpacing) {
                    content()
                }
                .padding(.horizontal, ComponentConstants.Expandable.contentPadding)
                .padding(.bottom, ComponentConstants.Expandable.contentPadding)
                .transition(ComponentConstants.Expandable.insertionTransition)
            }
        }
        .background(ComponentConstants.Expandable.headerBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: ComponentConstants.Expandable.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: ComponentConstants.Expandable.cornerRadius)
                .stroke(ComponentConstants.Expandable.borderColor, lineWidth: ComponentConstants.Expandable.borderWidth)
        )
    }
    
    // MARK: - Private Methods
    
    private func toggleExpanded() {
        isExpanded.toggle()
    }
    
    private var rotationAngle: Angle {
        Angle(degrees: isExpanded ? ComponentConstants.Expandable.expandedRotation : ComponentConstants.Expandable.collapsedRotation)
    }
    
    // MARK: - Equatable Conformance
    
    static func == (lhs: Expandable<Header, Content>, rhs: Expandable<Header, Content>) -> Bool {
        // Compare only the state that affects rendering
        lhs.isExpanded == rhs.isExpanded
    }
}

// MARK: - Custom Button Style

/// Custom button style that removes default button styling and visual feedback
private struct ExpandableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(
                .easeInOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

// MARK: - Expandable State Wrapper
/// A wrapper that manages expandable state internally for simpler usage
struct ExpandableState<Header: View, Content: View>: View {
    @State private var isExpanded: Bool
    
    @ViewBuilder let header: () -> Header
    @ViewBuilder let content: () -> Content
    
    init(
        isExpanded: Bool = false,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isExpanded = State(initialValue: isExpanded)
        self.header = header
        self.content = content
    }
    
    var body: some View {
        Expandable(isExpanded: $isExpanded, header: header, content: content)
    }
}

// MARK: - Preview Provider

#Preview("Expandable Component") {
    struct PreviewContent: View {
        @State private var expandedStates: Set<Int> = [0]
        
        var body: some View {
            ScrollView {
                VStack(spacing: ComponentConstants.Layout.sectionSpacing) {
                    // Example 1: Simple text content
                    Expandable(isExpanded: Binding(
                        get: { expandedStates.contains(0) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedStates.insert(0)
                            } else {
                                expandedStates.remove(0)
                            }
                        }
                    )) {
                        Label("Section 1", systemImage: "folder")
                            .font(ComponentConstants.Expandable.headerFont)
                    } content: {
                        ForEach(1...3, id: \.self) { index in
                            HStack {
                                Image(systemName: "doc")
                                    .foregroundStyle(.secondary)
                                Text("Item \(index)")
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // Example 2: Complex content with controls
                    Expandable(isExpanded: Binding(
                        get: { expandedStates.contains(1) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedStates.insert(1)
                            } else {
                                expandedStates.remove(1)
                            }
                        }
                    )) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Workout Settings")
                                    .font(ComponentConstants.Expandable.headerFont)
                                Text("3 intervals • 45 min")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } content: {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Rest Between Sets")
                                Spacer()
                                Text("60s")
                                    .foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Text("Target Heart Rate")
                                Spacer()
                                Text("140-160 bpm")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Button("Edit Settings") {
                                // Action
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    // Example 3: Nested expandables
                    Expandable(isExpanded: Binding(
                        get: { expandedStates.contains(2) },
                        set: { isExpanded in
                            if isExpanded {
                                expandedStates.insert(2)
                            } else {
                                expandedStates.remove(2)
                            }
                        }
                    )) {
                        Text("Parent Section")
                            .font(ComponentConstants.Expandable.headerFont)
                    } content: {
                        VStack(spacing: 8) {
                            Text("Some parent content")
                                .padding(.vertical, 4)
                            
                            // Use ExpandableState for nested expandable with internal state management
                            ExpandableState {
                                Text("Nested Section")
                                    .font(.subheadline)
                            } content: {
                                Text("Nested content goes here")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // Design adjustments section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Design Adjustments")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Tap-only interaction on entire header", systemImage: "hand.tap")
                            Label("Smooth spring animation", systemImage: "waveform")
                            Label("Chevron rotation indicator", systemImage: "chevron.right.circle")
                            Label("No shadow effects (per CLAUDE.md)", systemImage: "shadow")
                            Label("Equatable for performance", systemImage: "speedometer")
                            Label("List animations via parent container", systemImage: "list.bullet")
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        
                        Text("Animation Constants")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Duration: \(ComponentConstants.Expandable.animationDuration)s")
                            Text("Spring Response: \(ComponentConstants.Expandable.springResponse)")
                            Text("Spring Damping: \(ComponentConstants.Expandable.springDamping)")
                            Text("Rotation: 0° → 90°")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        
                        Text("List Animation Note")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        Text("When used in lists, apply animation to the parent container with expandedStates as the value parameter for smooth position transitions.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
                .padding()
                // Animate list layout changes based on expanded states
                .animation(ComponentConstants.Animation.springAnimation, value: expandedStates)
            }
            .background(ComponentConstants.Colors.groupedBackground)
        }
    }
    
    return PreviewContent()
}

#Preview("Performance Test") {
    struct PerformanceTestView: View {
        @State private var expandedItems: Set<Int> = [0, 1]
        
        var body: some View {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(0..<50) { index in
                        Expandable(isExpanded: Binding(
                            get: { expandedItems.contains(index) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedItems.insert(index)
                                } else {
                                    expandedItems.remove(index)
                                }
                            }
                        )) {
                            HStack {
                                Text("Section \(index + 1)")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int.random(in: 3...10)) items")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } content: {
                            ForEach(0..<5) { itemIndex in
                                HStack {
                                    Circle()
                                        .fill(.secondary.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    VStack(alignment: .leading) {
                                        Text("Item \(itemIndex + 1)")
                                            .font(.subheadline)
                                        Text("Description text")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding()
                // Animate layout changes when items expand/collapse
                .animation(ComponentConstants.Animation.springAnimation, value: expandedItems)
            }
            .background(ComponentConstants.Colors.groupedBackground)
        }
    }
    
    return PerformanceTestView()
}