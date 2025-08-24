import SwiftUI

@main
struct SSHChatApp: App {
    @StateObject private var store = MessageStore()

    // Basic connection state persisted locally for the mockup
    @AppStorage("ssh_host") private var host: String = ""
    @AppStorage("ssh_port") private var port: String = "22"
    @AppStorage("ssh_username") private var username: String = ""
    @AppStorage("ssh_auth_method") private var authMethod: String = "Password"  // or "Key"
    @AppStorage("ssh_is_connected") private var isConnected: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {

                if isConnected && !host.isEmpty && !username.isEmpty {
                    ChatView(isConnected: $isConnected)
                        .environmentObject(store)
                        .theme(.terminal)
                } else {
                    ConnectionSetupView(
                        host: $host,
                        port: $port,
                        username: $username,
                        authMethod: $authMethod,
                        isConnected: $isConnected,
                        onConnect: { host, port, username, password in
                            store.currentHost = { host }
                            store.currentPort = { port }
                            store.currentUser = { username }
                            store.currentPassword = { password }
                        }
                    )
                    .environmentObject(store)
                    .theme(.terminal)
                }
            }
            .preferredColorScheme(.dark)  // terminal aesthetic by default
        }
    }
}
