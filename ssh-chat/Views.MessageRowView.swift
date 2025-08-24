import SwiftUI
import UIKit

struct MessageRowView: View {
    @Environment(\.theme) private var theme
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(message.role.speakerTag)
                .foregroundStyle(theme.accent)
                .font(.system(.body, design: .monospaced))
                .padding(.trailing, 2)

            Text(message.text)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .contextMenu {
            Button("Copy") {
                UIPasteboard.general.string = "\(message.role.speakerTag) \(message.text)"
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(theme.line.opacity(0.2)).frame(height: 0.5)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        MessageRowView(message: .init(role: .user, text: "ls -la && echo hello world"))
        MessageRowView(message: .init(role: .assistant, text: "total 0\n-rw-r--r--  1 sam  staff  0 Aug 22 22:02 README.md\nThe output above demonstrates selection and wrapping across lines."))
    }
    .padding()
    .background(ThemePalette.terminal.background)
    .preferredColorScheme(.dark)
    .theme(.terminal)
}

