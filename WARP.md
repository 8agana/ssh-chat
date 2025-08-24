# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Overview
- This is a SwiftUI iOS mock app that presents a terminal‑style chat UI. There is no real SSH or AI backend; transport is a mocked SSH client. SwiftPM-only; no third‑party deps; no Docker.
- Targets iOS 16+ and is intended to be opened and run via Xcode 15+.

Commands and workflows
- Open the project in Xcode (primary workflow)
  - From repo root: open -a Xcode .
  - Select an iOS 16+ Simulator → Product → Build (⌘B), Run (⌘R).
  - Run all tests: Product → Test (⌘U). Run a single test by selecting it in the Test Navigator.

- Terminal builds and tests with xcodebuild (only after a .xcodeproj or .xcworkspace exists)
  - List schemes/targets (choose one):
    - xcodebuild -list -json -project ssh-chat.xcodeproj
    - xcodebuild -list -json -workspace ssh-chat.xcworkspace
  - Build:
    - xcodebuild -project ssh-chat.xcodeproj -scheme SCHEME_NAME -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' build
  - Test all:
    - xcodebuild -project ssh-chat.xcodeproj -scheme SCHEME_NAME -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' test
  - Run a single test (replace placeholders with exact identifiers from Xcode):
    - xcodebuild -project ssh-chat.xcodeproj -scheme SCHEME_NAME -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' test -only-testing:TARGET_NAME/TestCaseName/testMethodName

Notes pulled from README
- SwiftUI + SwiftPM only; no .xcodeproj committed by default (Xcode generates it when opening the folder).
- Voice input uses on‑device SFSpeechRecognizer + AVAudioEngine. First run will prompt for permissions.
- Info.plist contains NSSpeechRecognitionUsageDescription and NSMicrophoneUsageDescription.

High-level architecture
- App entry (SSHChatApp)
  - Decides between ConnectionSetupView and ChatView based on @AppStorage state (host/username/auth, isConnected). Applies a terminal theme by default.
- Theme (ThemePalette via EnvironmentKey)
  - Centralizes colors (background, foreground, accent, line). Injected into the environment and consumed across views.
- Model (Message)
  - Identifiable message with role (user/assistant/system), timestamp, text. Includes a terminal-like speakerTag. Demo seed provided in Array<Message>.demo.
- State/store (MessageStore)
  - @MainActor ObservableObject holding the timeline and lastAppendedMessageID. Exposes closures for current connection parameters provided by setup. send(text:) appends a user message and asynchronously routes command text to SSHClient; replies are appended on completion.
- Mock transport (SSHClient)
  - Async mock router that simulates SSH command outputs for ls, pwd, echo, cat, whoami, date, help; adds small latency and returns stdout/stderr/exitStatus. Unknown commands return “command not found”.
- Chat UI (ChatView)
  - ScrollView + ScrollViewReader rendering MessageRowView for each message, with auto‑scroll to bottom when near end. Shows a “jump ▽” button when scrolled up.
- Input (InputBar)
  - Monospaced TextEditor that auto‑grows up to a line cap; “send” enabled only for non‑empty input. Includes a mic button that toggles dictation.
- Speech (SpeechRecognizer)
  - Wraps SFSpeechRecognizer and AVAudioEngine. Handles permission requests, audio session config, streaming partial/final transcripts into the compose field, and microphone level visualization.
- Connection setup (ConnectionSetupView)
  - Gathers host/port/username and auth method (Password/Key placeholder), persists via @AppStorage, and injects closures into MessageStore before marking isConnected.

Operational considerations
- This repository is a mock UI: commands typed into the chat are handled by SSHClient’s mock router. To introduce a real backend, replace SSHClient with a true SSH/streaming implementation while maintaining MessageStore’s surface so the UI remains unchanged.
- Tests: Unit (ssh-chatTests) and UI (ssh-chatUITests) are present but minimal. Prefer running via Xcode; use -only-testing for targeted runs when using xcodebuild once a project file exists.

