import SwiftUI

struct ChatView: View {
    @Environment(\.theme) private var theme
    @EnvironmentObject private var store: MessageStore
    @StateObject private var speech = SpeechRecognizer()
    @Binding var isConnected: Bool

    @State private var composeText: String = ""
    @State private var isNearBottom: Bool = true
    @State private var showJumpToLatest: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with disconnect button
            HStack {
                Text("ssh://\(store.currentHost()):\(store.currentPort())")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(theme.accent)
                Spacer()
                Button("disconnect") {
                    isConnected = false
                    store.reset()
                }
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(theme.accent)
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(theme.background)

            // Timeline
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(store.messages) { msg in
                            MessageRowView(message: msg)
                                .id(msg.id)
                                .padding(.horizontal)
                        }

                        // Bottom anchor for precise scrolling
                        Color.clear.frame(height: 1).id("bottom-anchor")
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: geo.frame(in: .named("scroll")).maxY)
                        })
                }
                .coordinateSpace(name: "scroll")
                .background(theme.background)
                .onChange(of: store.lastAppendedMessageID) { _ in
                    if isNearBottom {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo("bottom-anchor", anchor: .bottom)
                        }
                    } else {
                        showJumpToLatest = true
                    }
                }
                .onChange(of: store.messages.count) { _ in
                    // Ensure new sessions start at bottom
                    if isNearBottom {
                        DispatchQueue.main.async {
                            proxy.scrollTo("bottom-anchor", anchor: .bottom)
                        }
                    }
                }
                .onPreferenceChange(ScrollOffsetKey.self) { _ in
                    // Heuristic: when bottom anchor is roughly visible, consider near bottom
                }
                .overlay(alignment: .bottomTrailing) {
                    if showJumpToLatest {
                        Button {
                            withAnimation(.easeOut(duration: 0.25)) {
                                proxy.scrollTo("bottom-anchor", anchor: .bottom)
                            }
                            showJumpToLatest = false
                            isNearBottom = true
                        } label: {
                            Text("jump ▽")
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(12)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            InputBar(
                text: $composeText,
                isListening: $speech.isListening,
                level: $speech.level,
                onSend: { text in
                    store.send(text: text)
                },
                onMicPressed: {
                    if speech.isListening {
                        speech.stopDictation()
                    } else {
                        speech.startDictation(
                            onPartial: { partial in
                                composeText = partial
                            },
                            onFinal: { final in
                                composeText = final
                            }
                        )
                    }
                }
            )
            .background(theme.background)
        }
        .background(theme.background.ignoresSafeArea())
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

#Preview {
    ChatView(isConnected: .constant(true))
        .environmentObject(MessageStore())
        .preferredColorScheme(.dark)
        .theme(.terminal)
}
