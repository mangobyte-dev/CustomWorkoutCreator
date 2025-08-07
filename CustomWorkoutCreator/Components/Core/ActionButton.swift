import SwiftUI

// MARK: - Action Button Style
enum ActionButtonStyle: String, CaseIterable {
    case primary
    case secondary
    case destructive
    case ghost
    case link
}

// MARK: - Action Button Size
enum ActionButtonSize: String, CaseIterable {
    case small
    case medium
    case large
    
    // Size-specific constants
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return ComponentConstants.ActionButton.Small.horizontalPadding
        case .medium: return ComponentConstants.ActionButton.Medium.horizontalPadding
        case .large: return ComponentConstants.ActionButton.Large.horizontalPadding
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return ComponentConstants.ActionButton.Small.verticalPadding
        case .medium: return ComponentConstants.ActionButton.Medium.verticalPadding
        case .large: return ComponentConstants.ActionButton.Large.verticalPadding
        }
    }
    
    var minHeight: CGFloat {
        switch self {
        case .small: return ComponentConstants.ActionButton.Small.minHeight
        case .medium: return ComponentConstants.ActionButton.Medium.minHeight
        case .large: return ComponentConstants.ActionButton.Large.minHeight
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return ComponentConstants.ActionButton.Small.cornerRadius
        case .medium: return ComponentConstants.ActionButton.Medium.cornerRadius
        case .large: return ComponentConstants.ActionButton.Large.cornerRadius
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .small: return ComponentConstants.ActionButton.Small.iconSize
        case .medium: return ComponentConstants.ActionButton.Medium.iconSize
        case .large: return ComponentConstants.ActionButton.Large.iconSize
        }
    }
    
    var font: Font {
        switch self {
        case .small: return ComponentConstants.ActionButton.Small.font
        case .medium: return ComponentConstants.ActionButton.Medium.font
        case .large: return ComponentConstants.ActionButton.Large.font
        }
    }
    
    // Animation scale factors (smaller buttons = subtler animations)
    var animationScaleFactor: CGFloat {
        switch self {
        case .small: return 0.5
        case .medium: return 1.0
        case .large: return 1.5
        }
    }
}

// MARK: - ActionButton
/// A reusable button component following CLAUDE.md performance principles
/// Step 5: Complete implementation with size variants
struct ActionButton: View {
    // MARK: - Properties
    let title: String
    let icon: String?
    let style: ActionButtonStyle
    let size: ActionButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    // Pre-computed values for icon-only mode
    private var isIconOnly: Bool {
        title.isEmpty && icon != nil
    }
    
