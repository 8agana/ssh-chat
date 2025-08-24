import AVFoundation
import SwiftUI

struct InputBar: View {
    @Environment(\.theme) private var theme

    @Binding var text: String
    @Binding var isListening: Bool
    @Binding var level: Double  // 0...1

    var onSend: (String) -> Void
    var onMicPressed: () -> Void

    @FocusState private var focused: Bool

    @State private var measuredHeight: CGFloat = 40
    private let minHeight: CGFloat = 36
    private let maxLines: Int = 6

    var body: some View {
        VStack(spacing: 8) {
            Divider().background(theme.line)

            HStack(alignment: .bottom, spacing: 8) {
                ZStack(alignment: .leading) {
                    // Auto-sizing mirror
                    Text(text + " ")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.clear)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear { updateHeight(from: geo.size.height) }
                                    .onChange(of: text) { _, _ in
                                        updateHeight(from: geo.size.height)
                                    }
                            }
                        )
                        .hidden()

                    TextEditor(text: $text)
                        .font(.system(.body, design: .monospaced))
                        .scrollContentBackground(.hidden)
                        .background(theme.background)
                        .frame(minHeight: minHeight, maxHeight: measuredHeight)
                        .focused($focused)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .accessibilityLabel("compose input")
                }
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(theme.line, lineWidth: 1)
                        .opacity(0.3)
                )

                Button(action: send) {
                    Text("send")
                        .font(.system(.headline, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background {
                            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.line)
                                    .opacity(0.2)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.accent)
                                    .opacity(0.15)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.plain)

                Button(action: onMicPressed) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(isListening ? theme.accent : theme.line)
                            .frame(width: 8, height: 8)
                            .overlay(alignment: .center) {
                                if isListening {
                                    Circle()
                                        .stroke(theme.accent, lineWidth: 1)
                                        .opacity(0.6)
                                        .frame(width: 14, height: 14)
                                }
                            }
                        Text(isListening ? "listening" : "mic")
                            .font(.system(.headline, design: .monospaced))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.line)
                            .opacity(0.2)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isListening ? "Stop listening" : "Start voice input")
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(theme.background)
        .onAppear { focused = true }
    }

    private func updateHeight(from proxyHeight: CGFloat) {
        // Estimate number of lines based on content; cap to maxLines
        let lineHeight: CGFloat = UIFont.preferredFont(forTextStyle: .body).lineHeight + 6
        let target = min(CGFloat(maxLines) * lineHeight, max(minHeight, proxyHeight))
        if abs(target - measuredHeight) > 1 { measuredHeight = target }
    }

    private func send() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSend(trimmed)
        text = ""
    }

}

#Preview {
    InputBar(
        text: .constant("echo hello"), isListening: .constant(false), level: .constant(0.3),
        onSend: { _ in }, onMicPressed: {}
    )
    .preferredColorScheme(.dark)
    .theme(.terminal)
}
