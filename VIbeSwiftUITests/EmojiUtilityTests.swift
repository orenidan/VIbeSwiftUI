import XCTest
@testable import VIbeSwiftUI

final class EmojiUtilityTests: XCTestCase {

    // MARK: - Basic Emoji Addition Tests

    func testAddFruitEmojis_singleFruit() {
        let input = "apple"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "apple 🍎")
    }

    func testAddFruitEmojis_multipleFruits() {
        let input = "apple and banana"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertTrue(result.contains("apple 🍎"))
        XCTAssertTrue(result.contains("banana 🍌"))
    }

    func testAddFruitEmojis_pluralFruits() {
        let input = "apples"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "apples 🍎")
    }

    func testAddFruitEmojis_caseInsensitive() {
        let input = "APPLE"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "APPLE 🍎")
    }

    func testAddFruitEmojis_mixedCase() {
        let input = "ApPlE"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "ApPlE 🍎")
    }

    // MARK: - Edge Cases

    func testAddFruitEmojis_emptyString() {
        let input = ""
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "")
    }

    func testAddFruitEmojis_noFruits() {
        let input = "vegetables and grains"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "vegetables and grains")
    }

    func testAddFruitEmojis_alreadyHasEmoji() {
        let input = "apple 🍎"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "apple 🍎") // Should not add duplicate emoji
    }

    func testAddFruitEmojis_partialWordMatch() {
        let input = "pineapple"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "pineapple 🍍") // Should match whole word
    }

    func testAddFruitEmojis_partialWordNoMatch() {
        let input = "applecart"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "applecart") // Should NOT match partial word
    }

    func testAddFruitEmojis_whitespaceTrimming() {
        let input = "  apple  "
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertEqual(result, "apple 🍎")
    }

    // MARK: - Multiple Fruits in Complex Sentences

    func testAddFruitEmojis_complexSentence() {
        let input = "I like apple pie and banana bread with strawberry jam"
        let result = EmojiUtility.addFruitEmojis(to: input)

        XCTAssertTrue(result.contains("apple 🍎"))
        XCTAssertTrue(result.contains("banana 🍌"))
        XCTAssertTrue(result.contains("strawberry 🍓"))
        XCTAssertTrue(result.contains("pie"))
        XCTAssertTrue(result.contains("bread"))
        XCTAssertTrue(result.contains("jam"))
    }

    func testAddFruitEmojis_punctuation() {
        let input = "apple, banana; orange!"
        let result = EmojiUtility.addFruitEmojis(to: input)
        XCTAssertTrue(result.contains("apple 🍎"))
        XCTAssertTrue(result.contains("banana 🍌"))
        XCTAssertTrue(result.contains("orange 🍊"))
    }

    // MARK: - Contains Enhanceable Fruits Tests

    func testContainsEnhanceableFruits_true() {
        let input = "apple"
        let result = EmojiUtility.containsEnhanceableFruits(in: input)
        XCTAssertTrue(result)
    }

    func testContainsEnhanceableFruits_false() {
        let input = "vegetables"
        let result = EmojiUtility.containsEnhanceableFruits(in: input)
        XCTAssertFalse(result)
    }

    func testContainsEnhanceableFruits_alreadyEnhanced() {
        let input = "apple 🍎"
        let result = EmojiUtility.containsEnhanceableFruits(in: input)
        XCTAssertFalse(result) // Should return false if already enhanced
    }

    // MARK: - Performance Tests

    func testAddFruitEmojis_performance() {
        let input = "apple banana cherry orange grape strawberry watermelon pineapple mango kiwi pear peach plum lemon lime"

        measure {
            for _ in 0..<1000 {
                _ = EmojiUtility.addFruitEmojis(to: input)
            }
        }
    }

    // MARK: - Specific Fruit Tests

    func testAllSupportedFruits() {
        let testCases: [(input: String, expectedEmoji: String)] = [
            ("apple", "🍎"),
            ("banana", "🍌"),
            ("cherry", "🍒"),
            ("orange", "🍊"),
            ("grape", "🍇"),
            ("strawberry", "🍓"),
            ("watermelon", "🍉"),
            ("pineapple", "🍍"),
            ("mango", "🥭"),
            ("kiwi", "🥝"),
            ("pear", "🍐"),
            ("peach", "🍑"),
            ("lemon", "🍋"),
            ("avocado", "🥑"),
            ("coconut", "🥥"),
            ("blueberry", "🫐")
        ]

        for testCase in testCases {
            let result = EmojiUtility.addFruitEmojis(to: testCase.input)
            XCTAssertTrue(result.contains(testCase.expectedEmoji),
                         "Expected '\(testCase.input)' to contain emoji '\(testCase.expectedEmoji)', but got '\(result)'")
        }
    }
}