    // MARK: - Initialization
    init(
        title: String = "",
        icon: String? = nil,
        style: ActionButtonStyle = .primary,
        size: ActionButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    // MARK: - State
    @State private var isPressed = false
    @State private var pressStartTime: Date?
    
    // MARK: - Pre-computed Values
    private static let pressedScale = ComponentConstants.ActionButton.pressAnimationScale
    private static let animationDuration = ComponentConstants.ActionButton.pressAnimationDuration
    
    // Style-specific animation parameters
    private var pressedScaleX: CGFloat {
        let baseScale: CGFloat = switch style {
        case .primary: 0.94  // Slightly more squish for heavier feel
        case .secondary: 0.95
        case .destructive: 0.93  // More dramatic for destructive actions
        case .ghost: 0.97  // Subtle for ghost buttons
        case .link: 1.0  // No scale for links
        }
        // Apply size-based animation scaling
        return 1.0 - ((1.0 - baseScale) * size.animationScaleFactor)
    }
    
    private var pressedScaleY: CGFloat {
        let baseScale: CGFloat = switch style {
        case .primary: 0.92  // More vertical squish for physical button feel
        case .secondary: 0.94
        case .destructive: 0.91  // Even more dramatic
        case .ghost: 0.96  // Very subtle
        case .link: 1.0  // No scale for links
        }
        // Apply size-based animation scaling
        return 1.0 - ((1.0 - baseScale) * size.animationScaleFactor)
    }
    
    private var pressedOpacity: Double {
        switch style {
        case .primary: return 0.85
        case .secondary: return 0.9
        case .destructive: return 0.8
        case .ghost: return 0.7
        case .link: return 0.6
        }
    }
    
    // Spring parameters for different styles
    private var springResponse: Double {
        switch style {
        case .primary: return 0.35
        case .secondary: return 0.3
        case .destructive: return 0.4
        case .ghost: return 0.25
        case .link: return 0.2
        }
    }
    
    private var springDamping: Double {
        switch style {
        case .primary: return 0.7  // Slightly bouncy
        case .secondary: return 0.75
        case .destructive: return 0.65  // More bounce for emphasis
        case .ghost: return 0.85  // Less bounce, more subtle
        case .link: return 0.9  // Almost no bounce
        }
    }
    
    // Press down is faster than release
    private var pressAnimation: SwiftUI.Animation {
        .spring(response: 0.15, dampingFraction: 0.85)
    }
    
    private var releaseAnimation: SwiftUI.Animation {
        .spring(response: springResponse, dampingFraction: springDamping)
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            if !isDisabled && !isLoading {
                action()
            }
        }) {
            switch style {
            case .primary:
                primaryContent
            case .secondary:
                secondaryContent
            case .destructive:
                destructiveContent
            case .ghost:
                ghostContent
            case .link:
                linkContent
            }
        }
        .scaleEffect(
            x: isPressed && !isDisabled ? pressedScaleX : 1.0,
            y: isPressed && !isDisabled ? pressedScaleY : 1.0
        )
        .opacity(isDisabled ? ComponentConstants.ActionButton.disabledOpacity : (isPressed ? pressedOpacity : 1.0))
        .brightness(isPressed && !isDisabled && style != .link ? -0.05 : 0)  // Subtle darkening except for links
        .rotation3DEffect(
            .degrees(isPressed && !isDisabled && (style == .primary || style == .destructive) ? 1 : 0),
            axis: (x: 1, y: 0, z: 0),
            anchor: .center,
            anchorZ: 0,
            perspective: 1
        )
        .animation(isPressed ? pressAnimation : releaseAnimation, value: isPressed)
        .buttonStyle(PressedButtonStyle(isPressed: $isPressed, pressStartTime: $pressStartTime, isDisabled: isDisabled))
        .disabled(isDisabled || isLoading)
        .overlay(loadingOverlay)
    }
    
    // MARK: - Style Variants
    private var primaryContent: some View {
        contentView(foregroundColor: ComponentConstants.ActionButton.Primary.foregroundColor)
            .frame(maxWidth: isIconOnly ? nil : .infinity)
            .frame(minHeight: size.minHeight)
            .frame(minWidth: isIconOnly ? size.minHeight : nil)
            .padding(.horizontal, isIconOnly ? size.verticalPadding : size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(primaryBackground)
            .cornerRadius(size.cornerRadius)
            .shadow(
                color: ComponentConstants.ActionButton.shadowColor.opacity(isPressed ? 0.15 : 0.25),
                radius: isPressed ? 2 : 4,
                x: 0,
                y: isPressed ? 1 : 2
            )
    }
    
    private var secondaryContent: some View {
        contentView(foregroundColor: isPressed ? ComponentConstants.ActionButton.Secondary.pressedForegroundColor : ComponentConstants.ActionButton.Secondary.foregroundColor)
            .frame(maxWidth: isIconOnly ? nil : .infinity)
            .frame(minHeight: size.minHeight)
            .frame(minWidth: isIconOnly ? size.minHeight : nil)
            .padding(.horizontal, isIconOnly ? size.verticalPadding : size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(isPressed ? ComponentConstants.ActionButton.Secondary.pressedBorderColor : ComponentConstants.ActionButton.Secondary.borderColor, lineWidth: ComponentConstants.ActionButton.borderWidth)
            )
            .cornerRadius(size.cornerRadius)
            .shadow(
                color: ComponentConstants.ActionButton.shadowColor.opacity(isPressed ? 0.05 : 0.1),
                radius: isPressed ? 1 : 2,
                x: 0,
                y: isPressed ? 0.5 : 1
            )
    }
    
    private var destructiveContent: some View {
        contentView(foregroundColor: ComponentConstants.ActionButton.Destructive.foregroundColor)
            .frame(maxWidth: isIconOnly ? nil : .infinity)
            .frame(minHeight: size.minHeight)
            .frame(minWidth: isIconOnly ? size.minHeight : nil)
            .padding(.horizontal, isIconOnly ? size.verticalPadding : size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(destructiveBackground)
            .cornerRadius(size.cornerRadius)
            .shadow(
                color: Color.red.opacity(isPressed ? 0.2 : 0.3),
                radius: isPressed ? 2 : 4,
                x: 0,
                y: isPressed ? 1 : 2
            )
    }
    
    private var ghostContent: some View {
        contentView(foregroundColor: isPressed ? ComponentConstants.ActionButton.Ghost.pressedForegroundColor : ComponentConstants.ActionButton.Ghost.foregroundColor)
            .frame(maxWidth: isIconOnly ? nil : .infinity)
            .frame(minHeight: size.minHeight)
            .frame(minWidth: isIconOnly ? size.minHeight : nil)
            .padding(.horizontal, isIconOnly ? size.verticalPadding : size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(isPressed ? ComponentConstants.ActionButton.Ghost.pressedBorderColor : ComponentConstants.ActionButton.Ghost.borderColor, lineWidth: ComponentConstants.ActionButton.borderWidth)
            )
            .cornerRadius(size.cornerRadius)
    }
    
    private var linkContent: some View {
        contentView(foregroundColor: isPressed ? ComponentConstants.ActionButton.Link.pressedForegroundColor : ComponentConstants.ActionButton.Link.foregroundColor)
            .frame(minHeight: size.minHeight)
            .padding(.horizontal, isIconOnly ? size.verticalPadding : size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
    }
    
    // MARK: - Background Views
    @ViewBuilder
    private var primaryBackground: some View {
        if isPressed {
            ComponentConstants.ActionButton.Primary.pressedBackgroundColor
        } else {
            ComponentConstants.ActionButton.Primary.backgroundColor
        }
    }
    
    @ViewBuilder
    private var secondaryBackground: some View {
        if isPressed {
            ComponentConstants.ActionButton.Secondary.pressedBackgroundColor
        } else {
            ComponentConstants.ActionButton.Secondary.backgroundColor
        }
    }
    
    @ViewBuilder
    private var destructiveBackground: some View {
        if isPressed {
            ComponentConstants.ActionButton.Destructive.pressedBackgroundColor
        } else {
            ComponentConstants.ActionButton.Destructive.backgroundColor
        }
    }
    
    // MARK: - Content View Builder
    @ViewBuilder
    private func contentView(foregroundColor: Color) -> some View {
        if isIconOnly {
            // Icon-only mode
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                    .scaleEffect(size.iconSize / 20) // Scale to match icon size
            } else if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size.iconSize, weight: .medium))
                    .foregroundColor(foregroundColor)
            }
        } else if let icon = icon {
            // Icon + Text mode
            HStack(spacing: ComponentConstants.ActionButton.iconSpacing) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(size.iconSize / 20) // Scale to match icon size
                } else {
                    Image(systemName: icon)
                        .font(.system(size: size.iconSize, weight: .medium))
                        .foregroundColor(foregroundColor)
                }
                
                Text(title)
                    .font(size.font)
                    .foregroundColor(foregroundColor)
            }
        } else {
            // Text-only mode
            HStack(spacing: ComponentConstants.ActionButton.iconSpacing) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(size.iconSize / 20) // Scale to match icon size
                }
                
                Text(title)
                    .font(size.font)
                    .foregroundColor(foregroundColor)
            }
        }
    }
    
    // MARK: - Loading Overlay
    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            // Subtle pulse animation
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(Color.white.opacity(0.1))
                .scaleEffect(isLoading ? 1.02 : 1.0)
                .opacity(isLoading ? 0.0 : 0.3)
                .animation(
                    Animation.easeInOut(duration: ComponentConstants.ActionButton.loadingAnimationDuration)
                        .repeatForever(autoreverses: true),
                    value: isLoading
                )
        }
    }
}

