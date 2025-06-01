import Foundation

// Enum to manage focus state for TextFields
internal enum FocusableField: Hashable {
    case title(UUID)
    case value(UUID)
}
