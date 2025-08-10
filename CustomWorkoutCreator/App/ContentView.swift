import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "figure.strengthtraining.traditional")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Clean Slate")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Ready to rebuild with better foundations")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}