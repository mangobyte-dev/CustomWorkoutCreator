//
//  SectionHeader.swift
//  CustomWorkoutCreator
//
//  Created by Developer on 30/07/2025.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let trailingContent: AnyView?
    
    // Pre-computed static values
    private static let titleFont = Font.headline
    private static let titleColor = Color.secondary
    private static let verticalPadding: CGFloat = 8
    private static let horizontalPadding: CGFloat = 16
    private static let topPadding: CGFloat = 20
    
    init(title: String) {
        self.title = title
        self.trailingContent = nil
    }
    
    init<Content: View>(title: String, @ViewBuilder trailing: () -> Content) {
        self.title = title
        self.trailingContent = AnyView(trailing())
    }
    
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(Self.titleFont)
                .foregroundStyle(Self.titleColor)
            
            Spacer()
            
            if let trailingContent {
                trailingContent
            }
        }
        .padding(.horizontal, Self.horizontalPadding)
        .padding(.top, Self.topPadding)
        .padding(.bottom, Self.verticalPadding)
    }
}

#Preview("Basic Header") {
    VStack(spacing: 0) {
        SectionHeader(title: "Workout Details")
        
        Rectangle()
            .fill(Color(.systemBackground))
            .frame(height: 100)
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Header with Trailing") {
    VStack(spacing: 0) {
        SectionHeader(title: "Intervals") {
            Button("Add") {
                print("Add tapped")
            }
            .font(.callout)
        }
        
        Rectangle()
            .fill(Color(.systemBackground))
            .frame(height: 100)
    }
    .background(Color(.systemGroupedBackground))
}