// MARK: - Factory Methods
extension ActionButton {
    /// Creates a toolbar button (small ghost style)
    static func toolbar(
        title: String = "",
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(
            title: title,
            icon: icon,
            style: .ghost,
            size: .small,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }
    
    /// Creates a primary CTA button (large primary style)
    static func cta(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(
            title: title,
            icon: icon,
            style: .primary,
            size: .large,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }
    
    /// Creates a compact button (small secondary style)
    static func compact(
        title: String = "",
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(
            title: title,
            icon: icon,
            style: .secondary,
            size: .small,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }
    
    /// Creates a danger button (destructive style, default medium)
    static func danger(
        title: String,
        icon: String? = nil,
        size: ActionButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) -> ActionButton {
        ActionButton(
            title: title,
            icon: icon,
            style: .destructive,
            size: size,
            isLoading: isLoading,
            isDisabled: isDisabled,
            action: action
        )
    }
}

// MARK: - Button Style
/// Custom button style to track press state with timing
private struct PressedButtonStyle: SwiftUI.ButtonStyle {
    @Binding var isPressed: Bool
    @Binding var pressStartTime: Date?
    let isDisabled: Bool
    
    func makeBody(configuration: SwiftUI.ButtonStyle.Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                if !isDisabled {
                    if newValue {
                        pressStartTime = Date()
                        // Haptic feedback on press (requires UIKit)
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.prepare()
                        impactFeedback.impactOccurred()
                    } else {
                        pressStartTime = nil
                    }
                    isPressed = newValue
                }
            }
    }
}

// MARK: - Previews
#Preview("ActionButton Complete Showcase") {
    InteractiveButtonShowcase()
}

// MARK: - Interactive Preview
struct InteractiveButtonShowcase: View {
    @State private var isLoading = false
    @State private var isDisabled = false
    @State private var loadingStyle: ActionButtonStyle = .primary
    
