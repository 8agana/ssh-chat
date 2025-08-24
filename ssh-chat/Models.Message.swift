import Foundation

struct Message: Identifiable, Equatable, Hashable {
    enum Role: String, Codable, CaseIterable, Hashable {
        case user
        case assistant
        case system

        var speakerTag: String {
            switch self {
            case .user: return "you$"
            case .assistant: return "ai▷"
            case .system: return "sys#"
            }
        }
    }

    let id: UUID
    var role: Role
    var timestamp: Date
    var text: String

    init(id: UUID = UUID(), role: Role, timestamp: Date = .init(), text: String) {
        self.id = id
        self.role = role
        self.timestamp = timestamp
        self.text = text
    }
}

extension Array where Element == Message {
    static var demo: [Message] {
        [
            Message(role: .system, text: "session started — terminal chat mockup"),
            Message(role: .assistant, text: "Hello! I’m a terminal-style AI. Ask me anything in plain text. No bubbles here."),
            Message(role: .user, text: "Show me a SwiftUI view that wraps long text lines nicely and supports selection."),
            Message(role: .assistant, text: "Use Text with .textSelection(.enabled) and no lineLimit. Prefer monospaced font for a terminal feel. This example is long enough to test wrapping across multiple lines on smaller iPhones, ensuring smooth scrolling and proper selection behavior without chat bubbles.")
        ]
    }
}

