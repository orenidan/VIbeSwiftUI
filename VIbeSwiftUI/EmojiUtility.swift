import Foundation

/// Utility for automatically adding fruit emojis to text based on fruit names
internal struct EmojiUtility {

    /// Compiled regex patterns for better performance
    private struct CompiledPattern {
        let regex: NSRegularExpression
        let emoji: String
        let fruit: String
    }

    /// Pre-compiled regex patterns for fruit detection
    private static let compiledPatterns: [CompiledPattern] = {
        let fruitEmojis: [String: String] = [
            "apple": "🍎", "apples": "🍎",
            "banana": "🍌", "bananas": "🍌",
            "cherry": "🍒", "cherries": "🍒",
            "orange": "🍊", "oranges": "🍊",
            "grape": "🍇", "grapes": "🍇",
            "strawberry": "🍓", "strawberries": "🍓",
            "watermelon": "🍉", "watermelons": "🍉",
            "pineapple": "🍍", "pineapples": "🍍",
            "mango": "🥭", "mangoes": "🥭",
            "kiwi": "🥝", "kiwis": "🥝",
            "pear": "🍐", "pears": "🍐",
            "peach": "🍑", "peaches": "🍑",
            "plum": "🍑", // Using peach emoji for plum for now
            "lemon": "🍋", "lemons": "🍋",
            "lime": "🍋",  // Using lemon emoji for lime
            "avocado": "🥑", "avocados": "🥑",
            "coconut": "🥥", "coconuts": "🥥",
            "blueberry": "🫐", "blueberries": "🫐"
        ]

        return fruitEmojis.compactMap { (fruit, emoji) in
            let escapedFruit = NSRegularExpression.escapedPattern(for: fruit)
            let escapedEmoji = NSRegularExpression.escapedPattern(for: emoji)
            let pattern = "\\b(\(escapedFruit))\\b(?!\\s*\(escapedEmoji))"

            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
                return nil
            }

            return CompiledPattern(regex: regex, emoji: emoji, fruit: fruit)
        }
    }()

    /// Adds appropriate fruit emojis to the given text
    /// - Parameter text: The input text to process
    /// - Returns: Text with fruit emojis added where appropriate
    internal static func addFruitEmojis(to text: String) -> String {
        var processedText = text
        var textDidChange = false

        for pattern in compiledPatterns {
            let matches = pattern.regex.matches(
                in: processedText,
                options: [],
                range: NSRange(processedText.startIndex..., in: processedText)
            )

            // Process matches in reverse order to preserve ranges
            for match in matches.reversed() {
                guard match.numberOfRanges == 2 else { continue }
                guard let fruitRange = Range(match.range(at: 1), in: processedText) else { continue }

                let originalFruitName = String(processedText[fruitRange])
                let replacementString = "\(originalFruitName) \(pattern.emoji)"

                processedText.replaceSubrange(fruitRange, with: replacementString)
                textDidChange = true
            }
        }

        if textDidChange {
            // Clean up potential double spaces and trim whitespace
            processedText = processedText
                .replacingOccurrences(of: "  ", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return processedText
    }

    /// Check if text contains any fruit names that could have emojis added
    /// - Parameter text: The text to check
    /// - Returns: True if the text contains fruit names that could be enhanced with emojis
    internal static func containsEnhanceableFruits(in text: String) -> Bool {
        return compiledPatterns.contains { pattern in
            let matches = pattern.regex.matches(
                in: text,
                options: [],
                range: NSRange(text.startIndex..., in: text)
            )
            return !matches.isEmpty
        }
    }
}