    var body: some View {
        ScrollView {
            VStack(spacing: ComponentConstants.Layout.sectionSpacing) {
                // MARK: Interactive Controls
                PreviewSection(title: "Interactive Controls") {
                    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                        Toggle("Loading State", isOn: $isLoading)
                            .padding(.horizontal)
                        
                        Toggle("Disabled State", isOn: $isDisabled)
                            .padding(.horizontal)
                        
                        if isLoading {
                            HStack {
                                Text("Loading Style:")
                                Picker("Style", selection: $loadingStyle) {
                                    Text("Primary").tag(ActionButtonStyle.primary)
                                    Text("Secondary").tag(ActionButtonStyle.secondary)
                                    Text("Destructive").tag(ActionButtonStyle.destructive)
                                    Text("Ghost").tag(ActionButtonStyle.ghost)
                                    Text("Link").tag(ActionButtonStyle.link)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding(.horizontal)
                        }
                        
                        // Interactive button
                        ActionButton(
                            title: "Interactive Button",
                            icon: "hand.tap.fill",
                            style: loadingStyle,
                            isLoading: isLoading,
                            isDisabled: isDisabled
                        ) {
                            print("Interactive button tapped!")
                        }
                        .padding(.horizontal)
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // MARK: Size Comparison
                PreviewSection(title: "Size Comparison") {
                    VStack(spacing: ComponentConstants.Layout.sectionSpacing) {
                        // Size comparison grid
                        VStack(alignment: .leading, spacing: ComponentConstants.Layout.itemSpacing) {
                            Text("All Sizes Side by Side")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Small", icon: "s.square", style: .primary, size: .small) {
                                    print("Small tapped")
                                }
                                
                                ActionButton(title: "Medium", icon: "m.square", style: .primary, size: .medium) {
                                    print("Medium tapped")
                                }
                                
                                ActionButton(title: "Large", icon: "l.square", style: .primary, size: .large) {
                                    print("Large tapped")
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                        
                        // Mixed size examples
                        VStack(alignment: .leading, spacing: ComponentConstants.Layout.itemSpacing) {
                            Text("Mixed Size Examples")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Small Ghost Button", icon: "square.dashed", style: .ghost, size: .small) {
                                    print("Small ghost tapped")
                                }
                                
                                ActionButton(title: "Large Primary CTA", icon: "arrow.right.circle.fill", style: .primary, size: .large) {
                                    print("Large primary tapped")
                                }
                                
                                ActionButton(title: "Medium Secondary", icon: "info.circle", style: .secondary, size: .medium) {
                                    print("Medium secondary tapped")
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                        
                        // Toolbar example with small buttons
                        VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                            Text("Toolbar Example (Small Buttons)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            HStack {
                                ActionButton.toolbar(icon: "square.and.arrow.up") {
                                    print("Share tapped")
                                }
                                
                                ActionButton.toolbar(icon: "heart") {
                                    print("Favorite tapped")
                                }
                                
                                ActionButton.toolbar(icon: "ellipsis") {
                                    print("More tapped")
                                }
                                
                                Spacer()
                                
                                ActionButton.toolbar(title: "Edit", icon: "pencil") {
                                    print("Edit tapped")
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                        
                        // Hero section with large CTA
                        VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                            Text("Hero Section Example")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                Text("Start Your Workout Journey")
                                    .font(.title2.bold())
                                
                                Text("Create custom workouts tailored to your fitness goals")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                ActionButton.cta(title: "Get Started Now", icon: "play.circle.fill") {
                                    print("Hero CTA tapped")
                                }
                                .padding(.top)
                            }
                            .padding()
                            .background(ComponentConstants.Colors.secondaryGroupedBackground)
                            .cornerRadius(ComponentConstants.Layout.cornerRadius)
                            .padding(.horizontal)
                        }
                        
                        Divider()
                        
                        // Size variants with different states
                        VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                            Text("Size Variants with States")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            // Loading states at different sizes
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Small", style: .primary, size: .small, isLoading: true) {}
                                ActionButton(title: "Medium", style: .secondary, size: .medium, isLoading: true) {}
                                ActionButton(title: "Large", style: .destructive, size: .large, isLoading: true) {}
                            }
                            .padding(.horizontal)
                            
                            // Disabled states at different sizes
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Small", style: .ghost, size: .small, isDisabled: true) {}
                                ActionButton(title: "Medium", style: .link, size: .medium, isDisabled: true) {}
                                ActionButton(title: "Large", style: .primary, size: .large, isDisabled: true) {}
                            }
                            .padding(.horizontal)
                            
                            // Icon-only at different sizes
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(icon: "plus", style: .primary, size: .small) {}
                                ActionButton(icon: "star.fill", style: .secondary, size: .medium) {}
                                ActionButton(icon: "trash.fill", style: .destructive, size: .large) {}
                                ActionButton(icon: "gearshape.fill", style: .ghost, size: .small, isLoading: true) {}
                                ActionButton(icon: "xmark.circle.fill", style: .link, size: .medium, isDisabled: true) {}
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                        
                        // Factory method examples
                        VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                            Text("Factory Method Examples")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton.toolbar(title: "Filter", icon: "line.3.horizontal.decrease.circle") {
                                    print("Toolbar filter tapped")
                                }
                                
                                ActionButton.cta(title: "Start Free Trial", icon: "crown.fill") {
                                    print("CTA tapped")
                                }
                                
                                ActionButton.compact(title: "View All", icon: "arrow.right") {
                                    print("Compact tapped")
                                }
                                
                                ActionButton.danger(title: "Delete Account", icon: "trash") {
                                    print("Danger tapped")
                                }
                                
                                ActionButton.danger(title: "Remove All", icon: "xmark.bin.fill", size: .small) {
                                    print("Small danger tapped")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical)
                
                // MARK: Primary Style
                PreviewSection(title: "Primary Style") {
                    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                        ActionButton(title: "Get Started", icon: "play.circle.fill", style: .primary) {
                            print("Primary: Get Started tapped")
                        }
                        
                        ActionButton(title: "Save Workout", icon: "square.and.arrow.down", style: .primary, isLoading: true) {
                            print("Primary: Save Workout tapped")
                        }
                        
                        ActionButton(title: "Continue", icon: "arrow.right.circle", style: .primary, isDisabled: true) {
                            print("Primary: Continue tapped")
                        }
                        
                        // Icon-only buttons
                        HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                            ActionButton(icon: "plus.circle", style: .primary) {
                                print("Primary: Add tapped")
                            }
                            
                            ActionButton(icon: "heart.fill", style: .primary, isLoading: true) {
                                print("Primary: Favorite tapped")
                            }
                            
                            ActionButton(icon: "square.and.pencil", style: .primary, isDisabled: true) {
                                print("Primary: Edit tapped")
                            }
                        }
                        
                        // Text-only loading
                        ActionButton(title: "Processing...", style: .primary, isLoading: true) {
                            print("Primary: Processing tapped")
                        }
                    }
                }
            
                // MARK: Secondary Style
                PreviewSection(title: "Secondary Style") {
                    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                        ActionButton(title: "Browse Exercises", icon: "magnifyingglass", style: .secondary) {
                            print("Secondary: Browse Exercises tapped")
                        }
                        
                        ActionButton(title: "View History", icon: "clock.arrow.circlepath", style: .secondary, isLoading: true) {
                            print("Secondary: View History tapped")
                        }
                        
                        ActionButton(title: "Export Data", icon: "square.and.arrow.up", style: .secondary, isDisabled: true) {
                            print("Secondary: Export Data tapped")
                        }
                        
                        // Icon-only buttons
                        HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                            ActionButton(icon: "gear", style: .secondary) {
                                print("Secondary: Settings tapped")
                            }
                            
                            ActionButton(icon: "questionmark.circle", style: .secondary, isLoading: true) {
                                print("Secondary: Help tapped")
                            }
                            
                            ActionButton(icon: "bell", style: .secondary, isDisabled: true) {
                                print("Secondary: Notifications tapped")
                            }
                        }
                        
                        // Text-only loading
                        ActionButton(title: "Loading...", style: .secondary, isLoading: true) {
                            print("Secondary: Loading tapped")
                        }
                    }
                }
            
                // MARK: Destructive Style
                PreviewSection(title: "Destructive Style") {
                    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                        ActionButton(title: "Delete Workout", icon: "trash", style: .destructive) {
                            print("Destructive: Delete Workout tapped")
                        }
                        
                        ActionButton(title: "Remove Exercise", icon: "minus.circle", style: .destructive, isLoading: true) {
                            print("Destructive: Remove Exercise tapped")
                        }
                        
                        ActionButton(title: "Clear All Data", icon: "xmark.bin", style: .destructive, isDisabled: true) {
                            print("Destructive: Clear All Data tapped")
                        }
                        
                        // Icon-only destructive button
                        HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                            ActionButton(icon: "trash.fill", style: .destructive) {
                                print("Destructive: Delete tapped")
                            }
                            
                            ActionButton(icon: "xmark.circle.fill", style: .destructive, isLoading: true) {
                                print("Destructive: Cancel tapped")
                            }
                            
                            ActionButton(icon: "minus.circle.fill", style: .destructive, isDisabled: true) {
                                print("Destructive: Remove tapped")
                            }
                        }
                        
                        // Text-only deleting
                        ActionButton(title: "Deleting...", style: .destructive, isLoading: true) {
                            print("Destructive: Deleting tapped")
                        }
                    }
                }
            
                // MARK: Ghost Style
                PreviewSection(title: "Ghost Style") {
                    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                        ActionButton(title: "Skip", icon: "forward", style: .ghost) {
                            print("Ghost: Skip tapped")
                        }
                        
                        ActionButton(title: "Maybe Later", icon: "clock", style: .ghost, isLoading: true) {
                            print("Ghost: Maybe Later tapped")
                        }
                        
                        ActionButton(title: "Dismiss", icon: "xmark", style: .ghost, isDisabled: true) {
                            print("Ghost: Dismiss tapped")
                        }
                        
                        // Icon-only ghost buttons
                        HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                            ActionButton(icon: "ellipsis", style: .ghost) {
                                print("Ghost: More tapped")
                            }
                            
                            ActionButton(icon: "arrow.up.arrow.down", style: .ghost, isLoading: true) {
                                print("Ghost: Sort tapped")
                            }
                            
                            ActionButton(icon: "line.3.horizontal.decrease.circle", style: .ghost, isDisabled: true) {
                                print("Ghost: Filter tapped")
                            }
                        }
                        
                        // Text-only loading
                        ActionButton(title: "Updating...", style: .ghost, isLoading: true) {
                            print("Ghost: Updating tapped")
                        }
                    }
                }
            
