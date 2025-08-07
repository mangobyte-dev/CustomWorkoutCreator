import SwiftUI

// MARK: - Row Position
enum RowPosition {
    case only
    case first
    case middle
    case last
}

// MARK: - Row Component
struct Row<Leading: View, Content: View, Trailing: View>: View {
    private let leading: () -> Leading
    private let content: () -> Content
    private let trailing: () -> Trailing
    private let spacing: CGFloat
    private let position: RowPosition
    
    init(
        spacing: CGFloat = ComponentConstants.Row.contentSpacing,
        position: RowPosition = .middle,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.spacing = spacing
        self.position = position
        self.leading = leading
        self.content = content
        self.trailing = trailing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            leading()
            
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            trailing()
        }
        .padding(.horizontal, ComponentConstants.Row.horizontalPadding)
        .padding(.vertical, ComponentConstants.Row.verticalPadding)
        .background(ComponentConstants.Row.backgroundColor)
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: topCornerRadius,
            bottomLeadingRadius: bottomCornerRadius,
            bottomTrailingRadius: bottomCornerRadius,
            topTrailingRadius: topCornerRadius,
            style: .continuous
        ))
    }
    
    private var topCornerRadius: CGFloat {
        switch position {
        case .only, .first:
            return ComponentConstants.Row.cornerRadius
        case .middle, .last:
            return 0
        }
    }
    
    private var bottomCornerRadius: CGFloat {
        switch position {
        case .only, .last:
            return ComponentConstants.Row.cornerRadius
        case .first, .middle:
            return 0
        }
    }
}

// MARK: - Convenience Initializers
extension Row {
    // Content only
    init(
        position: RowPosition = .middle,
        @ViewBuilder content: @escaping () -> Content
    ) where Leading == EmptyView, Trailing == EmptyView {
        self.init(
            position: position,
            leading: { EmptyView() },
            content: content,
            trailing: { EmptyView() }
        )
    }
    
    // Leading and Content
    init(
        position: RowPosition = .middle,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder content: @escaping () -> Content
    ) where Trailing == EmptyView {
        self.init(
            position: position,
            leading: leading,
            content: content,
            trailing: { EmptyView() }
        )
    }
    
    // Content and Trailing
    init(
        position: RowPosition = .middle,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) where Leading == EmptyView {
        self.init(
            position: position,
            leading: { EmptyView() },
            content: content,
            trailing: trailing
        )
    }
}

// MARK: - Factory Method Views

// MARK: Label Row
struct LabelRow: View {
    let title: String
    let value: String
    let position: RowPosition
    
    init(title: String, value: String, position: RowPosition = .middle) {
        self.title = title
        self.value = value
        self.position = position
    }
    
    var body: some View {
        Row(
            position: position,
            content: {
                Text(title)
                    .font(ComponentConstants.Row.titleFont)
                    .foregroundColor(ComponentConstants.Row.primaryTextColor)
            },
            trailing: {
                Text(value)
                    .font(ComponentConstants.Row.valueFont)
                    .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                    .multilineTextAlignment(.trailing)
            }
        )
    }
}

// MARK: Field Row
struct FieldRow: View {
    let title: String
    @Binding var text: String
    let placeholder: String?
    let position: RowPosition
    
