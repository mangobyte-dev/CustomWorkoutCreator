import SwiftUI

// MARK: - Component Constants
// Pre-computed static values following CLAUDE.md performance principles
// All values are computed at compile time to avoid runtime allocations

enum ComponentConstants {
    
    // MARK: - SectionHeader Constants
    enum SectionHeader {
        // Typography
        static let titleFont: Font = .headline
        static let subtitleFont: Font = .subheadline
        
        // Colors
        static let titleColor: Color = .primary
        static let subtitleColor: Color = .secondary
        static let backgroundColor: Color = Color(UIColor.systemGroupedBackground)
        
        // Spacing & Padding
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 8
        static let titleSubtitleSpacing: CGFloat = 4
        
        // Layout
        static let cornerRadius: CGFloat = 0
        static let dividerOpacity: Double = 0.3
    }
    
    // MARK: - Row Constants
    enum Row {
        // Spacing & Padding
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 12
        static let contentSpacing: CGFloat = 8
        static let iconTextSpacing: CGFloat = 12
        
        // Colors
        static let backgroundColor: Color = Color(UIColor.secondarySystemGroupedBackground)
        static let selectedBackgroundColor: Color = Color(UIColor.systemGray4)
        static let borderColor: Color = Color(UIColor.separator)
        static let primaryTextColor: Color = .primary
        static let secondaryTextColor: Color = .secondary
        static let destructiveColor: Color = .red
        
        // Layout
        static let cornerRadius: CGFloat = 10
        static let borderWidth: CGFloat = 0.5
        static let shadowRadius: CGFloat = 2
        static let shadowOpacity: Double = 0.1
        static let shadowOffsetY: CGFloat = 1
        
        // Typography
        static let titleFont: Font = .body
        static let subtitleFont: Font = .caption
        static let valueFont: Font = .body
        
        // Icons
        static let chevronSize: CGFloat = 14
        static let iconSize: CGFloat = 20
        
        // Animation
        static let selectionAnimationDuration: Double = 0.1
        
        // Pre-computed Formatters (cached to avoid repeated allocations)
        static let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 0
            return formatter
        }()
        
