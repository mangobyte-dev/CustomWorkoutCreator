//
//  EquatableView.swift
//  CustomWorkoutCreator
//
//  Created by Claude Code on 2025-08-07.
//

import SwiftUI

/// Simple wrapper to optimize list row updates by preventing unnecessary redraws
/// when the wrapped content implements Equatable
struct EquatableView<Content: View & Equatable>: View {
    let content: Content
    
    var body: some View {
        content
    }
}

extension EquatableView: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.content == rhs.content
    }
}