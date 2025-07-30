//
//  CustomRow.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 30/07/2025.
//

import SwiftUI

struct CustomRow<Content: View>: View {
    let content: Content
    let isInset: Bool
    
    // Pre-computed static values
    private static let horizontalPadding: CGFloat = 16
    private static let verticalPadding: CGFloat = 12
    private static let insetLeadingPadding: CGFloat = 32
    private static let backgroundColor = Color(.systemBackground)
    private static let cornerRadius: CGFloat = 10
    private static let insetHorizontalPadding: CGFloat = 16
    
    init(isInset: Bool = false, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isInset = isInset
    }
    
    var body: some View {
        content
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.vertical, Self.verticalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Self.backgroundColor)
            .cornerRadius(isInset ? 0 : Self.cornerRadius)
            .padding(.leading, isInset ? Self.insetLeadingPadding : 0)
            .padding(.horizontal, isInset ? 0 : Self.insetHorizontalPadding)
    }
}

// Convenience extension for common row patterns
extension CustomRow {
    static func labeledRow(
        label: String,
        value: String,
        valueColor: Color = .primary
    ) -> some View {
        CustomRow {
            HStack {
                Text(label)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(value)
                    .foregroundStyle(valueColor)
            }
        }
    }
    
    static func navigationRow(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil
    ) -> some View {
        CustomRow {
            HStack {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(.accent)
                        .frame(width: 28)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.quaternary)
            }
        }
    }
}

#Preview("Basic Row") {
    VStack(spacing: 16) {
        CustomRow {
            Text("Basic Row Content")
        }
        
        CustomRow {
            HStack {
                Text("Row with multiple elements")
                Spacer()
                Text("Value")
                    .foregroundStyle(.secondary)
            }
        }
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Convenience Rows") {
    VStack(spacing: 16) {
        CustomRow.labeledRow(label: "Duration", value: "45:00")
        
        CustomRow.navigationRow(
            title: "Interval 1",
            subtitle: "3 exercises",
            systemImage: "repeat"
        )
        
        CustomRow(isInset: true) {
            Text("Inset row content")
                .font(.callout)
        }
    }
    .background(Color(.systemGroupedBackground))
}