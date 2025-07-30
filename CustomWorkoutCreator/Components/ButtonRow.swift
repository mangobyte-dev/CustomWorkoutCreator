//
//  ButtonRow.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 30/07/2025.
//

import SwiftUI

struct ButtonRow: View {
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case add
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .accentColor
            case .secondary: return .secondary
            case .destructive: return .red
            case .add: return .accentColor
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .destructive: return Color.red.opacity(0.1)
            default: return Color.clear
            }
        }
        
        var iconName: String? {
            switch self {
            case .add: return "plus.circle.fill"
            case .destructive: return "trash"
            default: return nil
            }
        }
    }
    
    let title: String
    let style: ButtonStyle
    let systemImage: String?
    let action: () -> Void
    
    // Pre-computed static values
    private static let horizontalPadding: CGFloat = 16
    private static let verticalPadding: CGFloat = 12
    private static let iconSpacing: CGFloat = 8
    private static let cornerRadius: CGFloat = 10
    private static let destructiveBackgroundOpacity: Double = 0.1
    
    init(
        _ title: String,
        style: ButtonStyle = .primary,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.systemImage = systemImage ?? style.iconName
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Self.iconSpacing) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.medium))
                }
                
                Text(title)
                    .font(.body.weight(style == .add ? .medium : .regular))
                
                if style != .add {
                    Spacer()
                }
            }
            .foregroundStyle(style.foregroundColor)
            .padding(.horizontal, Self.horizontalPadding)
            .padding(.vertical, Self.verticalPadding)
            .frame(maxWidth: style == .add ? nil : .infinity)
            .background(style.backgroundColor)
            .cornerRadius(Self.cornerRadius)
        }
        .buttonStyle(.plain)
    }
}

// Convenience factory methods
extension ButtonRow {
    static func deleteButton(action: @escaping () -> Void) -> ButtonRow {
        ButtonRow("Delete", style: .destructive, action: action)
    }
    
    static func addButton(_ title: String, action: @escaping () -> Void) -> ButtonRow {
        ButtonRow(title, style: .add, action: action)
    }
    
    static func actionButton(
        _ title: String,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) -> ButtonRow {
        ButtonRow(title, style: .primary, systemImage: systemImage, action: action)
    }
}

#Preview("Button Styles") {
    VStack(spacing: 16) {
        ButtonRow("Primary Action", style: .primary) {
            print("Primary tapped")
        }
        
        ButtonRow("Secondary Action", style: .secondary, systemImage: "gear") {
            print("Secondary tapped")
        }
        
        ButtonRow.deleteButton {
            print("Delete tapped")
        }
        
        ButtonRow.addButton("Add Exercise") {
            print("Add tapped")
        }
        
        ButtonRow.actionButton("Start Workout", systemImage: "play.fill") {
            print("Start tapped")
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}