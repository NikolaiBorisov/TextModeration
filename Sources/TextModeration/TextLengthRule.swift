import Foundation

/// A rule that reports text shorter or longer than configured character limits.
public struct TextLengthRule: ModerationRule {
    /// The stable identifier for this rule.
    public let id = "text_length"
    
    private let minimumLength: Int?
    private let maximumLength: Int
    private let severity: ModerationSeverity
    private let decision: ModerationDecision
    
    /// Creates a text length rule.
    ///
    /// - Parameters:
    ///   - minimumLength: The optional minimum number of characters required.
    ///   - maximumLength: The maximum number of characters allowed.
    ///   - severity: The severity used when the rule matches.
    ///   - decision: The decision recommended when the rule matches.
    public init(
        minimumLength: Int? = nil,
        maximumLength: Int,
        severity: ModerationSeverity = .medium,
        decision: ModerationDecision = .flagged
    ) {
        self.minimumLength = minimumLength
        self.maximumLength = maximumLength
        self.severity = severity
        self.decision = decision
    }
    
    /// Evaluates whether the text is outside the configured length limits.
    public func evaluate(_ text: String) -> ModerationIssue? {
        let characterCount = text.count
        
        if let minimumLength, characterCount < minimumLength {
            return ModerationIssue(
                ruleID: id,
                message: "Text is shorter than the minimum allowed length.",
                severity: severity,
                suggestedDecision: decision
            )
        }
        
        if characterCount > maximumLength {
            return ModerationIssue(
                ruleID: id,
                message: "Text exceeds the maximum allowed length.",
                severity: severity,
                suggestedDecision: decision
            )
        }
        
        return nil
    }
}