    init(_ title: String, text: Binding<String>, placeholder: String? = nil, position: RowPosition = .middle) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.position = position
    }
    
    var body: some View {
        Row(position: position) {
            HStack(spacing: ComponentConstants.Row.contentSpacing) {
                Text(title)
                    .font(ComponentConstants.Row.titleFont)
                    .foregroundColor(ComponentConstants.Row.primaryTextColor)
                    .fixedSize(horizontal: true, vertical: false)
                
                TextField(placeholder ?? title, text: $text)
                    .font(ComponentConstants.Row.valueFont)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

// MARK: Toggle Row
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let position: RowPosition
    
    init(_ title: String, isOn: Binding<Bool>, position: RowPosition = .middle) {
        self.title = title
        self._isOn = isOn
        self.position = position
    }
    
    var body: some View {
        Row(
            position: position,
            content: {
                Text(title)
                    .font(ComponentConstants.Row.titleFont)
                    .foregroundColor(ComponentConstants.Row.primaryTextColor)
            },
            trailing: {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        )
    }
}

// MARK: Stepper Row
struct StepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let format: String
    let position: RowPosition
    
    init(
        _ title: String,
        value: Binding<Int>,
        in range: ClosedRange<Int>,
        step: Int = 1,
        format: String = "%d",
        position: RowPosition = .middle
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.format = format
        self.position = position
    }
    
    var body: some View {
        Row(
            position: position,
            content: {
                Text(title)
                    .font(ComponentConstants.Row.titleFont)
                    .foregroundColor(ComponentConstants.Row.primaryTextColor)
            },
            trailing: {
                HStack {
                    
                    Text(String(format: format, value))
                        .font(ComponentConstants.Row.valueFont)
                        .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                        .monospacedDigit()
                    
                    Stepper("", value: $value, in: range, step: step)
                        .labelsHidden()
                }
            }
        )
    }
}

// MARK: Button Row
struct ButtonRow: View {
    let title: String
    let role: ButtonRole?
    let action: () -> Void
    let position: RowPosition
    
    init(_ title: String, role: ButtonRole? = nil, position: RowPosition = .middle, action: @escaping () -> Void) {
        self.title = title
        self.role = role
        self.position = position
        self.action = action
    }
    
    var body: some View {
        Button(role: role, action: action) {
            Row(position: position) {
                Text(title)
                    .font(ComponentConstants.Row.titleFont)
                    .foregroundColor(role == .destructive ? ComponentConstants.Row.destructiveColor : .accentColor)
            }
        }
    }
}

// MARK: - Row Extension for Factory Methods
extension Row {
    static func label(_ title: String, value: String, position: RowPosition = .middle) -> some View {
        LabelRow(title: title, value: value, position: position)
    }
    
    static func field(_ title: String, text: Binding<String>, placeholder: String? = nil, position: RowPosition = .middle) -> some View {
        FieldRow(title, text: text, placeholder: placeholder, position: position)
    }
    
    static func toggle(_ title: String, isOn: Binding<Bool>, position: RowPosition = .middle) -> some View {
        ToggleRow(title, isOn: isOn, position: position)
    }
    
    static func stepper(
        _ title: String,
        value: Binding<Int>,
        in range: ClosedRange<Int>,
        step: Int = 1,
        format: String = "%d",
        position: RowPosition = .middle
    ) -> some View {
        StepperRow(title, value: value, in: range, step: step, format: format, position: position)
    }
    
    static func button(_ title: String, position: RowPosition = .middle, action: @escaping () -> Void) -> some View {
        ButtonRow(title, position: position, action: action)
    }
    
    static func destructiveButton(_ title: String, position: RowPosition = .middle, action: @escaping () -> Void) -> some View {
        ButtonRow(title, role: .destructive, position: position, action: action)
    }
}

// MARK: - Row Group
struct RowGroup<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 1) {
            content()
        }
        .background(ComponentConstants.Colors.groupedBackground)
    }
}

// MARK: - Equatable for Performance
extension Row: Equatable where Leading: Equatable, Content: Equatable, Trailing: Equatable {
    static func == (lhs: Row, rhs: Row) -> Bool {
        // Since we use ViewBuilder closures, we can't directly compare them
        // This is a placeholder - real implementation would need view identity
        true
    }
}

