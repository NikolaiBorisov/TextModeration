import Foundation

/// A rule that reports excessive or repeated emoji usage.
public struct EmojiRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "emoji"
    
    private let maximumAllowedEmojiCount: Int
    private let maximumEmojiRatio: Double
    private let maximumAllowedRepeatedEmojiCount: Int
    private let allowsEmojiOnlyText: Bool
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    
    /// Creates an emoji rule.
    ///
    /// - Parameters:
    ///   - maximumAllowedEmojiCount: The maximum total number of emoji characters allowed.
    ///   - maximumEmojiRatio: The maximum ratio of emoji characters to non-whitespace characters.
    ///   - maximumAllowedRepeatedEmojiCount: The maximum number of identical neighboring emoji characters allowed.
    ///   - allowsEmojiOnlyText: A Boolean value indicating whether text made only of emojis is allowed.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        maximumAllowedEmojiCount: Int = 8,
        maximumEmojiRatio: Double = 0.5,
        maximumAllowedRepeatedEmojiCount: Int = 3,
        allowsEmojiOnlyText: Bool = true,
        severity: ModerationSeverity = .low,
        decision: ModerationDecision = .flagged
    ) {
        self.maximumAllowedEmojiCount = maximumAllowedEmojiCount
        self.maximumEmojiRatio = maximumEmojiRatio
        self.maximumAllowedRepeatedEmojiCount = maximumAllowedRepeatedEmojiCount
        self.allowsEmojiOnlyText = allowsEmojiOnlyText
        self.severity = severity
        self.decision = decision
    }
    
    /// Evaluates whether the text contains excessive or repeated emoji usage.
    public func evaluate(_ text: String) -> ModerationIssue? {
        let nonWhitespaceCharacters = Array(text.filter { !$0.isWhitespace })
        
        guard !nonWhitespaceCharacters.isEmpty else {
            return nil
        }
        
        let emojiCharacters = nonWhitespaceCharacters.filter(\.isEmoji)
        
        guard !emojiCharacters.isEmpty else {
            return nil
        }
        
        if emojiCharacters.count > maximumAllowedEmojiCount {
            return issue(message: "Text contains more emojis than allowed.")
        }
        
        let emojiRatio = Double(emojiCharacters.count) / Double(nonWhitespaceCharacters.count)
        
        if emojiRatio > maximumEmojiRatio {
            return issue(message: "Text contains a high ratio of emojis.")
        }
        
        if !allowsEmojiOnlyText && emojiCharacters.count == nonWhitespaceCharacters.count {
            return issue(message: "Text contains only emojis.")
        }
        
        if containsRepeatedEmojis(in: nonWhitespaceCharacters) {
            return issue(message: "Text contains the same emoji repeated too many times in a row.")
        }
        
        return nil
    }
    
    private func containsRepeatedEmojis(in characters: [Character]) -> Bool {
        var previousEmoji: Character?
        var repeatCount = 0
        
        for character in characters {
            guard character.isEmoji else {
                previousEmoji = nil
                repeatCount = 0
                continue
            }
            
            if character == previousEmoji {
                repeatCount += 1
            } else {
                previousEmoji = character
                repeatCount = 1
            }
            
            if repeatCount > maximumAllowedRepeatedEmojiCount {
                return true
            }
        }
        
        return false
    }
    
    private func issue(message: String) -> ModerationIssue {
        ModerationIssue(
            ruleID: id,
            message: message,
            severity: severity,
            suggestedDecision: decision
        )
    }
}

private extension Character {
    var isEmoji: Bool {
        unicodeScalars.contains { scalar in
            scalar.properties.isEmojiPresentation ||
            scalar.properties.generalCategory == .otherSymbol
        }
    }
}
