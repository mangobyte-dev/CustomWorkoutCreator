//
//  WorkoutDetailViewCache.swift
//  CustomWorkoutCreator
//
//  Created on 2025-07-31.
//

import Foundation
import SwiftUI

/// Performance-optimized cache for WorkoutDetailView formatters and computed values.
/// All formatters are static to avoid repeated allocations as per CLAUDE.md performance principles.
enum WorkoutDetailViewCache {
    
    // MARK: - Static Formatters
    
    /// Cached date formatter for displaying dates in the UI
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    /// Cached time formatter for displaying times in the UI
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    /// Cached date and time formatter for full timestamp display
    static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: - Duration Formatting
    
    /// Formats a TimeInterval duration into a human-readable string.
    /// - Parameter duration: The duration in seconds
    /// - Returns: A formatted string like "5 min" or "3:45"
    static func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if seconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
    
    // MARK: - Additional Helper Methods
    
    /// Formats a date for display in the workout detail view
    /// - Parameter date: The date to format
    /// - Returns: A formatted date string
    static func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    /// Formats a time for display in the workout detail view
    /// - Parameter date: The date containing the time to format
    /// - Returns: A formatted time string
    static func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
    
    /// Formats a complete date and time for display
    /// - Parameter date: The date to format
    /// - Returns: A formatted date and time string
    static func formatDateTime(_ date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }
}
