import Foundation

/// A rule that reports text containing a character repeated too many times in a row.
public struct RepeatedCharactersRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "repeated_characters"
    
    private let maximumAllowedRepeats: Int
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    
    /// Creates a repeated characters rule.
    ///
    /// - Parameters:
    ///   - maximumAllowedRepeats: The maximum number of identical consecutive characters allowed.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        maximumAllowedRepeats: Int = 4,
        severity: ModerationSeverity = .low,
        decision: ModerationDecision = .flagged
    ) {
        self.maximumAllowedRepeats = maximumAllowedRepeats
        self.severity = severity
        self.decision = decision
    }
    
    /// Evaluates whether the text contains too many identical consecutive characters.
    public func evaluate(_ text: String) -> ModerationIssue? {
        guard !text.isEmpty else {
            return nil
        }
        
        var previousCharacter: Character?
        var repeatCount = 0
        
        for character in text {
            if character == previousCharacter {
                repeatCount += 1
            } else {
                previousCharacter = character
                repeatCount = 1
            }
            
            if repeatCount > maximumAllowedRepeats {
                return ModerationIssue(
                    ruleID: id,
                    message: "Text contains characters repeated too many times in a row.",
                    severity: severity,
                    suggestedDecision: decision
                )
            }
        }
        
        return nil
    }
}