        static let percentFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = 0
            return formatter
        }()
        
        static let timeFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            return formatter
        }()
        
        static let shortTimeFormatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }()
    }
    
    // MARK: - Expandable Constants
    enum Expandable {
        // Animation
        static let animationDuration: Double = 0.3
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.8
        static let rotationAngle: Double = 90
        static let collapsedRotation: Double = 0
        static let expandedRotation: Double = 90
        
        // Colors
        static let headerBackgroundColor: Color = Color(UIColor.secondarySystemGroupedBackground)
        static let contentBackgroundColor: Color = Color(UIColor.tertiarySystemGroupedBackground)
        static let chevronColor: Color = .secondary
        static let borderColor: Color = Color(UIColor.separator)
        
        // Spacing & Padding
        static let headerPadding: CGFloat = 16
        static let contentPadding: CGFloat = 12
        static let itemSpacing: CGFloat = 8
        static let chevronSize: CGFloat = 16
        
        // Layout
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 0.5
        static let dividerHeight: CGFloat = 0.5
        
        // Typography
        static let headerFont: Font = .headline
        static let contentFont: Font = .body
        
        // Transition
        static let insertionTransition: AnyTransition = .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 0.8).combined(with: .opacity)
        )
    }
    
    // MARK: - ActionButton Constants
    enum ActionButton {
        // Size Variants
        enum Small {
            static let horizontalPadding: CGFloat = 16
            static let verticalPadding: CGFloat = 8
            static let minHeight: CGFloat = 36
            static let cornerRadius: CGFloat = 8
            static let iconSize: CGFloat = 14
            static let font: Font = .footnote.weight(.medium)
        }
        
        enum Medium {
            static let horizontalPadding: CGFloat = 20
            static let verticalPadding: CGFloat = 12
            static let minHeight: CGFloat = 44
            static let cornerRadius: CGFloat = 10
            static let iconSize: CGFloat = 18
            static let font: Font = .body.weight(.medium)
        }
        
        enum Large {
            static let horizontalPadding: CGFloat = 24
            static let verticalPadding: CGFloat = 16
            static let minHeight: CGFloat = 52
            static let cornerRadius: CGFloat = 12
            static let iconSize: CGFloat = 22
            static let font: Font = .title3.weight(.medium)
        }
        
        // Common Constants (defaults to medium)
        static let horizontalPadding: CGFloat = Medium.horizontalPadding
        static let verticalPadding: CGFloat = Medium.verticalPadding
        static let minHeight: CGFloat = Medium.minHeight
        static let cornerRadius: CGFloat = Medium.cornerRadius
        static let borderWidth: CGFloat = 2
        static let iconSize: CGFloat = Medium.iconSize
        static let iconSpacing: CGFloat = 8
        
        // Typography
        static let labelFont: Font = Medium.font
        static let compactLabelFont: Font = .footnote.weight(.medium)
        
        // Animation
        static let pressAnimationScale: CGFloat = 0.95
        static let pressAnimationDuration: Double = 0.1
        static let disabledOpacity: Double = 0.6
        
        // Refined Animation Constants
        static let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
        static let brightnessDelta: Double = -0.05
        static let linkBrightnessDelta: Double = 0.0
        
        // Primary Style Colors
        enum Primary {
            static let backgroundColor: Color = .accentColor
            static let foregroundColor: Color = .white
            static let pressedBackgroundColor: Color = Color.accentColor.opacity(0.8)
        }
        
        // Secondary Style Colors
        enum Secondary {
            static let backgroundColor: Color = Color(UIColor.secondarySystemFill)
            static let foregroundColor: Color = .primary
            static let borderColor: Color = Color(UIColor.separator)
            static let pressedBackgroundColor: Color = Color(UIColor.tertiarySystemFill)
            static let pressedForegroundColor: Color = .primary
            static let pressedBorderColor: Color = Color(UIColor.opaqueSeparator)
        }
        
        // Destructive Style Colors
        enum Destructive {
            static let backgroundColor: Color = .red
            static let foregroundColor: Color = .white
            static let pressedBackgroundColor: Color = Color.red.opacity(0.8)
        }
        
        // Ghost Style Colors
        enum Ghost {
            static let backgroundColor: Color = .clear
            static let foregroundColor: Color = .accentColor
            static let borderColor: Color = .accentColor
            static let pressedBackgroundColor: Color = Color.accentColor.opacity(0.1)
            static let pressedForegroundColor: Color = Color.accentColor.opacity(0.7)
            static let pressedBorderColor: Color = Color.accentColor.opacity(0.7)
        }
        
        // Link Style Colors
        enum Link {
            static let backgroundColor: Color = .clear
            static let foregroundColor: Color = .accentColor
            static let pressedForegroundColor: Color = Color.accentColor.opacity(0.7)
            static let underlineColor: Color = .accentColor
        }
        
        // Shadow Properties
        static let shadowColor: Color = Color.black.opacity(0.1)
        static let shadowRadius: CGFloat = 4
        static let shadowOffsetY: CGFloat = 2
        
        // Loading State
        static let loadingAnimationDuration: Double = 1.0
        static let loadingSpinnerSize: CGFloat = 16
    }
    
    // MARK: - Global Animation Constants
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let quickDuration: Double = 0.15
        static let slowDuration: Double = 0.5
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.8
        static let defaultAnimation: SwiftUI.Animation = .easeInOut(duration: defaultDuration)
        static let springAnimation: SwiftUI.Animation = .spring(response: springResponse, dampingFraction: springDamping)
    }
    
    // MARK: - Global Layout Constants
    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let defaultCornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let largeCornerRadius: CGFloat = 16
        static let defaultPadding: CGFloat = 16
        static let compactPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        static let itemSpacing: CGFloat = 12
        static let sectionSpacing: CGFloat = 20
    }
    
    // MARK: - Global Color Constants
    enum Colors {
        static let primaryBackground: Color = Color(UIColor.systemBackground)
        static let secondaryBackground: Color = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground: Color = Color(UIColor.tertiarySystemBackground)
        static let groupedBackground: Color = Color(UIColor.systemGroupedBackground)
        static let secondaryGroupedBackground: Color = Color(UIColor.secondarySystemGroupedBackground)
        static let separator: Color = Color(UIColor.separator)
        static let opaqueSeparator: Color = Color(UIColor.opaqueSeparator)
        static let primaryLabel: Color = Color(UIColor.label)
        static let secondaryLabel: Color = Color(UIColor.secondaryLabel)
        static let tertiaryLabel: Color = Color(UIColor.tertiaryLabel)
        static let quaternaryLabel: Color = Color(UIColor.quaternaryLabel)
    }
}

// MARK: - Helper Extensions for Pre-computed Values
extension ComponentConstants {
    // Pre-computed gradient for performance
    static let defaultGradient = LinearGradient(
        gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
