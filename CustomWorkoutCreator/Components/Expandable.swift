import SwiftUI

// MARK: - Expandable Component
/// A reusable expandable container with animated header and content sections.
/// Follows CLAUDE.md performance principles with pre-computed values and Equatable conformance.
///
/// Usage:
/// ```swift
/// Expandable(isExpanded: true) {
///     // Header content
///     HStack {
///         Text("Section Title")
///         Spacer()
///     }
/// } content: {
///     // Expandable content
///     VStack {
///         Text("Content 1")
///         Text("Content 2")
///     }
/// }
/// ```
struct Expandable<Header: View, Content: View>: View, Equatable {
    @State private var isExpanded: Bool
    
    // ViewBuilder closures for lazy evaluation
    @ViewBuilder let header: () -> Header
    @ViewBuilder let content: () -> Content
    
    // Pre-computed animation values
    private let animation = ComponentConstants.Animation.springAnimation
    private let chevronRotation: Angle
    
    init(
        isExpanded: Bool = false,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isExpanded = State(initialValue: isExpanded)
        self.header = header
        self.content = content
        
        // Pre-compute rotation angle
        self.chevronRotation = Angle(degrees: isExpanded ? ComponentConstants.Expandable.expandedRotation : ComponentConstants.Expandable.collapsedRotation)
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
        .animation(animation, value: isExpanded)
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

/// Custom button style that removes default button styling while maintaining interaction feedback
private struct ExpandableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed 
                    ? ComponentConstants.Row.selectedBackgroundColor 
                    : Color.clear
            )
            .animation(
                .easeInOut(duration: ComponentConstants.Row.selectionAnimationDuration),
                value: configuration.isPressed
            )
    }
}

// MARK: - Preview Provider

#Preview("Expandable Component") {
    ScrollView {
        VStack(spacing: ComponentConstants.Layout.sectionSpacing) {
            // Example 1: Simple text content
            Expandable(isExpanded: true) {
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
            Expandable {
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
            Expandable {
                Text("Parent Section")
                    .font(ComponentConstants.Expandable.headerFont)
            } content: {
                VStack(spacing: 8) {
                    Text("Some parent content")
                        .padding(.vertical, 4)
                    
                    Expandable {
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
            }
            .padding(.horizontal)
        }
        .padding()
    }
    .background(ComponentConstants.Colors.groupedBackground)
}

#Preview("Performance Test") {
    ScrollView {
        LazyVStack(spacing: 8) {
            ForEach(0..<50) { index in
                Expandable(isExpanded: index < 2) {
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
    }
    .background(ComponentConstants.Colors.groupedBackground)
}