// MARK: - Preview Provider
#Preview("Row Component Showcase") {
    ScrollView {
        VStack(spacing: 1) {
            // Section: Basic Rows
            VStack(spacing: 1) {
                SectionHeader(title: "Basic Rows")
                
                LabelRow(title: "Label", value: "Value", position: .first)
                
                LabelRow(title: "Long Label Text That Might Wrap", value: "Short Value", position: .middle)
                
                LabelRow(title: "Temperature", value: "72°F", position: .middle)
                
                LabelRow(title: "Status", value: "Active", position: .last)
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
            
            // Section: Input Rows
            VStack(spacing: 1) {
                SectionHeader(title: "Input Rows")
                
                FieldRow("Name", text: .constant("John Doe"), position: .first)
                
                FieldRow("Email", text: .constant(""), placeholder: "Enter email", position: .middle)
                
                ToggleRow("Enable Notifications", isOn: .constant(true), position: .middle)
                
                ToggleRow("Dark Mode", isOn: .constant(false), position: .middle)
                
                StepperRow("Rounds", value: .constant(3), in: 1...10, position: .middle)
                
                StepperRow("Reps", value: .constant(12), in: 1...50, format: "%d reps", position: .last)
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
            
            // Section: Action Rows
            VStack(spacing: 1) {
                SectionHeader(title: "Action Rows")
                
                ButtonRow("Add Exercise", position: .first) {
                    print("Add tapped")
                }
                
                ButtonRow("Delete Workout", role: .destructive, position: .last) {
                    print("Delete tapped")
                }
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
            
            // Section: Custom Rows
            VStack(spacing: 1) {
                SectionHeader(title: "Custom Rows")
                
                // Row with icon
                Row(
                    position: .first,
                    leading: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    },
                    content: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Profile")
                                .font(ComponentConstants.Row.titleFont)
                            Text("View and edit your profile")
                                .font(ComponentConstants.Row.subtitleFont)
                                .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                        }
                    },
                    trailing: {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                    }
                )
                
                // Row with multiple trailing elements
                Row(
                    position: .middle,
                    content: {
                        Text("Workout")
                            .font(ComponentConstants.Row.titleFont)
                    },
                    trailing: {
                        HStack(spacing: 12) {
                            Text("45 min")
                                .font(.caption)
                                .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                        }
                    }
                )
                
                // Complex row
                Row(
                    position: .last,
                    leading: {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                    },
                    content: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Upper Body Workout")
                                .font(ComponentConstants.Row.titleFont)
                            HStack(spacing: 8) {
                                Label("3 intervals", systemImage: "square.stack.3d.up")
                                Label("45 min", systemImage: "timer")
                            }
                            .font(.caption)
                            .foregroundColor(ComponentConstants.Row.secondaryTextColor)
                        }
                    },
                    trailing: {
                        Button("Start") {
                            print("Start tapped")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .cornerRadius(6)
                    }
                )
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
        }
        .background(ComponentConstants.Colors.groupedBackground)
    }
    .background(ComponentConstants.Colors.groupedBackground)
}

// MARK: - Design Adjustment Preview
#Preview("Design Adjustments") {
    @Previewable @State var textValue = "Sample Text"
    @Previewable @State var toggleValue = true
    @Previewable @State var stepperValue = 5
    
    ScrollView {
        VStack(spacing: 20) {
            // Test different row configurations
            VStack(spacing: 1) {
                SectionHeader(title: "Form Replacement Test")
                
                LabelRow(title: "Workout Name", value: "Full Body", position: .first)
                LabelRow(title: "Duration", value: "45 minutes", position: .middle)
                StepperRow("Sets", value: $stepperValue, in: 1...10, position: .middle)
                ToggleRow("Track Progress", isOn: $toggleValue, position: .last)
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
            
            // Comparison with native Form element
            VStack(spacing: 1) {
                SectionHeader(title: "Interactive Elements")
                
                FieldRow("Exercise Name", text: $textValue, position: .first)
                StepperRow("Reps", value: $stepperValue, in: 8...20, format: "%d reps", position: .middle)
                ButtonRow("Add to Workout", position: .last) {
                    print("Added: \(textValue) for \(stepperValue) reps")
                }
            }
            .padding(.horizontal, ComponentConstants.Layout.defaultPadding)
        }
        .padding(.vertical)
    }
    .background(ComponentConstants.Colors.groupedBackground)
}

// MARK: - Light/Dark Mode Preview
#Preview("Light & Dark Mode") {
    VStack(spacing: 20) {
        // Multiple rows
        VStack(spacing: 1) {
            LabelRow(title: "Appearance Test", value: "Value", position: .first)
            ToggleRow("Dark Mode", isOn: .constant(true), position: .middle)
            ButtonRow("Action", position: .last) {}
        }
        
        // Single row
        LabelRow(title: "Single Row", value: "Test", position: .only)
    }
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}
