import Combine
import Foundation

@MainActor
final class MessageStore: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published var lastAppendedMessageID: Message.ID?

    // Connection context (host/port/user persisted via @AppStorage elsewhere); password transient
    var currentHost: () -> String = { "" }
    var currentPort: () -> Int = { 22 }
    var currentUser: () -> String = { "" }
    var currentPassword: () -> String = { "" }

    init(seed: Bool = true) {
        if seed { messages = .demo }
    }

    func send(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMsg = Message(role: .user, text: text)
        messages.append(userMsg)
        lastAppendedMessageID = userMsg.id

        Task { [weak self] in
            await self?.runSSH(command: text)
        }
    }

    func reset() {
        messages = []
        lastAppendedMessageID = nil
    }

    private func runSSH(command: String) async {
        let host = currentHost()
        let port = currentPort()
        let user = currentUser()
        let pass = currentPassword()
        print(
            "SSH execution - host: \(host), port: \(port), user: \(user), pass empty: \(pass.isEmpty), command: \(command)"
        )
        guard !host.isEmpty, !user.isEmpty, !pass.isEmpty else {
            let reply = Message(
                role: .assistant, text: "SSH not configured: host/user/password missing.")
            messages.append(reply)
            lastAppendedMessageID = reply.id
            return
        }
        do {
            let result = try await SSHClient.execute(
                host: host, port: port, username: user, password: pass, command: command)
            var out = result.stdout
            if !result.stderr.isEmpty { out += (out.isEmpty ? "" : "\n") + result.stderr }
            if let code = result.exitStatus { out += "\n(exit \(code))" }
            let reply = Message(role: .assistant, text: out.isEmpty ? "(no output)" : out)
            messages.append(reply)
            lastAppendedMessageID = reply.id
            print("SSH execution successful: \(out)")
        } catch {
            let reply = Message(role: .assistant, text: "SSH error: \(error.localizedDescription)")
            messages.append(reply)
            lastAppendedMessageID = reply.id
            print("SSH execution failed: \(error.localizedDescription)")
        }
    }
}
