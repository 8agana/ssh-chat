import Foundation

// Placeholder data type to avoid SwiftData dependency if this file remains in the target.
struct Item: Identifiable, Hashable {
    var id = UUID()
    var timestamp: Date = Date()
}
