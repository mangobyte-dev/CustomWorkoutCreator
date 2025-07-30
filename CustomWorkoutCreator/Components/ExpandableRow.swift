//
//  ExpandableRow.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 30/07/2025.
//

import SwiftUI

struct ExpandableRow<Header: View, Content: View>: View {
    let header: Header
    let content: Content
    @State private var isExpanded: Bool
    
    // Pre-computed static values
    private static let chevronAnimationDuration: Double = 0.3
    private static let contentAnimationDuration: Double = 0.35
    private static let chevronRotation: Double = 90
    private static let headerBackgroundColor = Color(.systemBackground)
    private static let cornerRadius: CGFloat = 10
    private static let horizontalPadding: CGFloat = 16
    
    init(
        isExpanded: Bool = false,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self._isExpanded = State(initialValue: isExpanded)
        self.header = header()
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with tap gesture
            Button(action: toggleExpansion) {
                HStack {
                    header
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? Self.chevronRotation : 0))
                        .animation(
                            .easeInOut(duration: Self.chevronAnimationDuration),
                            value: isExpanded
                        )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Self.headerBackgroundColor)
                .cornerRadius(Self.cornerRadius)
            }
            .buttonStyle(.plain)
            
            // Expandable content
            if isExpanded {
                content
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
                    .animation(
                        .easeInOut(duration: Self.contentAnimationDuration),
                        value: isExpanded
                    )
            }
        }
        .padding(.horizontal, Self.horizontalPadding)
    }
    
    private func toggleExpansion() {
        withAnimation {
            isExpanded.toggle()
        }
    }
}

// Convenience initializer for simple text headers
extension ExpandableRow where Header == Text {
    init(
        title: String,
        isExpanded: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.init(isExpanded: isExpanded) {
            Text(title)
                .font(.headline)
        } content: {
            content()
        }
    }
}

// Pre-built expandable row for common patterns
struct LabeledExpandableRow<Content: View>: View {
    let title: String
    let subtitle: String?
    let systemImage: String?
    let isExpanded: Bool
    let content: Content
    
    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        isExpanded: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        ExpandableRow(isExpanded: isExpanded) {
            HStack(spacing: 12) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(.accent)
                        .frame(width: 24)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } content: {
            content
        }
    }
}

#Preview("Simple Expandable") {
    VStack(spacing: 16) {
        ExpandableRow(title: "Interval Details") {
            VStack(spacing: 8) {
                CustomRow {
                    Text("3 rounds")
                }
                CustomRow {
                    Text("60s rest between rounds")
                }
            }
        }
        
        ExpandableRow(title: "Expanded by Default", isExpanded: true) {
            CustomRow {
                Text("This content is visible by default")
            }
        }
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Complex Expandable") {
    VStack(spacing: 16) {
        LabeledExpandableRow(
            title: "Workout Settings",
            subtitle: "Customize your workout",
            systemImage: "gear"
        ) {
            VStack(spacing: 0) {
                CustomRow {
                    Toggle("Auto-advance intervals", isOn: .constant(true))
                }
                Divider()
                    .padding(.leading, 48)
                CustomRow {
                    Toggle("Sound effects", isOn: .constant(false))
                }
            }
        }
        
        LabeledExpandableRow(
            title: "Exercise: Push-ups",
            subtitle: "3 sets • 10-15 reps",
            systemImage: "figure.strengthtraining.traditional"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                CustomRow {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Instructions")
                            .font(.subheadline.weight(.semibold))
                        Text("Keep your core tight and maintain a straight line from head to heels.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ButtonRow.deleteButton {
                    print("Delete exercise")
                }
            }
        }
    }
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
}