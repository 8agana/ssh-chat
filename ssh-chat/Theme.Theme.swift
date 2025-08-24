import SwiftUI

// Terminal palette and environment plumbing
struct ThemePalette {
    let background: Color
    let foreground: Color
    let accent: Color
    let line: Color

    static let terminal = ThemePalette(
        background: Color(red: 0.06, green: 0.07, blue: 0.08),
        foreground: Color(red: 0.85, green: 0.86, blue: 0.87),
        accent: Color(red: 0.4, green: 0.9, blue: 0.7),
        line: Color(red: 0.35, green: 0.38, blue: 0.40)
    )
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: ThemePalette = .terminal
}

extension EnvironmentValues {
    var theme: ThemePalette {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }

}

extension View {
    func theme(_ palette: ThemePalette) -> some View {
        environment(\.theme, palette)
    }

}
