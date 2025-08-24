import SwiftUI

struct ConnectionSetupView: View {
    @Environment(\.theme) private var theme

    @Binding var host: String
    @Binding var port: String
    @Binding var username: String
    @Binding var authMethod: String
    @Binding var isConnected: Bool

    @State private var password: String = ""
    @State private var keyURLString: String = ""

    // Connection callback
    var onConnect: ((String, Int, String, String) -> Void)?

    var isValid: Bool {
        !host.trimmingCharacters(in: .whitespaces).isEmpty && Int(port) != nil && !username.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title
            HStack {
                Text("ssh-chat setup")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundStyle(theme.accent)
                Spacer()
            }
            .padding(.bottom, 8)

            Form {
                Section(header: Text("connection").textCase(.lowercase)) {
                    TextField("host", text: $host)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.system(.body, design: .monospaced))
                    TextField("port", text: $port)
                        .keyboardType(.numberPad)
                        .font(.system(.body, design: .monospaced))
                    TextField("username", text: $username)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .font(.system(.body, design: .monospaced))
                }
                Section(header: Text("auth").textCase(.lowercase)) {
                    Picker("method", selection: $authMethod) {
                        Text("Password").tag("Password")
                        Text("Key").tag("Key")
                    }
                    .pickerStyle(.segmented)

                    if authMethod == "Password" {
                        SecureField("password", text: $password)
                            .font(.system(.body, design: .monospaced))
                    } else {
                        HStack {
                            TextField("key file URL (placeholder)", text: $keyURLString)
                                .font(.system(.body, design: .monospaced))
                            // Placeholder; a real app would present a DocumentPicker
                            Button("Choose") {}
                                .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(theme.background)
            .tint(theme.accent)

            HStack {
                Spacer()
                Button {
                    // Capture into store closures for runtime usage
                    print(
                        "Connection setup: host=\(host), port=\(port), user=\(username), authMethod=\(authMethod)"
                    )

                    // Use callback instead of direct store access
                    onConnect?(host, Int(port) ?? 22, username, password)
                    isConnected = true
                } label: {
                    Text("connect")
                        .font(.system(.headline, design: .monospaced))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(isValid ? theme.accent.opacity(0.15) : theme.line.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!isValid)
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(theme.background.ignoresSafeArea())
    }
}

#Preview {
    ConnectionSetupView(
        host: .constant("server.local"),
        port: .constant("22"),
        username: .constant("sam"),
        authMethod: .constant("Password"),
        isConnected: .constant(false),
        onConnect: nil
    )
    .preferredColorScheme(.dark)
    .theme(.terminal)
}
