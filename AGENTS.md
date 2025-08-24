# Repository Guidelines

## Project Structure & Module Organization
- Source: `ssh-chat/` with logical namespaces via dotted filenames (e.g., `Views.ChatView.swift`, `SSH.SSHClient.swift`).
- Assets: `ssh-chat/Assets.xcassets`.
- App entry: `ssh-chat/ssh_chatApp.swift`.
- Modules: `Models.*`, `Store.*`, `Views.*`, `Theme.*`, `Speech.*`, `SSH.*`.
- Tests: `ssh-chatTests/` (unit) and `ssh-chatUITests/` (UI).
- Xcode project: `SSHChat.xcodeproj` (generated/maintained alongside `project.yml`).

## Build, Test, and Development Commands
- Build (Simulator): `xcodebuild -project SSHChat.xcodeproj -scheme SSHChat -sdk iphonesimulator build`.
- Unit/UI tests: `xcodebuild test -project SSHChat.xcodeproj -scheme SSHChat -destination 'platform=iOS Simulator,name=iPhone 15'`.
- Open in Xcode: `open SSHChat.xcodeproj` (preferred for day‑to‑day dev).
- Regenerate project (if using XcodeGen): `xcodegen generate` from `project.yml`.

## Coding Style & Naming Conventions
- Indentation: 2 spaces; keep lines ~120 chars.
- Swift style: follow the Swift API Design Guidelines; prefer `struct` and value semantics where reasonable.
- Naming: Types `UpperCamelCase`; properties/functions `lowerCamelCase`; views end with `View`.
- File naming: keep dotted prefixes to group by area, e.g., `Store.MessageStore.swift`, `Theme.Theme.swift`.
- Formatting/linting: no enforced tool in repo; use Xcode’s Re‑Indent and organize imports. If using SwiftFormat/SwiftLint locally, run before commits.

## Testing Guidelines
- Frameworks: XCTest for unit tests, XCUITest for UI.
- Test files: place in `ssh-chatTests/` or `ssh-chatUITests/` with `*Tests.swift`/`*UITests.swift` suffix.
- Naming: methods start with `test...`; prefer `given_when_then` in method names for clarity.
- Coverage: aim for meaningful coverage of `Models`, `Store`, and view logic helpers.
- Run: via Product → Test in Xcode or the `xcodebuild test` command above.

## Commit & Pull Request Guidelines
- Commits: small, focused; present‑tense, imperative (e.g., “Add ChatView auto‑scroll guard”). Conventional prefixes like `feat:`, `fix:`, `refactor:` are welcome.
- PRs: include a clear description, linked issues, and screenshots for UI changes. Note any schema or permission changes (e.g., `Info.plist` entries for mic/speech).
- Checks: ensure the app builds, tests pass, and no new warnings.

## Security & Configuration Tips
- Permissions: keep `Info.plist` privacy strings for Speech/Microphone in sync with usage.
- Secrets: none required; avoid embedding credentials. SSH features are stubbed.
- Platforms: target iOS 16+; stick to SwiftPM and system frameworks.
