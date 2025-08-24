import Foundation

/// Mock SSH client for demonstration purposes
/// Simulates common SSH commands with realistic output
struct SSHClient {
    struct Result {
        let exitStatus: Int32?
        let stdout: String
        let stderr: String
    }

    static func execute(
        host: String, port: Int, username: String, password: String, command: String,
        timeoutSeconds: TimeInterval = 10
    ) async throws -> Result {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds

        let trimmedCommand = command.trimmingCharacters(in: .whitespacesAndNewlines)

        // Handle common SSH commands with mock responses
        switch trimmedCommand {
        case let cmd where cmd.hasPrefix("ls"):
            return handleLSCommand(cmd)

        case let cmd where cmd.hasPrefix("pwd"):
            return Result(exitStatus: 0, stdout: "/home/\(username)", stderr: "")

        case let cmd where cmd.hasPrefix("echo"):
            return handleEchoCommand(cmd)

        case let cmd where cmd.hasPrefix("cat"):
            return handleCatCommand(cmd)

        case let cmd where cmd.hasPrefix("whoami"):
            return Result(exitStatus: 0, stdout: username, stderr: "")

        case let cmd where cmd.hasPrefix("date"):
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss zzz yyyy"
            return Result(exitStatus: 0, stdout: formatter.string(from: Date()), stderr: "")

        case "help", "--help", "-h":
            return Result(
                exitStatus: 0,
                stdout: """
                    Available commands: ls, pwd, echo, cat, whoami, date, help
                    This is a mock SSH terminal for demonstration purposes.
                    """, stderr: "")

        default:
            return Result(
                exitStatus: 127, stdout: "",
                stderr: "\(trimmedCommand.split(separator: " ").first ?? ""): command not found")
        }
    }

    private static func handleLSCommand(_ command: String) -> Result {
        let parts = command.split(separator: " ")
        let showAll = parts.contains("-a") || parts.contains("--all")
        let longFormat = parts.contains("-l")

        var output = ""
        if longFormat {
            output = """
                total 48
                drwxr-xr-x  12 user  staff   384 Aug 22 14:30 .
                drwxr-xr-x   5 user  staff   160 Aug 21 09:15 ..
                -rw-r--r--   1 user  staff   287 Aug 20 11:22 .bashrc
                -rw-r--r--   1 user  staff   128 Aug 19 16:45 .profile
                drwxr-xr-x   3 user  staff    96 Aug 18 13:20 Documents
                drwxr-xr-x   4 user  staff   128 Aug 17 10:30 Downloads
                drwxr-xr-x   3 user  staff    96 Aug 16 08:15 Music
                drwxr-xr-x   4 user  staff   128 Aug 15 14:20 Pictures
                -rw-r--r--   1 user  staff  1024 Aug 14 09:45 README.md
                drwxr-xr-x   2 user  staff    64 Aug 13 11:30 Projects
                """
        } else {
            output = """
                Documents    Downloads   Music    Pictures
                README.md    Projects
                """
            if showAll {
                output = ".bashrc   .profile   " + output
            }
        }

        return Result(exitStatus: 0, stdout: output, stderr: "")
    }

    private static func handleEchoCommand(_ command: String) -> Result {
        let parts = command.split(separator: " ")
        guard parts.count > 1 else {
            return Result(exitStatus: 0, stdout: "", stderr: "")
        }

        let text = parts.dropFirst().joined(separator: " ")
        return Result(exitStatus: 0, stdout: text, stderr: "")
    }

    private static func handleCatCommand(_ command: String) -> Result {
        let parts = command.split(separator: " ")
        guard parts.count > 1 else {
            return Result(exitStatus: 1, stdout: "", stderr: "cat: missing file operand")
        }

        let filename = String(parts[1])

        switch filename {
        case "README.md":
            return Result(
                exitStatus: 0,
                stdout: """
                    # Welcome to Mock SSH Server

                    This is a demonstration SSH terminal interface.
                    Available commands: ls, pwd, echo, cat, whoami, date, help

                    Try exploring the file system with 'ls -la' or
                    check the current directory with 'pwd'.
                    """, stderr: "")

        case ".bashrc":
            return Result(
                exitStatus: 0,
                stdout: """
                    # ~/.bashrc
                    export PS1='\\u@\\h:\\w\\$ '
                    alias ll='ls -la'
                    alias ..='cd ..'
                    """, stderr: "")

        default:
            return Result(
                exitStatus: 1, stdout: "", stderr: "cat: \(filename): No such file or directory")
        }
    }
}