                // MARK: Link Style
                PreviewSection(title: "Link Style") {
                    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                        ActionButton(title: "Learn More", icon: "info.circle", style: .link) {
                            print("Link: Learn More tapped")
                        }
                        
                        ActionButton(title: "View Details", icon: "chevron.right", style: .link, isLoading: true) {
                            print("Link: View Details tapped")
                        }
                        
                        ActionButton(title: "Terms of Service", icon: "doc.text", style: .link, isDisabled: true) {
                            print("Link: Terms of Service tapped")
                        }
                        
                        // Icon-only link buttons
                        HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                            ActionButton(icon: "arrow.up.right.square", style: .link) {
                                print("Link: External link tapped")
                            }
                            
                            ActionButton(icon: "chevron.right.circle", style: .link, isLoading: true) {
                                print("Link: Next tapped")
                            }
                            
                            ActionButton(icon: "arrow.down.circle", style: .link, isDisabled: true) {
                                print("Link: Download tapped")
                            }
                        }
                        
                        // Text-only loading
                        ActionButton(title: "Loading content...", style: .link, isLoading: true) {
                            print("Link: Loading tapped")
                        }
                    }
                }
            
                // MARK: State Examples
                PreviewSection(title: "State Examples") {
                    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                        // Loading states across styles
                        VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                            Text("Loading States")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Loading", style: .primary, isLoading: true) {}
                                ActionButton(title: "Loading", style: .secondary, isLoading: true) {}
                                ActionButton(title: "Loading", style: .destructive, isLoading: true) {}
                            }
                            
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Loading", style: .ghost, isLoading: true) {}
                                ActionButton(title: "Loading", style: .link, isLoading: true) {}
                            }
                        }
                        
                        Divider()
                        
                        // Disabled states across styles
                        VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                            Text("Disabled States")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Disabled", style: .primary, isDisabled: true) {}
                                ActionButton(title: "Disabled", style: .secondary, isDisabled: true) {}
                                ActionButton(title: "Disabled", style: .destructive, isDisabled: true) {}
                            }
                            
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Disabled", style: .ghost, isDisabled: true) {}
                                ActionButton(title: "Disabled", style: .link, isDisabled: true) {}
                            }
                        }
                        
                        Divider()
                        
                        // Mixed icon states
                        VStack(alignment: .leading, spacing: ComponentConstants.Layout.compactPadding) {
                            Text("Icon-Only States")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(icon: "heart", style: .primary, isLoading: true) {}
                                ActionButton(icon: "star", style: .secondary, isLoading: true) {}
                                ActionButton(icon: "trash", style: .destructive, isLoading: true) {}
                                ActionButton(icon: "plus", style: .ghost, isDisabled: true) {}
                                ActionButton(icon: "link", style: .link, isDisabled: true) {}
                            }
                        }
                    }
                }
            
                // MARK: Mixed Styles in Context
                PreviewSection(title: "Mixed Styles in Context") {
                    VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                        // Action Card Example with Loading
                        VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                            Text("Saving your workout...")
                                .font(.headline)
                            Text("Please wait while we save your progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Cancel", icon: "xmark", style: .ghost, isDisabled: true) {
                                    print("Cancel tapped")
                                }
                                
                                ActionButton(title: "Saving...", icon: "checkmark.circle.fill", style: .primary, isLoading: true) {
                                    print("Saving tapped")
                                }
                            }
                        }
                        .padding()
                        .background(ComponentConstants.Colors.secondaryGroupedBackground)
                        .cornerRadius(ComponentConstants.Layout.cornerRadius)
                        
                        Divider()
                        
                        // Deletion Confirmation with Loading
                        VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                            Text("Deleting workout...")
                                .font(.headline)
                            Text("This action cannot be undone")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                                ActionButton(title: "Deleting...", icon: "trash.fill", style: .destructive, isLoading: true) {
                                    print("Delete confirmed")
                                }
                                
                                ActionButton(title: "Cancel", icon: "xmark.circle", style: .secondary, isDisabled: true) {
                                    print("Deletion cancelled")
                                }
                            }
                        }
                        .padding()
                        .background(ComponentConstants.Colors.secondaryGroupedBackground)
                        .cornerRadius(ComponentConstants.Layout.cornerRadius)
                    }
                }
            
            // MARK: Size Variations
            PreviewSection(title: "Size Variations") {
                VStack(spacing: ComponentConstants.Layout.itemSpacing) {
                    // Full width with icon
                    ActionButton(title: "Full Width Button", icon: "rectangle.expand.vertical", style: .primary) {
                        print("Full width tapped")
                    }
                    
                    // Fixed widths with icons
                    HStack(spacing: ComponentConstants.Layout.itemSpacing) {
                        ActionButton(title: "Small", icon: "s.circle", style: .secondary) {
                            print("Small tapped")
                        }
                        .frame(width: 100)
                        
                        ActionButton(title: "Medium", icon: "m.circle", style: .secondary) {
                            print("Medium tapped")
                        }
                        .frame(width: 140)
                        
                        ActionButton(title: "Large", icon: "l.circle", style: .secondary) {
                            print("Large tapped")
                        }
                        .frame(width: 180)
                    }
                    
                    // Icon-only grid
                    Text("Icon-Only Grid")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: ComponentConstants.Layout.itemSpacing) {
                        ActionButton(icon: "plus", style: .primary) {
                            print("Add tapped")
                        }
                        
                        ActionButton(icon: "pencil", style: .secondary) {
                            print("Edit tapped")
                        }
                        
                        ActionButton(icon: "trash", style: .destructive) {
                            print("Delete tapped")
                        }
                        
                        ActionButton(icon: "ellipsis", style: .ghost) {
                            print("More tapped")
                        }
                        
                        ActionButton(icon: "square.and.arrow.up", style: .secondary) {
                            print("Share tapped")
                        }
                        
                        ActionButton(icon: "doc.on.doc", style: .secondary) {
                            print("Copy tapped")
                        }
                        
                        ActionButton(icon: "star", style: .ghost) {
                            print("Star tapped")
                        }
                        
                        ActionButton(icon: "flag", style: .link) {
                            print("Flag tapped")
                        }
                    }
                    
                    // Long text handling with icon
                    ActionButton(title: "This is a very long button title that should wrap properly and maintain good readability", icon: "text.alignleft", style: .primary) {
                        print("Long title tapped")
                    }
                    }
                }
            }
            .padding()
        }
        .background(ComponentConstants.Colors.groupedBackground)
    }
}

// MARK: - Preview Helpers
private struct PreviewSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: ComponentConstants.Layout.itemSpacing) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            content()
        }
    }
}
