import SwiftUI

struct SectionHeader<Trailing: View>: View {
    // Pre-computed display strings
    private let displayTitle: String
    private let displaySubtitle: String?
    
    // ViewBuilder for trailing content
    private let trailing: () -> Trailing
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        // Pre-compute all display strings at initialization
        self.displayTitle = title.uppercased()
        self.displaySubtitle = subtitle
        self.trailing = trailing
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: ComponentConstants.SectionHeader.titleSubtitleSpacing) {
                Text(displayTitle)
                    .font(ComponentConstants.SectionHeader.titleFont)
                    .foregroundColor(ComponentConstants.SectionHeader.titleColor)
                
                if let displaySubtitle = displaySubtitle {
                    Text(displaySubtitle)
                        .font(ComponentConstants.SectionHeader.subtitleFont)
                        .foregroundColor(ComponentConstants.SectionHeader.subtitleColor)
                }
            }
            
            Spacer(minLength: 16)
            
            trailing()
        }
        .padding(.horizontal, ComponentConstants.SectionHeader.horizontalPadding)
        .padding(.top, ComponentConstants.SectionHeader.topPadding)
        .padding(.bottom, ComponentConstants.SectionHeader.bottomPadding)
        .background(ComponentConstants.SectionHeader.backgroundColor)
    }
}

// MARK: - Convenience Initializer
extension SectionHeader where Trailing == EmptyView {
    init(
        title: String,
        subtitle: String? = nil
    ) {
        self.init(title: title, subtitle: subtitle) {
            EmptyView()
        }
    }
}

// MARK: - Equatable for Performance
extension SectionHeader: Equatable where Trailing: Equatable {
    static func == (lhs: SectionHeader<Trailing>, rhs: SectionHeader<Trailing>) -> Bool {
        lhs.displayTitle == rhs.displayTitle &&
        lhs.displaySubtitle == rhs.displaySubtitle
    }
}

// MARK: - Previews
#Preview("Section Headers Showcase") {
    ScrollView {
        VStack(spacing: 0) {
            // Basic section header
            SectionHeader(title: "Basic Section")
            
            // With subtitle
            SectionHeader(
                title: "With Subtitle",
                subtitle: "This section has additional context"
            )
            
            // With trailing button
            SectionHeader(title: "With Action") {
                Button("Add") {
                    print("Add tapped")
                }
                .foregroundColor(.accentColor)
                .font(.subheadline)
            }
            
            // With trailing icon
            SectionHeader(title: "With Icon") {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            // Complex trailing content
            SectionHeader(
                title: "Complex",
                subtitle: "Multiple actions available"
            ) {
                HStack(spacing: 16) {
                    Button {
                        print("Edit tapped")
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.secondary)
                    }
                    
                    Button {
                        print("Add tapped")
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                .font(.title3)
            }
            
            // Long text handling
            SectionHeader(
                title: "Very Long Section Title That Might Wrap",
                subtitle: "This is a very long subtitle that demonstrates how the component handles text that might need to wrap to multiple lines"
            )
            
            // With custom styling in trailing
            SectionHeader(title: "Custom Styled") {
                Text("Custom")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
            }
            
            // Mimicking Form section style
            Group {
                SectionHeader(title: "Form Style Section")
                
                // Sample content below header
                VStack(spacing: 0) {
                    ForEach(0..<3) { index in
                        HStack {
                            Text("Row \(index + 1)")
                                .font(.body)
                            Spacer()
                            Text("Value")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, ComponentConstants.Row.horizontalPadding)
                        .padding(.vertical, ComponentConstants.Row.verticalPadding)
                        .background(ComponentConstants.Row.backgroundColor)
                        
                        if index < 2 {
                            Divider()
                                .padding(.leading, ComponentConstants.Row.horizontalPadding)
                        }
                    }
                }
                .cornerRadius(ComponentConstants.Row.cornerRadius)
                .padding(.horizontal, ComponentConstants.SectionHeader.horizontalPadding)
            }
            
            // Empty state
            SectionHeader(title: "Empty Section") {
                Text("0 items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer(minLength: 50)
        }
    }
    .background(ComponentConstants.Colors.groupedBackground)
}

// MARK: - Design Adjustment Preview
#Preview("Design Adjustments") {
    VStack(spacing: 0) {
        // Adjust these values to test different designs
        let customTitle = "WORKOUTS"
        let customSubtitle = "3 workouts saved"
        let showSubtitle = true
        let showTrailing = true
        
        SectionHeader(
            title: customTitle,
            subtitle: showSubtitle ? customSubtitle : nil
        ) {
            if showTrailing {
                Button("Edit") {
                    print("Edit tapped")
                }
                .foregroundColor(.accentColor)
            } else {
                EmptyView()
            }
        }
        
        // Sample content
        VStack(spacing: 1) {
            ForEach(0..<3) { index in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sample Workout \(index + 1)")
                            .font(.body)
                        Text("\(index + 2) intervals • 45 min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, ComponentConstants.Row.horizontalPadding)
                .padding(.vertical, ComponentConstants.Row.verticalPadding)
                .background(ComponentConstants.Row.backgroundColor)
            }
        }
        .cornerRadius(ComponentConstants.Row.cornerRadius)
        .padding(.horizontal, ComponentConstants.SectionHeader.horizontalPadding)
        .padding(.bottom, ComponentConstants.Layout.sectionSpacing)
        
        Spacer()
    }
    .background(ComponentConstants.Colors.groupedBackground)
}

// MARK: - Light/Dark Mode Preview
#Preview("Light & Dark Mode") {
    VStack(spacing: 40) {
        SectionHeader(
            title: "Appearance Test",
            subtitle: "Testing in both color schemes"
        ) {
            Image(systemName: "moon.circle.fill")
                .foregroundColor(.accentColor)
        }
    }
    .padding()
    .background(ComponentConstants.Colors.groupedBackground)
}