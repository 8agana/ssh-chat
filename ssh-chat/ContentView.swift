import SwiftUI

// Placeholder to avoid build issues if this template file is still in the target.
// The real app entry is in SSHChatApp.
struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("ssh-chat mockup")
                .font(.system(.headline, design: .monospaced))
            Text("This is a template placeholder. The real UI starts in SSHChatApp → ConnectionSetupView/ChatView.")
                .font(.system(.footnote, design: .monospaced))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
