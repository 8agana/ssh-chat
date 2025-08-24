# SSHChat (SwiftUI mockup)

A minimal, terminal‑aesthetic iOS chat interface optimized for AI conversations (e.g., Claude Code style). No bubbles. Monospaced text, native text selection, proper wrapping, smooth scrolling, and push‑to‑talk voice input.

Status: mock UI only — no real SSH or AI backend.

Requirements
- Xcode 15+
- iOS 16.0+
- SwiftUI, SwiftPM only (no third‑party deps)

Key features
- Terminal aesthetic: dark palette, monospaced font, no chat bubbles
- Conversation‑optimized: full‑width wrapped text, selection enabled
- Smooth scrolling: auto‑scroll when near bottom, Jump to latest when scrolled up
- Voice input: native SFSpeechRecognizer + AVAudioEngine push‑to‑talk
- Simple connection setup: host/port/username + auth method (password/key placeholder)

Project layout
- SSHChatApp.swift — App entry and simple router
- Models.Message.swift — Message model and demo seed
- Store.MessageStore.swift — In‑memory store with simulated assistant replies
- Theme.Theme.swift — ThemePalette and environment injection
- Views.ChatView.swift — Terminal‑like timeline + bottom InputBar
- Views.MessageRowView.swift — Selectable monospaced message lines
- Views.InputBar.swift — Auto‑growing TextEditor, Send, Mic
- Views.ConnectionSetupView.swift — Minimal setup screen
- Speech.SpeechRecognizer.swift — Speech recognition helper
- Info.plist — Privacy strings for speech and microphone

Build & run
1) Open the folder in Xcode (File → Open… → select this directory). If you prefer, create a new iOS App target and add these files.
2) Ensure the target uses iOS 16.0 or newer.
3) Add Info.plist to the target if Xcode doesn’t pick it up automatically (Build Settings → Info.plist File or Target → Info).
4) Build and run on Simulator or a device.

First‑run permissions
- The mic button will request Speech Recognition and Microphone access.
- If denied, you can enable them later in Settings → Privacy → Speech Recognition / Microphone.

Acceptance checklist
- Text wraps naturally and is fully selectable; no chat bubbles.
- Long assistant messages scroll smoothly; auto‑scroll occurs only when near bottom.
- Jump to latest button appears when scrolled up; tapping scrolls to bottom.
- Mic button toggles listening and inserts partial/final transcripts into the input field.
- Connection screen collects host/port/username/auth method and navigates to chat.

Notes
- This is a mock UI: no SSH connection or AI model calls.
- Voice input is on‑device through Apple’s APIs; network availability may affect recognizer availability depending on locale.
- No Docker. SwiftPM only.

Next steps (optional)
- Replace the simulated assistant with a real streaming backend (Server‑Sent Events / WebSocket) to render tokens progressively.
- Add real SSH connection management (libssh2 or NWTCPConnection); keep UI unchanged to preserve terminal feel.
- Improve auto‑scroll detection using precise content offset with a custom ScrollView wrapper.

